import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finow/features/premium/premium_model.dart';
import 'package:finow/features/ticker/services/ticker_api_service.dart';
import 'package:finow/features/exchange_rate/exchange_rate_provider.dart';
import 'package:finow/features/ticker/data/models/bithumb_ticker_model.dart';
import 'package:finow/features/ticker/models/ticker_price_data.dart';
import 'package:finow/features/instruments/services/instruments_local_storage_service.dart';
import 'package:finow/features/instruments/models/instrument.dart';

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  return PremiumRepository(ref);
});

class PremiumRepository {
  PremiumRepository(this._ref) {
    _tickerApiService = TickerApiService();
    _localStorageService = _ref.read(instrumentsLocalStorageServiceProvider);
  }

  final Ref _ref;
  late final TickerApiService _tickerApiService;
  late final InstrumentsLocalStorageService _localStorageService;

  Future<List<Premium>> getPremiumTickers(
    PremiumSortOption sortOption,
    SortDirection sortDirection,
    String searchQuery,
  ) async {
    // 1. Load instruments from local storage
    final allInstruments = await _localStorageService.loadInstruments();
    final bithumbInstruments = allInstruments.where((i) => i.exchange == 'bithumb').toList();
    final bybitInstruments = allInstruments.where((i) => i.exchange == 'bybit' && i.category == 'spot').toList();

    // 2. Fetch tickers from Bybit and Bithumb
    final bybitTickers = await _tickerApiService.getSpotTickers();
    final bithumbTickers = await _tickerApiService.fetchBithumbTickers();

    // 3. Fetch USD/KRW exchange rate
    final exchangeRateState = _ref.read(exchangeRateProvider);
    double? usdToKrwRate;
    if (exchangeRateState.hasValue) {
      for (final rate in exchangeRateState.value!) {
        if (rate.quoteCode == 'KRW') {
          usdToKrwRate = rate.price;
          break;
        }
      }
    }

    if (usdToKrwRate == null) {
      throw Exception('Could not get USD/KRW exchange rate');
    }

    // 4. Combine and calculate premium
    final List<Premium> premiumTickers = [];

    for (final bithumbInstrument in bithumbInstruments) {
      Instrument? bybitInstrument;

      // Case 1: KRW vs USDT
      if (bithumbInstrument.quoteCode == 'KRW') {
        bybitInstrument = _findInstrument(bybitInstruments, 'bybit', bithumbInstrument.baseCode, 'USDT', 'spot');
        if (bybitInstrument != null) {
          // Found a KRW/USDT pair, process it
          _processPremiumCalculation(
            premiumTickers: premiumTickers,
            bithumbInstrument: bithumbInstrument,
            bybitInstrument: bybitInstrument,
            bithumbTickers: bithumbTickers,
            bybitTickers: bybitTickers,
            usdToKrwRate: usdToKrwRate,
            isUsdKrwPair: true,
          );
        }
      } else {
        // Case 2: Exact match (e.g., BTC/ETH vs BTC/ETH)
        bybitInstrument = _findInstrument(bybitInstruments, 'bybit', bithumbInstrument.baseCode, bithumbInstrument.quoteCode, 'spot');
        if (bybitInstrument != null) {
          // Found an identical quote currency pair, process it
          _processPremiumCalculation(
            premiumTickers: premiumTickers,
            bithumbInstrument: bithumbInstrument,
            bybitInstrument: bybitInstrument,
            bithumbTickers: bithumbTickers,
            bybitTickers: bybitTickers,
            usdToKrwRate: usdToKrwRate,
            isUsdKrwPair: false,
          );
        }
      }
    }

    // Filter by search query
    final filteredPremiumTickers = premiumTickers.where((premium) {
      final query = searchQuery.toLowerCase();
      return premium.symbol.toLowerCase().contains(query) ||
             premium.name.toLowerCase().contains(query) ||
             (premium.koreanName?.toLowerCase().contains(query) ?? false);
    }).toList();

    // 5. Sort the premium tickers
    filteredPremiumTickers.sort((a, b) {
      int compare = 0;
      switch (sortOption) {
        case PremiumSortOption.symbol:
          compare = a.symbol.compareTo(b.symbol);
          break;
        case PremiumSortOption.bybitPrice:
          compare = (a.bybitPrice ?? 0).compareTo(b.bybitPrice ?? 0);
          break;
        case PremiumSortOption.bithumbPrice:
          compare = (a.bithumbPrice ?? 0).compareTo(b.bithumbPrice ?? 0);
          break;
        case PremiumSortOption.premium:
          compare = (a.premium ?? 0).compareTo(b.premium ?? 0);
          break;
      }
      return sortDirection == SortDirection.asc ? compare : -compare;
    });

    return filteredPremiumTickers;
  }

  void _processPremiumCalculation({
    required List<Premium> premiumTickers,
    required Instrument bithumbInstrument,
    required Instrument bybitInstrument,
    required List<BithumbTicker> bithumbTickers,
    required List<TickerPriceData> bybitTickers,
    required double usdToKrwRate,
    required bool isUsdKrwPair,
  }) {
    final bybitTicker = _findTicker(bybitTickers, bybitInstrument.symbol);
    final bithumbTicker = _findBithumbTicker(bithumbTickers, bithumbInstrument.symbol);

    if (bybitTicker == null || bithumbTicker == null) return;

    final bybitPriceString = bybitTicker.lastPrice;
    final bithumbPriceString = bithumbTicker.closingPrice;

    if (bybitPriceString == null || bithumbPriceString == null) return;

    final bybitPrice = double.tryParse(bybitPriceString);
    final bithumbPriceRaw = double.tryParse(bithumbPriceString);

    if (bybitPrice == null || bybitPrice <= 0 || bithumbPriceRaw == null || bithumbPriceRaw <= 0) return;

    double premium;
    double bithumbPriceInTargetCurrency;
    double? bithumbPriceKRW;

    if (isUsdKrwPair) {
      // KRW -> USD for comparison
      bithumbPriceInTargetCurrency = bithumbPriceRaw / usdToKrwRate;
      bithumbPriceKRW = bithumbPriceRaw;
      premium = ((bithumbPriceInTargetCurrency - bybitPrice) / bybitPrice) * 100;
    } else {
      // Direct comparison
      bithumbPriceInTargetCurrency = bithumbPriceRaw;
      // If the common currency is KRW, we can still show it.
      if (bithumbInstrument.quoteCode == 'KRW') {
        bithumbPriceKRW = bithumbPriceRaw;
      }
      premium = ((bithumbPriceInTargetCurrency - bybitPrice) / bybitPrice) * 100;
    }

    premiumTickers.add(
      Premium(
        symbol: bithumbInstrument.baseCode,
        name: bithumbInstrument.koreanName ?? bithumbInstrument.baseCode,
        koreanName: bithumbInstrument.koreanName,
        bybitPrice: bybitPrice,
        bybitQuoteCode: bybitInstrument.quoteCode,
        bithumbPrice: bithumbPriceInTargetCurrency,
        bithumbPriceKRW: bithumbPriceKRW,
        bithumbQuoteCode: bithumbInstrument.quoteCode,
        premium: premium,
      ),
    );
  }

  Instrument? _findInstrument(List<Instrument> instruments, String exchange, String baseCode, String quoteCode, String category) {
    for (final instrument in instruments) {
      if (instrument.exchange == exchange && instrument.baseCode == baseCode && instrument.quoteCode == quoteCode && instrument.category == category) {
        return instrument;
      }
    }
    return null;
  }

  TickerPriceData? _findTicker(List<TickerPriceData> tickers, String symbol) {
    for (final ticker in tickers) {
      if (ticker.symbol == symbol) {
        return ticker;
      }
    }
    return null;
  }

  BithumbTicker? _findBithumbTicker(List<BithumbTicker> tickers, String market) {
    for (final ticker in tickers) {
      if (ticker.market == market) {
        return ticker;
      }
    }
    return null;
  }
}

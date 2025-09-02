
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finow/features/home/home_model.dart';
import 'package:finow/features/ticker/services/ticker_api_service.dart';
import 'package:finow/features/exchange_rate/exchange_rate_provider.dart';
import 'package:finow/features/ticker/data/models/bithumb_ticker_model.dart';
import 'package:finow/features/ticker/models/ticker_price_data.dart';
import 'package:finow/features/instruments/services/instruments_local_storage_service.dart';
import 'package:finow/features/instruments/models/instrument.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref);
});

class HomeRepository {
  HomeRepository(this._ref) {
    _tickerApiService = TickerApiService();
    _localStorageService = _ref.read(instrumentsLocalStorageServiceProvider);
  }

  final Ref _ref;
  late final TickerApiService _tickerApiService;
  late final InstrumentsLocalStorageService _localStorageService;

  Future<List<CryptoPremium>> getPremiumTickers(
    PremiumSortOption sortOption,
    SortDirection sortDirection,
    String searchQuery,
  ) async {
    debugPrint('[HomeRepository] Getting premium tickers...');

    // 1. Load instruments from local storage
    final allInstruments = await _localStorageService.loadInstruments();
    debugPrint('[HomeRepository] Loaded ${allInstruments.length} instruments from local storage.');
    final bithumbInstruments = allInstruments.where((i) => i.exchange == 'bithumb').toList();
    debugPrint('[HomeRepository] Found ${bithumbInstruments.length} Bithumb instruments.');

    // 2. Fetch tickers from Bybit and Bithumb
    final bybitTickers = await _tickerApiService.getSpotTickers();
    debugPrint('[HomeRepository] Fetched ${bybitTickers.length} Bybit tickers.');
    final bithumbTickers = await _tickerApiService.fetchBithumbTickers();
    debugPrint('[HomeRepository] Fetched ${bithumbTickers.length} Bithumb tickers.');

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
    debugPrint('[HomeRepository] USD/KRW exchange rate: $usdToKrwRate');

    if (usdToKrwRate == null) {
      throw Exception('Could not get USD/KRW exchange rate');
    }

    // 4. Combine and calculate premium
    final List<CryptoPremium> premiumTickers = [];

    for (final bithumbInstrument in bithumbInstruments) {
      final baseCode = bithumbInstrument.baseCode;

      // Find corresponding Bybit instrument
      final bybitInstrument = _findInstrument(allInstruments, 'bybit', baseCode, 'USDT');

      if (bybitInstrument != null) {
        final bybitTicker = _findTicker(bybitTickers, bybitInstrument.symbol);
        final bithumbTicker = _findBithumbTicker(bithumbTickers, bithumbInstrument.symbol);

        if (bybitTicker != null && bithumbTicker != null) {
          final bybitPriceString = bybitTicker.lastPrice;
          final bithumbPriceString = bithumbTicker.closingPrice;

          if (bybitPriceString != null && bithumbPriceString != null) {
            final bybitPrice = double.tryParse(bybitPriceString);
            final bithumbPriceKRW = double.tryParse(bithumbPriceString);

            if (bybitPrice != null && bybitPrice > 0 && bithumbPriceKRW != null && bithumbPriceKRW > 0) {
              final bithumbPriceUSD = bithumbPriceKRW / usdToKrwRate;
              final premium = ((bithumbPriceUSD - bybitPrice) / bybitPrice) * 100;

              premiumTickers.add(
                CryptoPremium(
                  symbol: baseCode,
                  name: bithumbInstrument.koreanName ?? baseCode,
                  koreanName: bithumbInstrument.koreanName,
                  bybitPrice: bybitPrice,
                  bithumbPrice: bithumbPriceUSD,
                  bithumbPriceKRW: bithumbPriceKRW,
                  premium: premium,
                ),
              );
            }
          }
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

    debugPrint('[HomeRepository] Calculated ${filteredPremiumTickers.length} premium tickers.');
    return filteredPremiumTickers;
  }

  Instrument? _findInstrument(List<Instrument> instruments, String exchange, String baseCode, String quoteCode) {
    for (final instrument in instruments) {
      if (instrument.exchange == exchange && instrument.baseCode == baseCode && instrument.quoteCode == quoteCode) {
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

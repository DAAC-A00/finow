import 'package:finow/features/home/instrument_detail_model.dart';
import 'package:finow/features/instruments/models/instrument.dart';
import 'package:finow/features/instruments/services/instruments_local_storage_service.dart';
import 'package:finow/features/ticker/data/models/bithumb_ticker_model.dart';
import 'package:finow/features/ticker/models/ticker_price_data.dart';
import 'package:finow/features/ticker/services/ticker_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final instrumentDetailProvider = FutureProvider.family<InstrumentDetail, String>((ref, symbol) async {
  final localStorageService = ref.read(instrumentsLocalStorageServiceProvider);
  final tickerApiService = TickerApiService();

  final allInstruments = await localStorageService.loadInstruments();
  final bybitInstrument = allInstruments.firstWhere((i) => i.exchange == 'bybit' && i.baseCode == symbol && i.quoteCode == 'USDT' && i.category == 'spot');
  final bithumbInstrument = allInstruments.firstWhere((i) => i.exchange == 'bithumb' && i.baseCode == symbol && i.quoteCode == 'KRW');

  final bybitTickers = await tickerApiService.getSpotTickers();
  final bybitTicker = bybitTickers.firstWhere((t) => t.symbol == bybitInstrument.symbol);

  final bithumbTickers = await tickerApiService.fetchBithumbTickers();
  final bithumbTickerData = bithumbTickers.firstWhere((t) => t.market == bithumbInstrument.symbol);

  final bithumbTicker = TickerPriceData.fromBithumbTicker(bithumbTickerData);


  return InstrumentDetail(
    bybitInstrument: bybitInstrument,
    bithumbInstrument: bithumbInstrument,
    bybitTicker: bybitTicker,
    bithumbTicker: bithumbTicker,
  );
});

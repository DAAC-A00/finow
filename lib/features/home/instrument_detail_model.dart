import 'package:finow/features/instruments/models/instrument.dart';
import 'package:finow/features/ticker/models/ticker_price_data.dart';

class InstrumentDetail {
  final Instrument bybitInstrument;
  final Instrument bithumbInstrument;
  final TickerPriceData bybitTicker;
  final TickerPriceData bithumbTicker;

  InstrumentDetail({
    required this.bybitInstrument,
    required this.bithumbInstrument,
    required this.bybitTicker,
    required this.bithumbTicker,
  });
}

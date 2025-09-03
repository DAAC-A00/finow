import 'package:finow/features/home/home_model.dart';
import 'package:finow/features/home/instrument_detail_provider.dart';
import 'package:finow/features/instruments/models/instrument.dart';
import 'package:finow/features/ticker/models/ticker_price_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CryptoPremiumDetailScreen extends ConsumerWidget {
  const CryptoPremiumDetailScreen({super.key, required this.premium});

  final CryptoPremium premium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instrumentDetailAsync = ref.watch(instrumentDetailProvider(premium.symbol));

    return Scaffold(
      appBar: AppBar(
        title: Text(premium.symbol),
      ),
      body: instrumentDetailAsync.when(
        data: (details) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Premium Summary'),
                _buildPremiumSummary(premium),
                const SizedBox(height: 24),
                _buildSectionTitle('Bithumb Details'),
                _buildInstrumentDetails(details.bithumbInstrument),
                const SizedBox(height: 16),
                _buildTickerDetails(details.bithumbTicker),
                const SizedBox(height: 24),
                _buildSectionTitle('Bybit Details'),
                _buildInstrumentDetails(details.bybitInstrument),
                const SizedBox(height: 16),
                _buildTickerDetails(details.bybitTicker),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPremiumSummary(CryptoPremium premium) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow('Symbol', premium.symbol),
            _buildDetailRow('Name', premium.name),
            if (premium.koreanName != null)
              _buildDetailRow('Korean Name', premium.koreanName!),
            _buildDetailRow(
                'Bybit Price',
                '${_formatPrice(premium.bybitPrice)} ${premium.bybitQuoteCode ?? 'USDT'}'),
            _buildDetailRow('Bithumb Price (USD)',
                '${_formatPrice(premium.bithumbPrice)} USD'),
            _buildDetailRow('Bithumb Price (KRW)',
                '${_formatPrice(premium.bithumbPriceKRW)} KRW'),
            _buildDetailRow('Premium', '${premium.premium?.toStringAsFixed(2)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstrumentDetails(Instrument instrument) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Exchange', instrument.exchange),
            _buildDetailRow('Symbol', instrument.symbol),
            _buildDetailRow('Base Code', instrument.baseCode),
            _buildDetailRow('Quote Code', instrument.quoteCode),
            _buildDetailRow('Category', instrument.category ?? '-'),
            if (instrument.koreanName != null)
              _buildDetailRow('Korean Name', instrument.koreanName!),
            if (instrument.englishName != null)
              _buildDetailRow('English Name', instrument.englishName!),
            if (instrument.marketWarning != null)
              _buildDetailRow('Market Warning', instrument.marketWarning!),
          ],
        ),
      ),
    );
  }

  Widget _buildTickerDetails(TickerPriceData ticker) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Last Price', ticker.lastPrice ?? '-'),
            _buildDetailRow('24h High', ticker.highPrice24h ?? '-'),
            _buildDetailRow('24h Low', ticker.lowPrice24h ?? '-'),
            _buildDetailRow('24h Volume', ticker.volume24h ?? '-'),
            _buildDetailRow('24h Turnover', ticker.turnover24h ?? '-'),
            _buildDetailRow('24h Price Change', '${ticker.price24hPcnt ?? '-'}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  String _formatPrice(double? price) {
    if (price == null) return '-';
    if (price >= 1000) {
      return NumberFormat('#,##0').format(price);
    }
    return price.toString();
  }
}

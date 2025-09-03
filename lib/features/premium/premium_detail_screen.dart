import 'package:finow/features/premium/premium_model.dart';
import 'package:finow/features/premium/premium_detail_provider.dart';
import 'package:finow/features/instruments/models/instrument.dart';
import 'package:finow/features/ticker/models/ticker_price_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PremiumDetailScreen extends ConsumerWidget {
  const PremiumDetailScreen({super.key, required this.premium});

  final Premium premium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instrumentDetailAsync = ref.watch(premiumDetailProvider(premium.symbol));

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
                _buildSectionTitle('Details'),
                _buildComparisonTable(
                  details.bithumbInstrument,
                  details.bybitInstrument,
                  details.bithumbTicker,
                  details.bybitTicker,
                ),
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

  Widget _buildPremiumSummary(Premium premium) {
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

  Widget _buildComparisonTable(
    Instrument bithumbInstrument,
    Instrument bybitInstrument,
    TickerPriceData bithumbTicker,
    TickerPriceData bybitTicker,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildComparisonHeader(),
            const Divider(),
            _buildComparisonRow('Symbol', bithumbInstrument.symbol, bybitInstrument.symbol),
            _buildComparisonRow('Base Code', bithumbInstrument.baseCode, bybitInstrument.baseCode),
            _buildComparisonRow('Quote Code', bithumbInstrument.quoteCode, bybitInstrument.quoteCode),
            _buildComparisonRow('Category', bithumbInstrument.category ?? '-', bybitInstrument.category ?? '-'),
            _buildComparisonRow('Korean Name', bithumbInstrument.koreanName ?? '-', bybitInstrument.koreanName ?? '-'),
            _buildComparisonRow('English Name', bithumbInstrument.englishName ?? '-', bybitInstrument.englishName ?? '-'),
            _buildComparisonRow('Market Warning', bithumbInstrument.marketWarning ?? '-', bybitInstrument.marketWarning ?? '-'),
            const Divider(),
            _buildComparisonRow('Last Price', bithumbTicker.lastPrice ?? '-', bybitTicker.lastPrice ?? '-'),
            _buildComparisonRow('24h High', bithumbTicker.highPrice24h ?? '-', bybitTicker.highPrice24h ?? '-'),
            _buildComparisonRow('24h Low', bithumbTicker.lowPrice24h ?? '-', bybitTicker.lowPrice24h ?? '-'),
            _buildComparisonRow('24h Volume', bithumbTicker.volume24h ?? '-', bybitTicker.volume24h ?? '-'),
            _buildComparisonRow('24h Turnover', bithumbTicker.turnover24h ?? '-', bybitTicker.turnover24h ?? '-'),
            _buildComparisonRow('24h Price Change', '${bithumbTicker.price24hPcnt ?? '-'}%', '${bybitTicker.price24hPcnt ?? '-'}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Expanded(flex: 2, child: Text('Attribute', style: TextStyle(fontWeight: FontWeight.bold))),
          const Expanded(flex: 3, child: Text('Bithumb', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
          const Expanded(flex: 3, child: Text('Bybit', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String bithumbValue, String bybitValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(flex: 3, child: Text(bithumbValue, textAlign: TextAlign.end)),
          Expanded(flex: 3, child: Text(bybitValue, textAlign: TextAlign.end)),
        ],
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

import 'package:flutter/material.dart';
import '../models/integrated_instrument.dart';

class InstrumentDetailsScreen extends StatelessWidget {
  final IntegratedInstrument instrument;

  const InstrumentDetailsScreen({super.key, required this.instrument});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(instrument.symbol),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'General Information'),
            _buildInfoCard(
              context,
              [
                _buildDetailRow(context, 'Exchange', instrument.exchange.toUpperCase(), icon: Icons.account_balance),
                _buildDetailRow(context, 'Base Coin', instrument.baseCoin, icon: Icons.currency_bitcoin),
                _buildDetailRow(context, 'Quote Coin', instrument.quoteCoin, icon: Icons.currency_exchange),
                _buildDetailRow(context, 'Status', instrument.status, icon: Icons.info_outline),
                if (instrument.englishName != null)
                  _buildDetailRow(context, 'English Name', instrument.englishName!, icon: Icons.language),
                if (instrument.marketWarning != null && instrument.marketWarning != 'NONE')
                  _buildDetailRow(context, 'Warning', instrument.marketWarning!, icon: Icons.warning, isWarning: true),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Filters'),
            _buildInfoCard(
              context,
              [
                if (instrument.priceFilter != null)
                  _buildDetailRow(context, 'Tick Size', instrument.priceFilter!.tickSize, icon: Icons.precision_manufacturing),
                if (instrument.lotSizeFilter != null) ...[
                  _buildDetailRow(context, 'Min Order Qty', instrument.lotSizeFilter!.minOrderQty, icon: Icons.add_shopping_cart),
                  _buildDetailRow(context, 'Max Order Qty', instrument.lotSizeFilter!.maxOrderQty, icon: Icons.shopping_cart),
                  _buildDetailRow(context, 'Min Order Amt', instrument.lotSizeFilter!.minOrderAmt, icon: Icons.money),
                  _buildDetailRow(context, 'Max Order Amt', instrument.lotSizeFilter!.maxOrderAmt, icon: Icons.attach_money),
                ],
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Last Updated'),
            _buildInfoCard(
              context,
              [
                _buildDetailRow(context, 'Timestamp',
                    '${instrument.lastUpdated.year}-${instrument.lastUpdated.month.toString().padLeft(2, '0')}-${instrument.lastUpdated.day.toString().padLeft(2, '0')} ${instrument.lastUpdated.hour.toString().padLeft(2, '0')}:${instrument.lastUpdated.minute.toString().padLeft(2, '0')}', icon: Icons.access_time),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      color: colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {IconData? icon, bool isWarning = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: isWarning ? colorScheme.error : colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isWarning ? colorScheme.error : colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
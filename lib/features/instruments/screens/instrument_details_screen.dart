import 'package:flutter/material.dart';
import '../models/instrument.dart';


class InstrumentDetailsScreen extends StatelessWidget {
  final Instrument instrument;

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
                if (instrument.quantity != null)
                  _buildDetailRow(context, 'Quantity', instrument.quantity!.toStringAsFixed(0), icon: Icons.production_quantity_limits),
                _buildDetailRow(context, 'Base Code', instrument.baseCode, icon: Icons.currency_bitcoin),
                _buildDetailRow(context, 'Quote Code', instrument.quoteCode, icon: Icons.currency_exchange),
                _buildDetailRow(context, 'Status', instrument.status, icon: Icons.info_outline),
                if (instrument.category != null)
                  _buildDetailRow(context, 'Category', instrument.category!.toUpperCase(), icon: Icons.category),
                if (instrument.endDate != null)
                  _buildDetailRow(context, 'End Date', instrument.endDate!, icon: Icons.article),
                if (instrument.settleCoin != null)
                  _buildDetailRow(context, 'Settle Coin', instrument.settleCoin!, icon: Icons.account_balance_wallet),
                if (instrument.englishName != null)
                  _buildDetailRow(context, 'English Name', instrument.englishName!, icon: Icons.language),
                if (instrument.marketWarning != null && instrument.marketWarning != 'NONE')
                  _buildDetailRow(context, 'Warning', instrument.marketWarning!, icon: Icons.warning, isWarning: true),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Trading Information'),
            _buildInfoCard(
              context,
              [
                if (instrument.launchTime != null)
                  _buildDetailRow(context, 'Launch Time', _formatTimestamp(instrument.launchTime!), icon: Icons.rocket_launch),
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
      color: colorScheme.surfaceContainerHighest,
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
            Icon(icon, color: isWarning ? colorScheme.error : colorScheme.onSurfaceVariant),
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

  String _formatTimestamp(String timestamp) {
    try {
      final milliseconds = int.parse(timestamp);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp; // Return original if parsing fails
    }
  }

  
}
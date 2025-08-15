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
                _buildDetailRow(context, 'Base Coin', instrument.baseCoin, icon: Icons.currency_bitcoin),
                _buildDetailRow(context, 'Quote Coin', instrument.quoteCoin, icon: Icons.currency_exchange),
                _buildDetailRow(context, 'Status', instrument.status, icon: Icons.info_outline),
                if (instrument.category != null)
                  _buildDetailRow(context, 'Category', instrument.category!.toUpperCase(), icon: Icons.category),
                if (instrument.contractType != null)
                  _buildDetailRow(context, 'Contract Type', instrument.contractType!, icon: Icons.article),
                if (instrument.settleCoin != null)
                  _buildDetailRow(context, 'Settle Coin', instrument.settleCoin!, icon: Icons.account_balance_wallet),
                if (instrument.englishName != null)
                  _buildDetailRow(context, 'English Name', instrument.englishName!, icon: Icons.language),
                if (instrument.displayName != null && instrument.displayName!.isNotEmpty)
                  _buildDetailRow(context, 'Display Name', instrument.displayName!, icon: Icons.label),
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
                if (instrument.deliveryTime != null && instrument.deliveryTime != '0')
                  _buildDetailRow(context, 'Delivery Time', _formatTimestamp(instrument.deliveryTime!), icon: Icons.delivery_dining),
                if (instrument.deliveryFeeRate != null && instrument.deliveryFeeRate!.isNotEmpty)
                  _buildDetailRow(context, 'Delivery Fee Rate', instrument.deliveryFeeRate!, icon: Icons.percent),
                if (instrument.priceScale != null)
                  _buildDetailRow(context, 'Price Scale', instrument.priceScale!, icon: Icons.scale),
                if (instrument.unifiedMarginTrade != null)
                  _buildDetailRow(context, 'Unified Margin Trade', instrument.unifiedMarginTrade! ? 'Yes' : 'No', icon: Icons.account_balance),
                if (instrument.fundingInterval != null)
                  _buildDetailRow(context, 'Funding Interval', '${instrument.fundingInterval} minutes', icon: Icons.schedule),
                if (instrument.copyTrading != null)
                  _buildDetailRow(context, 'Copy Trading', instrument.copyTrading!, icon: Icons.content_copy),
                if (instrument.isPreListing != null)
                  _buildDetailRow(context, 'Pre-listing', instrument.isPreListing! ? 'Yes' : 'No', icon: Icons.preview),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Price Filters'),
            _buildInfoCard(
              context,
              [
                if (instrument.priceFilter != null) ...[
                  _buildDetailRow(context, 'Tick Size', instrument.priceFilter!.tickSize, icon: Icons.precision_manufacturing),
                  if (instrument.priceFilter!.minPrice != null)
                    _buildDetailRow(context, 'Min Price', instrument.priceFilter!.minPrice!, icon: Icons.trending_down),
                  if (instrument.priceFilter!.maxPrice != null)
                    _buildDetailRow(context, 'Max Price', instrument.priceFilter!.maxPrice!, icon: Icons.trending_up),
                ],
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Lot Size Filters'),
            _buildInfoCard(
              context,
              [
                if (instrument.lotSizeFilter != null) ...[
                  _buildDetailRow(context, 'Min Order Qty', instrument.lotSizeFilter!.minOrderQty, icon: Icons.add_shopping_cart),
                  _buildDetailRow(context, 'Max Order Qty', instrument.lotSizeFilter!.maxOrderQty, icon: Icons.shopping_cart),
                  _buildDetailRow(context, 'Qty Step', instrument.lotSizeFilter!.qtyStep, icon: Icons.linear_scale),
                  if (instrument.lotSizeFilter!.postOnlyMaxOrderQty != null)
                    _buildDetailRow(context, 'Post-Only Max Qty', instrument.lotSizeFilter!.postOnlyMaxOrderQty!, icon: Icons.post_add),
                  if (instrument.lotSizeFilter!.maxMktOrderQty != null)
                    _buildDetailRow(context, 'Max Market Order Qty', instrument.lotSizeFilter!.maxMktOrderQty!, icon: Icons.speed),
                  if (instrument.lotSizeFilter!.minNotionalValue != null)
                    _buildDetailRow(context, 'Min Notional Value', instrument.lotSizeFilter!.minNotionalValue!, icon: Icons.attach_money),
                  if (instrument.lotSizeFilter!.minOrderAmt != null)
                    _buildDetailRow(context, 'Min Order Amount', instrument.lotSizeFilter!.minOrderAmt!, icon: Icons.money),
                  if (instrument.lotSizeFilter!.maxOrderAmt != null)
                    _buildDetailRow(context, 'Max Order Amount', instrument.lotSizeFilter!.maxOrderAmt!, icon: Icons.monetization_on),
                ],
              ],
            ),
            if (instrument.leverageFilter != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Leverage'),
              _buildInfoCard(
                context,
                [
                  _buildDetailRow(context, 'Min Leverage', '${instrument.leverageFilter!.minLeverage}x', icon: Icons.trending_up),
                  _buildDetailRow(context, 'Max Leverage', '${instrument.leverageFilter!.maxLeverage}x', icon: Icons.trending_up),
                  _buildDetailRow(context, 'Leverage Step', instrument.leverageFilter!.leverageStep, icon: Icons.linear_scale),
                ],
              ),
            ],
            if (instrument.upperFundingRate != null || instrument.lowerFundingRate != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Funding Rates'),
              _buildInfoCard(
                context,
                [
                  if (instrument.upperFundingRate != null)
                    _buildDetailRow(context, 'Upper Funding Rate', _formatFundingRate(instrument.upperFundingRate!), icon: Icons.arrow_upward),
                  if (instrument.lowerFundingRate != null)
                    _buildDetailRow(context, 'Lower Funding Rate', _formatFundingRate(instrument.lowerFundingRate!), icon: Icons.arrow_downward),
                ],
              ),
            ],
            if (instrument.riskParameters != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Risk Parameters'),
              _buildInfoCard(
                context,
                [
                  if (instrument.riskParameters!.priceLimitRatioX != null)
                    _buildDetailRow(context, 'Price Limit Ratio X', _formatPercentage(instrument.riskParameters!.priceLimitRatioX!), icon: Icons.security),
                  if (instrument.riskParameters!.priceLimitRatioY != null)
                    _buildDetailRow(context, 'Price Limit Ratio Y', _formatPercentage(instrument.riskParameters!.priceLimitRatioY!), icon: Icons.security),
                ],
              ),
            ],
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

  String _formatFundingRate(String rate) {
    try {
      final rateValue = double.parse(rate);
      return '${(rateValue * 100).toStringAsFixed(4)}%';
    } catch (e) {
      return rate;
    }
  }

  String _formatPercentage(String percentage) {
    try {
      final percentageValue = double.parse(percentage);
      return '${(percentageValue * 100).toStringAsFixed(2)}%';
    } catch (e) {
      return percentage;
    }
  }
}
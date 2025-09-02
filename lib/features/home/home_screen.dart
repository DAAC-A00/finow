import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/features/home/home_provider.dart';
import 'package:finow/features/home/home_model.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Premium'),
      ),
      body: Column(
        children: [
          _buildSortChips(ref),
          Expanded(
            child: homeState.when(
              data: (premiums) => _buildPremiumList(premiums, context, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumList(List<CryptoPremium> premiums, BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (premiums.isEmpty) {
      return const Center(
        child: Text('No premium data available.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(homeProvider.notifier).refresh();
      },
      child: ListView.builder(
        itemCount: premiums.length,
        itemBuilder: (context, index) {
          final premium = premiums[index];
          final premiumValue = premium.premium ?? 0;
          final premiumColor = premiumValue >= 0 ? Colors.green : Colors.red;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side - Symbols
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        premium.symbol,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (premium.koreanName != null)
                        Text(
                          premium.koreanName!,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
                    ],
                  ),
                  // Right side - Prices and Premium
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_formatPrice(premium.bithumbPriceKRW)} KRW',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '${_formatPrice(premium.bybitPrice)} USD',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface.withAlpha(153),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          '${premiumValue.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: premiumColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatPrice(double? price) {
    if (price == null) return '-';
    if (price >= 1000) {
      return NumberFormat('#,##0').format(price);
    }
    return price.toStringAsFixed(2);
  }

  Widget _buildSortChips(WidgetRef ref) {
    final sortOption = ref.watch(premiumSortOptionProvider);
    final sortDirection = ref.watch(premiumSortDirectionProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: PremiumSortOption.values.map((option) {
            final isSelected = sortOption == option;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_getSortOptionName(option)),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(
                          sortDirection == SortDirection.asc
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (isSelected) {
                    ref.read(premiumSortDirectionProvider.notifier).state =
                        sortDirection == SortDirection.asc
                            ? SortDirection.desc
                            : SortDirection.asc;
                  } else {
                    ref.read(premiumSortOptionProvider.notifier).state = option;
                    ref.read(premiumSortDirectionProvider.notifier).state =
                        SortDirection.asc;
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getSortOptionName(PremiumSortOption option) {
    switch (option) {
      case PremiumSortOption.symbol:
        return 'Symbol';
      case PremiumSortOption.bybitPrice:
        return 'Bybit Price';
      case PremiumSortOption.bithumbPrice:
        return 'Bithumb Price';
      case PremiumSortOption.premium:
        return 'Premium %';
    }
  }
}


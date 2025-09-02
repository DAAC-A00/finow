import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/features/home/home_provider.dart';
import 'package:finow/features/home/home_model.dart';

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${premium.name} (${premium.symbol})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriceInfo('Bybit', premium.bybitPrice, 'USD', colorScheme),
                      _buildPriceInfo('Bithumb', premium.bithumbPrice, 'USD', colorScheme),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Premium: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
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
                ],
              ),
            ),
          );
        },
      ),
    );
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

  Widget _buildPriceInfo(String exchange, double? price, String currency, ColorScheme colorScheme) {
    Widget leadingWidget;

    switch (exchange.toLowerCase()) {
      case 'bybit':
        leadingWidget = const Text(
          '🌎',
          style: TextStyle(fontSize: 16), // Adjust size as needed
        );
        break;
      case 'bithumb':
        leadingWidget = const Text(
          '🇰🇷',
          style: TextStyle(fontSize: 16), // Adjust size as needed
        );
        break;
      default:
        // Fallback to image or text if not Bybit or Bithumb
        // This part is technically not needed as we only pass 'Bybit' and 'Bithumb'
        // but kept for robustness.
        leadingWidget = Text(
          exchange,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withAlpha(153),
          ),
        );
        break;
    }

    return Row(
      children: [
        leadingWidget,
        const SizedBox(width: 8.0),
        Text(
          '${price?.toStringAsFixed(2) ?? '-'} $currency',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

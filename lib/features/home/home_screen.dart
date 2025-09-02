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
      body: homeState.when(
        data: (premiums) => _buildPremiumList(premiums, context, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
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

  Widget _buildPriceInfo(String exchange, double? price, String currency, ColorScheme colorScheme) {
    Widget leadingWidget;

    switch (exchange.toLowerCase()) {
      case 'bybit':
        leadingWidget = const Text(
          '🌎',
        );
        break;
      case 'bithumb':
        leadingWidget = const Text(
          '🇰🇷',
        );
        break;
      default:
        // Fallback to image or text if not Bybit or Bithumb
        // This part is technically not needed as we only pass 'Bybit' and 'Bithumb'
        // but kept for robustness.
        leadingWidget = Text(
          exchange,
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

import 'package:finow/features/premium/premium_model.dart';
import 'package:finow/features/premium/premium_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumProvider);
    final searchQuery = ref.watch(premiumSearchQueryProvider);

    if (_searchController.text != searchQuery) {
      _searchController.text = searchQuery;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Premium'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(premiumSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search by symbol or name...',
                border: const OutlineInputBorder(),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(premiumSearchQueryProvider.notifier).state = '';
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          _buildSortChips(ref),
          Expanded(
            child: premiumState.when(
              data: (premiums) => _buildPremiumList(premiums, context, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumList(List<Premium> premiums, BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (premiums.isEmpty) {
      return const Center(
        child: Text('No premium data available.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(premiumProvider.notifier).refresh();
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
            child: InkWell(
              onTap: () {
                context.push('/premium/details', extra: premium);
              },
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
                        ),
                        if (premium.koreanName != null)
                          Text(
                            premium.koreanName!,
                          ),
                      ],
                    ),
                    // Right side - Prices and Premium
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Emojis Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text(
                                '🇰🇷',
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                '🌎',
                              ),
                            ],
                          ),
                          const SizedBox(width: 4.0), // Spacing between emojis and prices
                          // Prices Column
                          SizedBox(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                (premium.bithumbQuoteCode == 'KRW' && premium.bithumbPriceKRW != null)
                                    ? AutoSizeText(
                                        '${_formatPrice(premium.bithumbPriceKRW)} KRW',
                                        maxLines: 1,
                                        textAlign: TextAlign.end,
                                      )
                                    : AutoSizeText(
                                        '${_formatPrice(premium.bithumbPrice)} ${premium.bithumbQuoteCode ?? ''}',
                                        maxLines: 1,
                                        textAlign: TextAlign.end,
                                      ),
                                const SizedBox(height: 4.0),
                                AutoSizeText(
                                  '${_formatPrice(premium.bybitPrice)} ${premium.bybitQuoteCode ?? 'USDT'}',
                                  maxLines: 1,
                                  textAlign: TextAlign.end,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0), // Spacing between prices and premium %
                          SizedBox(
                            width: 80,
                            child: Text(
                              '${premiumValue.toStringAsFixed(2)}%',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: premiumColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
    return price.toString();
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
        return 'Global Price';
      case PremiumSortOption.bithumbPrice:
        return 'Korean Price';
      case PremiumSortOption.premium:
        return 'Premium';
      case PremiumSortOption.turnover:
        return 'Turnover';
      case PremiumSortOption.volume:
        return 'Volume';
    }
  }
}

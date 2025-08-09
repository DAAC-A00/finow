import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:finow/ui_scale_provider.dart';

// 정렬 기준을 정의하는 Enum
enum SortCriteria { byCodeAsc, byCodeDesc, byPriceAsc, byPriceDesc }

// 검색어 관리를 위한 StateProvider
final searchQueryProvider = StateProvider<String>((ref) => '');

// 정렬 기준 관리를 위한 StateProvider (초기값: 코드 오름차순)
final sortCriteriaProvider =
    StateProvider<SortCriteria>((ref) => SortCriteria.byCodeAsc);

// 검색 및 정렬된 환율 데이터를 제공하는 Provider
final filteredRatesProvider = Provider<List<ExchangeRate>>((ref) {
  final asyncRates = ref.watch(exchangeRateProvider);
  final rates = asyncRates.asData?.value ?? [];
  final searchQuery = ref.watch(searchQueryProvider);
  final sortCriteria = ref.watch(sortCriteriaProvider);

  // 검색어 필터링
  final filtered = rates.where((rate) {
    final query = searchQuery.toLowerCase();
    final combinedCode = (rate.baseCode + rate.quoteCode).toLowerCase();
    final quoteCode = rate.quoteCode.toLowerCase();
    return combinedCode.contains(query) || quoteCode.contains(query);
  }).toList();

  // 정렬
  filtered.sort((a, b) {
    switch (sortCriteria) {
      case SortCriteria.byCodeAsc:
        return (a.baseCode + a.quoteCode)
            .compareTo(b.baseCode + b.quoteCode);
      case SortCriteria.byCodeDesc:
        return (b.baseCode + b.quoteCode)
            .compareTo(a.baseCode + a.quoteCode);
      case SortCriteria.byPriceAsc:
        return a.price.compareTo(b.price);
      case SortCriteria.byPriceDesc:
        return b.price.compareTo(a.price);
    }
  });

  return filtered;
});

class ExchangeRateScreen extends ConsumerStatefulWidget {
  const ExchangeRateScreen({super.key});

  @override
  ConsumerState<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends ConsumerState<ExchangeRateScreen> {
  late final TextEditingController _controller;
  

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return NumberFormat('#,##0').format(price);
    }
    return price.toString();
  }

  @override
  Widget build(BuildContext context) {
    final asyncRates = ref.watch(exchangeRateProvider);
    final filteredRates = ref.watch(filteredRatesProvider);
    final sortCriteria = ref.watch(sortCriteriaProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    // local storage에서 검색어 불러오는 코드 제거
    // 입력란에 Provider 상태만 반영
    if (_controller.text != searchQuery) {
      _controller.text = searchQuery;
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
          decoration: const InputDecoration(
            hintText: 'Search by currency code (e.g., KRW, JPY)',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(exchangeRateProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 정렬 버튼과 개수 표시를 양 끝으로
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ScaledText('ABC'),
                          const SizedBox(width: 4),
                          if (sortCriteria == SortCriteria.byCodeAsc ||
                              sortCriteria == SortCriteria.byCodeDesc)
                            ScaledIcon(
                              sortCriteria == SortCriteria.byCodeAsc
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 16,
                            ),
                        ],
                      ),
                      selected: sortCriteria == SortCriteria.byCodeAsc ||
                          sortCriteria == SortCriteria.byCodeDesc,
                      onSelected: (selected) {
                        final notifier = ref.read(sortCriteriaProvider.notifier);
                        final isCurrentlyCodeSort =
                            notifier.state == SortCriteria.byCodeAsc ||
                                notifier.state == SortCriteria.byCodeDesc;
                        if (isCurrentlyCodeSort) {
                          notifier.state = notifier.state == SortCriteria.byCodeAsc
                              ? SortCriteria.byCodeDesc
                              : SortCriteria.byCodeAsc;
                        } else {
                          notifier.state = SortCriteria.byCodeAsc;
                        }
                      },
                    ),
                    const SizedBox(width: 8.0),
                    FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ScaledText('Price'),
                          const SizedBox(width: 4),
                          if (sortCriteria == SortCriteria.byPriceAsc ||
                              sortCriteria == SortCriteria.byPriceDesc)
                            ScaledIcon(
                              sortCriteria == SortCriteria.byPriceAsc
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 16,
                            ),
                        ],
                      ),
                      selected: sortCriteria == SortCriteria.byPriceAsc ||
                          sortCriteria == SortCriteria.byPriceDesc,
                      onSelected: (selected) {
                        final notifier = ref.read(sortCriteriaProvider.notifier);
                        final isCurrentlyPriceSort =
                            notifier.state == SortCriteria.byPriceAsc ||
                                notifier.state == SortCriteria.byPriceDesc;
                        if (isCurrentlyPriceSort) {
                          notifier.state = notifier.state == SortCriteria.byPriceAsc
                              ? SortCriteria.byPriceDesc
                              : SortCriteria.byPriceAsc;
                        } else {
                          notifier.state = SortCriteria.byPriceAsc;
                        }
                      },
                    ),
                  ],
                ),
                ScaledText(
                  '${filteredRates.length} items',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: asyncRates.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ScaledText('Failed to load data.\nError: $err',
                      textAlign: TextAlign.center),
                ),
              ),
              data: (rates) => _buildPriceList(
                context,
                filteredRates,
                rates.isNotEmpty ? rates.first.lastUpdatedUnix : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceList(
      BuildContext context, List<ExchangeRate> rates, int lastUpdatedUnix) {
    if (rates.isEmpty) {
      return const Center(
          child: ScaledText('No data available or matches your search.'));
    }

    return ListView.builder(
      itemCount: rates.length,
      itemBuilder: (context, index) {
          final rate = rates[index];
          Widget leadingIcon;
          if (rate.source == 'exconvert.com') {
            leadingIcon = const ScaledAssetImage(
              assetPath: 'images/exconvert.png',
              baseWidth: 20,
              baseHeight: 20,
            );
          } else if (rate.source == 'v6.exchangerate-api.com') {
            leadingIcon = const ScaledAssetImage(
              assetPath: 'images/exchangerate-api.png',
              baseWidth: 20,
              baseHeight: 20,
            );
          } else {
            leadingIcon = const ScaledIcon(
              Icons.currency_exchange,
              color: Colors.blueAccent,
              size: 20,
            );
          }

          return Card(
            margin:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              leading: leadingIcon,
              title: ScaledText(
                '${rate.baseCode}/${rate.quoteCode}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: ScaledText(
                _formatPrice(rate.price),
                style: const TextStyle(fontSize: 15),
              ),
              onTap: () =>
                  context.push('/exchange/${rate.quoteCode}', extra: rate),
            ),
          );
        },
    );
  }
}
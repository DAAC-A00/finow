import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:finow/features/storage_viewer/local_storage_service.dart';

// 정렬 기준을 정의하는 Enum
enum SortCriteria { byCodeAsc, byCodeDesc, byRateAsc, byRateDesc }

// 검색어 관리를 위한 StateProvider
final searchQueryProvider = StateProvider<String>((ref) => '');

// 정렬 기준 관리를 위한 StateProvider (초기값: 코드 오름차순)
final sortCriteriaProvider = StateProvider<SortCriteria>((ref) => SortCriteria.byCodeAsc);

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
      case SortCriteria.byRateAsc:
        return a.rate.compareTo(b.rate);
      case SortCriteria.byRateDesc:
        return b.rate.compareTo(a.rate);
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
  bool _initialized = false;

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

  String _formatRate(double rate) {
    if (rate >= 1000) return NumberFormat('#,##0').format(rate);
    if (rate >= 100) return rate.toStringAsFixed(1);
    if (rate >= 10) return rate.toStringAsFixed(2);
    if (rate >= 1) return rate.toStringAsFixed(3);
    if (rate >= 0.1) return rate.toStringAsFixed(4);
    if (rate >= 0.01) return rate.toStringAsFixed(5);
    if (rate >= 0.001) return rate.toStringAsFixed(6);
    if (rate >= 0.0001) return rate.toStringAsFixed(7);
    if (rate >= 0.00001) return rate.toStringAsFixed(8);
    if (rate >= 0.000001) return rate.toStringAsFixed(9);
    if (rate > 0) return rate.toStringAsFixed(10);
    return rate.toStringAsFixed(2);
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('ABC'),
                      const SizedBox(width: 4),
                      if (sortCriteria == SortCriteria.byCodeAsc ||
                          sortCriteria == SortCriteria.byCodeDesc)
                        Icon(
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
                    // local storage 저장 코드 제거
                  },
                ),
                const SizedBox(width: 8.0),
                FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Rate'),
                      const SizedBox(width: 4),
                      if (sortCriteria == SortCriteria.byRateAsc ||
                          sortCriteria == SortCriteria.byRateDesc)
                        Icon(
                          sortCriteria == SortCriteria.byRateAsc
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                        ),
                    ],
                  ),
                  selected: sortCriteria == SortCriteria.byRateAsc ||
                      sortCriteria == SortCriteria.byRateDesc,
                  onSelected: (selected) {
                    final notifier = ref.read(sortCriteriaProvider.notifier);
                    final isCurrentlyRateSort =
                        notifier.state == SortCriteria.byRateAsc ||
                            notifier.state == SortCriteria.byRateDesc;
                    if (isCurrentlyRateSort) {
                      notifier.state = notifier.state == SortCriteria.byRateAsc
                          ? SortCriteria.byRateDesc
                          : SortCriteria.byRateAsc;
                    } else {
                      notifier.state = SortCriteria.byRateAsc;
                    }
                    // local storage 저장 코드 제거
                  },
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
                  child: Text('Failed to load data.\nError: $err',
                      textAlign: TextAlign.center),
                ),
              ),
              data: (rates) => _buildRateList(
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

  Widget _buildRateList(
      BuildContext context, List<ExchangeRate> rates, int lastUpdatedUnix) {
    if (rates.isEmpty) {
      return const Center(
          child: Text('No data available or matches your search.'));
    }

    final dateTime =
        DateTime.fromMillisecondsSinceEpoch(lastUpdatedUnix * 1000);
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDateTime = formatter.format(dateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lastUpdatedUnix > 0)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Last Updated: $formattedDateTime',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: rates.length,
            itemBuilder: (context, index) {
              final rate = rates[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.currency_exchange,
                      color: Colors.blueAccent),
                  title: Text(
                    '${rate.baseCode}/${rate.quoteCode}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    _formatRate(rate.rate),
                    style: const TextStyle(fontSize: 15),
                  ),
                  onTap: () =>
                      context.push('/exchange/${rate.quoteCode}', extra: rate),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
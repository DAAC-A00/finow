import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/ticker_price_data.dart';
import '../models/ticker_sort_option.dart';
import '../providers/ticker_provider.dart';
import 'package:go_router/go_router.dart';

/// 실시간 Ticker 정보 화면
class TickerScreen extends ConsumerStatefulWidget {
  const TickerScreen({super.key});

  @override
  ConsumerState<TickerScreen> createState() => _TickerScreenState();
}

class _TickerScreenState extends ConsumerState<TickerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 Ticker 정보'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(liveTickerProvider.notifier).refreshTickers();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Spot'),
            Tab(text: 'Linear'),
            Tab(text: 'Inverse'),
          ],
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withAlpha(153),
          indicatorColor: colorScheme.primary,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: '심볼, 코인명으로 검색...',
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          _buildFilterChips(colorScheme),
          _buildSortChips(ref),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLiveTickerList('all'),
                _buildLiveTickerList('spot'),
                _buildLiveTickerList('linear'),
                _buildLiveTickerList('inverse'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Trading'),
            selected: _selectedStatus == 'Trading',
            onSelected: (selected) {
              setState(() {
                _selectedStatus = selected ? 'Trading' : 'all';
              });
            },
          ),
          const SizedBox(width: 8.0),
          FilterChip(
            label: const Text('PreListing'),
            selected: _selectedStatus == 'PreListing',
            onSelected: (selected) {
              setState(() {
                _selectedStatus = selected ? 'PreListing' : 'all';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortChips(WidgetRef ref) {
    final sortOption = ref.watch(tickerSortOptionProvider);
    final sortDirection = ref.watch(sortDirectionProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TickerSortOption.values.map((option) {
            final isSelected = sortOption == option;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ActionChip(
                avatar: isSelected
                    ? Icon(
                        sortDirection == SortDirection.asc
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                      )
                    : null,
                label: Text(_getSortOptionName(option)),
                onPressed: () {
                  if (isSelected) {
                    ref.read(sortDirectionProvider.notifier).state =
                        sortDirection == SortDirection.asc
                            ? SortDirection.desc
                            : SortDirection.asc;
                  } else {
                    ref.read(tickerSortOptionProvider.notifier).state = option;
                    ref.read(sortDirectionProvider.notifier).state =
                        SortDirection.desc;
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getSortOptionName(TickerSortOption option) {
    switch (option) {
      case TickerSortOption.symbol:
        return 'Symbol';
      case TickerSortOption.koreanName:
        return 'Korean Name';
      case TickerSortOption.lastPrice:
        return 'Price';
      case TickerSortOption.priceChangePercent:
        return 'Change';
      case TickerSortOption.volume24h:
        return 'Volume';
      case TickerSortOption.turnover24h:
        return 'Turnover';
    }
  }

  Widget _buildLiveTickerList(String category) {
    final liveTickerState = ref.watch(liveTickerProvider);
    final sortOption = ref.watch(tickerSortOptionProvider);
    final sortDirection = ref.watch(sortDirectionProvider);

    return liveTickerState.when(
      data: (tickers) {
        final notifier = ref.read(liveTickerProvider.notifier);
        final filteredTickers = notifier.getFilteredAndSortedTickers(
          category: category,
          query: _searchQuery,
          status: _selectedStatus,
          sortOption: sortOption,
          sortDirection: sortDirection,
        );

        if (filteredTickers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64.0),
                SizedBox(height: 16.0),
                Text('실시간 ticker 데이터가 없습니다'),
                SizedBox(height: 8.0),
                Text('새로고침하거나 필터를 조정해보세요'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(liveTickerProvider.notifier).refreshTickers();
          },
          child: ListView.builder(
            itemCount: filteredTickers.length,
            itemBuilder: (context, index) {
              final ticker = filteredTickers[index];
              return _buildLiveTickerCard(ticker, Theme.of(context).colorScheme);
            },
          ),
        );
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('실시간 ticker 정보를 로드하는 중...'),
          ],
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64.0, color: Colors.red),
            const SizedBox(height: 16.0),
            const Text('실시간 ticker 데이터 로드 오류'),
            const SizedBox(height: 8.0),
            Text(error.toString()),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                ref.read(liveTickerProvider.notifier).refreshTickers();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTickerCard(
      IntegratedTickerPriceData ticker, ColorScheme colorScheme) {
    final priceData = ticker.priceData;
    final priceDirection = ticker.priceDirection;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push('/ticker/details', extra: ticker);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          'images/exchange${ticker.exchange}.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'images/exchange${ticker.exchange}.jpeg',
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.business, size: 24);
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getIntegratedSymbol(ticker),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildCategoryBadge(ticker.category, colorScheme),
                      if (priceData != null) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          _formatNumberWithCommas(priceData.lastPrice),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getPriceColor(priceDirection, colorScheme),
                          ),
                        ),
                        if (priceData.price24hPcnt != null) ...[
                          Text(
                            '${priceData.price24hPcnt}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getPriceColor(priceDirection, colorScheme),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  _buildInfoChip(
                    ticker.symbol,
                    colorScheme,
                  ),
                  _buildStatusChip(ticker.status, colorScheme),
                  if (ticker.contractType != null)
                    _buildContractTypeChip(ticker.contractType!, colorScheme),
                ],
              ),
              if (priceData != null) ...[
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (priceData.volume24h != null)
                      Text(
                        '24h Vol: ${_formatVolume(priceData.volume24h!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    if (priceData.highPrice24h != null &&
                        priceData.lowPrice24h != null)
                      Text(
                        'H: ${_formatNumberWithCommas(priceData.highPrice24h)} L: ${_formatNumberWithCommas(priceData.lowPrice24h)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriceColor(PriceDirection direction, ColorScheme colorScheme) {
    switch (direction) {
      case PriceDirection.up:
        return Colors.green;
      case PriceDirection.down:
        return Colors.red;
      case PriceDirection.neutral:
        return colorScheme.onSurface;
    }
  }

  String _formatVolume(String volume) {
    final value = double.tryParse(volume);
    if (value == null) return volume;

    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    }
    return value.toStringAsFixed(2);
  }

  String _formatNumberWithCommas(String? numberString) {
    if (numberString == null || numberString.isEmpty) {
      return '-';
    }
    final double? value = double.tryParse(numberString);
    if (value == null) {
      return numberString;
    }
    // Create a NumberFormat instance for formatting with commas.
    final formatter = NumberFormat('#,##0.########');
    return formatter.format(value);
  }

  String _getIntegratedSymbol(IntegratedTickerPriceData ticker) {
    String baseSymbol;
    if (ticker.quantity != null && ticker.quantity != 1.0) {
      baseSymbol = '${ticker.quantity}${ticker.baseCode}/${ticker.quoteCode}';
    } else {
      baseSymbol = '${ticker.baseCode}/${ticker.quoteCode}';
    }

    return baseSymbol;
  }

  

  Widget _buildCategoryBadge(String category, ColorScheme colorScheme) {
    Color color;
    switch (category.toLowerCase()) {
      case 'spot':
        color = Colors.green;
        break;
      case 'linear':
        color = Colors.blue;
        break;
      case 'inverse':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    final color = status == 'Trading' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildContractTypeChip(String contractType, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withAlpha(76)),
      ),
      child: Text(
        contractType,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  
}
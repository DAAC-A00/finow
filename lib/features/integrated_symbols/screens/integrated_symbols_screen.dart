import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/integrated_instrument.dart';
import '../providers/integrated_symbols_provider.dart';

/// 통합 심볼 정보 조회 화면
class IntegratedSymbolsScreen extends ConsumerStatefulWidget {
  const IntegratedSymbolsScreen({super.key});

  @override
  ConsumerState<IntegratedSymbolsScreen> createState() => _IntegratedSymbolsScreenState();
}

class _IntegratedSymbolsScreenState extends ConsumerState<IntegratedSymbolsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedExchange = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 화면 진입 시 저장된 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(integratedSymbolsProvider.notifier).loadStoredInstruments();
    });
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
        title: const Text('통합 심볼 정보'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: '전체', icon: Icon(Icons.list)),
            Tab(text: 'Bybit', icon: Icon(Icons.currency_bitcoin)),
            Tab(text: 'Bithumb', icon: Icon(Icons.account_balance)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
            tooltip: '데이터 새로고침',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _clearStoredData();
                  break;
                case 'info':
                  _showInfoDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('저장된 데이터 삭제'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('정보'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(colorScheme),
          _buildFilterChips(colorScheme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInstrumentsList('all'),
                _buildInstrumentsList('bybit'),
                _buildInstrumentsList('bithumb'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _refreshData(),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.cloud_download),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withAlpha((255 * 0.2).round()),
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '심볼, 코인명으로 검색...',
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withAlpha((255 * 0.6).round())),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withAlpha((255 * 0.5).round())),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary),
          ),
          filled: true,
          fillColor: colorScheme.surface,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '상태 필터:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('전체', 'all', colorScheme),
                  const SizedBox(width: 8),
                  _buildFilterChip('거래중', 'Trading', colorScheme),
                  const SizedBox(width: 8),
                  _buildFilterChip('경고', 'Warning', colorScheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, ColorScheme colorScheme) {
    final isSelected = _selectedExchange == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedExchange = selected ? value : 'all';
        });
      },
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary.withAlpha((255 * 0.2).round()),
      checkmarkColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? colorScheme.primary : colorScheme.outline.withAlpha((255 * 0.5).round()),
      ),
    );
  }

  Widget _buildInstrumentsList(String exchange) {
    return Consumer(
      builder: (context, ref, child) {
        final symbolsState = ref.watch(integratedSymbolsProvider);
        
        return symbolsState.when(
          data: (instruments) {
            final filteredInstruments = _filterInstruments(instruments, exchange);
            
            if (filteredInstruments.isEmpty) {
              return _buildEmptyState();
            }
            
            return RefreshIndicator(
              onRefresh: () => _refreshData(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredInstruments.length,
                itemBuilder: (context, index) {
                  final instrument = filteredInstruments[index];
                  return _buildInstrumentCard(instrument);
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
                Text('심볼 정보를 불러오는 중...'),
              ],
            ),
          ),
          error: (error, stackTrace) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  List<IntegratedInstrument> _filterInstruments(List<IntegratedInstrument> instruments, String exchange) {
    var filtered = instruments;
    
    // 거래소 필터링
    if (exchange != 'all') {
      filtered = filtered.where((instrument) => instrument.exchange == exchange).toList();
    }
    
    // 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((instrument) {
        return instrument.symbol.toLowerCase().contains(query) ||
               instrument.baseCoin.toLowerCase().contains(query) ||
               instrument.quoteCoin.toLowerCase().contains(query) ||
               (instrument.koreanName?.toLowerCase().contains(query) ?? false) ||
               (instrument.englishName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    // 상태 필터링
    if (_selectedExchange == 'Trading') {
      filtered = filtered.where((instrument) => instrument.status == 'Trading').toList();
    } else if (_selectedExchange == 'Warning') {
      filtered = filtered.where((instrument) => 
          instrument.marketWarning != null && 
          instrument.marketWarning != 'NONE').toList();
    }
    
    return filtered;
  }

  Widget _buildInstrumentCard(IntegratedInstrument instrument) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: colorScheme.surface,
      child: InkWell(
        onTap: () => _showInstrumentDetails(instrument),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          instrument.symbol,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (instrument.koreanName != null)
                          Text(
                            instrument.koreanName!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildExchangeBadge(instrument.exchange, colorScheme),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip('${instrument.baseCoin}/${instrument.quoteCoin}', colorScheme),
                  const SizedBox(width: 8),
                  _buildStatusChip(instrument.status, colorScheme),
                  if (instrument.marketWarning != null && instrument.marketWarning != 'NONE')
                    ...[
                      const SizedBox(width: 8),
                      _buildWarningChip(instrument.marketWarning!, colorScheme),
                    ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExchangeBadge(String exchange, ColorScheme colorScheme) {
    final color = exchange == 'bybit' ? Colors.orange : Colors.blue;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((255 * 0.3).round())),
      ),
      child: Text(
        exchange.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha((255 * 0.3).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurface.withAlpha((255 * 0.8).round()),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    final color = status == 'Trading' ? Colors.green : Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildWarningChip(String warning, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '경고',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: colorScheme.onSurface.withAlpha((255 * 0.4).round()),
          ),
          const SizedBox(height: 16),
          Text(
            '심볼 정보가 없습니다',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로고침 버튼을 눌러 데이터를 불러오세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withAlpha((255 * 0.5).round()),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _refreshData(),
            icon: const Icon(Icons.refresh),
            label: const Text('데이터 불러오기'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withAlpha((255 * 0.7).round()),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _refreshData(),
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    try {
      await ref.read(integratedSymbolsProvider.notifier).fetchAndSaveInstruments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('데이터를 성공적으로 업데이트했습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 업데이트 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearStoredData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 삭제'),
        content: const Text('저장된 모든 심볼 정보를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(integratedSymbolsProvider.notifier).clearStoredData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('저장된 데이터를 삭제했습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('데이터 삭제 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('통합 심볼 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Bybit과 Bithumb의 심볼 정보를 통합하여 제공합니다'),
            SizedBox(height: 8),
            Text('• 데이터는 로컬 스토리지에 저장되어 오프라인에서도 조회 가능합니다'),
            SizedBox(height: 8),
            Text('• 새로고침을 통해 최신 데이터로 업데이트할 수 있습니다'),
            SizedBox(height: 8),
            Text('• 검색 및 필터링 기능을 제공합니다'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showInstrumentDetails(IntegratedInstrument instrument) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(instrument.symbol),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('거래소', instrument.exchange.toUpperCase()),
              _buildDetailRow('기본 코인', instrument.baseCoin),
              _buildDetailRow('견적 코인', instrument.quoteCoin),
              _buildDetailRow('상태', instrument.status),
              if (instrument.koreanName != null)
                _buildDetailRow('한국어명', instrument.koreanName!),
              if (instrument.englishName != null)
                _buildDetailRow('영어명', instrument.englishName!),
              if (instrument.marketWarning != null)
                _buildDetailRow('경고', instrument.marketWarning!),
              if (instrument.priceFilter != null)
                _buildDetailRow('틱 사이즈', instrument.priceFilter!.tickSize),
              if (instrument.lotSizeFilter != null) ...[
                _buildDetailRow('최소 주문량', instrument.lotSizeFilter!.minOrderQty),
                _buildDetailRow('최대 주문량', instrument.lotSizeFilter!.maxOrderQty),
                _buildDetailRow('최소 주문금액', instrument.lotSizeFilter!.minOrderAmt),
                _buildDetailRow('최대 주문금액', instrument.lotSizeFilter!.maxOrderAmt),
              ],
              _buildDetailRow('업데이트 시간', 
                  '${instrument.lastUpdated.year}-${instrument.lastUpdated.month.toString().padLeft(2, '0')}-${instrument.lastUpdated.day.toString().padLeft(2, '0')} ${instrument.lastUpdated.hour.toString().padLeft(2, '0')}:${instrument.lastUpdated.minute.toString().padLeft(2, '0')}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

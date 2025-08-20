import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/instruments/models/instrument.dart';
import 'package:finow/features/storage_viewer/local_storage_service.dart';
import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/storage_viewer/api_keys_storage_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:finow/features/storage_viewer/edit_storage_entry_screen.dart';


// 검색어를 관리하는 StateProvider
final searchQueryProvider = StateProvider<String>((ref) => '');

// 모든 Hive Box 데이터를 비동기적으로 가져오는 FutureProvider
final allStorageDataProvider = FutureProvider<Map<String, Map>>((ref) {
  return ref.watch(localStorageServiceProvider).getAllBoxes();
});

// 총 스토리지 사용량을 비동기적으로 가져오는 FutureProvider
final storageUsageProvider = FutureProvider<int>((ref) {
  return ref.watch(localStorageServiceProvider).getTotalStorageUsage();
});

// 각 탭의 아이템 수를 제공하는 Provider
final settingsItemCountProvider = Provider<AsyncValue<int>>((ref) {
  final allData = ref.watch(allStorageDataProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return allData.whenData((data) {
    final boxData = data['settings'] ?? {};
    final filteredData = boxData.entries.where((entry) {
      final key = entry.key.toString().toLowerCase();
      // instruments_last_update 키는 제외
      if (key == 'instruments_last_update') return false;
      final value = entry.value;
      final query = searchQuery.toLowerCase();
      final valueString = value.toString().toLowerCase();
      return key.contains(query) || valueString.contains(query);
    }).toList();
    return filteredData.length;
  });
});

final exchangeRatesItemCountProvider = Provider<AsyncValue<int>>((ref) {
  final allData = ref.watch(allStorageDataProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return allData.whenData((data) {
    final boxData = data['exchangeRates'] ?? {};
    final filteredData = boxData.entries.where((entry) {
      final key = entry.key.toString().toLowerCase();
      final value = entry.value;
      final query = searchQuery.toLowerCase();
      if (value is ExchangeRate) {
        final combinedCode = (value.baseCode + value.quoteCode).toLowerCase();
        final priceString = value.price.toString();
        final sourceString = value.source.toLowerCase();
        return key.contains(query) ||
            combinedCode.contains(query) ||
            priceString.contains(query) ||
            sourceString.contains(query);
      }
      final valueString = value.toString().toLowerCase();
      return key.contains(query) || valueString.contains(query);
    }).toList();
    return filteredData.length;
  });
});

final symbolsItemCountProvider = Provider<AsyncValue<int>>((ref) {
  final allData = ref.watch(allStorageDataProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return allData.whenData((data) {
    final boxData = data['instruments'] ?? {};
    final filteredData = boxData.entries.where((entry) {
      final key = entry.key.toString().toLowerCase();
      final value = entry.value;
      final query = searchQuery.toLowerCase();
      if (value is Instrument) {
        final symbolString = value.symbol.toLowerCase();
        final baseCoinString = value.baseCoin.toLowerCase();
        final quoteCoinString = value.quoteCoin.toLowerCase();
        final exchangeString = value.exchange.toLowerCase();
        final statusString = value.status.toLowerCase();
        final koreanNameString = (value.koreanName ?? '').toLowerCase();
        final englishNameString = (value.englishName ?? '').toLowerCase();
        final categoryString = (value.category ?? '').toLowerCase();

        return key.contains(query) ||
            symbolString.contains(query) ||
            baseCoinString.contains(query) ||
            quoteCoinString.contains(query) ||
            exchangeString.contains(query) ||
            statusString.contains(query) ||
            koreanNameString.contains(query) ||
            englishNameString.contains(query) ||
            categoryString.contains(query);
      }
      final valueString = value.toString().toLowerCase();
      return key.contains(query) || valueString.contains(query);
    }).toList();
    return filteredData.length;
  });
});

final apiKeysItemCountProvider = Provider<AsyncValue<int>>((ref) {
  final apiKeysAsync = ref.watch(apiKeyListProvider);
  return apiKeysAsync.whenData((apiKeys) => apiKeys.length);
});

class StorageViewerScreen extends ConsumerStatefulWidget {
  const StorageViewerScreen({super.key});

  @override
  ConsumerState<StorageViewerScreen> createState() => _StorageViewerScreenState();
}

class _StorageViewerScreenState extends ConsumerState<StorageViewerScreen> 
    with RouteAware, TickerProviderStateMixin {
  late final TextEditingController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteObserver 등록
    final routeObserver = ModalRoute.of(context)?.navigator?.widget.observers.whereType<RouteObserver<PageRoute>>().firstOrNull;
    routeObserver?.subscribe(this, ModalRoute.of(context)! as PageRoute);
    // 최초 진입 시에도 invalidate
    ref.invalidate(allStorageDataProvider);
  }

  @override
  void didPopNext() {
    // 다른 화면에서 다시 돌아올 때마다 invalidate
    ref.invalidate(allStorageDataProvider);
  }

  // 웹 기준 최대 저장 용량 (10MB)
  static const double maxStorageMB = 10.0;
  static const int maxStorageBytes = 10 * 1024 * 1024; // 10MB를 바이트로 변환

  @override
  Widget build(BuildContext context) {
    final asyncUsage = ref.watch(storageUsageProvider);
    final localStorageService = ref.watch(localStorageServiceProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    if (_controller.text != searchQuery) {
      _controller.text = searchQuery;
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
                title: const Text('Local Storage Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Local Storage Viewer Information',
            onPressed: () => _showInfoBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search local storage...', 
                border: const OutlineInputBorder(),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).state = '';
                          _controller.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          asyncUsage.when(
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Usage Error: $err'),
            ),
            data: (currentBytes) {
              final currentMB = currentBytes / (1024 * 1024);
              final percentage = (currentBytes / maxStorageBytes) * 100;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage Usage: ${currentMB.toStringAsFixed(2)} MB / ${maxStorageMB.toStringAsFixed(2)} MB (${percentage.toStringAsFixed(2)}%)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          Consumer(
            builder: (context, ref, child) {
              return TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.settings),
                    text: 'Settings',
                  ),
                  Tab(
                    icon: const Icon(Icons.attach_money),
                    text: 'Exchange Rates',
                  ),
                  Tab(
                    icon: const Icon(Icons.currency_exchange),
                    text: 'Instruments',
                  ),
                  Tab(
                    icon: const Icon(Icons.vpn_key),
                    text: 'API Keys',
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBoxContent('settings', localStorageService, searchQuery),
                _buildBoxContent('exchangeRates', localStorageService, searchQuery),
                _buildBoxContent('instruments', localStorageService, searchQuery),
                const ApiKeysStorageView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 삭제 확인 대화상자
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref,
      LocalStorageService localStorageService, String boxName, dynamic key) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Data'),
          content: Text('Are you sure you want to delete \'$key\'?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await localStorageService.deleteEntry(boxName, key);
      ref.invalidate(allStorageDataProvider);
      ref.invalidate(storageUsageProvider);
    }
  }

  // Box 전체 삭제 확인 대화상자
  Future<void> _clearBox(BuildContext context, WidgetRef ref,
      LocalStorageService localStorageService, String boxName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Box Data'),
          content: Text('Are you sure you want to delete all data in \'$boxName\' Box? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await localStorageService.clearBox(boxName);
      ref.invalidate(allStorageDataProvider);
      ref.invalidate(storageUsageProvider);
    }
  }

  

  void _showInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.3).round()),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Local Storage Viewer Information',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "This screen allows you to view and manage data stored in the application's local storage (Hive boxes).",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Key features:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoPoint('Search: Filter data by key or value.'),
                      _buildInfoPoint('Storage Usage: Monitor the total storage used by Hive boxes.'),
                      _buildInfoPoint('Box-specific views: View data for different categories (Settings, Exchange Rates, Instruments, API Keys).'),
                      _buildInfoPoint('Data Management: Edit or delete individual entries, or clear all data within a specific box.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: Theme.of(context).textTheme.bodyLarge),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  // 각 Box의 데이터를 개별적으로 표시하는 메서드
  Widget _buildBoxContent(String boxName, LocalStorageService localStorageService, String searchQuery) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getBoxData(boxName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Box 데이터 로드 오류',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        final boxData = snapshot.data ?? {};
        
        // 검색 쿼리로 필터링
        final filteredData = boxData.entries.where((entry) {
          final key = entry.key.toString().toLowerCase();
          // instruments_last_update 키는 제외
          if (key == 'instruments_last_update') return false;
          final value = entry.value;
          final query = searchQuery.toLowerCase();
          
          if (value is ExchangeRate) {
            final combinedCode = (value.baseCode + value.quoteCode).toLowerCase();
            final priceString = value.price.toString();
            final sourceString = value.source.toLowerCase();
            return key.contains(query) ||
                combinedCode.contains(query) ||
                priceString.contains(query) ||
                sourceString.contains(query);
          }
          
          if (value is Instrument) {
            final symbolString = value.symbol.toLowerCase();
            final baseCoinString = value.baseCoin.toLowerCase();
            final quoteCoinString = value.quoteCoin.toLowerCase();
            final exchangeString = value.exchange.toLowerCase();
            final statusString = value.status.toLowerCase();
            final koreanNameString = (value.koreanName ?? '').toLowerCase();
            final englishNameString = (value.englishName ?? '').toLowerCase();
            final categoryString = (value.category ?? '').toLowerCase();
            
            return key.contains(query) ||
                symbolString.contains(query) ||
                baseCoinString.contains(query) ||
                quoteCoinString.contains(query) ||
                exchangeString.contains(query) ||
                statusString.contains(query) ||
                koreanNameString.contains(query) ||
                englishNameString.contains(query) ||
                categoryString.contains(query);
          }
          
          final valueString = value.toString().toLowerCase();
          return key.contains(query) || valueString.contains(query);
        }).toList();
        
        return Column(
          children: [
            // Box 헤더
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$boxName',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(filteredData.length)} items',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () => _clearBox(context, ref, localStorageService, boxName),
                    tooltip: 'Clear all data in this box',
                  ),
                ],
              ),
            ),
            const Divider(),
            // 데이터 목록 또는 검색 결과 없음 메시지
            Expanded(
              child: filteredData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.isEmpty ? '$boxName Box가 비어있습니다' : '검색 결과가 없습니다',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final entry = filteredData[index];
                        final key = entry.key;
                        final value = entry.value;
                        
                        Widget subtitleWidget;
                        if (value is ExchangeRate) {
                          subtitleWidget = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('base_code: ${value.baseCode}'),
                              Text('quote_code: ${value.quoteCode}'),
                              Text('price: ${value.price}'),
                              Text('source: ${value.source}'),
                              Text('time_last_update_unix: ${value.lastUpdatedUnix}'),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                child: Text(
                                  '└ Converted: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(value.lastUpdatedUnix * 1000).toLocal())} (KST)',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(204),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (value is Instrument) {
                          subtitleWidget = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 기본 정보
                              Text('symbol: ${value.symbol}'),
                              Text('baseCoin: ${value.baseCoin}'),
                              Text('quoteCoin: ${value.quoteCoin}'),
                              Text('exchange: ${value.exchange}'),
                              Text('status: ${value.status}'),
                              if (value.category != null) Text('category: ${value.category}'),
                              if (value.koreanName != null) Text('koreanName: ${value.koreanName}'),
                              if (value.englishName != null) Text('englishName: ${value.englishName}'),
                              if (value.marketWarning != null) Text('marketWarning: ${value.marketWarning}'),
                              
                              // Price Filter 정보
                              if (value.priceFilter != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('priceFilter:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text('tickSize: ${value.priceFilter!.tickSize}'),
                                      ),
                                    ],
                                  ),
                                ),

                              // Lot Size Filter 정보
                              if (value.lotSizeFilter != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('lotSizeFilter:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('basePrecision: ${value.lotSizeFilter!.basePrecision}'),
                                            Text('quotePrecision: ${value.lotSizeFilter!.quotePrecision}'),
                                            Text('minOrderQty: ${value.lotSizeFilter!.minOrderQty}'),
                                            Text('maxOrderQty: ${value.lotSizeFilter!.maxOrderQty}'),
                                            Text('minOrderAmt: ${value.lotSizeFilter!.minOrderAmt}'),
                                            Text('maxOrderAmt: ${value.lotSizeFilter!.maxOrderAmt}'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // 마지막 업데이트 시간
                              Text('lastUpdated: ${value.lastUpdated.toIso8601String()}'),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                child: Text(
                                  '└ Converted: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(value.lastUpdated.toLocal())} (KST)',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(204),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          subtitleWidget = Text(value.toString());
                        }
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          elevation: 1.0,
                          child: ListTile(
                            title: Text(key.toString()),
                            subtitle: subtitleWidget,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditStorageEntryScreen(
                                          boxName: boxName,
                                          originalKey: key,
                                          originalValue: value,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _confirmDelete(
                                    context, ref, localStorageService, boxName, key),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // 특정 Box의 데이터를 가져오는 헬퍼 메서드
  Future<Map<String, dynamic>> _getBoxData(String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        // Box가 열려 있지 않으면 데이터를 가져올 수 없습니다.
        return {};
      }
      
      final Map<String, dynamic> data = {};
      
      // Box 타입에 따라 안전하게 데이터 접근
      if (boxName == 'exchangeRates') {
        // ExchangeRate 타입의 Box 처리
        final box = Hive.box<ExchangeRate>(boxName);
        for (var key in box.keys) {
          final value = box.get(key);
          if (value != null) {
            data[key.toString()] = value;
          }
        }
      } else if (boxName == 'instruments') {
        // Instrument 타입의 Box 처리
        final box = Hive.box<Instrument>(boxName);
        for (var key in box.keys) {
          final value = box.get(key);
          if (value != null) {
            data[key.toString()] = value;
          }
        }
      } else {
        // 일반 Box 처리
        final box = Hive.box(boxName);
        for (var key in box.keys) {
          data[key.toString()] = box.get(key);
        }
      }
      
      return data;
    } catch (e) {
      throw Exception('Failed to load $boxName box data: $e');
    }
  }
}

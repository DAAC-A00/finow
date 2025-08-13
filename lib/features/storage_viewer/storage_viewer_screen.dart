import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/integrated_symbols/models/integrated_instrument.dart';
import 'package:finow/features/storage_viewer/local_storage_service.dart';
import 'package:finow/features/storage_viewer/api_keys_storage_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:finow/ui_scale_provider.dart';

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
        title: TextField(
          controller: _controller,
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
          decoration: const InputDecoration(
            hintText: 'Search local storage...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Box 목록 보기',
            onPressed: () => _showBoxListBottomSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
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
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(
                icon: Icon(Icons.settings),
                text: 'Settings',
              ),
              Tab(
                icon: Icon(Icons.attach_money),
                text: 'Exchange Rates',
              ),
              Tab(
                icon: Icon(Icons.currency_exchange),
                text: 'Symbols',
              ),
              Tab(
                icon: Icon(Icons.vpn_key),
                text: 'API Keys',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBoxContent('settings', localStorageService, searchQuery),
                _buildBoxContent('exchangeRates', localStorageService, searchQuery),
                _buildBoxContent('integrated_instruments', localStorageService, searchQuery),
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

  // 수정 대화상자
  Future<void> _showEditDialog(BuildContext context, WidgetRef ref,
      LocalStorageService localStorageService, String boxName, dynamic key, dynamic value) async {
    TextEditingController genericController = TextEditingController(text: value.toString());
    bool? boolValue = value is bool ? value : null;

    // ExchangeRate 전용 컨트롤러들
    TextEditingController lastUpdatedUnixController = TextEditingController();
    TextEditingController baseCodeController = TextEditingController();
    TextEditingController quoteCodeController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    if (value is ExchangeRate) {
      lastUpdatedUnixController.text = value.lastUpdatedUnix.toString();
      baseCodeController.text = value.baseCode;
      quoteCodeController.text = value.quoteCode;
      priceController.text = value.price.toString();
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $key'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value is bool)
                  SwitchListTile(
                    title: const Text('값'),
                    value: boolValue!,
                    onChanged: (newValue) {
                      boolValue = newValue;
                      if (!context.mounted) return;
                      (context as Element).markNeedsBuild(); // 다이얼로그 내부 UI 갱신
                    },
                  )
                else if (value is ExchangeRate)
                  Column(
                    children: [
                      TextField(
                        controller: lastUpdatedUnixController,
                        decoration: const InputDecoration(labelText: 'Last Updated (Unix)'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: baseCodeController,
                        decoration: const InputDecoration(labelText: 'Base Code'),
                      ),
                      TextField(
                        controller: quoteCodeController,
                        decoration: const InputDecoration(labelText: 'Quote Code'),
                      ),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  )
                else
                  TextField(
                    controller: genericController,
                    decoration: const InputDecoration(labelText: '값'),
                    keyboardType: value is int || value is double
                        ? TextInputType.number
                        : TextInputType.text,
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                dynamic newValue;
                if (value is bool) {
                  newValue = boolValue;
                } else if (value is int) {
                  newValue = int.tryParse(genericController.text);
                } else if (value is double) {
                  newValue = double.tryParse(genericController.text);
                } else if (value is ExchangeRate) {
                  newValue = ExchangeRate(
                    lastUpdatedUnix: int.tryParse(lastUpdatedUnixController.text) ?? value.lastUpdatedUnix,
                    baseCode: baseCodeController.text,
                    quoteCode: quoteCodeController.text,
                    price: double.tryParse(priceController.text) ?? value.price,
                    source: value.source, // 기존 source 값 유지
                  );
                } else {
                  newValue = genericController.text;
                }

                if (newValue != null) {
                  if (!context.mounted) return;
                  await localStorageService.updateEntry(boxName, key, newValue);
                  ref.invalidate(allStorageDataProvider);
                  ref.invalidate(storageUsageProvider);
                  Navigator.of(context).pop();
                } else {
                  final currentContext = context;
                  if (!currentContext.mounted) return;
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(content: Text('유효하지 않은 값입니다.')),
                  );
                }
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  /// Box 목록을 보여주는 Bottom Sheet
  void _showBoxListBottomSheet(BuildContext context, WidgetRef ref) {
    final localStorageService = ref.watch(localStorageServiceProvider);
    
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
                'Hive Box 목록',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _getBoxNames(),
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
                              '오류가 발생했습니다',
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
                    
                    final boxNames = snapshot.data ?? [];
                    
                    if (boxNames.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '등록된 Box가 없습니다',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: boxNames.length,
                      itemBuilder: (context, index) {
                        final boxName = boxNames[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.1).round()),
                              child: Icon(
                                Icons.storage,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              boxName,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: FutureBuilder<int>(
                              future: _getBoxItemCount(boxName),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text('${snapshot.data}개 항목');
                                }
                                return const Text('로딩 중...');
                              },
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () => _showBoxInfo(context, boxName),
                                  tooltip: 'Box 정보',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _confirmDeleteBox(context, ref, boxName),
                                  tooltip: 'Box 삭제',
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // 해당 Box의 데이터만 필터링하여 표시하는 기능 추가 가능
                              _filterByBox(ref, boxName);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 모든 Box 이름 가져오기
  Future<List<String>> _getBoxNames() async {
    try {
      // 알려진 Box 이름들을 확인하여 존재하는 것들만 반환
      final knownBoxes = <String>[];
      
      // 기존에 알려진 Box들 확인
      final commonBoxNames = [
        'exchangeRates',
        'settings',
        'integrated_instruments',
        'ui_scale',
        'font_size',
        'theme_mode',
      ];
      
      for (final boxName in commonBoxNames) {
        try {
          if (await Hive.boxExists(boxName)) {
            knownBoxes.add(boxName);
          }
        } catch (_) {
          // 개별 Box 확인 실패는 무시
        }
      }
      
      return knownBoxes;
    } catch (e) {
      // 오류 발생 시 빈 리스트 반환
      return [];
    }
  }

  /// 특정 Box의 항목 개수 가져오기
  Future<int> _getBoxItemCount(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        // Box 타입에 따라 안전하게 접근
        if (boxName == 'exchangeRates') {
          final box = Hive.box<ExchangeRate>(boxName);
          return box.length;
        } else {
          final box = Hive.box(boxName);
          return box.length;
        }
      } else {
        // Box가 열려 있지 않으면 0을 반환
        return 0;
      }
    } catch (e) {
      // 오류 발생 시 0을 반환
      return 0;
    }
  }

  /// Box 정보 다이얼로그 표시
  void _showBoxInfo(BuildContext context, String boxName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Box 정보: $boxName'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: _getBoxInfo(boxName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (snapshot.hasError) {
              return Text('오류: ${snapshot.error}');
            }
            
            final details = snapshot.data ?? {};
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Box 이름: $boxName'),
                const SizedBox(height: 8),
                Text('항목 개수: ${details['itemCount'] ?? 0}'),
                const SizedBox(height: 8),
                Text('열린 상태: ${details['isOpen'] ? '예' : '아니오'}'),
                if (details['path'] != null) ...[
                  const SizedBox(height: 8),
                  Text('경로: ${details['path']}'),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  /// Box 세부 정보 가져오기
  Future<Map<String, dynamic>> _getBoxInfo(String boxName) async {
    try {
      final isOpen = Hive.isBoxOpen(boxName);
      
      if (!isOpen) {
        // Box가 열려 있지 않으면 정보를 가져올 수 없습니다.
        return {'itemCount': 0, 'isOpen': false, 'path': 'Box not open'};
      }
      
      // Box 타입에 따라 안전하게 접근
      if (boxName == 'exchangeRates') {
        final box = Hive.box<ExchangeRate>(boxName);
        return {
          'itemCount': box.length,
          'isOpen': isOpen,
          'path': box.path,
        };
      } else {
        final box = Hive.box(boxName);
        return {
          'itemCount': box.length,
          'isOpen': isOpen,
          'path': box.path,
        };
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Box 삭제 확인 다이얼로그
  Future<void> _confirmDeleteBox(BuildContext context, WidgetRef ref, String boxName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Box 삭제'),
        content: Text('"$boxName" Box를 완전히 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Hive.deleteBoxFromDisk(boxName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"$boxName" Box가 삭제되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
          // 데이터 새로고침
          ref.invalidate(allStorageDataProvider);
          ref.invalidate(storageUsageProvider);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Box 삭제 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 특정 Box로 필터링
  void _filterByBox(WidgetRef ref, String boxName) {
    // 검색어에 Box 이름을 설정하여 필터링 효과
    ref.read(searchQueryProvider.notifier).state = boxName;
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
          
          if (value is IntegratedInstrument) {
            final symbolString = value.symbol.toLowerCase();
            final baseCoinString = value.baseCoin.toLowerCase();
            final quoteCoinString = value.quoteCoin.toLowerCase();
            final exchangeString = value.exchange.toLowerCase();
            final statusString = value.status.toLowerCase();
            final koreanNameString = (value.koreanName ?? '').toLowerCase();
            final englishNameString = (value.englishName ?? '').toLowerCase();
            
            return key.contains(query) ||
                symbolString.contains(query) ||
                baseCoinString.contains(query) ||
                quoteCoinString.contains(query) ||
                exchangeString.contains(query) ||
                statusString.contains(query) ||
                koreanNameString.contains(query) ||
                englishNameString.contains(query);
          }
          
          final valueString = value.toString().toLowerCase();
          return key.contains(query) || valueString.contains(query);
        }).toList();
        
        if (filteredData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty ? '$boxName Box가 비어있습니다' : '검색 결과가 없습니다',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            // Box 헤더
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$boxName (${filteredData.length} items)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const ScaledIcon(Icons.clear_all, size: 24),
                    onPressed: () => _clearBox(context, ref, localStorageService, boxName),
                    tooltip: 'Clear all data in this box',
                  ),
                ],
              ),
            ),
            const Divider(),
            // 데이터 목록
            Expanded(
              child: ListView.builder(
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
                  } else if (value is IntegratedInstrument) {
                    subtitleWidget = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 기본 정보
                        Text('symbol: ${value.symbol}'),
                        Text('baseCoin: ${value.baseCoin}'),
                        Text('quoteCoin: ${value.quoteCoin}'),
                        Text('exchange: ${value.exchange}'),
                        Text('status: ${value.status}'),
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
                            icon: const ScaledIcon(Icons.edit, size: 20),
                            onPressed: () => _showEditDialog(
                              context, ref, localStorageService, boxName, key, value),
                          ),
                          IconButton(
                            icon: const ScaledIcon(Icons.delete, size: 20),
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
      } else if (boxName == 'integrated_instruments') {
        // IntegratedInstrument 타입의 Box 처리
        final box = Hive.box<IntegratedInstrument>(boxName);
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
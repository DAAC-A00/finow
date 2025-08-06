import 'dart:convert';

import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/storage_viewer/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class StorageViewerScreen extends ConsumerWidget {
  const StorageViewerScreen({super.key});

  // 웹 기준 최대 저장 용량 (10MB)
  static const double maxStorageMB = 10.0;
  static const int maxStorageBytes = 10 * 1024 * 1024; // 10MB를 바이트로 변환

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(allStorageDataProvider);
    final asyncUsage = ref.watch(storageUsageProvider);
    final localStorageService = ref.watch(localStorageServiceProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: TextField(
          onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
          decoration: const InputDecoration(
            hintText: 'Search local storage...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // 스토리지 사용량 표시 위젯
          asyncUsage.when(
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => Text('Usage Error: $err'),
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
                      backgroundColor: Colors.grey[300],
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          // 저장된 데이터 목록
          Expanded(
            child: asyncData.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (allBoxes) {
                if (allBoxes.isEmpty) {
                  return const Center(child: Text('No data in any box.'));
                }

                final List<Widget> allDisplayWidgets = [];

                allBoxes.entries.forEach((boxEntry) {
                  final boxName = boxEntry.key;
                  final boxData = boxEntry.value;
                  List<Widget> boxContentWidgets = [];

                  // Filter box data based on search query
                  final filteredBoxData = boxData.entries.where((entry) {
                    final key = entry.key.toString().toLowerCase();
                    final value = entry.value;
                    final query = searchQuery.toLowerCase();

                    if (value is ExchangeRate) {
                      final combinedCode = (value.baseCode + value.quoteCode).toLowerCase();
                      final rateString = value.rate.toString();
                      return key.contains(query) ||
                          combinedCode.contains(query) ||
                          rateString.contains(query) ||
                          boxName.toLowerCase().contains(query);
                    }

                    final valueString = value.toString().toLowerCase();
                    return key.contains(query) || valueString.contains(query) || boxName.toLowerCase().contains(query);
                  }).toList();

                  // Only add box header if there's matching data or box name matches
                  if (filteredBoxData.isNotEmpty || boxName.toLowerCase().contains(searchQuery.toLowerCase())) {
                    boxContentWidgets.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Box: $boxName',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear_all, size: 24),
                              onPressed: () => _clearBox(context, ref, localStorageService, boxName),
                              tooltip: 'Clear all data in this box',
                            ),
                          ],
                        ),
                      ),
                    );

                    if (filteredBoxData.isEmpty) {
                      boxContentWidgets.add(const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text('No matching data in this box.'),
                      ));
                    } else {
                      filteredBoxData.forEach((entry) {
                        final key = entry.key;
                        final value = entry.value;
                        Widget subtitleWidget;

                        if (value is ExchangeRate) {
                          subtitleWidget = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Base: ${value.baseCode}'),
                              Text('Quote: ${value.quoteCode}'),
                              Text('Rate: ${value.rate.toStringAsFixed(4)}'),
                              Text('Quantity: ${value.quantity}'),
                              Text('Last Updated: ${DateTime.fromMillisecondsSinceEpoch(value.lastUpdatedUnix * 1000).toString()}'),
                            ],
                          );
                        } else {
                          subtitleWidget = Text(value.toString());
                        }

                        boxContentWidgets.add(
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            elevation: 1.0,
                            child: ListTile(
                              title: Text(key.toString()),
                              subtitle: subtitleWidget,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _showEditDialog(
                                        context, ref, localStorageService, boxName, key, value),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _confirmDelete(
                                        context, ref, localStorageService, boxName, key),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    }
                    boxContentWidgets.add(const Divider()); // Add a divider between boxes
                    allDisplayWidgets.addAll(boxContentWidgets);
                  }
                });

                if (allDisplayWidgets.isEmpty && searchQuery.isNotEmpty) {
                  return const Center(child: Text('No matching data found.'));
                }
                return ListView(children: allDisplayWidgets);
              },
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
          title: const Text('데이터 삭제'),
          content: Text('정말로 \'$key\' 항목을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
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
          title: const Text('Box 데이터 모두 삭제'),
          content: Text('정말로 \'$boxName\' Box의 모든 데이터를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('모두 삭제'),
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
    TextEditingController quantityController = TextEditingController();
    TextEditingController rateController = TextEditingController();

    if (value is ExchangeRate) {
      lastUpdatedUnixController.text = value.lastUpdatedUnix.toString();
      baseCodeController.text = value.baseCode;
      quoteCodeController.text = value.quoteCode;
      quantityController.text = value.quantity.toString();
      rateController.text = value.rate.toString();
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$key 항목 수정'),
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
                        controller: quantityController,
                        decoration: const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: rateController,
                        decoration: const InputDecoration(labelText: 'Rate'),
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
                    quantity: int.tryParse(quantityController.text) ?? value.quantity,
                    rate: double.tryParse(rateController.text) ?? value.rate,
                  );
                } else {
                  newValue = genericController.text;
                }

                if (newValue != null) {
                  await localStorageService.updateEntry(boxName, key, newValue);
                  ref.invalidate(allStorageDataProvider);
                  ref.invalidate(storageUsageProvider);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
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
}

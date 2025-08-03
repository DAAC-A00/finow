
import 'package:finow/features/storage_viewer/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 모든 Hive Box 데이터를 비동기적으로 가져오는 FutureProvider
final allStorageDataProvider = FutureProvider.autoDispose<Map<String, Map>>((ref) {
  return ref.watch(localStorageServiceProvider).getAllBoxes();
});

// 총 스토리지 사용량을 비동기적으로 가져오는 FutureProvider
final storageUsageProvider = FutureProvider.autoDispose<int>((ref) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Storage Viewer'),
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

                return ListView.builder(
                  itemCount: allBoxes.length,
                  itemBuilder: (context, index) {
                    final boxName = allBoxes.keys.elementAt(index);
                    final boxData = allBoxes[boxName]!;

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        title: Text(boxName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        children: boxData.entries.map((entry) {
                          return ListTile(
                            title: Text(entry.key.toString()),
                            subtitle: Text(entry.value.toString()),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

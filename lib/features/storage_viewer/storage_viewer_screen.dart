
import 'package:finow/features/storage_viewer/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 모든 Hive Box 데이터를 비동기적으로 가져오는 FutureProvider
final allStorageDataProvider = FutureProvider<Map<String, Map>>((ref) {
  return ref.watch(localStorageServiceProvider).getAllBoxes();
});

class StorageViewerScreen extends ConsumerWidget {
  const StorageViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(allStorageDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Storage Viewer'),
      ),
      body: asyncData.when(
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
                  title: Text(boxName, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
}

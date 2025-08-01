
import 'package:finow/features/storage_viewer/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageViewerScreen extends ConsumerWidget {
  const StorageViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageData = ref.watch(localStorageServiceProvider).getAll();

    // 디버그 출력: canPop() 값 확인
    print('StorageViewerScreen: Navigator.of(context).canPop() = ${Navigator.of(context).canPop()}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('로컬 스토리지 뷰어'),
        leading: Navigator.of(context).canPop() ? const BackButton() : null,
      ),
      body: storageData.isEmpty
          ? const Center(child: Text('저장된 데이터가 없습니다.'))
          : ListView.builder(
              itemCount: storageData.length,
              itemBuilder: (context, index) {
                final key = storageData.keys.elementAt(index);
                final value = storageData[key];
                return ListTile(
                  title: Text(key.toString()),
                  subtitle: Text(value.toString()),
                );
              },
            ),
    );
  }
}

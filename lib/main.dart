import 'dart:async';

import 'package:finow/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. 실시간 데이터를 시뮬레이션하는 StreamProvider 추가
// Ground Rule: WebSocket -> Stream -> UI 구조 준수
final realTimeDataProvider = StreamProvider<String>((ref) {
  return Stream.periodic(const Duration(milliseconds: 100), (count) {
    return '실시간 값: $count';
  });
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
        brightness: Brightness.dark,
      ),
      themeMode: themeMode,
      // 3. MyHomePage에서 불필요해진 title 파라미터 제거
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  // 3. 불필요해진 title 파라미터 제거
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        // 2. Consumer 위젯으로 title을 감싸서 실시간 데이터 변경 시 이 부분만 리빌드
        // Ground Rule: View 갱신 범위 제한 원칙 준수
        title: Consumer(
          builder: (context, ref, child) {
            final asyncValue = ref.watch(realTimeDataProvider);
            // Stream의 상태(data, loading, error)에 따라 다른 UI를 표시
            return asyncValue.when(
              data: (title) => Text(title),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => const Text('Error'),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              ref.read(themeModeNotifierProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'AppBar의 제목이 실시간으로 변경됩니다.',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
// 상태관리 Provider 패턴들의 실제 구현 예시를 제공합니다.
// docs/GROUND_RULES.md에서 제거된 Provider 코드 예시들을 실제로 동작하는 형태로 구현합니다.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/ui_scale_provider.dart';

// 예시용 Provider들
final counterProvider = StateProvider<int>((ref) => 0);

final asyncCounterProvider = AsyncNotifierProvider<AsyncCounterNotifier, int>(
  AsyncCounterNotifier.new,
);

class AsyncCounterNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    await Future.delayed(const Duration(seconds: 1));
    return 0;
  }

  Future<void> increment() async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(milliseconds: 500));
    final current = await future;
    state = AsyncData(current + 1);
  }
}

final exampleStateNotifierProvider = StateNotifierProvider<ExampleStateNotifier, ExampleState>(
  (ref) => ExampleStateNotifier(),
);

class ExampleState {
  final String message;
  final bool isLoading;

  const ExampleState({
    this.message = 'Initial State',
    this.isLoading = false,
  });

  ExampleState copyWith({String? message, bool? isLoading}) {
    return ExampleState(
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ExampleStateNotifier extends StateNotifier<ExampleState> {
  ExampleStateNotifier() : super(const ExampleState());

  Future<void> updateMessage(String newMessage) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(message: newMessage, isLoading: false);
  }
}

final futureExampleProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Data loaded successfully!';
});

class ProvidersGuideWidget extends ConsumerWidget {
  const ProvidersGuideWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        _buildHeaderCard('Finow Provider 패턴 예시'),
        const SizedBox(height: 16),
        
        _buildProviderExampleCard(
          title: '1. StateProvider',
          subtitle: '간단한 상태 관리 (예: 카운터, 검색어)',
          child: _buildStateProviderExample(ref),
        ),
        
        _buildProviderExampleCard(
          title: '2. AsyncNotifier',
          subtitle: '비동기 데이터 관리 (예: 환율 데이터)',
          child: _buildAsyncNotifierExample(ref),
        ),
        
        _buildProviderExampleCard(
          title: '3. StateNotifier',
          subtitle: '복잡한 상태 관리 (예: Admin Mode)',
          child: _buildStateNotifierExample(ref),
        ),
        
        _buildProviderExampleCard(
          title: '4. FutureProvider',
          subtitle: '읽기 전용 비동기 데이터',
          child: _buildFutureProviderExample(ref),
        ),
        
        _buildUsageGuideCard(),
      ],
    );
  }

  Widget _buildHeaderCard(String title) {
    return Card(
      elevation: 4.0,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ScaledIcon(
              Icons.account_tree,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            ScaledText(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const ScaledText(
              '실제 프로젝트에서 사용되는 5가지 Provider 패턴의 동작 예시',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderExampleCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ScaledIcon(Icons.code, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScaledText(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ScaledText(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStateProviderExample(WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaledText('현재 값: $counter', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => ref.read(counterProvider.notifier).state++,
                child: const ScaledText('증가'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => ref.read(counterProvider.notifier).state--,
                child: const ScaledText('감소'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => ref.read(counterProvider.notifier).state = 0,
                child: const ScaledText('리셋'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAsyncNotifierExample(WidgetRef ref) {
    final asyncCounter = ref.watch(asyncCounterProvider);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: asyncCounter.when(
        loading: () => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 8),
            ScaledText('로딩 중...'),
          ],
        ),
        error: (error, stack) => ScaledText('오류: $error', style: const TextStyle(color: Colors.red)),
        data: (value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaledText('비동기 카운터: $value', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(asyncCounterProvider.notifier).increment(),
              child: const ScaledText('비동기 증가 (0.5초 딜레이)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateNotifierExample(WidgetRef ref) {
    final exampleState = ref.watch(exampleStateNotifierProvider);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaledText('메시지: ${exampleState.message}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          if (exampleState.isLoading)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                ScaledText('업데이트 중...', style: TextStyle(color: Colors.orange)),
              ],
            )
          else
            ElevatedButton(
              onPressed: () => ref
                  .read(exampleStateNotifierProvider.notifier)
                  .updateMessage('업데이트됨 ${DateTime.now().millisecondsSinceEpoch}'),
              child: const ScaledText('메시지 업데이트'),
            ),
        ],
      ),
    );
  }

  Widget _buildFutureProviderExample(WidgetRef ref) {
    final futureData = ref.watch(futureExampleProvider);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: futureData.when(
        loading: () => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 8),
            ScaledText('데이터 로딩 중... (2초)'),
          ],
        ),
        error: (error, stack) => ScaledText('오류: $error', style: const TextStyle(color: Colors.red)),
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaledText('데이터: $data', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.refresh(futureExampleProvider),
              child: const ScaledText('데이터 새로고침'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageGuideCard() {
    return Card(
      elevation: 2.0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                ScaledIcon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                ScaledText(
                  '사용 가이드',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildGuideItem('StateProvider', '간단한 값 (int, String, bool) 저장'),
            _buildGuideItem('AsyncNotifier', '비동기 데이터 로딩/업데이트'),
            _buildGuideItem('StateNotifier', '복잡한 객체 상태 관리'),
            _buildGuideItem('FutureProvider', '읽기 전용 비동기 데이터'),
            _buildGuideItem('Provider', '서비스 인스턴스 제공'),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String provider, String usage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScaledText('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          ScaledText(
            '$provider: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          Expanded(child: ScaledText(usage)),
        ],
      ),
    );
  }
}
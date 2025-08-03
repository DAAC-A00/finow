import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // intl 패키지 임포트

class ExchangeRateScreen extends ConsumerWidget {
  const ExchangeRateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 새로운 AsyncNotifierProvider를 watch
    final asyncRate = ref.watch(exchangeRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Rate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // 새로고침 버튼을 누르면 Notifier의 refresh 메서드 호출
            onPressed: () => ref.read(exchangeRateProvider.notifier).refresh(),
          ),
        ],
      ),
      body: asyncRate.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Failed to load data.\nError: $err', textAlign: TextAlign.center),
          ),
        ),
        data: (rate) => _buildRateList(context, rate),
      ),
    );
  }

  Widget _buildRateList(BuildContext context, ExchangeRate rate) {
    final rates = rate.rates;
    final sortedKeys = rates.keys.toList()..sort();

    // UNIX 타임스탬프를 DateTime으로 변환
    final dateTime = DateTime.fromMillisecondsSinceEpoch(rate.lastUpdatedUnix * 1000);
    // 날짜 포맷터
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDateTime = formatter.format(dateTime);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Base: ${rate.baseCode} / Last Updated: $formattedDateTime',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final key = sortedKeys[index];
              return ListTile(
                title: Text(key),
                trailing: Text(rates[key].toString()),
              );
            },
          ),
        ),
      ],
    );
  }
}

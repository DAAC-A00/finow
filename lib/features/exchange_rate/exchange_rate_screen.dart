import 'package:finow/features/exchange_rate/exchange_rate_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExchangeRateScreen extends ConsumerWidget {
  const ExchangeRateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exchangeRateAsyncValue = ref.watch(exchangeRateFutureProvider);
    final localRateAsyncValue = ref.watch(localExchangeRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Rate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(exchangeRateFutureProvider),
          ),
        ],
      ),
      body: exchangeRateAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          // API 요청 실패 시 로컬 데이터 보여주기
          return localRateAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (localErr, localStack) => Center(
              child: Text('Failed to load data.\nAPI Error: $err\nLocal Error: $localErr'),
            ),
            data: (localRate) {
              if (localRate != null) {
                return _buildRateList(context, localRate, true);
              }
              return const Center(child: Text('No data available.'));
            },
          );
        },
        data: (rate) => _buildRateList(context, rate, false),
      ),
    );
  }

  Widget _buildRateList(BuildContext context, dynamic rate, bool isLocal) {
    final rates = rate.rates as Map<String, double>;
    final sortedKeys = rates.keys.toList()..sort();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Base: ${rate.baseCode} / Last Updated: ${rate.lastUpdated}'
            '${isLocal ? ' (Local Data)' : ''}',
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
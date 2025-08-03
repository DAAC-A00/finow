import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ExchangeRateScreen extends ConsumerWidget {
  const ExchangeRateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRates = ref.watch(exchangeRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Rate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(exchangeRateProvider.notifier).refresh(),
          ),
        ],
      ),
      body: asyncRates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Failed to load data.\nError: $err', textAlign: TextAlign.center),
          ),
        ),
        data: (rates) => _buildRateList(context, rates),
      ),
    );
  }

  Widget _buildRateList(BuildContext context, List<ExchangeRate> rates) {
    if (rates.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final baseCode = rates.first.baseCode;
    final lastUpdatedUnix = rates.first.lastUpdatedUnix;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdatedUnix * 1000);
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDateTime = formatter.format(dateTime);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Base: $baseCode / Last Updated: $formattedDateTime',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: rates.length,
            itemBuilder: (context, index) {
              final rate = rates[index];
              return ListTile(
                title: Text('${rate.baseCode}/${rate.quoteCode}'),
                trailing: Text(rate.rate.toString()),
              );
            },
          ),
        ),
      ],
    );
  }
}

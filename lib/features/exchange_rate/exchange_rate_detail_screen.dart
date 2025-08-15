import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finow/ui_scale_provider.dart';

class ExchangeRateDetailScreen extends StatelessWidget {
  final ExchangeRate exchangeRate;

  const ExchangeRateDetailScreen({super.key, required this.exchangeRate});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(exchangeRate.lastUpdatedUnix * 1000);
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDateTime = formatter.format(dateTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('${exchangeRate.baseCode}/${exchangeRate.quoteCode}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const ScaledIcon(Icons.show_chart, color: Colors.blueAccent),
                  title: const Text('Price'),
                  trailing: Text(
                    exchangeRate.price.toString(),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const ScaledIcon(Icons.flag, color: Colors.green),
                  title: const Text('Base Code'),
                  trailing: Text(exchangeRate.baseCode),
                ),
                ListTile(
                  leading: const ScaledIcon(Icons.flag_outlined, color: Colors.orange),
                  title: const Text('Quote Code'),
                  trailing: Text(exchangeRate.quoteCode),
                ),
                const Divider(),
                ListTile(
                  leading: const ScaledIcon(Icons.update, color: Colors.grey),
                  title: const Text('Last Updated'),
                  trailing: Text(formattedDateTime),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

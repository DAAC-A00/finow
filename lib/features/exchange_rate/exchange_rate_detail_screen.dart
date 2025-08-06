import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExchangeRateDetailScreen extends StatelessWidget {
  final ExchangeRate rate;

  const ExchangeRateDetailScreen({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(rate.lastUpdatedUnix * 1000);
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDateTime = formatter.format(dateTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('${rate.baseCode}/${rate.quoteCode}'),
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
                  leading: const Icon(Icons.show_chart, color: Colors.blueAccent),
                  title: const Text('Rate'),
                  trailing: Text(
                    rate.rate.toString(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.flag, color: Colors.green),
                  title: const Text('Base Code'),
                  trailing: Text(rate.baseCode),
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Colors.orange),
                  title: const Text('Quote Code'),
                  trailing: Text(rate.quoteCode),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.update, color: Colors.grey),
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

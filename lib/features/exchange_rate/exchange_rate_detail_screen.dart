import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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
                  leading: const Icon(Icons.show_chart, color: Colors.blueAccent),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Price'),
                      Text(
                        exchangeRate.price.toString(),
                      ),
                    ]
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.flag, color: Colors.green),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Base Code'),
                      Text(exchangeRate.baseCode),
                    ]
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Colors.orange),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quote Code'),
                      Text(exchangeRate.quoteCode),
                    ]
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.update, color: Colors.grey),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Last Updated'),
                      Text(formattedDateTime),
                    ]
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

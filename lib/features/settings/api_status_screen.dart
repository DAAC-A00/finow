import 'package:finow/features/settings/api_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiStatusScreen extends ConsumerStatefulWidget {
  const ApiStatusScreen({super.key});

  @override
  ConsumerState<ApiStatusScreen> createState() => _ApiStatusScreenState();
}

class _ApiStatusScreenState extends ConsumerState<ApiStatusScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch statuses when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(apiStatusProvider.notifier).fetchAllInstruments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiStatusState = ref.watch(apiStatusProvider);
    final statuses = apiStatusState.statuses;
    final isLoading = apiStatusState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading
                ? null
                : () => ref.read(apiStatusProvider.notifier).fetchAllInstruments(),
          ),
        ],
      ),
      body: isLoading && statuses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: statuses.keys.length,
              itemBuilder: (context, index) {
                final exchange = statuses.keys.elementAt(index);
                final status = statuses[exchange];
                return ListTile(
                  title: Text(exchange),
                  trailing: Icon(
                    status == ApiStatus.success ? Icons.check_circle : Icons.error,
                    color: status == ApiStatus.success ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
    );
  }
}
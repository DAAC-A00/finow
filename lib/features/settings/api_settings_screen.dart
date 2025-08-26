import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/settings/api_key_validation_service.dart';
import 'package:finow/features/settings/models/api_key_data.dart';
import 'package:finow/features/settings/api_key_status.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ApiSettingsScreen extends ConsumerStatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  ConsumerState<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends ConsumerState<ApiSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateAllKeys();
    });
  }

  Future<void> _validateAllKeys() async {
    final apiKeys = ref.read(apiKeyListProvider).value ?? [];
    for (final apiKeyData in apiKeys) {
      await ref.read(apiKeyStatusProvider.notifier).validateKey(apiKeyData.key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiKeyDataMap = ref.watch(apiKeyStatusProvider);
    final apiKeysAsync = ref.watch(apiKeyListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('API Key Management'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          await _validateAllKeys();
          if (!mounted) return;
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('API keys have been re-validated.'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: apiKeysAsync.when(
          data: (apiKeys) => ListView(
            children: [
              const ListTile(
                title: Text(
                  'V6 Exchange Rate API',
                ),
                subtitle: Text('API keys for currency exchange rate data.'),
              ),
              const Divider(),
              ...apiKeys.asMap().entries.map((entry) {
                final index = entry.key;
                final apiKeyData = apiKeyDataMap[entry.value.key] ?? entry.value;
                final status = apiKeyData.status;

                String quotaString = '';
                if (apiKeyData.requestsRemaining != null && apiKeyData.planQuota != null) {
                  final percentage = apiKeyData.planQuota! > 0
                      ? (apiKeyData.requestsRemaining! / apiKeyData.planQuota! * 100)
                      : 0;
                  quotaString = 'Quota: ${apiKeyData.requestsRemaining} / ${apiKeyData.planQuota} (${percentage.toStringAsFixed(1)}%)';
                }

                return ListTile(
                  title: Text(apiKeyData.key, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(status.icon, color: status.color, size: 16),
                          const SizedBox(width: 4),
                          Text(status.label, style: TextStyle(color: status.color)),
                        ],
                      ),
                      if (quotaString.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            quotaString,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      if (apiKeyData.refreshDayOfMonth != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Refreshes on day ${apiKeyData.refreshDayOfMonth} of the month',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.sync),
                        onPressed: () {
                          ref.read(apiKeyStatusProvider.notifier).validateKey(apiKeyData.key);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showApiKeyDialog(context, ref, existingKey: apiKeyData, index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          ref.read(apiKeyServiceProvider).deleteApiKey(apiKeyData.key);
                        },
                      ),
                    ],
                  ),
                );
              }),
              ListTile(
                title: const Text('Add API Key'),
                trailing: const Icon(Icons.add),
                onTap: () => _showApiKeyDialog(context, ref),
              ),
              const Divider(),
              ListTile(
                title: const Text('API Status'),
                trailing: const Icon(Icons.network_check),
                onTap: () {
                  context.push('/api-status');
                },
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, WidgetRef ref, {ApiKeyData? existingKey, int? index}) {
    final keyController = TextEditingController(text: existingKey?.key);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingKey == null ? 'Add API Key' : 'Edit API Key'),
          content: TextField(
            controller: keyController,
            decoration: const InputDecoration(labelText: "API Key"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final newKey = keyController.text.trim();

                if (newKey.isNotEmpty) {
                  final service = ref.read(apiKeyServiceProvider);
                  if (existingKey != null && index != null) {
                    // Update existing API Key
                    final updatedApiKeyData = existingKey.copyWith(
                      key: newKey,
                      status: ApiKeyStatus.unknown, // Reset status
                      lastValidated: null,
                      planQuota: null,
                      requestsRemaining: null,
                      refreshDayOfMonth: null,
                    );
                    await service.updateApiKey(index, updatedApiKeyData);
                    ref.read(apiKeyStatusProvider.notifier).validateKey(newKey);
                  } else {
                    // Add new API Key
                    await service.addApiKey(newKey);
                    ref.read(apiKeyStatusProvider.notifier).validateKey(newKey);
                  }
                  if (!mounted) return;
                  navigator.pop();
                } else {
                  // Show error if key is empty
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('API Key cannot be empty.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

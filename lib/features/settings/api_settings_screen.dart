import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/settings/api_key_validation_service.dart';
import 'package:finow/features/settings/models/api_key_data.dart';
import 'package:finow/features/settings/api_key_status.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final apiKeyStatusMap = ref.watch(apiKeyStatusProvider);
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
                final apiKeyData = entry.value;
                final status = apiKeyStatusMap[apiKeyData.key] ?? apiKeyData.status;

                return ListTile(
                  title: Text(apiKeyData.key, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Row(
                    children: [
                      Icon(status.icon, color: status.color),
                      const SizedBox(width: 4),
                      Text(status.label, style: TextStyle(color: status.color)),
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
    final lastValidatedController = TextEditingController(text: existingKey?.lastValidated?.toString());
    ApiKeyStatus selectedStatus = existingKey?.status ?? ApiKeyStatus.unknown; // Initialize with existing status or unknown

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingKey == null ? 'Add API Key' : 'Edit API Key'),
          content: SingleChildScrollView( // Use SingleChildScrollView to prevent overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keyController,
                  decoration: const InputDecoration(labelText: "API Key"),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ApiKeyStatus>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(labelText: "Status"),
                  items: ApiKeyStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    );
                  }).toList(),
                  onChanged: (ApiKeyStatus? newValue) {
                    if (newValue != null) {
                      selectedStatus = newValue;
                      // Rebuild the dialog to reflect the change (optional, but good for immediate feedback)
                      (context as Element).markNeedsBuild();
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastValidatedController,
                  decoration: const InputDecoration(labelText: "Last Validated (Unix Timestamp)"),
                  keyboardType: TextInputType.number, // Allow only numbers
                ),
              ],
            ),
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
                final newLastValidated = int.tryParse(lastValidatedController.text); // Parse to int?

                if (newKey.isNotEmpty) {
                  final service = ref.read(apiKeyServiceProvider);
                  if (existingKey != null && index != null) {
                    // Update existing API Key
                    final updatedApiKeyData = existingKey.copyWith(
                      key: newKey,
                      status: selectedStatus,
                      lastValidated: newLastValidated,
                    );
                    await service.updateApiKey(index, updatedApiKeyData);
                    // Re-validate the key after update if its key changed
                    if (existingKey.key != newKey) {
                      ref.read(apiKeyStatusProvider.notifier).validateKey(newKey);
                    }
                  } else {
                    // Add new API Key
                    final newApiKeyData = ApiKeyData(
                      key: newKey,
                      status: selectedStatus,
                      lastValidated: newLastValidated,
                    );
                    await service.addApiKey(newApiKeyData.key); // addApiKey only takes key, so we need to update status and lastValidated after adding
                    // Find the newly added key and update its status and lastValidated
                    final addedKeys = service.getApiKeys().where((element) => element.key == newKey);
                    if (addedKeys.isNotEmpty) {
                      final addedKey = addedKeys.first;
                      final addedIndex = service.getApiKeys().indexOf(addedKey);
                      if (addedIndex != -1) {
                        final updatedAddedKey = addedKey.copyWith(
                          status: selectedStatus,
                          lastValidated: newLastValidated,
                        );
                        await service.updateApiKey(addedIndex, updatedAddedKey);
                      }
                    }
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
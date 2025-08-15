import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/settings/api_key_validation_service.dart';
import 'package:finow/features/settings/models/api_key_data.dart';
import 'package:finow/features/settings/api_key_status.dart';
import 'package:finow/ui_scale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:finow/features/storage_viewer/storage_viewer_screen.dart'; // For searchQueryProvider

class ApiKeysStorageView extends ConsumerWidget {
  const ApiKeysStorageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKeysAsync = ref.watch(apiKeyListProvider);
    final apiKeyStatusMap = ref.watch(apiKeyStatusProvider);

    return Scaffold(
      body: Column(
        children: [
          apiKeysAsync.when(
            data: (apiKeys) {
              final searchQuery = ref.watch(searchQueryProvider);
              final filteredApiKeys = apiKeys.where((apiKey) {
                final query = searchQuery.toLowerCase();
                return apiKey.key.toLowerCase().contains(query) ||
                       apiKey.status.name.toLowerCase().contains(query) ||
                       (apiKey.lastValidated?.toString().toLowerCase().contains(query) ?? false);
              }).toList();

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'API Keys',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(filteredApiKeys.length)} items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      icon: const ScaledIcon(Icons.clear_all, size: 24),
                      onPressed: () async {
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Clear All API Keys'),
                              content: const Text('Are you sure you want to delete all API keys? This action cannot be undone.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Clear All'),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true) {
                          await ref.read(apiKeyServiceProvider).clearAllApiKeys();
                        }
                      },
                      tooltip: 'Clear all API keys',
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(), // Hide during loading
            error: (err, stack) => const SizedBox.shrink(), // Hide during error
          ),
          const Divider(),
          Expanded(
            child: apiKeysAsync.when(
              data: (apiKeys) {
                final searchQuery = ref.watch(searchQueryProvider);
                final filteredApiKeys = apiKeys.where((apiKey) {
                  final query = searchQuery.toLowerCase();
                  return apiKey.key.toLowerCase().contains(query) ||
                         apiKey.status.name.toLowerCase().contains(query) ||
                         (apiKey.lastValidated?.toString().toLowerCase().contains(query) ?? false);
                }).toList();

                if (filteredApiKeys.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaledIcon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty ? 'API Keys Box가 비어있습니다' : '검색 결과가 없습니다',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredApiKeys.length,
                  itemBuilder: (context, index) {
                    final apiKey = filteredApiKeys[index];
                    final status = apiKeyStatusMap[apiKey.key] ?? apiKey.status;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Text('Key: ${_maskApiKey(apiKey.key)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Full Key: ${apiKey.key}'),
                            Row(
                              children: [
                                const Text('Status: '),
                                Text(status.name),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Row(
                                children: [
                                  const Text('└ '),
                                  ScaledIcon(status.icon, color: status.color, size: 16),
                                  const SizedBox(width: 4),
                                  Text(status.label, style: TextStyle(color: status.color, fontStyle: FontStyle.italic)),
                                  const SizedBox(width: 8),
                                  Text('(Priority: ${apiKey.priority})', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                            Text(
                              'Last Validated (Unix): ${apiKey.lastValidated ?? 'N/A'}',
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                              child: Text(
                                '└ Converted: ${apiKey.lastValidated != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(apiKey.lastValidated!).toLocal()) : 'N/A'} (KST)',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(204),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const ScaledIcon(Icons.sync),
                              onPressed: () {
                                ref.read(apiKeyStatusProvider.notifier).validateKey(apiKey.key);
                              },
                            ),
                            IconButton(
                              icon: const ScaledIcon(Icons.edit),
                              onPressed: () => _showApiKeyDialog(context, ref, existingKey: apiKey, index: index),
                            ),
                            IconButton(
                              icon: const ScaledIcon(Icons.delete),
                              onPressed: () => _confirmDelete(context, ref, apiKey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showApiKeyDialog(context, ref),
        child: const ScaledIcon(Icons.add),
      ),
    );
  }

  String _maskApiKey(String key) {
    if (key.length <= 8) {
      return key;
    }
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, ApiKeyData apiKey) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete API Key'),
          content: Text('Are you sure you want to delete \'${_maskApiKey(apiKey.key)}\'?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ref.read(apiKeyServiceProvider).deleteApiKey(apiKey.key);
    }
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
                  value: selectedStatus,
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
                  Navigator.of(context).pop();
                } else {
                  // Show error if key is empty
                  ScaffoldMessenger.of(context).showSnackBar(
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
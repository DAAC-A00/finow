import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/settings/api_key_validation_service.dart';
import 'package:finow/features/settings/models/api_key_data.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:finow/features/storage_viewer/storage_viewer_screen.dart'; // For searchQueryProvider
import 'package:finow/features/storage_viewer/edit_api_key_screen.dart';

class ApiKeysStorageView extends ConsumerWidget {
  const ApiKeysStorageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKeysAsync = ref.watch(apiKeyListProvider);
    final apiKeyDataMap = ref.watch(apiKeyStatusProvider);

    return Scaffold(
      body: Column(
        children: [
          apiKeysAsync.when(
            data: (apiKeys) {
              final searchQuery = ref.watch(searchQueryProvider);
              final filteredApiKeys = apiKeys.where((apiKey) {
                final query = searchQuery.toLowerCase();
                final data = apiKeyDataMap[apiKey.key] ?? apiKey;
                return data.key.toLowerCase().contains(query) ||
                       data.status.name.toLowerCase().contains(query) ||
                       (data.lastValidated?.toString().toLowerCase().contains(query) ?? false);
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
                      icon: const Icon(Icons.clear_all),
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
                  final data = apiKeyDataMap[apiKey.key] ?? apiKey;
                  return data.key.toLowerCase().contains(query) ||
                         data.status.name.toLowerCase().contains(query) ||
                         (data.lastValidated?.toString().toLowerCase().contains(query) ?? false);
                }).toList();

                if (filteredApiKeys.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
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
                    final apiKeyData = apiKeyDataMap[apiKey.key] ?? apiKey;
                    final status = apiKeyData.status;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Text('Key: ${_maskApiKey(apiKeyData.key)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Full Key: ${apiKeyData.key}'),
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
                                  Icon(status.icon, color: status.color),
                                  const SizedBox(width: 4),
                                  Text(status.label, style: TextStyle(color: status.color, fontStyle: FontStyle.italic)),
                                  const SizedBox(width: 8),
                                  Text('(Priority: ${apiKeyData.priority})', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                            Text('Plan Quota: ${apiKeyData.planQuota ?? 'N/A'}'),
                            Text('Requests Remaining: ${apiKeyData.requestsRemaining ?? 'N/A'}'),
                            Text('Refresh Day Of Month: ${apiKeyData.refreshDayOfMonth ?? 'N/A'}'),
                            Text(
                              'Last Validated (Unix): ${apiKeyData.lastValidated ?? 'N/A'}'
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                              child: Text(
                                '└ Converted: ${apiKeyData.lastValidated != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(apiKeyData.lastValidated!).toLocal()) : 'N/A'} (KST)',
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
                              icon: const Icon(Icons.sync),
                              onPressed: () {
                                ref.read(apiKeyStatusProvider.notifier).validateKey(apiKeyData.key);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditApiKeyScreen(
                                      existingKey: apiKeyData,
                                      index: index,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _confirmDelete(context, ref, apiKeyData),
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
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => const EditApiKeyScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
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
    final navigator = Navigator.of(context);
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete API Key'),
          content: Text('Are you sure you want to delete \'${_maskApiKey(apiKey.key)}\'?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => navigator.pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => navigator.pop(true),
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
}

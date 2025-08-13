import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/settings/api_key_validation_service.dart';
import 'package:finow/features/settings/models/api_key_data.dart';
import 'package:finow/features/settings/api_key_status.dart';
import 'package:finow/ui_scale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ApiKeysStorageView extends ConsumerWidget {
  const ApiKeysStorageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKeysAsync = ref.watch(apiKeyListProvider);
    final apiKeyStatusMap = ref.watch(apiKeyStatusProvider);

    return Scaffold(
      body: apiKeysAsync.when(
        data: (apiKeys) => ListView.builder(
          itemCount: apiKeys.length,
          itemBuilder: (context, index) {
            final apiKey = apiKeys[index];
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
                          Icon(status.icon, color: status.color, size: 16),
                          const SizedBox(width: 4),
                          Text(status.label, style: TextStyle(color: status.color, fontStyle: FontStyle.italic)),
                          const SizedBox(width: 8),
                          Text('(Priority: ${apiKey.priority})', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    Text(
                      'Last Validated: ${apiKey.lastValidated != null ? DateFormat('yyyy-MM-dd HH:mm').format(apiKey.lastValidated!) : 'N/A'}',
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.sync),
                      onPressed: () {
                        ref.read(apiKeyStatusProvider.notifier).validateKey(apiKey.key);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showApiKeyDialog(context, ref, existingKey: apiKey, index: index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context, ref, apiKey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showApiKeyDialog(context, ref),
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
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const ScaledText('Delete API Key'),
          content: ScaledText('Are you sure you want to delete \'${_maskApiKey(apiKey.key)}\'?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const ScaledText('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const ScaledText('Delete'),
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
    final textController = TextEditingController(text: existingKey?.key);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: ScaledText(existingKey == null ? 'Add API Key' : 'Edit API Key'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Enter API Key"),
          ),
          actions: [
            TextButton(
              child: const ScaledText('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const ScaledText('Save'),
              onPressed: () {
                final newKey = textController.text.trim();
                if (newKey.isNotEmpty) {
                  final service = ref.read(apiKeyServiceProvider);
                  if (existingKey != null && index != null) {
                    service.updateApiKey(index, newKey).then((_) {
                      ref.read(apiKeyStatusProvider.notifier).validateKey(newKey);
                    });
                  } else {
                    service.addApiKey(newKey).then((_) {
                      ref.read(apiKeyStatusProvider.notifier).validateKey(newKey);
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
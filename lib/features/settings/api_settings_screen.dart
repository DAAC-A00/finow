import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/settings/api_key_validation_service.dart';
import 'package:finow/features/settings/models/api_key_data.dart';
import 'package:finow/features/settings/api_key_status.dart';
import 'package:finow/ui_scale_provider.dart';
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
        title: const ScaledText('API Key Management'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _validateAllKeys();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: ScaledText('API keys have been re-validated.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: apiKeysAsync.when(
          data: (apiKeys) => ListView(
            children: [
              const ListTile(
                title: ScaledText(
                  'V6 Exchange Rate API',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: ScaledText('API keys for currency exchange rate data.'),
              ),
              const Divider(),
              ...apiKeys.asMap().entries.map((entry) {
                final index = entry.key;
                final apiKeyData = entry.value;
                final status = apiKeyStatusMap[apiKeyData.key] ?? apiKeyData.status;

                return ListTile(
                  title: ScaledText(apiKeyData.key, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Row(
                    children: [
                      Icon(status.icon, color: status.color, size: 16),
                      const SizedBox(width: 4),
                      ScaledText(status.label, style: TextStyle(color: status.color)),
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
                title: const ScaledText('Add API Key'),
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
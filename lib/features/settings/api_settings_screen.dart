
import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/settings/api_key_validation_service.dart';
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
    // Post-frame callback to ensure providers are available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateAllKeys();
    });
  }

  void _validateAllKeys() {
    final keys = ref.read(apiKeyListProvider);
    for (final key in keys) {
      ref.read(apiKeyStatusProvider.notifier).validateKey(key);
    }
  }


  @override
  Widget build(BuildContext context) {
    final apiKeyStatusMap = ref.watch(apiKeyStatusProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const ScaledText('API Key Management'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: ScaledText(
              'V6 Exchange Rate API',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: ScaledText('API keys for currency exchange rate data.'),
          ),
          const Divider(),
          ...ref.watch(apiKeyListProvider).asMap().entries.map((entry) {
            final index = entry.key;
            final key = entry.value;
            final status = apiKeyStatusMap[key] ?? ApiKeyStatus.unknown;

            return ListTile(
              title: ScaledText(key, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                      ref.read(apiKeyStatusProvider.notifier).validateKey(key);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showApiKeyDialog(context, ref, existingKey: key, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      ref.read(apiKeyServiceProvider).deleteApiKey(key).then((_) {
                        ref.read(apiKeyStatusProvider.notifier).clearStatus(key);
                        ref.refresh(apiKeyListProvider);
                      });
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
    );
  }

  void _showApiKeyDialog(BuildContext context, WidgetRef ref, {String? existingKey, int? index}) {
    final textController = TextEditingController(text: existingKey);
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
                      ref.refresh(apiKeyListProvider);
                      ref.read(apiKeyStatusProvider.notifier).validateKey(newKey);
                    });
                  } else {
                    service.addApiKey(newKey).then((_) {
                      ref.refresh(apiKeyListProvider);
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

import 'package:finow/features/settings/api_key_service.dart';
import 'package:finow/features/settings/models/api_key_data.dart';
import 'package:finow/features/settings/api_key_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/features/settings/api_key_validation_service.dart';

class EditApiKeyScreen extends ConsumerStatefulWidget {
  final ApiKeyData? existingKey;
  final int? index;

  const EditApiKeyScreen({super.key, this.existingKey, this.index});

  @override
  ConsumerState<EditApiKeyScreen> createState() => _EditApiKeyScreenState();
}

class _EditApiKeyScreenState extends ConsumerState<EditApiKeyScreen> {
  late final TextEditingController _keyController;
  late final TextEditingController _lastValidatedController;
  late final TextEditingController _planQuotaController;
  late final TextEditingController _requestsRemainingController;
  late final TextEditingController _refreshDayOfMonthController;
  late ApiKeyStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.existingKey?.key);
    _lastValidatedController = TextEditingController(text: widget.existingKey?.lastValidated?.toString());
    _planQuotaController = TextEditingController(text: widget.existingKey?.planQuota?.toString());
    _requestsRemainingController = TextEditingController(text: widget.existingKey?.requestsRemaining?.toString());
    _refreshDayOfMonthController = TextEditingController(text: widget.existingKey?.refreshDayOfMonth?.toString());
    _selectedStatus = widget.existingKey?.status ?? ApiKeyStatus.unknown;
  }

  @override
  void dispose() {
    _keyController.dispose();
    _lastValidatedController.dispose();
    _planQuotaController.dispose();
    _requestsRemainingController.dispose();
    _refreshDayOfMonthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingKey == null ? 'Add API Key' : 'Edit API Key'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveApiKey,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(labelText: "API Key"),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ApiKeyStatus>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(labelText: "Status"),
              items: ApiKeyStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.name),
                );
              }).toList(),
              onChanged: (ApiKeyStatus? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _planQuotaController,
              decoration: const InputDecoration(labelText: "Plan Quota"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _requestsRemainingController,
              decoration: const InputDecoration(labelText: "Requests Remaining"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _refreshDayOfMonthController,
              decoration: const InputDecoration(labelText: "Refresh Day Of Month"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastValidatedController,
              decoration: const InputDecoration(labelText: "Last Validated (Unix Timestamp)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveApiKey() async {
    final newKey = _keyController.text.trim();
    final newLastValidated = int.tryParse(_lastValidatedController.text);
    final newPlanQuota = int.tryParse(_planQuotaController.text);
    final newRequestsRemaining = int.tryParse(_requestsRemainingController.text);
    final newRefreshDayOfMonth = int.tryParse(_refreshDayOfMonthController.text);

    if (newKey.isNotEmpty) {
      final service = ref.read(apiKeyServiceProvider);
      if (widget.existingKey != null && widget.index != null) {
        final updatedApiKeyData = widget.existingKey!.copyWith(
          key: newKey,
          status: _selectedStatus,
          lastValidated: newLastValidated,
          planQuota: newPlanQuota,
          requestsRemaining: newRequestsRemaining,
          refreshDayOfMonth: newRefreshDayOfMonth,
        );
        await service.updateApiKey(widget.index!, updatedApiKeyData);
        if (widget.existingKey!.key != newKey) {
          ref.read(apiKeyStatusProvider.notifier).validateKey(newKey);
        }
      } else {
        final newApiKeyData = ApiKeyData(
          key: newKey,
          status: _selectedStatus,
          lastValidated: newLastValidated,
          planQuota: newPlanQuota,
          requestsRemaining: newRequestsRemaining,
          refreshDayOfMonth: newRefreshDayOfMonth,
        );
        await service.addApiKey(newApiKeyData.key);
        final addedKeys = service.getApiKeys().where((element) => element.key == newKey);
        if (addedKeys.isNotEmpty) {
          final addedKey = addedKeys.first;
          final addedIndex = service.getApiKeys().indexOf(addedKey);
          if (addedIndex != -1) {
            final updatedAddedKey = addedKey.copyWith(
              status: _selectedStatus,
              lastValidated: newLastValidated,
              planQuota: newPlanQuota,
              requestsRemaining: newRequestsRemaining,
              refreshDayOfMonth: newRefreshDayOfMonth,
            );
            await service.updateApiKey(addedIndex, updatedAddedKey);
          }
        }
        ref.read(apiKeyStatusProvider.notifier).validateKey(newKey);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API Key cannot be empty.')),
        );
      }
    }
  }
}

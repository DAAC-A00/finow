import 'package:finow/features/instruments/models/instrument.dart';
import 'package:finow/features/instruments/services/instruments_local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditInstrumentScreen extends ConsumerStatefulWidget {
  final Instrument existingInstrument;
  final dynamic originalKey;

  const EditInstrumentScreen({
    super.key,
    required this.existingInstrument,
    required this.originalKey,
  });

  @override
  ConsumerState<EditInstrumentScreen> createState() => _EditInstrumentScreenState();
}

class _EditInstrumentScreenState extends ConsumerState<EditInstrumentScreen> {
  late final TextEditingController _symbolController;
  late final TextEditingController _baseCodeController;
  late final TextEditingController _quoteCodeController;
  late final TextEditingController _quantityController;
  late final TextEditingController _exchangeController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _symbolController = TextEditingController(text: widget.existingInstrument.symbol);
    _baseCodeController = TextEditingController(text: widget.existingInstrument.baseCode);
    _quoteCodeController = TextEditingController(text: widget.existingInstrument.quoteCode);
    _quantityController = TextEditingController(text: widget.existingInstrument.quantity?.toString());
    _exchangeController = TextEditingController(text: widget.existingInstrument.exchange);
    _categoryController = TextEditingController(text: widget.existingInstrument.category);
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _baseCodeController.dispose();
    _quoteCodeController.dispose();
    _quantityController.dispose();
    _exchangeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Instrument'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveInstrument,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _symbolController,
              decoration: const InputDecoration(labelText: 'Symbol'),
            ),
            TextField(
              controller: _baseCodeController,
              decoration: const InputDecoration(labelText: 'Base Code'),
            ),
            TextField(
              controller: _quoteCodeController,
              decoration: const InputDecoration(labelText: 'Quote Code'),
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _exchangeController,
              decoration: const InputDecoration(labelText: 'Exchange'),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveInstrument() async {
    final newSymbol = _symbolController.text;
    final newCategory = _categoryController.text;
    final newExchange = _exchangeController.text;

    final oldSymbol = widget.existingInstrument.symbol;
    final oldCategory = widget.existingInstrument.category;
    final oldExchange = widget.existingInstrument.exchange;

    final updatedInstrument = widget.existingInstrument.copyWith(
      symbol: newSymbol,
      baseCode: _baseCodeController.text,
      quoteCode: _quoteCodeController.text,
      quantity: double.tryParse(_quantityController.text),
      exchange: newExchange,
      category: newCategory,
    );

    if (newSymbol != oldSymbol || newCategory != oldCategory || newExchange != oldExchange) {
      // Delete old instrument if key components changed
      await ref.read(instrumentsLocalStorageServiceProvider).deleteInstrument(
        oldSymbol,
        oldCategory ?? 'unknown',
        oldExchange,
      );
    }

    await ref.read(instrumentsLocalStorageServiceProvider).saveInstrument(updatedInstrument);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

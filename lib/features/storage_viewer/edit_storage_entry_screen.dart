import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/instruments/models/instrument.dart';
import 'package:finow/features/storage_viewer/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/features/storage_viewer/storage_viewer_screen.dart';

class EditStorageEntryScreen extends ConsumerStatefulWidget {
  final String boxName;
  final dynamic originalKey;
  final dynamic originalValue;

  const EditStorageEntryScreen({
    super.key,
    required this.boxName,
    required this.originalKey,
    required this.originalValue,
  });

  @override
  ConsumerState<EditStorageEntryScreen> createState() => _EditStorageEntryScreenState();
}

class _EditStorageEntryScreenState extends ConsumerState<EditStorageEntryScreen> {
  late TextEditingController _genericController;
  bool? _boolValue;

  // ExchangeRate controllers
  late TextEditingController _lastUpdatedUnixController;
  late TextEditingController _baseCodeController;
  late TextEditingController _quoteCodeController;
  late TextEditingController _priceController;

  // Instrument controllers
  late TextEditingController _symbolController;
  late TextEditingController _exchangeController;
  late TextEditingController _statusController;
  late TextEditingController _categoryController;
  late TextEditingController _koreanNameController;
  late TextEditingController _englishNameController;
  late TextEditingController _marketWarningController;
  late TextEditingController _contractTypeController;
  late TextEditingController _launchTimeController;
  late TextEditingController _deliveryTimeController;
  late TextEditingController _deliveryFeeRateController;
  late TextEditingController _priceScaleController;
  bool? _unifiedMarginTradeValue;
  late TextEditingController _fundingIntervalController;
  late TextEditingController _settleCoinController;
  late TextEditingController _copyTradingController;
  late TextEditingController _upperFundingRateController;
  late TextEditingController _lowerFundingRateController;
  bool? _isPreListingValue;
  late TextEditingController _preListingInfoController;
  late TextEditingController _displayNameController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final value = widget.originalValue;
    _genericController = TextEditingController(text: value.toString());
    _boolValue = value is bool ? value : null;

    // Initialize ExchangeRate controllers
    _lastUpdatedUnixController = TextEditingController();
    _baseCodeController = TextEditingController();
    _quoteCodeController = TextEditingController();
    _priceController = TextEditingController();

    // Initialize Instrument controllers
    _symbolController = TextEditingController();
    _baseCodeController = TextEditingController();
    _quoteCodeController = TextEditingController();
    _exchangeController = TextEditingController();
    _statusController = TextEditingController();
    _categoryController = TextEditingController();
    _koreanNameController = TextEditingController();
    _englishNameController = TextEditingController();
    _marketWarningController = TextEditingController();
    _contractTypeController = TextEditingController();
    _launchTimeController = TextEditingController();
    _deliveryTimeController = TextEditingController();
    _deliveryFeeRateController = TextEditingController();
    _priceScaleController = TextEditingController();
    _fundingIntervalController = TextEditingController();
    _settleCoinController = TextEditingController();
    _copyTradingController = TextEditingController();
    _upperFundingRateController = TextEditingController();
    _lowerFundingRateController = TextEditingController();
    _preListingInfoController = TextEditingController();
    _displayNameController = TextEditingController();

    if (value is ExchangeRate) {
      _lastUpdatedUnixController.text = value.lastUpdatedUnix.toString();
      _baseCodeController.text = value.baseCode;
      _quoteCodeController.text = value.quoteCode;
      _priceController.text = value.price.toString();
    } else if (value is Instrument) {
      _symbolController.text = value.symbol;
      _baseCodeController.text = value.baseCode;
      _quoteCodeController.text = value.quoteCode;
      _exchangeController.text = value.exchange;
      _statusController.text = value.status;
      _categoryController.text = value.category ?? '';
      _koreanNameController.text = value.koreanName ?? '';
      _englishNameController.text = value.englishName ?? '';
      _marketWarningController.text = value.marketWarning ?? '';
      _contractTypeController.text = value.contractType ?? '';
      _launchTimeController.text = value.launchTime ?? '';
      _deliveryTimeController.text = value.deliveryTime ?? '';
      _deliveryFeeRateController.text = value.deliveryFeeRate ?? '';
      _priceScaleController.text = value.priceScale ?? '';
      _unifiedMarginTradeValue = value.unifiedMarginTrade;
      _fundingIntervalController.text = value.fundingInterval?.toString() ?? '';
      _settleCoinController.text = value.settleCoin ?? '';
      _copyTradingController.text = value.copyTrading ?? '';
      _upperFundingRateController.text = value.upperFundingRate ?? '';
      _lowerFundingRateController.text = value.lowerFundingRate ?? '';
      _isPreListingValue = value.isPreListing;
      _preListingInfoController.text = value.preListingInfo?.toString() ?? '';
      _displayNameController.text = value.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _genericController.dispose();
    _lastUpdatedUnixController.dispose();
    _baseCodeController.dispose();
    _quoteCodeController.dispose();
    _priceController.dispose();
    _symbolController.dispose();
    _baseCodeController.dispose();
    _quoteCodeController.dispose();
    _exchangeController.dispose();
    _statusController.dispose();
    _categoryController.dispose();
    _koreanNameController.dispose();
    _englishNameController.dispose();
    _marketWarningController.dispose();
    _contractTypeController.dispose();
    _launchTimeController.dispose();
    _deliveryTimeController.dispose();
    _deliveryFeeRateController.dispose();
    _priceScaleController.dispose();
    _fundingIntervalController.dispose();
    _settleCoinController.dispose();
    _copyTradingController.dispose();
    _upperFundingRateController.dispose();
    _lowerFundingRateController.dispose();
    _preListingInfoController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.originalKey}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    final value = widget.originalValue;
    if (value is bool) {
      return SwitchListTile(
        title: const Text('Value'),
        value: _boolValue!,
        onChanged: (newValue) {
          setState(() {
            _boolValue = newValue;
          });
        },
      );
    } else if (value is ExchangeRate) {
      return Column(
        children: [
          TextField(
            controller: _lastUpdatedUnixController,
            decoration: const InputDecoration(labelText: 'Last Updated (Unix)'),
            keyboardType: TextInputType.number,
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
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      );
    } else if (value is Instrument) {
      return Column(
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
            controller: _exchangeController,
            decoration: const InputDecoration(labelText: 'Exchange'),
          ),
          TextField(
            controller: _statusController,
            decoration: const InputDecoration(labelText: 'Status'),
          ),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          TextField(
            controller: _koreanNameController,
            decoration: const InputDecoration(labelText: 'Korean Name'),
          ),
          TextField(
            controller: _englishNameController,
            decoration: const InputDecoration(labelText: 'English Name'),
          ),
          TextField(
            controller: _marketWarningController,
            decoration: const InputDecoration(labelText: 'Market Warning'),
          ),
          TextField(
            controller: _contractTypeController,
            decoration: const InputDecoration(labelText: 'Contract Type'),
          ),
          TextField(
            controller: _launchTimeController,
            decoration: const InputDecoration(labelText: 'Launch Time'),
          ),
          TextField(
            controller: _deliveryTimeController,
            decoration: const InputDecoration(labelText: 'Delivery Time'),
          ),
          TextField(
            controller: _deliveryFeeRateController,
            decoration: const InputDecoration(labelText: 'Delivery Fee Rate'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _priceScaleController,
            decoration: const InputDecoration(labelText: 'Price Scale'),
          ),
          SwitchListTile(
            title: const Text('Unified Margin Trade'),
            value: _unifiedMarginTradeValue ?? false,
            onChanged: (newValue) {
              setState(() {
                _unifiedMarginTradeValue = newValue;
              });
            },
          ),
          TextField(
            controller: _fundingIntervalController,
            decoration: const InputDecoration(labelText: 'Funding Interval'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _settleCoinController,
            decoration: const InputDecoration(labelText: 'Settle Coin'),
          ),
          TextField(
            controller: _copyTradingController,
            decoration: const InputDecoration(labelText: 'Copy Trading'),
          ),
          TextField(
            controller: _upperFundingRateController,
            decoration: const InputDecoration(labelText: 'Upper Funding Rate'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _lowerFundingRateController,
            decoration: const InputDecoration(labelText: 'Lower Funding Rate'),
            keyboardType: TextInputType.number,
          ),
          SwitchListTile(
            title: const Text('Is Pre-Listing'),
            value: _isPreListingValue ?? false,
            onChanged: (newValue) {
              setState(() {
                _isPreListingValue = newValue;
              });
            },
          ),
          TextField(
            controller: _preListingInfoController,
            decoration: const InputDecoration(labelText: 'Pre-Listing Info (JSON)'),
            maxLines: 3,
          ),
          TextField(
            controller: _displayNameController,
            decoration: const InputDecoration(labelText: 'Display Name'),
          ),
        ],
      );
    } else {
      return TextField(
        controller: _genericController,
        decoration: const InputDecoration(labelText: 'Value'),
        keyboardType: value is int || value is double
            ? TextInputType.number
            : TextInputType.text,
      );
    }
  }

  Future<void> _saveChanges() async {
    final localStorageService = ref.read(localStorageServiceProvider);
    dynamic newValue;
    final value = widget.originalValue;

    if (value is bool) {
      newValue = _boolValue;
    } else if (value is int) {
      newValue = int.tryParse(_genericController.text);
    } else if (value is double) {
      newValue = double.tryParse(_genericController.text);
    } else if (value is ExchangeRate) {
      newValue = ExchangeRate(
        lastUpdatedUnix: int.tryParse(_lastUpdatedUnixController.text) ?? value.lastUpdatedUnix,
        baseCode: _baseCodeController.text,
        quoteCode: _quoteCodeController.text,
        price: double.tryParse(_priceController.text) ?? value.price,
        source: value.source, // Keep original source
      );
    } else if (value is Instrument) {
      newValue = Instrument(
        symbol: _symbolController.text,
        baseCode: _baseCodeController.text,
        quoteCode: _quoteCodeController.text,
        exchange: _exchangeController.text,
        status: _statusController.text,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
        koreanName: _koreanNameController.text.isEmpty ? null : _koreanNameController.text,
        englishName: _englishNameController.text.isEmpty ? null : _englishNameController.text,
        marketWarning: _marketWarningController.text.isEmpty ? null : _marketWarningController.text,
        contractType: _contractTypeController.text.isEmpty ? null : _contractTypeController.text,
        launchTime: _launchTimeController.text.isEmpty ? null : _launchTimeController.text,
        deliveryTime: _deliveryTimeController.text.isEmpty ? null : _deliveryTimeController.text,
        deliveryFeeRate: _deliveryFeeRateController.text.isEmpty ? null : _deliveryFeeRateController.text,
        priceScale: _priceScaleController.text.isEmpty ? null : _priceScaleController.text,
        unifiedMarginTrade: _unifiedMarginTradeValue,
        fundingInterval: int.tryParse(_fundingIntervalController.text),
        settleCoin: _settleCoinController.text.isEmpty ? null : _settleCoinController.text,
        copyTrading: _copyTradingController.text.isEmpty ? null : _copyTradingController.text,
        upperFundingRate: _upperFundingRateController.text.isEmpty ? null : _upperFundingRateController.text,
        lowerFundingRate: _lowerFundingRateController.text.isEmpty ? null : _lowerFundingRateController.text,
        isPreListing: _isPreListingValue,
        preListingInfo: _preListingInfoController.text.isEmpty ? null : {'json': _preListingInfoController.text},
        displayName: _displayNameController.text.isEmpty ? null : _displayNameController.text,
        lastUpdated: value.lastUpdated, // Keep original lastUpdated
        priceFilter: value.priceFilter,
        lotSizeFilter: value.lotSizeFilter,
        leverageFilter: value.leverageFilter,
        riskParameters: value.riskParameters,
      );
    } else {
      newValue = _genericController.text;
    }

    if (newValue != null) {
      await localStorageService.updateEntry(widget.boxName, widget.originalKey, newValue);
      ref.invalidate(allStorageDataProvider);
      ref.invalidate(storageUsageProvider);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid value.')),
        );
      }
    }
  }
}

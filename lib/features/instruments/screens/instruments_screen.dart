import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/instrument.dart';
import '../providers/instruments_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:finow/features/instruments/screens/instrument_details_screen.dart';

/// Instrument Information Screen
class InstrumentsScreen extends ConsumerStatefulWidget {
  const InstrumentsScreen({super.key});

  @override
  ConsumerState<InstrumentsScreen> createState() => _InstrumentsScreenState();
}

class _InstrumentsScreenState extends ConsumerState<InstrumentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedExchange = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load stored data on screen entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(instrumentsProvider.notifier).loadStoredInstruments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search by symbol, coin name...',
            border: InputBorder.none,
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
            tooltip: 'Refresh Data',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _clearStoredData();
                  break;
                case 'info':
                  _showInfoDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Clear Stored Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Info'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(text: 'All', icon: Icon(Icons.list)),
              Tab(text: 'Bybit', icon: Icon(Icons.currency_bitcoin)),
              Tab(text: 'Bithumb', icon: Icon(Icons.account_balance)),
            ],
          ),
          _buildFilterChips(colorScheme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInstrumentsList('all'),
                _buildInstrumentsList('bybit'),
                _buildInstrumentsList('bithumb'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _refreshData(),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.cloud_download),
      ),
    );
  }

  

  Widget _buildFilterChips(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Status Filter:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', colorScheme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Trading', 'Trading', colorScheme),
                  const SizedBox(width: 8),
                  _buildFilterChip('Warning', 'Warning', colorScheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, ColorScheme colorScheme) {
    final isSelected = _selectedExchange == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedExchange = selected ? value : 'all';
        });
      },
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary.withAlpha((255 * 0.2).round()),
      checkmarkColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? colorScheme.primary : colorScheme.outline.withAlpha((255 * 0.5).round()),
      ),
    );
  }

  Widget _buildInstrumentsList(String exchange) {
    return Consumer(
      builder: (context, ref, child) {
        final symbolsState = ref.watch(instrumentsProvider);
        
        return symbolsState.when(
          data: (instruments) {
            final filteredInstruments = _filterInstruments(instruments, exchange);
            
            if (filteredInstruments.isEmpty) {
              return _buildEmptyState();
            }
            
            return RefreshIndicator(
              onRefresh: () => _refreshData(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredInstruments.length,
                itemBuilder: (context, index) {
                  final instrument = filteredInstruments[index];
                  return _buildInstrumentCard(instrument);
                },
              ),
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading symbol information...'),
              ],
            ),
          ),
          error: (error, stackTrace) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  List<Instrument> _filterInstruments(List<Instrument> instruments, String exchange) {
    var filtered = instruments;
    
    // Exchange filtering
    if (exchange != 'all') {
      filtered = filtered.where((instrument) => instrument.exchange == exchange).toList();
    }
    
    // Search query filtering
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((instrument) {
        return instrument.symbol.toLowerCase().contains(query) ||
               instrument.baseCoin.toLowerCase().contains(query) ||
               instrument.quoteCoin.toLowerCase().contains(query) ||
               (instrument.koreanName?.toLowerCase().contains(query) ?? false) ||
               (instrument.englishName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    // Status filtering
    if (_selectedExchange == 'Trading') {
      filtered = filtered.where((instrument) => instrument.status == 'Trading').toList();
    } else if (_selectedExchange == 'Warning') {
      filtered = filtered.where((instrument) => 
          instrument.marketWarning != null && 
          instrument.marketWarning != 'NONE').toList();
    }
    
    return filtered;
  }

  Widget _buildInstrumentCard(Instrument instrument) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: colorScheme.surface,
      child: InkWell(
        onTap: () => _showInstrumentDetails(instrument),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          instrument.symbol,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (instrument.koreanName != null)
                          Text(
                            instrument.koreanName!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildExchangeBadge(instrument.exchange, colorScheme),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip('${instrument.baseCoin}/${instrument.quoteCoin}', colorScheme),
                  const SizedBox(width: 8),
                  _buildStatusChip(instrument.status, colorScheme),
                  if (instrument.marketWarning != null && instrument.marketWarning != 'NONE')
                    ...[
                      const SizedBox(width: 8),
                      _buildWarningChip(instrument.marketWarning!, colorScheme),
                    ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExchangeBadge(String exchange, ColorScheme colorScheme) {
    final color = exchange == 'bybit' ? Colors.orange : Colors.blue;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((255 * 0.3).round())),
      ),
      child: Text(
        exchange.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha((255 * 0.3).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurface.withAlpha((255 * 0.8).round()),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    final color = status == 'Trading' ? Colors.green : Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildWarningChip(String warning, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Warning',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: colorScheme.onSurface.withAlpha((255 * 0.4).round()),
          ),
          const SizedBox(height: 16),
          Text(
            'No symbol information available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Press the refresh button to load data',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withAlpha((255 * 0.5).round()),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _refreshData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Load Data'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'An error occurred',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withAlpha((255 * 0.7).round()),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _refreshData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    try {
      await ref.read(instrumentsProvider.notifier).fetchAndSaveInstruments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearStoredData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Data'),
        content: const Text('Are you sure you want to delete all stored symbol information?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(instrumentsProvider.notifier).clearStoredData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stored data has been deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Provides instrument information from Bybit and Bithumb'),
            SizedBox(height: 8),
            Text('• Data is stored in local storage and can be viewed offline'),
            SizedBox(height: 8),
            Text('• You can update to the latest data by refreshing'),
            SizedBox(height: 8),
            Text('• Provides search and filtering functions'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInstrumentDetails(Instrument instrument) {
    context.push('/instruments/details', extra: instrument);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
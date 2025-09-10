import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finow/features/premium/premium_model.dart';
import 'package:finow/features/premium/premium_repository.dart';

// Add these two providers
final premiumSortOptionProvider = StateProvider<PremiumSortOption>((ref) => PremiumSortOption.turnover);
final premiumSortDirectionProvider = StateProvider<SortDirection>((ref) => SortDirection.asc);

// Add this provider
final premiumSearchQueryProvider = StateProvider<String>((ref) => '');

final premiumProvider = StateNotifierProvider.autoDispose<PremiumNotifier, AsyncValue<List<Premium>>>((ref) {
  return PremiumNotifier(ref);
});

class PremiumNotifier extends StateNotifier<AsyncValue<List<Premium>>> {
  PremiumNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref _ref;
  Timer? _timer;

  void _init() {
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    try {
      final sortOption = _ref.read(premiumSortOptionProvider);
      final sortDirection = _ref.read(premiumSortDirectionProvider);
      final searchQuery = _ref.read(premiumSearchQueryProvider);
      final repository = _ref.read(premiumRepositoryProvider);
      final tickers = await repository.getPremiumTickers(sortOption, sortDirection, searchQuery);
      state = AsyncValue.data(tickers);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _fetchData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

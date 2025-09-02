import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finow/features/home/home_model.dart';
import 'package:finow/features/home/home_repository.dart';

// Add these two providers
final premiumSortOptionProvider = StateProvider<PremiumSortOption>((ref) => PremiumSortOption.symbol);
final premiumSortDirectionProvider = StateProvider<SortDirection>((ref) => SortDirection.asc);

final homeProvider = StateNotifierProvider.autoDispose<HomeNotifier, AsyncValue<List<CryptoPremium>>>((ref) {
  return HomeNotifier(ref);
});

class HomeNotifier extends StateNotifier<AsyncValue<List<CryptoPremium>>> {
  HomeNotifier(this._ref) : super(const AsyncValue.loading()) {
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
      final repository = _ref.read(homeRepositoryProvider);
      final tickers = await repository.getPremiumTickers(sortOption, sortDirection);
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

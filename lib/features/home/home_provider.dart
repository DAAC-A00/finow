import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finow/features/home/home_model.dart';
import 'package:finow/features/home/home_repository.dart';

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
      final repository = _ref.read(homeRepositoryProvider);
      final tickers = await repository.getPremiumTickers();
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

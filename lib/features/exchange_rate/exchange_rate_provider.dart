import 'package:finow/features/exchange_rate/exchange_rate.dart';
import 'package:finow/features/exchange_rate/exchange_rate_local_service.dart';
import 'package:finow/features/exchange_rate/exchange_rate_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// API로부터 환율 정보를 가져오는 FutureProvider
final exchangeRateFutureProvider = FutureProvider.autoDispose<ExchangeRate>((ref) async {
  final repository = ref.watch(exchangeRateRepositoryProvider);
  final localService = ref.watch(exchangeRateLocalServiceProvider);

  // 1. API를 통해 최신 데이터 가져오기
  final newRate = await repository.getLatestRates('USD');

  // 2. 가져온 데이터를 Hive에 저장
  await localService.saveRate(newRate);

  return newRate;
});

// Hive에 저장된 로컬 환율 정보를 가져오는 FutureProvider
final localExchangeRateProvider = FutureProvider.autoDispose<ExchangeRate?>((ref) {
  final localService = ref.watch(exchangeRateLocalServiceProvider);
  return localService.getRate();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/integrated_instrument.dart';
import '../repositories/integrated_symbols_repository.dart';

/// 통합 심볼 상태 관리 프로바이더
final integratedSymbolsProvider = StateNotifierProvider<IntegratedSymbolsNotifier, AsyncValue<List<IntegratedInstrument>>>((ref) {
  final repository = ref.watch(integratedSymbolsRepositoryProvider);
  return IntegratedSymbolsNotifier(repository);
});

/// 통합 심볼 상태 관리 노티파이어
class IntegratedSymbolsNotifier extends StateNotifier<AsyncValue<List<IntegratedInstrument>>> {
  final IntegratedSymbolsRepository _repository;

  IntegratedSymbolsNotifier(this._repository) : super(const AsyncValue.loading()) {
    // 초기화 시 저장된 데이터 로드
    loadStoredInstruments();
  }

  /// 저장된 심볼 정보 불러오기
  Future<void> loadStoredInstruments() async {
    try {
      state = const AsyncValue.loading();
      final instruments = await _repository.getStoredInstruments();
      state = AsyncValue.data(instruments);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// API에서 최신 데이터 조회 후 저장
  Future<void> fetchAndSaveInstruments() async {
    try {
      state = const AsyncValue.loading();
      final instruments = await _repository.fetchAndSaveInstruments();
      state = AsyncValue.data(instruments);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 특정 거래소의 심볼만 조회
  Future<void> loadInstrumentsByExchange(String exchange) async {
    try {
      state = const AsyncValue.loading();
      final instruments = await _repository.getInstrumentsByExchange(exchange);
      state = AsyncValue.data(instruments);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 심볼 검색
  Future<void> searchInstruments(String query) async {
    try {
      state = const AsyncValue.loading();
      final instruments = await _repository.searchInstruments(query);
      state = AsyncValue.data(instruments);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 저장된 데이터 삭제
  Future<void> clearStoredData() async {
    try {
      await _repository.clearStoredData();
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 데이터 새로고침
  Future<void> refresh() async {
    await fetchAndSaveInstruments();
  }
}

/// 마지막 업데이트 시간 프로바이더
final lastUpdateTimeProvider = FutureProvider<DateTime?>((ref) async {
  final repository = ref.watch(integratedSymbolsRepositoryProvider);
  return await repository.getLastUpdateTime();
});

/// 저장된 데이터 존재 여부 프로바이더
final hasStoredDataProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(integratedSymbolsRepositoryProvider);
  return await repository.hasStoredData();
});

/// Bybit 심볼만 조회하는 프로바이더
final bybitInstrumentsProvider = FutureProvider<List<IntegratedInstrument>>((ref) async {
  final repository = ref.watch(integratedSymbolsRepositoryProvider);
  return await repository.getBybitInstruments();
});

/// Bithumb 심볼만 조회하는 프로바이더
final bithumbInstrumentsProvider = FutureProvider<List<IntegratedInstrument>>((ref) async {
  final repository = ref.watch(integratedSymbolsRepositoryProvider);
  return await repository.getBithumbInstruments();
});

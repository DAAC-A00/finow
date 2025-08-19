import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/instrument.dart';
import '../repositories/instruments_repository.dart';

/// 통합 심볼 상태 관리 프로바이더
final instrumentsProvider = StateNotifierProvider<InstrumentsNotifier, AsyncValue<List<Instrument>>>((ref) {
  final repository = ref.watch(instrumentsRepositoryProvider);
  return InstrumentsNotifier(repository);
});

/// 통합 심볼 상태 관리 노티파이어
class InstrumentsNotifier extends StateNotifier<AsyncValue<List<Instrument>>> {
  final InstrumentsRepository _repository;

  InstrumentsNotifier(this._repository) : super(const AsyncValue.loading()) {
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



/// 저장된 데이터 존재 여부 프로바이더
final hasStoredDataProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(instrumentsRepositoryProvider);
  return await repository.hasStoredData();
});

/// Bybit 심볼만 조회하는 프로바이더
final bybitInstrumentsProvider = FutureProvider<List<Instrument>>((ref) async {
  final repository = ref.watch(instrumentsRepositoryProvider);
  return await repository.getBybitInstruments();
});

/// Bithumb 심볼만 조회하는 프로바이더
final bithumbInstrumentsProvider = FutureProvider<List<Instrument>>((ref) async {
  final repository = ref.watch(instrumentsRepositoryProvider);
  return await repository.getBithumbInstruments();
});

/// 카테고리별 심볼 조회 프로바이더
final instrumentsByCategoryProvider = FutureProvider.family<List<Instrument>, String>((ref, category) async {
  final repository = ref.watch(instrumentsRepositoryProvider);
  return await repository.getInstrumentsByCategory(category);
});

/// Bybit 카테고리별 심볼 조회 프로바이더
final bybitInstrumentsByCategoryProvider = FutureProvider.family<List<Instrument>, String>((ref, category) async {
  final repository = ref.watch(instrumentsRepositoryProvider);
  return await repository.getBybitInstrumentsByCategory(category);
});

/// Bybit Spot 심볼만 조회하는 프로바이더
final bybitSpotInstrumentsProvider = FutureProvider<List<Instrument>>((ref) async {
  final repository = ref.watch(instrumentsRepositoryProvider);
  return await repository.getBybitSpotInstruments();
});

/// Bybit Linear 심볼만 조회하는 프로바이더
final bybitLinearInstrumentsProvider = FutureProvider<List<Instrument>>((ref) async {
  final repository = ref.watch(instrumentsRepositoryProvider);
  return await repository.getBybitLinearInstruments();
});

/// Bybit Inverse 심볼만 조회하는 프로바이더
final bybitInverseInstrumentsProvider = FutureProvider<List<Instrument>>((ref) async {
  final repository = ref.watch(instrumentsRepositoryProvider);
  return await repository.getBybitInverseInstruments();
});

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ticker_price_data.dart';
import '../repositories/ticker_repository.dart';

/// Ticker 데이터 상태 관리 프로바이더
final tickerRepositoryProvider = Provider<TickerRepository>((ref) {
  return TickerRepository();
});

/// 실시간 통합 ticker 데이터 프로바이더
final liveTickerProvider = StateNotifierProvider<LiveTickerNotifier, AsyncValue<List<IntegratedTickerPriceData>>>((ref) {
  final repository = ref.watch(tickerRepositoryProvider);
  return LiveTickerNotifier(repository);
});

/// 실시간 ticker 데이터 상태 관리 클래스
class LiveTickerNotifier extends StateNotifier<AsyncValue<List<IntegratedTickerPriceData>>> {
  final TickerRepository _repository;
  Timer? _timer;
  bool _isActive = false;

  LiveTickerNotifier(this._repository) : super(const AsyncValue.loading());

  /// 실시간 ticker 데이터 스트림 시작
  void startLiveUpdates() {
    if (_isActive) return;
    
    _isActive = true;
    _loadLiveTickers(); // 즉시 로드
    
    // 1초마다 API 호출
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isActive) {
        _loadLiveTickers();
      }
    });
  }

  /// 실시간 ticker 데이터 스트림 중지
  void stopLiveUpdates() {
    _isActive = false;
    _timer?.cancel();
    _timer = null;
  }

  /// 실시간 ticker 데이터 로드
  Future<void> _loadLiveTickers() async {
    try {
      final tickers = await _repository.getIntegratedLiveTickers();
      if (_isActive) {
        state = AsyncValue.data(tickers);
      }
    } catch (error, stackTrace) {
      if (_isActive) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  /// 수동 새로고침
  Future<void> refreshTickers() async {
    state = const AsyncValue.loading();
    await _loadLiveTickers();
  }

  /// 카테고리별 ticker 데이터 필터링
  List<IntegratedTickerPriceData> getTickersByCategory(String category) {
    return state.when(
      data: (tickers) => category == 'all' 
          ? tickers 
          : tickers.where((ticker) => ticker.category.toLowerCase() == category.toLowerCase()).toList(),
      loading: () => [],
      error: (_, _) => [],
    );
  }

  /// 검색어로 ticker 데이터 필터링
  List<IntegratedTickerPriceData> searchTickers(String query) {
    if (query.isEmpty) return state.value ?? [];
    
    return state.when(
      data: (tickers) {
        final lowerQuery = query.toLowerCase();
        return tickers.where((ticker) =>
            ticker.symbol.toLowerCase().contains(lowerQuery) ||
            ticker.baseCoin.toLowerCase().contains(lowerQuery) ||
            ticker.quoteCoin.toLowerCase().contains(lowerQuery) ||
            (ticker.koreanName?.toLowerCase().contains(lowerQuery) ?? false) ||
            (ticker.englishName?.toLowerCase().contains(lowerQuery) ?? false)
        ).toList();
      },
      loading: () => [],
      error: (_, _) => [],
    );
  }

  /// 상태별 ticker 데이터 필터링
  List<IntegratedTickerPriceData> getTickersByStatus(String status) {
    return state.when(
      data: (tickers) => status == 'all' 
          ? tickers 
          : tickers.where((ticker) => ticker.status == status).toList(),
      loading: () => [],
      error: (_, _) => [],
    );
  }

  /// 복합 필터링 (카테고리 + 검색어 + 상태)
  List<IntegratedTickerPriceData> getFilteredTickers({
    String category = 'all',
    String query = '',
    String status = 'all',
  }) {
    return state.when(
      data: (tickers) {
        var filtered = tickers;
        
        // 카테고리 필터링
        if (category != 'all') {
          filtered = filtered.where((ticker) => ticker.category.toLowerCase() == category.toLowerCase()).toList();
        }
        
        // 검색어 필터링
        if (query.isNotEmpty) {
          final lowerQuery = query.toLowerCase();
          filtered = filtered.where((ticker) =>
              ticker.symbol.toLowerCase().contains(lowerQuery) ||
              ticker.baseCoin.toLowerCase().contains(lowerQuery) ||
              ticker.quoteCoin.toLowerCase().contains(lowerQuery) ||
              (ticker.koreanName?.toLowerCase().contains(lowerQuery) ?? false) ||
              (ticker.englishName?.toLowerCase().contains(lowerQuery) ?? false)
          ).toList();
        }
        
        // 상태 필터링
        if (status != 'all') {
          filtered = filtered.where((ticker) => ticker.status == status).toList();
        }
        
        return filtered;
      },
      loading: () => [],
      error: (_, _) => [],
    );
  }

  @override
  void dispose() {
    stopLiveUpdates();
    super.dispose();
  }
}


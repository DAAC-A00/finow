import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ticker_price_data.dart';
import '../models/ticker_sort_option.dart';
import '../repositories/ticker_repository.dart';

/// Ticker 데이터 상태 관리 프로바이더
final tickerRepositoryProvider = Provider<TickerRepository>((ref) {
  return TickerRepository();
});

/// 현재 정렬 옵션을 관리하는 프로바이더
final tickerSortOptionProvider = StateProvider<TickerSortOption>((ref) => TickerSortOption.turnover24h);

/// 현재 정렬 방향을 관리하는 프로바이더
final sortDirectionProvider = StateProvider<SortDirection>((ref) => SortDirection.desc);

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

  /// 복합 필터링 및 정렬
  List<IntegratedTickerPriceData> getFilteredAndSortedTickers({
    String category = 'all',
    String query = '',
    String status = 'all',
    TickerSortOption sortOption = TickerSortOption.turnover24h,
    SortDirection sortDirection = SortDirection.desc,
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

        // 정렬
        filtered.sort((a, b) {
          int comparison;
          switch (sortOption) {
            case TickerSortOption.symbol:
              comparison = a.symbol.compareTo(b.symbol);
              break;
            case TickerSortOption.koreanName:
              comparison = (a.koreanName ?? '').compareTo(b.koreanName ?? '');
              break;
            case TickerSortOption.lastPrice:
              final aPrice = a.priceData?.lastPriceDouble ?? 0;
              final bPrice = b.priceData?.lastPriceDouble ?? 0;
              comparison = aPrice.compareTo(bPrice);
              break;
            case TickerSortOption.priceChangePercent:
              final aChange = a.priceData?.priceChangePercent ?? 0;
              final bChange = b.priceData?.priceChangePercent ?? 0;
              comparison = aChange.compareTo(bChange);
              break;
            case TickerSortOption.volume24h:
              final aVolume = a.priceData?.volume24hDouble ?? 0;
              final bVolume = b.priceData?.volume24hDouble ?? 0;
              comparison = aVolume.compareTo(bVolume);
              break;
            case TickerSortOption.turnover24h:
              final aTurnover = a.priceData?.turnover24hDouble ?? 0;
              final bTurnover = b.priceData?.turnover24hDouble ?? 0;
              comparison = aTurnover.compareTo(bTurnover);
              break;
          }
          return sortDirection == SortDirection.asc ? comparison : -comparison;
        });
        
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


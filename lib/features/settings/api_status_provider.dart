import 'package:finow/features/instruments/services/exchange_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ApiStatus { unknown, success, failure }

final allApiTargets = [
  'Bybit Spot',
  'Bybit Linear',
  'Bybit Inverse',
  'Bithumb',
  'Binance Spot',
  'Binance USDⓈ-M',
  'Binance COIN-M',
  'Bitget Spot',
  'Bitget USDT-FUTURES',
  'Coinbase',
];

class ApiStatusState {
  final Map<String, ApiStatus> statuses;
  final bool isLoading;

  ApiStatusState({required this.statuses, this.isLoading = false});

  ApiStatusState copyWith({Map<String, ApiStatus>? statuses, bool? isLoading}) {
    return ApiStatusState(
      statuses: statuses ?? this.statuses,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ApiStatusNotifier extends StateNotifier<ApiStatusState> {
  final ExchangeApiService _apiService;

  ApiStatusNotifier(this._apiService) : super(ApiStatusState(statuses: { for (var target in allApiTargets) target: ApiStatus.unknown }));

  Future<void> fetchAllInstruments() async {
    state = state.copyWith(isLoading: true, statuses: { for (var target in allApiTargets) target: ApiStatus.unknown });
    final newStatuses = Map<String, ApiStatus>.from(state.statuses);

    await _apiService.fetchAllInstruments(
      onStatusUpdate: (exchange, status) {
        newStatuses[exchange] = status ? ApiStatus.success : ApiStatus.failure;
        state = state.copyWith(statuses: newStatuses);
      },
    );

    state = state.copyWith(isLoading: false);
  }
}

final apiStatusProvider = StateNotifierProvider<ApiStatusNotifier, ApiStatusState>((ref) {
  final apiService = ref.watch(exchangeApiServiceProvider);
  return ApiStatusNotifier(apiService);
});
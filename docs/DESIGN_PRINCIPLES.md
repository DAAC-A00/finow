# Finow 설계 원칙

## 핵심 설계 철학

### 1. 실시간 금융 서비스 전용 최적화
**목표**: 고빈도 데이터(초당 10회 수준) 수신 시에도 60FPS 이상 유지하며 모든 플랫폼에서 실시간 뷰 갱신

**원칙**:
- Stream 기반 반응형 아키텍처
- 최소한의 리렌더링 범위 (RepaintBoundary 활용)
- 효율적인 상태 관리 (Riverpod의 select, autoDispose)
- 백그라운드 데이터 처리

### 2. 크로스 플랫폼 일관성
**목표**: 하나의 코드베이스로 모바일/데스크톱/웹에서 동일한 사용자 경험 제공

**원칙**:
- Flutter 프레임워크 단독 사용
- 플랫폼별 코드 최소화
- 반응형 UI 설계
- 플랫폼 호환성 우선 (예: Hive vs Isar)

## SOLID 원칙 적용

### 1. 단일 책임 원칙 (SRP)
각 클래스는 하나의 명확한 책임만 가집니다.

```dart
// ✅ 올바른 예시
class ExchangeRateRepository {
  // 오직 환율 데이터 관리만 담당
  Future<List<ExchangeRate>> getAllRates();
  Future<void> saveRates(List<ExchangeRate> rates);
  Future<void> deleteExpiredRates();
}

class ExchangeRateScreen extends ConsumerWidget {
  // 오직 환율 화면 UI 렌더링만 담당
  @override
  Widget build(BuildContext context, WidgetRef ref);
}

class ExchangeRateUpdateService {
  // 오직 환율 업데이트 로직만 담당
  Future<void> updateRatesIfNeeded();
  void startPeriodicUpdates();
  void stopPeriodicUpdates();
}
```

### 2. 개방-폐쇄 원칙 (OCP)
확장에는 열려있고 수정에는 닫혀있는 구조

```dart
// ✅ 추상 인터페이스 정의
abstract class ApiClient {
  Future<List<ExchangeRate>> fetchRates();
}

// 구현체들은 확장 가능
class ExConvertApiClient implements ApiClient {
  @override
  Future<List<ExchangeRate>> fetchRates() => _fetchFromExConvert();
}

class ExchangeRateApiClient implements ApiClient {
  @override
  Future<List<ExchangeRate>> fetchRates() => _fetchFromExchangeRateApi();
}
```

### 3. 리스코프 치환 원칙 (LSP)
상위 타입은 하위 타입으로 대체 가능해야 합니다.

```dart
// ✅ 모든 StorageService 구현체는 동일한 인터페이스 제공
abstract class StorageService {
  Future<T?> read<T>(String key);
  Future<void> write<T>(String key, T value);
}

class HiveStorageService implements StorageService { ... }
class SecureStorageService implements StorageService { ... }
```

### 4. 인터페이스 분리 원칙 (ISP)
클라이언트는 사용하지 않는 메서드에 의존하지 않아야 합니다.

```dart
// ✅ 기능별로 인터페이스 분리
abstract class ReadableStorage {
  Future<T?> read<T>(String key);
}

abstract class WritableStorage {
  Future<void> write<T>(String key, T value);
}

abstract class ClearableStorage {
  Future<void> clear();
  Future<void> delete(String key);
}

// 필요한 인터페이스만 구현
class ReadOnlyCache implements ReadableStorage {
  @override
  Future<T?> read<T>(String key) => _cache[key];
}
```

### 5. 의존성 역전 원칙 (DIP)
고수준 모듈은 저수준 모듈에 의존하지 않고, 추상화에 의존해야 합니다.

```dart
// ✅ 고수준 모듈이 추상화에 의존
class ExchangeRateRepository {
  final ApiClient _apiClient;          // 추상화에 의존
  final StorageService _storage;       // 추상화에 의존
  
  ExchangeRateRepository(this._apiClient, this._storage);
}

// Provider에서 의존성 주입
final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(storageServiceProvider);
  return ExchangeRateRepository(apiClient, storage);
});
```

## 아키텍처 패턴

### Clean Architecture 적용

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Screens   │  │  Providers  │  │   Widgets   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│                     Domain Layer                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Models    │  │   Usecases  │  │Repositories │        │
│  │  (Entities) │  │ (Business   │  │(Interfaces) │        │
│  │             │  │   Logic)    │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ API Clients │  │   Storage   │  │ Repository  │        │
│  │             │  │   Services  │  │Implementations│       │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

### Repository Pattern
```dart
// Domain Layer - 인터페이스
abstract class ExchangeRateRepository {
  Future<List<ExchangeRate>> getAllRates();
  Future<ExchangeRate?> getRate(String baseCode, String quoteCode);
  Future<void> saveRates(List<ExchangeRate> rates);
  Stream<List<ExchangeRate>> watchRates();
}

// Data Layer - 구현
class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  final ExConvertApiClient _apiClient;
  final LocalStorageService _localStorage;
  
  ExchangeRateRepositoryImpl(this._apiClient, this._localStorage);
  
  @override
  Future<List<ExchangeRate>> getAllRates() async {
    try {
      // API에서 최신 데이터 시도
      final rates = await _apiClient.fetchRates();
      await _localStorage.saveRates(rates);
      return rates;
    } catch (e) {
      // 실패 시 로컬 캐시 사용
      return _localStorage.getAllRates();
    }
  }
}
```

## 성능 최적화 설계

### 1. 렌더링 최적화
```dart
// ✅ RepaintBoundary로 렌더링 범위 제한
RepaintBoundary(
  child: ListView.builder(
    itemCount: rates.length,
    itemBuilder: (context, index) => RepaintBoundary(
      child: ExchangeRateListItem(rates[index]),
    ),
  ),
)
```

### 2. 상태 최적화
```dart
// ✅ select를 통한 세밀한 상태 구독
final filteredRates = ref.watch(
  exchangeRateProvider.select((asyncValue) => 
    asyncValue.asData?.value
      .where((rate) => rate.baseCode.contains(searchQuery))
      .toList() ?? []
  )
);
```

### 3. 메모리 최적화
```dart
// ✅ autoDispose로 자동 메모리 관리
final searchResultsProvider = Provider.autoDispose.family<List<ExchangeRate>, String>((ref, query) {
  final allRates = ref.watch(exchangeRateProvider).asData?.value ?? [];
  return allRates.where((rate) => rate.baseCode.contains(query)).toList();
});
```

## 오류 복원력 설계

### 1. Graceful Degradation
```dart
// ✅ API 실패 시 로컬 캐시로 fallback
Future<List<ExchangeRate>> getRates() async {
  try {
    final freshRates = await _apiClient.fetchRates();
    await _localStorage.saveRates(freshRates);
    return freshRates;
  } on NetworkException {
    // 네트워크 오류 시 로컬 데이터 사용
    final cachedRates = await _localStorage.getAllRates();
    if (cachedRates.isNotEmpty) {
      return cachedRates;
    }
    rethrow;
  }
}
```

### 2. 에러 바운더리
```dart
// ✅ 에러 발생 시 부분적 UI 실패만 허용
asyncRates.when(
  loading: () => const ShimmerLoading(),
  error: (error, stack) => ErrorWidget(
    error: error,
    onRetry: () => ref.refresh(exchangeRateProvider),
    fallbackData: _getCachedRates(), // 캐시된 데이터로 fallback
  ),
  data: (rates) => ExchangeRateList(rates: rates),
)
```

### 3. 자동 재시도
```dart
// ✅ Dio interceptor로 자동 재시도 구현
dio.interceptors.add(
  RetryInterceptor(
    dio: dio,
    logPrint: logger.i,
    retries: 3,
    retryDelays: const [
      Duration(seconds: 1),
      Duration(seconds: 2), 
      Duration(seconds: 3),
    ],
  ),
);
```

## 확장성 설계

### 1. Feature-Based 모듈 구조
```
lib/features/
├── exchange_rate/     # 환율 기능 모듈
├── settings/         # 설정 기능 모듈  
├── menu/            # 메뉴 기능 모듈
└── analytics/       # (미래) 분석 기능 모듈
```

### 2. Plugin 아키텍처
```dart
// ✅ 새로운 데이터 소스 쉽게 추가 가능
abstract class ExchangeRateDataSource {
  String get name;
  Future<List<ExchangeRate>> fetchRates();
  Duration get updateInterval;
}

class ExConvertDataSource implements ExchangeRateDataSource {
  @override
  String get name => 'ExConvert';
  
  @override
  Duration get updateInterval => const Duration(minutes: 1);
  
  @override
  Future<List<ExchangeRate>> fetchRates() => _fetchFromExConvert();
}

// 새로운 데이터 소스 추가 시
class CoinGeckoDataSource implements ExchangeRateDataSource { ... }
```

### 3. 설정 기반 기능 토글
```dart
// ✅ 기능별 ON/OFF 가능한 설계
class FeatureFlags {
  static const bool enableRealTimeUpdates = true;
  static const bool enablePushNotifications = false;
  static const bool enableAnalytics = true;
}

// Provider에서 기능 플래그 확인
final realTimeUpdatesProvider = Provider<bool>((ref) {
  return FeatureFlags.enableRealTimeUpdates && 
         ref.watch(settingsProvider).realTimeEnabled;
});
```

## 보안 설계

### 1. 민감한 데이터 보호
```dart
// ✅ API 키 등 민감한 정보는 secure storage 사용
final secureStorage = FlutterSecureStorage();

Future<String?> getApiKey() async {
  return await secureStorage.read(key: 'api_key');
}
```

### 2. 입력 데이터 검증
```dart
// ✅ 사용자 입력 및 API 응답 검증
class ExchangeRate {
  final String baseCode;
  final String quoteCode;
  final double price;
  
  ExchangeRate({
    required this.baseCode,
    required this.quoteCode,
    required this.price,
  }) {
    if (baseCode.length != 3) throw ArgumentError('Invalid base code');
    if (quoteCode.length != 3) throw ArgumentError('Invalid quote code');
    if (price <= 0) throw ArgumentError('Price must be positive');
  }
}
```

## 테스트 가능한 설계

### 1. 의존성 주입
```dart
// ✅ 테스트에서 mock 객체 쉽게 주입 가능
class ExchangeRateRepository {
  final ApiClient apiClient;
  final StorageService storage;
  
  ExchangeRateRepository({
    required this.apiClient,
    required this.storage,
  });
}

// 테스트에서
final mockApiClient = MockApiClient();
final mockStorage = MockStorageService();
final repository = ExchangeRateRepository(
  apiClient: mockApiClient,
  storage: mockStorage,
);
```

### 2. 순수 함수 선호
```dart
// ✅ 부수 효과 없는 순수 함수로 설계
List<ExchangeRate> filterRatesBySearchQuery(
  List<ExchangeRate> rates,
  String query,
) {
  return rates
    .where((rate) => 
      rate.baseCode.toLowerCase().contains(query.toLowerCase()) ||
      rate.quoteCode.toLowerCase().contains(query.toLowerCase())
    )
    .toList();
}
```

이러한 설계 원칙들을 따라 개발함으로써 유지보수성, 확장성, 성능, 안정성을 모두 확보한 금융 애플리케이션을 구축할 수 있습니다.
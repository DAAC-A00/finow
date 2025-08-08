# Finow 코딩 표준 및 규칙

## 파일 및 디렉토리 명명 규칙

### 파일명
- **Flutter 파일**: `snake_case.dart`
- **화면 파일**: `*_screen.dart`
- **모델 파일**: `*.dart` (예: `exchange_rate.dart`)
- **Provider 파일**: `*_provider.dart`
- **Repository 파일**: `*_repository.dart`
- **Service 파일**: `*_service.dart`

### 디렉토리명
**기능별 모듈화**: features/ 하위에 exchange_rate, settings, menu 등 snake_case로 구성

👉 **전체 폴더 구조**: UI Guide의 **Architecture** 탭에서 확인하세요

## 클래스 및 변수 명명 규칙

### 클래스명
**PascalCase 사용**: ExchangeRateScreen, FontSizeProvider, ExchangeRateRepository

**금지**: snake_case, 언더스코어 사용

### 변수명
**camelCase 사용**: baseCode, exchangeRate, filteredRates

**금지**: snake_case(상수 전용), PascalCase

### 상수명
**UPPER_SNAKE_CASE**: API_BASE_URL, MAX_RETRY_COUNT, DEFAULT_FONT_SCALE

**Private 상수**: _privateConstant

## 위젯 작성 규칙

### 1. const 생성자 사용 원칙
```dart
// ✅ 올바른 예시
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Text('Static content');  // const 사용
  }
}

// ❌ 잘못된 예시
return Text('Static content');  // const 누락
```

### 2. 위젯 분리 원칙
```dart
// ✅ 올바른 예시 - 단일 책임 원칙
class ExchangeRateScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }
  
  PreferredSizeWidget _buildAppBar() => AppBar(title: const Text('Exchange Rate'));
  Widget _buildBody() => const ExchangeRateList();
}

// ❌ 잘못된 예시 - 하나의 위젯에 모든 것을 구현
class ExchangeRateScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(/* 복잡한 앱바 코드 */),
      body: Column(children: [
        /* 100줄 넘는 복잡한 body 코드 */
      ]),
    );
  }
}
```

### 3. 스케일링 위젯 사용
**필수 사용**: ScaledIcon, ScaledAssetImage 등 스케일링 위젯만 사용

**금지**: 일반 Icon, Image.asset 사용

👉 **구현 예시**: UI Guide의 **Scaling** 탭에서 확인하세요

## Provider 작성 규칙

### 1. Provider 명명
**패턴별 명명**: exchangeRateProvider, fontSizeNotifierProvider, searchQueryProvider

👉 **구현 예시**: UI Guide의 **Providers** 탭에서 확인하세요

### 2. Provider 구조
```dart
// ✅ 올바른 예시
class ExchangeRateNotifier extends AsyncNotifier<List<ExchangeRate>> {
  @override
  Future<List<ExchangeRate>> build() async {
    final repository = ref.watch(exchangeRateRepositoryProvider);
    return repository.getAllRates();
  }
  
  Future<void> refreshRates() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(exchangeRateRepositoryProvider);
      final rates = await repository.fetchLatestRates();
      state = AsyncValue.data(rates);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
```

### 3. 상태 구독 최적화
```dart
// ✅ 올바른 예시 - select 사용으로 세밀한 구독
final filteredRates = ref.watch(exchangeRateProvider.select((asyncValue) => 
  asyncValue.asData?.value.where((rate) => rate.baseCode == 'USD').toList() ?? []
));

// ❌ 잘못된 예시 - 전체 상태 구독
final asyncRates = ref.watch(exchangeRateProvider);  // 불필요한 rebuild 발생 가능
```

## 에러 핸들링 규칙

### 1. API 호출 에러 처리
```dart
// ✅ 올바른 예시
Future<List<ExchangeRate>> fetchRates() async {
  try {
    final response = await dio.get('/exchange-rates');
    return response.data.map((json) => ExchangeRate.fromJson(json)).toList();
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      throw NetworkException('Connection timeout');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      throw NetworkException('Receive timeout');
    } else {
      throw ApiException('Failed to fetch rates: ${e.message}');
    }
  } catch (e) {
    throw UnknownException('Unexpected error: $e');
  }
}
```

### 2. UI 에러 표시
```dart
// ✅ 올바른 예시
asyncRates.when(
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget.withDetails(
    message: 'Failed to load data',
    error: error,
  ),
  data: (rates) => RatesList(rates: rates),
);
```

## 비동기 처리 규칙

### 1. Future vs Stream 사용 기준
```dart
// ✅ Future 사용 - 일회성 비동기 작업
Future<List<ExchangeRate>> fetchRates() async { ... }

// ✅ Stream 사용 - 연속적인 데이터 스트림
Stream<List<ExchangeRate>> watchRates() { ... }
```

### 2. 비동기 상태 관리
```dart
// ✅ 올바른 예시 - AsyncNotifier 사용
class DataNotifier extends AsyncNotifier<List<Data>> {
  @override
  Future<List<Data>> build() async {
    // 초기 데이터 로드
    return _loadInitialData();
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchFreshData());
  }
}
```

## 로깅 규칙

### 1. 로그 레벨 사용
```dart
import 'package:logger/logger.dart';

final logger = Logger();

// ✅ 올바른 예시
logger.d('Debug info: $debugData');  // 개발 시에만
logger.i('User action: refresh rates');  // 일반 정보
logger.w('Warning: API response delayed');  // 주의사항
logger.e('Error: Failed to save data', error, stackTrace);  // 에러
```

### 2. 민감한 정보 로깅 금지
```dart
// ❌ 잘못된 예시
logger.i('API Key: $apiKey');  // 민감한 정보 로깅 금지
logger.i('User password: $password');  // 보안 위험

// ✅ 올바른 예시
logger.i('API call successful');  // 일반적인 상태 정보
logger.i('User authenticated');  // 민감한 정보 제외
```

## 테스트 작성 규칙

### 1. 테스트 파일 구조
```
test/
├── unit/
│   ├── providers/
│   ├── repositories/
│   └── services/
├── widget/
│   ├── screens/
│   └── components/
└── integration/
    └── app_test.dart
```

### 2. 테스트 명명
```dart
// ✅ 올바른 예시
group('ExchangeRateNotifier', () {
  test('should load initial rates on build', () async {
    // given
    final container = ProviderContainer();
    
    // when
    final notifier = container.read(exchangeRateProvider.notifier);
    
    // then
    expect(container.read(exchangeRateProvider), isA<AsyncLoading>());
  });
  
  test('should refresh rates when refresh() is called', () async {
    // Test implementation
  });
});
```

## 성능 최적화 규칙

### 1. 빌드 메서드 최적화
```dart
// ✅ 올바른 예시
@override
Widget build(BuildContext context) {
  return RepaintBoundary(  // 리페인트 경계 설정
    child: Column(
      children: [
        const StaticHeader(),  // const 위젯
        Expanded(
          child: ListView.builder(  // 지연 로딩
            itemCount: items.length,
            itemBuilder: (context, index) => ItemWidget(items[index]),
          ),
        ),
      ],
    ),
  );
}

// ❌ 잘못된 예시
@override
Widget build(BuildContext context) {
  return Column(
    children: items.map((item) => ItemWidget(item)).toList(),  // 모든 아이템 한 번에 생성
  );
}
```

### 2. 메모리 관리
```dart
// ✅ 올바른 예시 - autoDispose 사용
final temporaryProvider = Provider.autoDispose<String>((ref) {
  final resource = ExpensiveResource();
  ref.onDispose(() => resource.dispose());
  return resource.data;
});
```

## 플랫폼 대응 규칙

### 1. 플랫폼 분기 처리
```dart
// ✅ 올바른 예시
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

Widget buildPlatformSpecificWidget() {
  if (kIsWeb) {
    return WebSpecificWidget();
  } else if (Platform.isIOS) {
    return IOSSpecificWidget();
  } else if (Platform.isAndroid) {
    return AndroidSpecificWidget();
  } else {
    return DefaultWidget();
  }
}
```

### 2. 반응형 레이아웃
```dart
// ✅ 올바른 예시
@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return DesktopLayout();
      } else if (constraints.maxWidth > 600) {
        return TabletLayout();
      } else {
        return MobileLayout();
      }
    },
  );
}
```

## 코드 리뷰 체크리스트

### 필수 확인 항목
- [ ] const 생성자 사용 여부
- [ ] 위젯 단일 책임 원칙 준수
- [ ] 적절한 Provider 사용
- [ ] 에러 처리 구현
- [ ] 스케일링 위젯 사용 (UI 요소)
- [ ] 메모리 누수 방지 (autoDispose 등)
- [ ] 플랫폼별 대응 (필요한 경우)
- [ ] 테스트 코드 작성 (중요한 로직)
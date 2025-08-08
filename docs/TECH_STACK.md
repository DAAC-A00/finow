# Finow 기술 스택

## 프레임워크 & 언어

### Flutter
- **Dart SDK**: ^3.8.1 (실제 사용 중)
- **플랫폼**: iOS, Android, Web, macOS, Windows, Linux  
- **용도**: 크로스 플랫폼 UI 개발
- **특징**: Material Design 3, 60FPS 성능 목표

## 상태 관리

### Riverpod (실제 사용 중)
- **패키지**: `flutter_riverpod: ^2.6.1`
- **용도**: 앱 전체 상태 관리
- **실제 사용 패턴**:
  - `AsyncNotifier` - 환율 데이터 (ExchangeRateNotifier)
  - `StateNotifier` - Admin Mode (AdminModeNotifier)  
  - `StateProvider` - 검색어 등 단순 상태
  - `FutureProvider` - 읽기 전용 비동기 데이터
  - `Provider` - 서비스 인스턴스 관리

## 로컬 데이터베이스

### Hive (실제 사용 중)
- **패키지**: `hive: ^2.2.3`, `hive_flutter: ^1.1.0`
- **용도**: 로컬 데이터 저장소
- **특징**:
  - NoSQL 키-값 데이터베이스
  - 웹 지원 (IndexedDB 사용)
  - 빠른 읽기/쓰기 성능
  - 타입 안전한 어댑터 시스템

### 데이터 모델
```dart
@HiveType(typeId: 0)
class ExchangeRate {
  @HiveField(0) String baseCode;
  @HiveField(1) String quoteCode;
  @HiveField(2) double price;
  @HiveField(3) int lastUpdatedUnix;
  @HiveField(4) String source;
}
```

## 네트워킹

### Dio (실제 사용 중)
- **패키지**: `dio: ^5.5.0+1`
- **용도**: HTTP 클라이언트
- **기능**:
  - Request/Response 인터셉터
  - 자동 재시도 로직
  - 타임아웃 설정
  - 에러 핸들링

### API 엔드포인트
```dart
// ExConvert API
final exconvertClient = Dio()..options.baseUrl = 'https://api.exconvert.com';

// ExchangeRate API  
final exchangeRateClient = Dio()..options.baseUrl = 'https://v6.exchangerate-api.com';
```

## 라우팅

### GoRouter (실제 사용 중)
- **패키지**: `go_router: ^16.0.0`
- **용도**: 선언적 라우팅
- **특징**:
  - URL 기반 네비게이션
  - 웹 브라우저 히스토리 지원
  - 중첩 라우팅
  - 타입 안전한 라우트 파라미터

### 라우팅 구조
```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/exchange', builder: (context, state) => ExchangeRateScreen()),
    GoRoute(path: '/exchange/:code', builder: (context, state) => ExchangeRateDetailScreen()),
    GoRoute(path: '/settings', builder: (context, state) => SettingsScreen()),
    GoRoute(path: '/menu', builder: (context, state) => MenuScreen()),
  ],
);
```

## UI 스케일링 시스템

### 폰트 크기 관리
- **Provider**: `FontSizeNotifier` (Riverpod)
- **옵션**: Small (0.9x), Medium (1.0x), Large (1.1x)
- **적용 방식**: MediaQuery `textScaler` + UIScaleProvider

### 반응형 컴포넌트
```dart
ScaledIcon(Icons.home, size: 24)  // 스케일링 적용된 아이콘
ScaledAssetImage('assets/logo.png', baseWidth: 40, baseHeight: 40)  // 스케일링 적용된 이미지
```

## 데이터 소스

### ExConvert API
- **URL**: `https://api.exconvert.com/exchange-rates`
- **업데이트 주기**: 1분마다
- **데이터**: 실시간 환율 정보 (143개 통화 쌍)

### ExchangeRate-API
- **URL**: `https://v6.exchangerate-api.com/v6/latest/USD`
- **업데이트 주기**: 일 1회
- **용도**: 누락된 환율 정보 보완

## 개발 도구

### 코드 생성 (실제 사용 중)
- **build_runner**: `^2.4.11` - Hive 어댑터 생성
- **hive_generator**: `^2.0.1` - Hive 타입 어댑터 생성
- **json_annotation**: `^4.9.0` - JSON 직렬화
- **json_serializable**: `^6.8.0` - JSON 코드 생성

### 로깅
- **logger**: 구조화된 로깅
- **레벨**: debug, info, warning, error

### 유틸리티 (실제 사용 중)
- **intl**: `^0.19.0` - 날짜 포맷팅 (환율 데이터)
- **lottie**: `^3.1.2` - 애니메이션 (UI 가이드)
- **cupertino_icons**: `^1.0.8` - iOS 스타일 아이콘
- **fluttertoast**: `^8.2.6` - 토스트 메시지

## 테마 시스템

### Material Design 3
```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light, // 또는 dark
  ),
  useMaterial3: true,
)
```

### 다크 모드 지원
- 시스템 설정 따름 (기본값)
- 라이트 모드 강제
- 다크 모드 강제

## 플랫폼 지원

### 웹 (Web)
- **엔진**: CanvasKit
- **특징**: IndexedDB를 통한 Hive 지원
- **제약**: 일부 네이티브 기능 제한

### 모바일 (iOS/Android)
- **저장소**: 네이티브 파일 시스템
- **네트워킹**: 네이티브 HTTP 스택

### 데스크톱 (macOS/Windows/Linux)
- **창 관리**: Flutter 데스크톱 플러그인
- **파일 시스템**: 플랫폼별 경로 지원

## 성능 최적화

### 위젯 최적화
```dart
const Text('Static Text')  // const 생성자 사용
RepaintBoundary(child: ComplexWidget())  // 리페인트 경계 설정
ListView.builder(itemBuilder: ...)  // 지연 로딩 리스트
```

### 상태 최적화
```dart
ref.watch(provider.select((state) => state.specificField))  // 세밀한 구독
ref.watch(providerFamily(id).autoDispose)  // 자동 메모리 정리
```

### 네트워크 최적화
```dart
dio.options.connectTimeout = Duration(seconds: 5);
dio.options.receiveTimeout = Duration(seconds: 3);
```

## 빌드 및 배포

### 환경별 빌드
```bash
flutter build web --release  # 웹 빌드
flutter build apk --release  # Android APK
flutter build ios --release  # iOS 빌드
flutter build macos --release  # macOS 빌드
```

### 설정 파일
- `analysis_options.yaml`: 코드 분석 규칙
- `build.yaml`: 코드 생성 설정
- `pubspec.yaml`: 의존성 관리
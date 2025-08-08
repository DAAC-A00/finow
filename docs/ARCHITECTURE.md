# Finow 아키텍처 가이드

## 시스템 아키텍처

### 전체 구조
```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App (Finow)                      │
├─────────────────────────────────────────────────────────────┤
│                        UI Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Exchange   │  │  Settings   │  │     Menu    │        │
│  │    Rate     │  │   Screen    │  │   Screen    │   ...  │
│  │   Screen    │  │             │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│                    State Management                         │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   Riverpod Providers                    │ │
│  │  - ExchangeRateProvider                                 │ │
│  │  - FontSizeProvider                                     │ │
│  │  - ThemeModeProvider                                    │ │
│  │  - AdminModeProvider                                    │ │
│  └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                    Business Logic                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Exchange   │  │   Storage   │  │   Update    │        │
│  │    Rate     │  │   Viewer    │  │   Service   │   ...  │
│  │ Repository  │  │   Service   │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│                     Data Layer                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │    Hive     │  │   HTTP/API  │  │    Local    │        │
│  │  (Local     │  │ (ExConvert, │  │  Storage    │   ...  │
│  │  Storage)   │  │ Exchange-   │  │  Service    │        │
│  │             │  │ rate API)   │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## 폴더 구조

### 주요 디렉토리
```
lib/
├── features/          # 기능별 모듈화
│   ├── exchange_rate/ # 환율 관련 기능
│   ├── settings/      # 설정 관련 기능
│   ├── menu/         # 메뉴 관련 기능
│   └── ...
├── screens/          # 공통 화면
├── routing/          # 라우팅 설정
├── main.dart         # 앱 진입점
├── theme_provider.dart
├── font_size_provider.dart
└── ui_scale_provider.dart
```

### Feature 구조 (예: exchange_rate)
```
features/exchange_rate/
├── exchange_rate.dart              # 데이터 모델
├── exchange_rate.g.dart           # 생성된 파일 (Hive 어댑터)
├── exchange_rate_screen.dart      # 메인 화면
├── exchange_rate_detail_screen.dart # 상세 화면
├── exchange_rate_provider.dart    # 상태 관리
├── exchange_rate_repository.dart  # 데이터 레포지토리
├── exchange_rate_local_service.dart # 로컬 스토리지 서비스
├── exchange_rate_update_service.dart # 업데이트 서비스
├── exconvert_api_client.dart      # API 클라이언트
└── exconvert_periodic_update_service.dart # 주기적 업데이트
```

## 데이터 플로우

### 환율 데이터 플로우
```
External API → API Client → Repository → Provider → UI
     ↓
  Local Cache (Hive) ← Repository
```

1. **API 클라이언트**가 외부 API에서 데이터를 가져옴
2. **Repository**가 데이터를 정제하고 로컬 캐시에 저장
3. **Provider**가 데이터 상태를 관리하고 UI에 제공
4. **UI**가 Provider를 통해 데이터를 구독하고 표시

### 상태 관리 패턴
```
User Action → Provider.notifier → Repository → Local Storage/API
     ↑                                              ↓
    UI ← Provider (State) ← Repository Response ← Data
```

## 핵심 설계 원칙

### 1. 단일 책임 원칙 (SRP)
- 각 클래스와 함수는 하나의 명확한 책임만 가집니다
- Screen은 UI 렌더링만, Repository는 데이터 관리만, Service는 비즈니스 로직만

### 2. 의존성 역전 원칙 (DIP)
- 상위 수준 모듈은 하위 수준 모듈에 의존하지 않음
- Provider → Repository → Service 구조로 추상화

### 3. 관심사 분리 (SoC)
- UI, 비즈니스 로직, 데이터 레이어 명확히 분리
- Feature 단위로 모듈화하여 응집도 높이고 결합도 낮춤

### 4. 반응형 프로그래밍
- Stream 기반의 반응형 데이터 플로우
- Provider를 통한 상태 변경 감지 및 UI 업데이트

## 성능 최적화 전략

### 1. 위젯 최적화
- `const` 생성자 사용으로 불필요한 재빌드 방지
- `RepaintBoundary`로 렌더링 영역 제한
- `ListView.builder`로 대용량 리스트 최적화

### 2. 상태 관리 최적화
- `select`를 통한 세밀한 상태 구독
- `autoDispose`로 메모리 누수 방지
- 필요한 부분만 리빌드하는 Provider 설계

### 3. 데이터 최적화
- Hive를 통한 효율적인 로컬 캐싱
- API 응답 최소화를 위한 diff 기반 업데이트
- 주기적 업데이트의 백그라운드 처리

### 4. 메모리 관리
- 불필요한 리소스 해제
- 이미지 캐싱 최적화
- Stream 구독 해제 관리

## 확장성 고려사항

### 1. 새로운 기능 추가 시
1. `features/` 아래에 새 디렉토리 생성
2. Screen, Provider, Repository, Service 패턴 유지
3. 라우팅 설정 업데이트
4. 메뉴 시스템에 추가

### 2. 새로운 데이터 소스 추가 시
1. 새 API Client 또는 Service 생성
2. Repository에 데이터 소스 추가
3. 모델 업데이트 (필요한 경우)
4. Provider 로직 업데이트

### 3. 새로운 플랫폼 지원 시
1. 플랫폼별 코드 분기 (`kIsWeb`, `Platform.isXXX`)
2. 플랫폼별 서비스 구현
3. UI 레이아웃 대응 (반응형 디자인)
4. 플랫폼별 테스트 추가
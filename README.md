# Finow - 실시간 금융 서비스

## 프로젝트 개요

**Finow**는 고빈도 데이터(초당 10회 수준) 수신이 가능한 크로스 플랫폼 실시간 금융 서비스입니다. Flutter를 기반으로 모바일(iOS/Android), 데스크톱(macOS/Windows/Linux), 웹 플랫폼에서 동일한 사용자 경험을 제공합니다.

### 주요 기능
- 실시간 환율 정보 (143개 통화 쌍)
- 사용자 맞춤형 폰트 크기 조절
- 다크/라이트 테마 지원
- 오프라인 데이터 캐싱
- 관리자 모드 및 개발자 도구

### 성능 특징
- **60FPS 이상** 실시간 뷰 갱신 보장
- **1분 주기** 자동 데이터 업데이트
- **오프라인 모드** 지원 (로컬 캐시 활용)
- **반응형 UI** (모든 화면 크기 대응)

## AI 개발자 협업 가이드

### 🚀 AI 개발자 필수 가이드

**AI 개발자는 개발 작업 시작 전 다음 순서로 문서를 읽어야 합니다:**

1. **[GEMINI.md](GEMINI.md)** 👈 **AI 개발자 필수 가이드**
   - 개발 워크플로우 안내
   - 하나의 마스터 Ground Rule 문서 참조 방법

2. **[docs/GROUND_RULES.md](docs/GROUND_RULES.md)** 👈 **마스터 Ground Rule**
   - 모든 개발 규칙이 통합된 핵심 문서
   - 95% 개발 작업을 이 문서만으로 수행 가능
   - 필요시 상세 문서 참조 가이드 포함

3. **상세 참조 문서들** (필요시에만)
   - [DESIGN_PRINCIPLES.md](docs/DESIGN_PRINCIPLES.md) - 상세 설계 원칙
   - [ARCHITECTURE.md](docs/ARCHITECTURE.md) - 시스템 구조 세부사항  
   - [CODING_STANDARDS.md](docs/CODING_STANDARDS.md) - 상세 코딩 규칙
   - [TECH_STACK.md](docs/TECH_STACK.md) - 기술 스택 상세 정보 (v2.0 업데이트)
   - [SCALING_GUIDE.md](docs/SCALING_GUIDE.md) - UI 스케일링 구현 세부사항
   - [DARK_LIGHT_MODE_GUIDE.md](docs/DARK_LIGHT_MODE_GUIDE.md) - 다크/라이트모드 개발 가이드라인

4. **자동 업데이트 시스템** 🔄
   - [DYNAMIC_RULE_UPDATE_SYSTEM.md](docs/DYNAMIC_RULE_UPDATE_SYSTEM.md) - 동적 규칙 업데이트 시스템
   - 사용자 요구사항이 기존 규칙과 충돌할 때 AI가 자동으로 docs 업데이트
   - 버전 관리 및 변경 추적 시스템

## 기술 스택

### 프레임워크 & 언어
- **Flutter** (Latest Stable) - 크로스 플랫폼 UI 프레임워크
- **Dart 3.x** - 프로그래밍 언어

### 상태 관리
- **Riverpod** - 타입 안전한 상태 관리
- **AsyncNotifier** - 비동기 상태 처리
- **Provider Family** - 파라미터화된 상태

### 데이터 관리
- **Hive** - 로컬 NoSQL 데이터베이스 (웹 호환)
- **Dio** - HTTP 클라이언트 (자동 재시도, 에러 처리)
- **go_router** - URL 기반 라우팅

### 외부 API
- **ExConvert API** - 1분 주기 실시간 환율 데이터
- **ExchangeRate-API** - 일 1회 환율 데이터 보완

### UI 시스템
- **Material Design 3** - 디자인 시스템
- **다크/라이트 테마** - 완전한 다크모드/라이트모드 지원
- **커스텀 스케일링** - 사용자 설정 기반 폰트/이미지 크기 조절

## 프로젝트 구조

```
finow/
├── README.md                    # 프로젝트 메인 인덱스 (현재 파일)
├── GEMINI.md                    # AI 개발자 가이드 (우선순위 1)
├── docs/                        # 상세 문서
│   ├── GROUND_RULES.md         # 🎯 마스터 Ground Rule (v2.0)
│   ├── DYNAMIC_RULE_UPDATE_SYSTEM.md # 🔄 동적 규칙 업데이트 시스템
│   ├── DESIGN_PRINCIPLES.md     # 설계 원칙 (SOLID, Clean Architecture)
│   ├── ARCHITECTURE.md          # 시스템 아키텍처 및 데이터 플로우
│   ├── CODING_STANDARDS.md      # 코딩 표준 및 네이밍 규칙
│   ├── TECH_STACK.md           # 기술 스택 상세 정보 (v2.0)
│   ├── SCALING_GUIDE.md        # UI 스케일링 시스템 가이드
│   └── DARK_LIGHT_MODE_GUIDE.md # 다크/라이트모드 개발 가이드라인
├── lib/                        # 소스 코드
│   ├── features/               # 기능별 모듈
│   │   ├── exchange_rate/      # 환율 기능
│   │   ├── settings/          # 설정 기능
│   │   └── menu/             # 메뉴 기능
│   ├── screens/              # 공통 화면
│   ├── routing/              # 라우팅 설정
│   └── main.dart            # 앱 진입점
└── assets/                  # 정적 리소스
```

## AI 개발자를 위한 작업 흐름

### 🎯 간소화된 개발 프로세스

**모든 개발 작업은 다음 간단한 3단계로 수행:**

```
1. GEMINI.md 읽기 (30초) 📖
2. docs/GROUND_RULES.md 읽기 (5분) 🎯  
3. 개발 작업 수행 (필요시 상세 문서 참조) 💻
```

### ✨ 장점
- **단순함**: 하나의 마스터 문서로 95% 작업 커버
- **일관성**: IDE에 관계없이 동일한 개발 경험
- **효율성**: 문서 읽기 시간 최소화
- **완전성**: 필요한 모든 규칙이 한 곳에 통합

## 빠른 시작

### 환경 설정
```bash
# Flutter 설치 확인
flutter doctor

# 의존성 설치
flutter pub get

# 코드 생성 (Hive 어댑터)
flutter packages pub run build_runner build
```

### 실행
```bash
# 디버그 모드 실행
flutter run

# 웹에서 실행
flutter run -d web

# 릴리즈 빌드
flutter build apk --release
```

### 주요 개발 도구
```bash
# 코드 분석
flutter analyze

# 테스트 실행  
flutter test

# 핫 리로드 (개발 중)
r (터미널에서)
```

## 개발팀 정보

### 프로젝트 관리
- **언어**: 한국어 (모든 주석 및 문서)
- **AI 협업**: Claude/Gemini 기반 개발 워크플로우
- **버전 관리**: Git (GitHub)

### 품질 보증
- **코드 분석**: `analysis_options.yaml` 기반
- **테스트**: Unit/Widget/Integration 테스트
- **성능 모니터링**: Flutter DevTools

### 배포 대상
- **모바일**: iOS App Store, Google Play Store  
- **웹**: 웹 애플리케이션 배포
- **데스크톱**: macOS/Windows/Linux 네이티브 앱

---

## 중요한 알림 ⚠️

**AI 개발자는 개발 작업을 시작하기 전에 반드시 다음 순서를 따라야 합니다:**

1. **[GEMINI.md](GEMINI.md)** 읽기 (AI 개발자 가이드)
2. **[docs/GROUND_RULES.md](docs/GROUND_RULES.md)** 읽기 (마스터 Ground Rule)

**이 두 문서만 읽으면 Finow 프로젝트의 모든 개발 규칙을 숙지할 수 있습니다.** 다른 IDE를 사용하더라도 동일한 품질과 일관성을 유지할 수 있습니다.
# Finow 프로젝트 Ground Rules (마스터 가이드) - v2.0

**🎯 실제 코드베이스 분석을 통해 업데이트된 통합 개발 가이드입니다.**

## 🚀 AI 개발자 필수 숙지 사항

### 핵심 프로젝트 정보
- **프로젝트**: 실시간 금융 서비스 (고빈도 환율 데이터 처리)
- **목표 성능**: 60FPS 이상 실시간 뷰 갱신
- **플랫폼**: Flutter 크로스 플랫폼 (iOS/Android/Web/Desktop)
- **데이터 주기**: 1분마다 환율 업데이트
- **특별 기능**: Admin Mode, UI 스케일링, 개발자 도구

## 📋 작업 유형별 필수 적용 규칙

### 🏗️ 모든 개발 작업 공통 규칙

#### 1. 실제 구현된 아키텍처 패턴
**폴더 구조**: features/[feature_name]/ 내부에 screen, provider, repository, local_service, api_client, update_service, model 파일들을 분리하여 구현

👉 **상세 구조와 예시**: UI Guide의 **Architecture** 탭에서 확인하세요

#### 2. 실제 사용되는 상태 관리 패턴들
**5가지 Provider 패턴**: AsyncNotifier(비동기 데이터), StateNotifier(복잡한 상태), StateProvider(간단한 상태), FutureProvider(읽기 전용), Provider(서비스 인스턴스)

👉 **구체적인 구현과 예시**: UI Guide의 **Providers** 탭에서 확인하세요

#### 3. 실제 사용 중인 네이밍 규칙 (엄격 준수)
- **파일명**: `snake_case.dart` (실제 적용됨)
- **클래스명**: `PascalCase` (실제 적용됨)
- **변수/함수명**: `camelCase` (실제 적용됨)
- **상수명**: `_privateConst` 또는 `PUBLIC_CONST`
- **Provider명**: 
  - `[feature]Provider` (Repository/Service)
  - `[feature]NotifierProvider` (StateNotifier/AsyncNotifier)
  - `[state]Provider` (StateProvider)

#### 4. 실제 기술 스택 (정확히 사용할 것)
**핵심 패키지들**: flutter_riverpod(^2.6.1), go_router(^16.0.0), hive(^2.2.3), dio(^5.5.0+1) 등

👉 **전체 목록과 버전**: `docs/TECH_STACK.md` 참조

### 🎨 UI 개발 필수 규칙 (실제 구현 기반)

#### 1. 스케일링 시스템 (100% 준수)
**기본 원리**: MediaQuery textScaler + UIScaleProvider 조합으로 글자 및 이미지 자동 스케일링

**필수 사용**: ScaledIcon(모든 아이콘), ScaledAssetImage(모든 이미지), 일반 Text(자동 스케일링)

👉 **구현 방법과 예시**: UI Guide의 **Scaling** 탭에서 확인하세요

#### 2. 실제 구현된 메뉴 시스템 패턴
**Repository 패턴**: Admin Mode 상태에 따라 동적으로 메뉴 제공

**메뉴 구조**: 기본 메뉴(Home, Exchange Rate, Menu, Settings) + Admin 전용(Storage, UI Guide)

👉 **구현 방법**: UI Guide의 **Architecture** 탭에서 확인하세요

#### 3. 실제 Model 구조 (Hive + JSON)
**이중 직렬화**: @HiveType + @JsonSerializable 어노테이션으로 JSON API와 로컬 DB 모두 지원

👉 **구체적인 구현**: UI Guide의 **Architecture** 탭에서 확인하세요

### 🔧 실제 구현된 서비스 패턴들

#### 1. Local Storage Service 패턴
**Hive 박스 관리**: 타입별로 박스를 분리하여 처리 (settings, exchangeRates)

👉 **구현 예시**: UI Guide의 **Architecture** 탭에서 확인하세요

#### 2. Repository + Service 분리 패턴
**책임 분리**: API Client(외부 API), Repository(비즈니스 로직), Local Service(로컬 저장)

👉 **구현 예시**: UI Guide의 **Architecture** 탭에서 확인하세요

#### 3. 실제 라우팅 구조
**이중 구조**: ShellRoute(하단 네비게이션) + GoRoute(상세 화면), NoTransitionPage로 전환 애니메이션 제거

👉 **구현 예시**: UI Guide의 **Architecture** 탭에서 확인하세요

## 🚨 실제 코드베이스 기반 금지 사항

### 절대 사용 금지
- **Isar** (웹 호환성 없음) → Hive 사용
- **직접 setState** → Riverpod Provider 사용  
- **GlobalKey** (성능 이슈, 단 라우팅 제외)
- **하드코딩된 메뉴** → MenuRepository 패턴 사용

### 실제 프로젝트 특별 규칙
- **Admin Mode 체크 필수**: 개발자 도구 접근 시
- **MediaQuery textScaler 의존**: 일반 Text 위젯 사용
- **NoTransitionPage 사용**: 페이지 전환 애니메이션 제거
- **Hive Box 타입 분리**: settings(일반), exchangeRates(타입드)

## ⚡ 빠른 개발 시작 체크리스트 (실제 프로젝트 기반)

### 새 기능 개발 시
- [ ] `features/[feature_name]/` 디렉토리 생성
- [ ] Model 클래스: `@HiveType` + `@JsonSerializable` 추가
- [ ] Provider: 적절한 패턴 선택 (AsyncNotifier/StateNotifier/StateProvider)
- [ ] Repository/Service 분리 구현
- [ ] MenuRepository에 메뉴 추가 (필요시)
- [ ] 라우팅에 경로 추가 (ShellRoute vs GoRoute 구분)

### UI 컴포넌트 작업 시
- [ ] ScaledIcon/ScaledAssetImage 사용 확인
- [ ] 일반 Text 위젯 사용 (MediaQuery textScaler 적용됨)
- [ ] const 생성자 사용
- [ ] Admin Mode 체크 (개발자 도구인 경우)

### Admin 기능 개발 시
- [ ] AdminModeProvider 상태 확인
- [ ] MenuRepository에 admin 전용 메뉴 추가
- [ ] showInBottomNav: false 설정 (일반적으로)

## 📚 복잡한 작업 시 참조할 상세 문서들

### 아키텍처 심화 설계 시
👉 **`docs/DESIGN_PRINCIPLES.md`** 
- SOLID 원칙 상세 적용법
- Clean Architecture 이론
- 확장성 고려사항

### 상세한 코딩 규칙 확인 시  
👉 **`docs/CODING_STANDARDS.md`**
- 테스트 작성 규칙
- 코드 리뷰 체크리스트
- 성능 최적화 세부사항

### 시스템 구조 이해 필요 시
👉 **`docs/ARCHITECTURE.md`**
- 전체 데이터 플로우
- 폴더 구조 상세 가이드
- 성능 최적화 전략

### 기술 스택 상세 정보 필요 시
👉 **`docs/TECH_STACK.md`**
- 라이브러리 버전 정보
- API 엔드포인트 상세
- 빌드 및 배포 설정

### UI 스케일링 구현 세부사항
👉 **`docs/SCALING_GUIDE.md`**
- UIScaleProvider 내부 구조
- 새 스케일링 컴포넌트 추가법
- 트러블슈팅 가이드

## 🚨 긴급 참조: 실제 발생하는 문제들

### 1. ParentDataWidget 오류
→ **원인**: 중복된 Expanded 위젯 (실제 발생)
→ **해결**: 위젯 구조 단순화, ListView 내부 구조 점검

### 2. Admin 메뉴가 보이지 않음  
→ **원인**: AdminModeProvider 상태 false
→ **해결**: Settings에서 Admin Mode 활성화

### 3. 스케일링이 적용되지 않음
→ **원인**: ScaledIcon 대신 일반 Icon 사용
→ **해결**: 모든 아이콘을 ScaledIcon으로 변경

### 4. 라우팅에서 데이터 전달 안됨
→ **원인**: state.extra 타입 캐스팅 오류
→ **해결**: `final data = state.extra as TargetType;`

### 5. Hive 데이터 읽기 실패
→ **원인**: Box 타입 불일치 (settings vs exchangeRates)
→ **해결**: 올바른 타입의 Box 사용

## 💡 실제 개발 업무 수행 순서

```
1. 이 GROUND_RULES.md 숙지 ✅
2. 실제 코드베이스 패턴 확인 ✅  
3. 필요시 상세 docs 문서 참조 📚
4. 개발 작업 수행 (실제 패턴 적용) 💻
5. Admin Mode/스케일링 등 특별 기능 테스트 🧪
6. 자가 점검 후 완료 ✨
```

---

## 🔄 동적 규칙 업데이트 시스템

**이 문서는 실제 코드베이스 변화에 따라 자동 업데이트됩니다.**

새로운 패턴이나 규칙 변경이 필요한 경우:
1. 기존 Ground Rules와 충돌하는 요구사항 발생
2. AI가 자동으로 이 문서를 업데이트 
3. 버전 번호 증가 (v2.0 → v2.1)
4. 변경 사항을 README.md에 반영

**현재 버전: v2.0 (실제 코드베이스 분석 반영)**
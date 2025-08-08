# AI 개발자 필수 가이드

**🎯 이 문서는 AI가 Finow 프로젝트에서 개발 업무를 수행할 때 따라야 할 간단한 절차를 정의합니다.**

## 🚀 개발 작업 시작 전 필수 절차

### 단 하나의 필수 문서 읽기

**모든 개발 작업을 시작하기 전에 다음 문서를 반드시 읽어야 합니다:**

👉 **[`docs/GROUND_RULES.md`](docs/GROUND_RULES.md)** 

이 문서 하나에 Finow 프로젝트의 모든 핵심 개발 규칙이 통합되어 있습니다.

## 📋 개발 워크플로우

```
1. docs/GROUND_RULES.md 읽기 📖
2. 해당 문서의 체크리스트 확인 ✅  
3. 필요시 상세 문서 참조 (GROUND_RULES.md에서 안내) 📚
4. 개발 작업 수행 💻
5. GROUND_RULES.md의 자가 점검 완료 ✨
```

## 🎯 핵심 원칙 요약

**GROUND_RULES.md를 읽기 전까지는 개발 작업을 시작하지 마세요.**

해당 문서에는 다음이 포함되어 있습니다:
- ✅ 필수 아키텍처 패턴
- ✅ 기술 스택 및 사용법  
- ✅ 네이밍 규칙
- ✅ UI 스케일링 규칙
- ✅ 금지 사항
- ✅ 자주 발생하는 문제 해결법
- ✅ 상세 문서 참조 가이드

## 🤖 IDE별 동일한 개발 경험

이 간소화된 구조는 다음과 같은 환경에서 동일하게 작동합니다:
- Cursor IDE
- VS Code  
- Android Studio
- IntelliJ IDEA
- 웹 기반 IDE

**어떤 IDE를 사용하든 `docs/GROUND_RULES.md` 하나만 읽으면 모든 개발 규칙을 숙지할 수 있습니다.**

## 🔄 동적 규칙 업데이트

**사용자의 요구사항이 기존 Ground Rules와 충돌하는 경우:**

1. **자동 감지**: AI가 충돌을 감지하고 분석
2. **규칙 업데이트**: `docs/GROUND_RULES.md` 자동 업데이트  
3. **버전 관리**: v2.0 → v2.1 버전 증가
4. **사용자 알림**: 변경사항 및 영향도 설명

**예시 시나리오**:
- "Provider 대신 Bloc 사용해주세요" → 상태관리 규칙 업데이트
- "Repository 없이 직접 API 호출해주세요" → 아키텍처 규칙 업데이트
- "파일명을 camelCase로 해주세요" → 네이밍 규칙 업데이트

**상세 가이드**: [`docs/DYNAMIC_RULE_UPDATE_SYSTEM.md`](docs/DYNAMIC_RULE_UPDATE_SYSTEM.md)

---

## ⚠️ 중요 알림

**AI 개발자는 개발 작업을 시작하기 전에 반드시 [`docs/GROUND_RULES.md`](docs/GROUND_RULES.md) 파일을 읽어야 합니다.**

이 하나의 문서가 Finow 프로젝트의 일관성과 품질을 보장하는 핵심 가이드이며, 사용자 요구사항에 따라 자동으로 업데이트됩니다.
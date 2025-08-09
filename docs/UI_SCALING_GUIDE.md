# UI 스케일링 시스템 개발 가이드

## 📋 개요

Finow 앱은 사용자가 설정한 폰트 크기에 따라 모든 UI 요소가 일관되게 스케일링되는 시스템을 구현하고 있습니다. 이 가이드는 개발자가 새로운 UI 컴포넌트를 구현할 때 반드시 따라야 할 원칙과 방법을 제시합니다.

## 🎯 핵심 원칙

### 1. 모든 UI 요소는 폰트 크기 설정에 반응해야 합니다
- 텍스트, 아이콘, 이미지, 컨테이너, 패딩, 마진 등 모든 UI 요소
- 사용자가 폰트 크기를 변경하면 전체 UI가 일관되게 스케일링

### 2. 기본 테마 시스템과 완전 통합
- AppTheme 클래스의 scale 매개변수 활용
- Flutter의 기본 테마 시스템과 충돌 없이 동작

### 3. 개발자 친화적 API 제공
- 기존 Flutter 위젯과 유사한 API
- 최소한의 코드 변경으로 스케일링 적용 가능

## 🏗 시스템 아키텍처

### 1. FontSizeProvider
```dart
// 사용자 폰트 크기 설정 관리
final fontSizeNotifierProvider = NotifierProvider<FontSizeNotifier, FontSizeOption>
```

### 2. UIScaleProvider
```dart
// 전역 스케일 정보 제공 (InheritedWidget)
class UIScaleProvider extends InheritedWidget
```

### 3. AppTheme
```dart
// 테마 시스템에 스케일 적용
static ThemeData getLightTheme(double scale)
static ThemeData getDarkTheme(double scale)
```

## 🛠 구현 가이드

### 1. 텍스트 (Text)

**❌ 잘못된 방법:**
```dart
Text('Hello World')
```

**✅ 올바른 방법:**
```dart
ScaledText('Hello World')
```

**참고:** ScaledText는 내부적으로 MediaQuery textScaler를 사용하므로 일반 Text와 동일하게 동작하지만, 일관성을 위해 사용을 권장합니다.

### 2. 아이콘 (Icon)

**❌ 잘못된 방법:**
```dart
Icon(Icons.home, size: 24)
```

**✅ 올바른 방법:**
```dart
ScaledIcon(Icons.home, size: 24)  // 24는 기본 크기, 자동으로 스케일링됨
```

### 3. 이미지 (Image)

**❌ 잘못된 방법:**
```dart
Image.asset('assets/logo.png', width: 40, height: 40)
```

**✅ 올바른 방법:**
```dart
ScaledAssetImage(
  assetPath: 'assets/logo.png',
  baseWidth: 40,
  baseHeight: 40,
)

// 또는 일반 이미지의 경우
ScaledImage(
  image: NetworkImage('https://example.com/image.png'),
  baseWidth: 40,
  baseHeight: 40,
)
```

### 4. 컨테이너 (Container)

**❌ 잘못된 방법:**
```dart
Container(
  width: 100,
  height: 50,
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.symmetric(horizontal: 8),
  child: child,
)
```

**✅ 올바른 방법:**
```dart
ScaledContainer(
  baseWidth: 100,
  baseHeight: 50,
  basePadding: EdgeInsets.all(16),
  baseMargin: EdgeInsets.symmetric(horizontal: 8),
  child: child,
)
```

### 5. 패딩 (Padding)

**❌ 잘못된 방법:**
```dart
Padding(
  padding: EdgeInsets.all(16),
  child: child,
)
```

**✅ 올바른 방법:**
```dart
ScaledPadding.all(
  baseValue: 16,
  child: child,
)

// 또는
ScaledPadding.symmetric(
  baseVertical: 8,
  baseHorizontal: 16,
  child: child,
)
```

### 6. SizedBox

**❌ 잘못된 방법:**
```dart
SizedBox(width: 20, height: 20)
```

**✅ 올바른 방법:**
```dart
ScaledSizedBox(baseWidth: 20, baseHeight: 20)

// 정사각형의 경우
ScaledSizedBox.square(baseDimension: 20)
```

### 7. BorderRadius

**❌ 잘못된 방법:**
```dart
BorderRadius.circular(8)
```

**✅ 올바른 방법:**
```dart
ScaledBorderRadius.circular(context, 8)

// 개별 모서리 설정
ScaledBorderRadius.only(
  context: context,
  topLeft: 8,
  topRight: 8,
)
```

### 8. EdgeInsets (헬퍼 사용)

**❌ 잘못된 방법:**
```dart
EdgeInsets.all(16)
EdgeInsets.symmetric(horizontal: 12, vertical: 8)
```

**✅ 올바른 방법:**
```dart
ScaledEdgeInsets.all(context, 16)
ScaledEdgeInsets.symmetric(
  context: context,
  horizontal: 12,
  vertical: 8,
)
```

## 🎨 테마 시스템 통합

### AppTheme 확장
새로운 UI 요소를 테마에 추가할 때는 반드시 scale 매개변수를 적용하세요:

```dart
static ThemeData _getScaledTheme(ThemeData baseTheme, double scale) {
  return baseTheme.copyWith(
    // 기존 테마 요소들...
    
    // 새로운 테마 요소 추가 시
    chipTheme: baseTheme.chipTheme.copyWith(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
      labelPadding: EdgeInsets.symmetric(horizontal: 8 * scale),
    ),
    
    // 다른 테마 요소들도 동일하게 scale 적용
  );
}
```

## 📱 반응형 디자인 고려사항

### 1. 최소/최대 크기 제한
```dart
// 아이콘 크기가 너무 작거나 크지 않도록 제한
ScaledIcon(
  Icons.home,
  size: math.max(16, math.min(48, 24 * scale)), // 16~48 범위로 제한
)
```

### 2. 텍스트 오버플로우 처리
```dart
ScaledText(
  'Long text that might overflow',
  overflow: TextOverflow.ellipsis,
  maxLines: 1,
)
```

### 3. 레이아웃 유연성
```dart
// Flexible이나 Expanded 사용으로 레이아웃 깨짐 방지
Row(
  children: [
    ScaledIcon(Icons.star),
    Expanded(
      child: ScaledText('Flexible text content'),
    ),
  ],
)
```

## 🧪 테스트 가이드

### 1. 다양한 폰트 크기에서 테스트
- 최소 크기 (0.8x)
- 기본 크기 (1.0x)
- 중간 크기 (1.2x)
- 최대 크기 (1.5x)

### 2. 레이아웃 검증 포인트
- 텍스트 오버플로우 없음
- 버튼 터치 영역 적절함
- 아이콘과 텍스트 정렬 일관성
- 전체적인 시각적 균형

### 3. 성능 검증
- 스케일 변경 시 부드러운 전환
- 메모리 사용량 적정 수준 유지

## 📋 체크리스트

새로운 UI 컴포넌트 구현 시 다음 사항을 확인하세요:

- [ ] 모든 Text 위젯을 ScaledText로 교체
- [ ] 모든 Icon 위젯을 ScaledIcon으로 교체
- [ ] 모든 이미지를 ScaledImage/ScaledAssetImage로 교체
- [ ] 고정 크기 Container를 ScaledContainer로 교체
- [ ] 고정 패딩을 ScaledPadding으로 교체
- [ ] 고정 SizedBox를 ScaledSizedBox로 교체
- [ ] BorderRadius를 ScaledBorderRadius로 교체
- [ ] 직접적인 EdgeInsets 사용을 ScaledEdgeInsets로 교체
- [ ] 다양한 폰트 크기에서 테스트 완료
- [ ] 레이아웃 깨짐 없음 확인
- [ ] 접근성 가이드라인 준수

## 🚨 주의사항

### 1. 중복 스케일링 방지
```dart
// ❌ 잘못된 예: 이미 스케일이 적용된 값에 다시 스케일 적용
final scale = UIScaleProvider.of(context).scale;
ScaledIcon(Icons.home, size: 24 * scale) // 중복 스케일링!

// ✅ 올바른 예: ScaledIcon이 자동으로 스케일링 처리
ScaledIcon(Icons.home, size: 24)
```

### 2. Context 접근 가능 위치에서만 헬퍼 사용
```dart
// ❌ build 메서드 외부에서 사용 불가
class MyWidget extends StatelessWidget {
  final borderRadius = ScaledBorderRadius.circular(context, 8); // 오류!
  
  @override
  Widget build(BuildContext context) {
    // ✅ build 메서드 내부에서 사용
    final borderRadius = ScaledBorderRadius.circular(context, 8);
    return Container(/* ... */);
  }
}
```

### 3. 성능 최적화
```dart
// 자주 사용되는 스케일 값은 캐싱
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scale = UIScaleProvider.of(context).scale;
    
    return Column(
      children: [
        // 여러 위젯에서 같은 스케일 값 재사용
        ScaledPadding.all(baseValue: 16, child: widget1),
        ScaledPadding.all(baseValue: 16, child: widget2),
      ],
    );
  }
}
```

## 🔄 마이그레이션 가이드

기존 코드를 스케일링 시스템으로 마이그레이션할 때:

1. **단계적 적용**: 한 번에 모든 파일을 수정하지 말고 화면별로 점진적 적용
2. **테스트 우선**: 각 변경 후 다양한 폰트 크기에서 테스트
3. **일관성 유지**: 같은 기능의 UI 요소는 동일한 기본 크기 사용
4. **문서화**: 특별한 크기 설정이 있다면 주석으로 이유 명시

## 📚 참고 자료

- `lib/ui_scale_provider.dart`: 모든 Scaled 위젯 구현
- `lib/theme_provider.dart`: AppTheme 클래스 및 테마 시스템
- `lib/font_size_provider.dart`: 폰트 크기 설정 관리
- `lib/features/ui_guide/`: UI 가이드 및 예제 코드

---

**이 가이드를 준수하여 모든 사용자가 자신에게 맞는 UI 크기로 편안하게 앱을 사용할 수 있도록 해주세요! 🎯**

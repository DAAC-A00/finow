# Finow 통합 UI 스케일링 가이드

## 1. 개요

Finow 앱의 모든 UI는 사용자가 **Settings**에서 설정한 폰트 크기 옵션(Small, Medium, Large)에 따라 **통합적으로 스케일링**됩니다. 이 시스템은 단순히 텍스트 크기만 조절하는 것을 넘어, **아이콘, 버튼, 카드, 탭, 리스트 타일 등 대부분의 UI 요소 크기와 간격**까지 일관되게 변경하여 최적의 사용자 경험과 접근성을 제공합니다.

## 2. 스케일링 시스템 구조

통합 스케일링 시스템은 다음 세 가지 핵심 요소로 구성됩니다.

### 1. `FontSizeProvider` (`lib/font_size_provider.dart`)
- 사용자의 폰트 크기 설정을 `FontSize` 열거형(Small, Medium, Large)으로 관리합니다.
- 각 옵션에 맞는 `scaleFactor` (예: 0.9, 1.0, 1.2)를 제공합니다.
- 이 `scaleFactor`가 모든 스케일링의 기준값이 됩니다.

### 2. 동적 `AppTheme` (`lib/theme_provider.dart`)
- `AppTheme.getLightTheme(scale)`와 `AppTheme.getDarkTheme(scale)` 함수를 통해 동적으로 `ThemeData`를 생성합니다.
- `scale` 값을 인자로 받아, `CardTheme`, `ElevatedButtonTheme`, `ListTileTheme` 등 Material 위젯의 **패딩, 마진, 아이콘 크기, 테두리 반경** 등을 스케일에 맞춰 계산합니다.
- **결과적으로, 테마를 따르는 모든 표준 위젯은 자동으로 스케일링됩니다.**

### 3. 전역 스케일링 적용 (`lib/main.dart`)
- `main.dart`는 `FontSizeProvider`에서 `scale` 값을 가져옵니다.
- 이 `scale` 값을 사용하여 다음 세 가지를 설정합니다.
  1.  **`theme` / `darkTheme`**: `AppTheme.get...Theme(scale)`를 호출하여 스케일링된 테마를 앱에 적용합니다.
  2.  **`MediaQuery.textScaler`**: 모든 `Text` 위젯이 스케일링되도록 설정합니다.
  3.  **`UIScaleProvider`**: `ScaledIcon`, `ScaledAssetImage` 등 커스텀 스케일링 위젯이 `scale` 값을 사용할 수 있도록 제공합니다.

```dart
// main.dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizeOption = ref.watch(fontSizeNotifierProvider);
    final scale = fontSizeOption.scale; // 모든 스케일링의 기준값

    return MaterialApp.router(
      theme: AppTheme.getLightTheme(scale),
      darkTheme: AppTheme.getDarkTheme(scale),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: UIScaleProvider(
            scale: scale,
            child: child!,
          ),
        );
      },
    );
  }
}
```

## 3. 사용 가이드

### 표준 Material 위젯 (Button, Card, ListTile 등)
- **별도의 작업 없이 자동으로 스케일링됩니다.**
- `theme_provider.dart`에 정의된 `ThemeData`를 따르기만 하면 됩니다.
- **절대로 위젯에 직접 크기나 패딩 값을 하드코딩하지 마세요.**

### 텍스트 위젯
- 일반 `Text` 위젯을 사용하면 `MediaQuery.textScaler`에 의해 **자동으로 스케일링**됩니다.

### 아이콘 및 이미지 위젯
- `ThemeData`의 영향을 직접 받지 않는 아이콘과 이미지는 기존과 같이 `ScaledIcon`과 `ScaledAssetImage`를 사용해야 합니다.

**✅ 아이콘 권장 사용법**
```dart
// 기본 크기(24.0)에 스케일이 자동 적용됨
ScaledIcon(Icons.home)

// 다른 기본 크기를 지정해도 스케일이 적용됨
ScaledIcon(Icons.settings, size: 32)
```

**✅ 이미지 권장 사용법**
```dart
ScaledAssetImage(
  assetPath: 'images/logo.png',
  baseWidth: 40,   // 기본 크기에 스케일이 자동 적용됨
  baseHeight: 40,
)
```

## 4. 새로운 화면/컴포넌트 추가 시

### Best Practices
1.  **Theme First**: 항상 `Theme.of(context)`를 통해 색상, 텍스트 스타일, 패딩 등 스타일 값을 가져오세요.
2.  **하드코딩 금지**: `SizedBox(width: 16)`, `Padding(all: 8.0)` 등 크기 관련 상수를 코드에 직접 작성하는 것을 **엄격히 금지**합니다. 모든 크기는 테마에 정의되어야 합니다.
3.  **새로운 컴포넌트 테마 추가**: 만약 새로운 종류의 위젯 스타일을 앱 전반에 일관되게 적용해야 한다면, `theme_provider.dart`의 `_getScaledTheme` 함수 내에 해당 위젯의 `...Theme`를 추가하여 스케일링이 적용되도록 만드세요.

```dart
// theme_provider.dart에 새로운 컴포넌트 테마 추가 예시
static ThemeData _getScaledTheme(ThemeData baseTheme, double scale) {
  return baseTheme.copyWith(
    // ... 기존 테마들
    dialogTheme: baseTheme.dialogTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0 * scale), // 스케일 적용
      ),
    ),
  );
}
```

### 체크리스트
- [ ] UI에 사용된 모든 위젯이 `ThemeData`를 통해 스타일이 적용되었는가?
- [ ] 아이콘은 `ScaledIcon`, 이미지는 `ScaledAssetImage`를 사용했는가?
- [ ] 크기나 간격에 관련된 하드코딩된 상수는 없는가?
- [ ] Settings에서 폰트 크기를 Small/Medium/Large로 변경하며 UI가 깨지지 않고 일관되게 조절되는지 테스트했는가?

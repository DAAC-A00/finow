# Finow 앱 스케일링 가이드

## 개요
Finow 앱은 사용자가 Settings에서 설정한 폰트 크기에 따라 전체 UI가 반응형으로 스케일링됩니다.

## 스케일링 시스템 구조

### 1. FontSizeProvider (`lib/font_size_provider.dart`)
- 사용자의 폰트 크기 설정을 관리 (Small: 0.9x, Medium: 1.0x, Large: 1.1x)
- Hive를 통해 설정 값을 영구 저장

### 2. UIScaleProvider (`lib/ui_scale_provider.dart`)
- 앱 전체에서 스케일 값에 접근할 수 있도록 하는 InheritedWidget
- 스케일링된 위젯들 제공: `ScaledText`, `ScaledIcon`, `ScaledImage`, `ScaledAssetImage`

### 3. 전역 스케일링 적용 (`lib/main.dart`)
```dart
// MediaQuery textScaler를 통해 모든 Text 위젯 자동 스케일링
return MaterialApp.router(
  builder: (context, child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(fontSizeOption.scale),
      ),
      child: UIScaleProvider(
        scale: fontSizeOption.scale,
        child: child!,
      ),
    );
  },
);
```

## 사용 가이드

### 텍스트 위젯
**✅ 권장 (자동 스케일링)**
```dart
Text('Hello World')  // MediaQuery textScaler에 의해 자동 스케일링
```

**✅ 호환성을 위한 대안**
```dart
ScaledText('Hello World')  // 내부적으로 일반 Text와 동일
```

### 아이콘 위젯
**✅ 권장**
```dart
ScaledIcon(Icons.home)  // 스케일링 적용
ScaledIcon(Icons.settings, size: 24)  // 기본 크기 지정 + 스케일링
```

**❌ 피해야 할 방식**
```dart
Icon(Icons.home)  // 스케일링 미적용
```

### 이미지 위젯
**✅ Asset 이미지**
```dart
ScaledAssetImage(
  assetPath: 'images/logo.png',
  baseWidth: 40,   // 기본 크기
  baseHeight: 40,
)
```

**✅ 일반 이미지**
```dart
ScaledImage(
  image: NetworkImage('https://example.com/image.png'),
  baseWidth: 100,
  baseHeight: 100,
)
```

## 실제 적용 예시

### Exchange Rate Screen
```dart
// 아이콘과 텍스트 모두 스케일링 적용
ListTile(
  leading: ScaledAssetImage(
    assetPath: 'images/exconvert.png',
    baseWidth: 20,
    baseHeight: 20,
  ),
  title: Text('USD/KRW'),  // 자동 스케일링
  trailing: Text('1,400.50'),  // 자동 스케일링
)
```

### Settings Screen
```dart
// 모든 텍스트가 자동으로 스케일링됨
RadioListTile<FontSizeOption>(
  title: Text(fontSize.label),  // 자동 스케일링
  value: fontSize,
  groupValue: currentFontSize,
  onChanged: (value) => updateFontSize(value),
)
```

## 스케일링 값
- **Small**: 0.9배 (90%)
- **Medium**: 1.0배 (100% - 기본값)
- **Large**: 1.1배 (110%)

## 베스트 프랙티스

### 1. 일관성 유지
- 모든 아이콘에 `ScaledIcon` 사용
- 이미지에는 `ScaledAssetImage` 또는 `ScaledImage` 사용
- 텍스트는 일반 `Text` 위젯 사용 (자동 스케일링)

### 2. 기본 크기 설정
- 아이콘: 일반적으로 24dp (Material Design 기준)
- 작은 아이콘: 16-20dp
- 이미지: 용도에 맞는 적절한 기본 크기 설정

### 3. 테스트
- Settings에서 폰트 크기를 변경하여 모든 화면이 적절히 스케일링되는지 확인
- 특히 작은 크기(Small)와 큰 크기(Large)에서 UI가 깨지지 않는지 확인

## 새로운 화면/컴포넌트 추가 시 체크리스트

- [ ] `ScaledIcon` 사용 (모든 아이콘)
- [ ] `ScaledAssetImage` 또는 `ScaledImage` 사용 (모든 이미지)
- [ ] `Text` 위젯 사용 (자동 스케일링)
- [ ] Settings에서 폰트 크기 변경 테스트 완료
- [ ] 모든 스케일링 옵션에서 UI 정상 동작 확인

## 트러블슈팅

### ParentDataWidget 오류
- MediaQuery textScaler와 UIScaleProvider를 함께 사용하여 해결
- `ScaledText`는 내부적으로 일반 `Text` 위젯 사용

### 스케일링이 적용되지 않는 경우
- `ScaledIcon`, `ScaledImage` 등 전용 위젯 사용 확인
- `UIScaleProvider` import 여부 확인
- `main.dart`의 스케일링 설정 확인
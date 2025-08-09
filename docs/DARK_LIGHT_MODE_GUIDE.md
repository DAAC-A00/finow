# 다크모드/라이트모드 개발 가이드라인

## 개요

이 문서는 Finow 프로젝트에서 다크모드와 라이트모드를 완벽히 지원하는 UI 컴포넌트를 개발하기 위한 가이드라인을 제공합니다. 모든 개발자는 새로운 UI 컴포넌트를 개발할 때 이 가이드라인을 준수해야 합니다.

## 테마 시스템 구조

### 1. 테마 제공자 (ThemeProvider)

```dart
// lib/theme_provider.dart
final themeModeNotifierProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  // 테마 모드 관리 로직
}
```

### 2. 메인 앱에서의 테마 적용

```dart
// lib/main.dart
MaterialApp.router(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    brightness: Brightness.light,
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple, brightness: Brightness.dark),
    brightness: Brightness.dark,
  ),
  themeMode: themeMode, // 사용자 설정에 따라 동적 변경
)
```

## 필수 준수 사항

### ✅ DO (반드시 해야 할 것)

1. **Theme.of(context).colorScheme 사용**
   ```dart
   // ✅ 올바른 방법
   Container(
     color: Theme.of(context).colorScheme.surface,
     child: Text(
       'Hello',
       style: TextStyle(
         color: Theme.of(context).colorScheme.onSurface,
       ),
     ),
   )
   ```

2. **Theme.of(context).textTheme 사용**
   ```dart
   // ✅ 올바른 방법
   Text(
     'Title',
     style: Theme.of(context).textTheme.titleLarge?.copyWith(
       color: Theme.of(context).colorScheme.onSurface,
     ),
   )
   ```

3. **투명도는 withOpacity() 사용**
   ```dart
   // ✅ 올바른 방법
   Icon(
     Icons.info,
     color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
   )
   ```

4. **카드와 컨테이너에 적절한 배경색 적용**
   ```dart
   // ✅ 올바른 방법
   Card(
     color: Theme.of(context).colorScheme.surface,
     child: ListTile(
       title: Text(
         'Item',
         style: TextStyle(
           color: Theme.of(context).colorScheme.onSurface,
         ),
       ),
     ),
   )
   ```

5. **다이얼로그와 바텀시트에 테마 적용**
   ```dart
   // ✅ 올바른 방법
   AlertDialog(
     backgroundColor: Theme.of(context).colorScheme.surface,
     title: Text(
       'Title',
       style: TextStyle(
         color: Theme.of(context).colorScheme.onSurface,
       ),
     ),
   )
   ```

### ❌ DON'T (하지 말아야 할 것)

1. **하드코딩된 색상 사용 금지**
   ```dart
   // ❌ 잘못된 방법
   Container(
     color: Colors.white, // 다크모드에서 문제 발생
     child: Text(
       'Hello',
       style: TextStyle(color: Colors.black), // 다크모드에서 보이지 않음
     ),
   )
   ```

2. **고정된 색상값 사용 금지**
   ```dart
   // ❌ 잘못된 방법
   Container(
     color: Color(0xFFFFFFFF), // 하드코딩된 흰색
   )
   ```

3. **테마를 고려하지 않은 아이콘 색상**
   ```dart
   // ❌ 잘못된 방법
   Icon(
     Icons.star,
     color: Colors.yellow, // 테마와 무관한 고정 색상
   )
   ```

## 색상 팔레트 가이드

### Material 3 ColorScheme 활용

| 색상 역할 | 사용 용도 | 예시 |
|----------|----------|------|
| `primary` | 주요 액션, 강조 요소 | 버튼, 링크, 선택된 항목 |
| `onPrimary` | primary 위의 텍스트/아이콘 | 버튼 내 텍스트 |
| `secondary` | 보조 액션, 부가 요소 | 보조 버튼, 태그 |
| `surface` | 카드, 시트, 메뉴 배경 | Card, BottomSheet |
| `onSurface` | surface 위의 텍스트/아이콘 | 일반 텍스트, 아이콘 |
| `background` | 앱의 기본 배경 | Scaffold 배경 |
| `onBackground` | background 위의 텍스트 | 기본 텍스트 |
| `error` | 오류, 경고 표시 | 에러 메시지, 삭제 버튼 |
| `outline` | 테두리, 구분선 | Border, Divider |

### 투명도 가이드라인

```dart
// 텍스트 투명도 레벨
primary: 1.0          // 주요 텍스트
secondary: 0.8        // 보조 텍스트  
disabled: 0.6         // 비활성화된 텍스트
hint: 0.4             // 힌트 텍스트
```

## 컴포넌트별 구현 예시

### 1. 리스트 아이템

```dart
Card(
  color: Theme.of(context).colorScheme.surface,
  child: ListTile(
    leading: Icon(
      Icons.star,
      color: Theme.of(context).colorScheme.primary,
    ),
    title: Text(
      'Title',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Text(
      'Subtitle',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
    ),
    trailing: Icon(
      Icons.arrow_forward_ios,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
    ),
  ),
)
```

### 2. 버튼 그룹

```dart
Row(
  children: [
    ElevatedButton(
      onPressed: () {},
      child: Text('Primary'),
    ),
    SizedBox(width: 8),
    OutlinedButton(
      onPressed: () {},
      child: Text('Secondary'),
    ),
    SizedBox(width: 8),
    TextButton(
      onPressed: () {},
      child: Text('Tertiary'),
    ),
  ],
)
```

### 3. 입력 필드

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Hint text',
    border: OutlineInputBorder(),
    prefixIcon: Icon(
      Icons.search,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
    ),
  ),
  style: TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
  ),
)
```

### 4. 바텀시트

```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Theme.of(context).colorScheme.surface,
  builder: (context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Column(
      children: [
        Icon(
          Icons.drag_handle,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
        Text(
          'Bottom Sheet',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    ),
  ),
)
```

## 테스트 가이드라인

### 1. 수동 테스트

새로운 컴포넌트를 개발한 후 반드시 다음을 확인하세요:

1. **라이트 모드에서 테스트**
   - 모든 텍스트가 명확히 보이는가?
   - 색상 대비가 충분한가?
   - 아이콘이 적절히 표시되는가?

2. **다크 모드에서 테스트**
   - 모든 텍스트가 명확히 보이는가?
   - 배경과 전경색이 적절한가?
   - 그림자나 elevation이 자연스러운가?

3. **테마 전환 테스트**
   - 실시간으로 테마를 전환했을 때 깨지는 부분이 없는가?
   - 모든 색상이 즉시 업데이트되는가?

### 2. UI & Code Guide 활용

개발 중인 컴포넌트를 UI & Code Guide의 Theme 탭에서 테스트하세요:

1. 앱 실행 후 UI & Code Guide 화면으로 이동
2. Theme 탭에서 라이트/다크 모드 토글 테스트
3. 개발한 컴포넌트가 올바르게 동작하는지 확인

## 접근성 고려사항

### 1. 색상 대비

- WCAG 2.1 AA 기준을 준수하세요 (최소 4.5:1 대비율)
- Material 3 ColorScheme는 기본적으로 접근성을 고려하여 설계됨

### 2. 다크모드 특별 고려사항

- 순수한 검은색(#000000) 배경 피하기
- 너무 밝은 흰색 텍스트 피하기
- 적절한 elevation과 그림자 활용

## 문제 해결

### 자주 발생하는 문제들

1. **텍스트가 보이지 않는 경우**
   ```dart
   // 해결책: 적절한 onSurface 색상 사용
   Text(
     'Text',
     style: TextStyle(
       color: Theme.of(context).colorScheme.onSurface,
     ),
   )
   ```

2. **카드가 배경과 구분되지 않는 경우**
   ```dart
   // 해결책: surface 색상과 elevation 사용
   Card(
     color: Theme.of(context).colorScheme.surface,
     elevation: 2,
     child: content,
   )
   ```

3. **아이콘이 테마와 어울리지 않는 경우**
   ```dart
   // 해결책: 테마 색상 적용
   Icon(
     Icons.icon,
     color: Theme.of(context).colorScheme.primary,
   )
   ```

## 체크리스트

새로운 UI 컴포넌트 개발 시 다음 체크리스트를 확인하세요:

- [ ] 하드코딩된 색상값 사용하지 않음
- [ ] Theme.of(context).colorScheme 사용
- [ ] Theme.of(context).textTheme 사용
- [ ] 투명도는 withOpacity() 사용
- [ ] 라이트 모드에서 테스트 완료
- [ ] 다크 모드에서 테스트 완료
- [ ] 테마 전환 시 정상 동작 확인
- [ ] 접근성 대비 기준 준수
- [ ] UI & Code Guide에서 검증 완료

## 참고 자료

- [Material 3 Color System](https://m3.material.io/styles/color/system)
- [Flutter Theme Documentation](https://docs.flutter.dev/cookbook/design/themes)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

이 가이드라인을 준수하여 일관되고 접근성이 뛰어난 다크모드/라이트모드 호환 UI를 구현하세요.

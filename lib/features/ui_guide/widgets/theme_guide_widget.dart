// 이 위젯은 다크모드/라이트모드 테마 시스템의 구현 예시와 가이드라인을 제공합니다.
// 프로젝트 내 모든 UI 컴포넌트가 다크모드/라이트모드를 완벽히 지원하도록 하는 기준점 역할을 합니다.
import 'package:finow/ui_scale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/theme_provider.dart';

class ThemeGuideWidget extends ConsumerWidget {
  const ThemeGuideWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        // 테마 시스템 개요
        _buildSectionCard(
          context,
          title: '테마 시스템 개요',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaledText(
                '현재 테마: ${isDarkMode ? "다크 모드" : "라이트 모드"}',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ScaledText(
                '시스템 테마 모드: ${themeMode.name}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withAlpha((255 * 0.8).round()),
                ),
              ),
              const SizedBox(height: 16),
              _buildThemeToggleButtons(ref, themeMode),
            ],
          ),
        ),

        // 핵심 원칙
        _buildSectionCard(
          context,
          title: '핵심 원칙',
          child: _buildCorePrinciples(context),
        ),

        // 컬러 팔레트 가이드
        _buildSectionCard(
          context,
          title: '컬러 팔레트',
          child: _buildColorPalette(context, colorScheme),
        ),

        // 텍스트 스타일 가이드
        _buildSectionCard(
          context,
          title: '텍스트 스타일',
          child: _buildTextStyleGuide(context),
        ),

        // 컴포넌트 예시
        _buildSectionCard(
          context,
          title: '컴포넌트 예시',
          child: _buildComponentExamples(context, colorScheme),
        ),

        // 개발 가이드라인
        _buildSectionCard(
          context,
          title: '다크/라이트 모드 개발 가이드라인',
          child: _buildDevelopmentGuidelines(context),
        ),
      ],
    );
  }

  Widget _buildCorePrinciples(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final principles = [
      '1. 중앙 테마 우선: 모든 색상과 텍스트 스타일은 Theme.of(context)를 통해 제공되는 값을 최우선으로 사용합니다.',
      '2. `copyWith` 남용 금지: 개별 위젯에서 스타일을 미세 조정하기 위해 `copyWith`를 사용하는 것을 지양합니다. 재사용이 필요한 스타일은 중앙 테마(ThemeData)에 정식으로 추가해야 합니다.',
      '3. 하드코딩 금지: `Colors.blue` 또는 특정 `TextStyle`을 직접 생성하여 사용하는 것을 엄격히 금지합니다. 모든 UI 요소는 테마의 일부여야 합니다.',
      '4. 컴포넌트 테마 활용: 버튼, 카드, 앱 바 등 공통 위젯의 스타일은 `ThemeData`의 `elevatedButtonTheme`, `cardTheme` 등으로 중앙에서 관리하여 일관성을 확보합니다.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: principles.map((principle) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaledText(
                '✅',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ScaledText(
                  principle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title, required Widget child}) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaledText(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggleButtons(WidgetRef ref, ThemeMode currentMode) {
    final context = ref.context;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => ref
                .read(themeModeNotifierProvider.notifier)
                .setThemeMode(ThemeMode.light),
            icon: const ScaledIcon(Icons.light_mode),
            label: const ScaledText('라이트 모드'),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentMode == ThemeMode.light
                  ? colorScheme.primary
                  : colorScheme.surface,
              foregroundColor: currentMode == ThemeMode.light
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => ref
                .read(themeModeNotifierProvider.notifier)
                .setThemeMode(ThemeMode.dark),
            icon: const ScaledIcon(Icons.dark_mode),
            label: const ScaledText('다크 모드'),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentMode == ThemeMode.dark
                  ? colorScheme.primary
                  : colorScheme.surface,
              foregroundColor: currentMode == ThemeMode.dark
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => ref
                .read(themeModeNotifierProvider.notifier)
                .setThemeMode(ThemeMode.system),
            icon: const ScaledIcon(Icons.settings),
            label: const ScaledText('시스템'),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentMode == ThemeMode.system
                  ? colorScheme.primary
                  : colorScheme.surface,
              foregroundColor: currentMode == ThemeMode.system
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPalette(BuildContext context, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    final colors = [
      ('Primary', colorScheme.primary, colorScheme.onPrimary),
      ('Secondary', colorScheme.secondary, colorScheme.onSecondary),
      ('Surface', colorScheme.surface, colorScheme.onSurface),
      ('Background', colorScheme.surface, colorScheme.onSurface),
      ('Error', colorScheme.error, colorScheme.onError),
      ('Outline', colorScheme.outline, colorScheme.onSurface),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((colorInfo) {
        return Container(
          width: 100,
          height: 80,
          decoration: BoxDecoration(
            color: colorInfo.$2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outline.withAlpha((255 * 0.3).round())),
          ),
          child: Center(
            child: ScaledText(
              colorInfo.$1,
              style: textTheme.labelMedium?.copyWith(
                color: colorInfo.$3,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextStyleGuide(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final styles = [
      ('Display Large', textTheme.displayLarge),
      ('Headline Large', textTheme.headlineLarge),
      ('Title Large', textTheme.titleLarge),
      ('Title Medium', textTheme.titleMedium),
      ('Body Large', textTheme.bodyLarge),
      ('Body Medium', textTheme.bodyMedium),
      ('Label Large', textTheme.labelLarge),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: styles.map((styleInfo) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: ScaledText(
                  styleInfo.$1,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                  ),
                ),
              ),
              Expanded(
                child: ScaledText(
                  '샘플 텍스트',
                  style: styleInfo.$2?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComponentExamples(BuildContext context, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        // 버튼 예시
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const ScaledText('Elevated Button'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const ScaledText('Outlined Button'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton(
                onPressed: () {},
                child: const ScaledText('Text Button'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 카드와 리스트 타일 예시
        Card(
          child: ListTile(
            leading: ScaledIcon(Icons.palette, color: colorScheme.primary),
            title: ScaledText('테마 적용 예시',
                style: textTheme.titleMedium
                    ?.copyWith(color: colorScheme.onSurface)),
            subtitle: ScaledText('다크/라이트 모드 호환',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurface.withAlpha((255 * 0.7).round()))),
            trailing: ScaledIcon(Icons.arrow_forward_ios,
                color: colorScheme.onSurface.withAlpha((255 * 0.5).round())),
          ),
        ),

        const SizedBox(height: 16),

        // 입력 필드 예시
        TextField(
          decoration: InputDecoration(
            labelText: '입력 필드 예시',
            hintText: '텍스트를 입력하세요',
            border: const OutlineInputBorder(),
            prefixIcon: ScaledIcon(Icons.edit, color: colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildDevelopmentGuidelines(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final guidelines = [
      '✅ Theme.of(context).colorScheme를 사용하여 색상 적용',
      '✅ Theme.of(context).textTheme를 사용하여 텍스트 스타일 적용',
      '✅ 하드코딩된 색상값 사용 금지 (예: Colors.white, Colors.black)',
      '✅ 투명도는 withAlpha()를 사용하여 동적으로 적용',
      '✅ 아이콘과 이미지도 테마에 맞게 색상 조정',
      '✅ 커스텀 위젯 생성 시 반드시 다크/라이트 모드 테스트',
      '⚠️ 그림자와 elevation은 다크모드에서 자동 조정됨',
      '⚠️ 대비(contrast)를 고려하여 접근성 확보',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: guidelines.map((guideline) {
        final isWarning = guideline.startsWith('⚠️');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaledText(
                guideline.substring(0, 2),
                style: textTheme.titleMedium?.copyWith(
                  color: isWarning ? colorScheme.error : colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ScaledText(
                  guideline.substring(3),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

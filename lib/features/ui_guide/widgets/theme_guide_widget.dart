// 이 위젯은 다크모드/라이트모드 테마 시스템의 구현 예시와 가이드라인을 제공합니다.
// 프로젝트 내 모든 UI 컴포넌트가 다크모드/라이트모드를 완벽히 지원하도록 하는 기준점 역할을 합니다.
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
              Text(
                '현재 테마: ${isDarkMode ? "다크 모드" : "라이트 모드"}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '시스템 테마 모드: ${themeMode.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              _buildThemeToggleButtons(ref, themeMode),
            ],
          ),
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

  Widget _buildSectionCard(BuildContext context, {required String title, required Widget child}) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => ref.read(themeModeNotifierProvider.notifier).setThemeMode(ThemeMode.light),
            icon: const Icon(Icons.light_mode),
            label: const Text('라이트 모드'),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentMode == ThemeMode.light 
                ? Theme.of(ref.context).colorScheme.primary 
                : Theme.of(ref.context).colorScheme.surface,
              foregroundColor: currentMode == ThemeMode.light 
                ? Theme.of(ref.context).colorScheme.onPrimary 
                : Theme.of(ref.context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => ref.read(themeModeNotifierProvider.notifier).setThemeMode(ThemeMode.dark),
            icon: const Icon(Icons.dark_mode),
            label: const Text('다크 모드'),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentMode == ThemeMode.dark 
                ? Theme.of(ref.context).colorScheme.primary 
                : Theme.of(ref.context).colorScheme.surface,
              foregroundColor: currentMode == ThemeMode.dark 
                ? Theme.of(ref.context).colorScheme.onPrimary 
                : Theme.of(ref.context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => ref.read(themeModeNotifierProvider.notifier).setThemeMode(ThemeMode.system),
            icon: const Icon(Icons.settings),
            label: const Text('시스템'),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentMode == ThemeMode.system 
                ? Theme.of(ref.context).colorScheme.primary 
                : Theme.of(ref.context).colorScheme.surface,
              foregroundColor: currentMode == ThemeMode.system 
                ? Theme.of(ref.context).colorScheme.onPrimary 
                : Theme.of(ref.context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPalette(BuildContext context, ColorScheme colorScheme) {
    final colors = [
      ('Primary', colorScheme.primary, colorScheme.onPrimary),
      ('Secondary', colorScheme.secondary, colorScheme.onSecondary),
      ('Surface', colorScheme.surface, colorScheme.onSurface),
      ('Background', colorScheme.background, colorScheme.onBackground),
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
            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              colorInfo.$1,
              style: TextStyle(
                color: colorInfo.$3,
                fontSize: 12,
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
                child: Text(
                  styleInfo.$1,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '샘플 텍스트',
                  style: styleInfo.$2?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
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
    return Column(
      children: [
        // 버튼 예시
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Elevated Button'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined Button'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton(
                onPressed: () {},
                child: const Text('Text Button'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 카드와 리스트 타일 예시
        Card(
          child: ListTile(
            leading: Icon(Icons.palette, color: colorScheme.primary),
            title: Text('테마 적용 예시', style: TextStyle(color: colorScheme.onSurface)),
            subtitle: Text('다크/라이트 모드 호환', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
            trailing: Icon(Icons.arrow_forward_ios, color: colorScheme.onSurface.withOpacity(0.5)),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 입력 필드 예시
        TextField(
          decoration: InputDecoration(
            labelText: '입력 필드 예시',
            hintText: '텍스트를 입력하세요',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.edit, color: colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildDevelopmentGuidelines(BuildContext context) {
    final guidelines = [
      '✅ Theme.of(context).colorScheme를 사용하여 색상 적용',
      '✅ Theme.of(context).textTheme를 사용하여 텍스트 스타일 적용',
      '✅ 하드코딩된 색상값 사용 금지 (예: Colors.white, Colors.black)',
      '✅ 투명도는 withOpacity()를 사용하여 동적으로 적용',
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
              Text(
                guideline.substring(0, 2),
                style: TextStyle(
                  fontSize: 16,
                  color: isWarning 
                    ? Theme.of(context).colorScheme.error 
                    : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  guideline.substring(3),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
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

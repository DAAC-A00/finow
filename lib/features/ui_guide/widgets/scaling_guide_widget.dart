// UI 스케일링 시스템의 실제 동작 예시를 제공합니다.
// docs에서 제거된 스케일링 관련 코드 예시들을 실제로 동작하는 형태로 구현합니다.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finow/ui_scale_provider.dart';

import 'package:finow/font_size_provider.dart';

class ScalingGuideWidget extends ConsumerWidget {
  const ScalingGuideWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFontSize = ref.watch(fontSizeNotifierProvider);

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        _buildHeaderCard(),
        const SizedBox(height: 16),
        _buildCurrentScaleCard(currentFontSize),
        _buildScalingExampleCard(
          title: '스케일링된 텍스트 예시',
          subtitle: '일반 Text 위젯은 MediaQuery textScaler로 자동 스케일링',
          child: _buildTextScalingExample(),
        ),
        _buildScalingExampleCard(
          title: '스케일링된 아이콘 예시',
          subtitle: 'ScaledIcon 사용 - UIScaleProvider 기반',
          child: _buildIconScalingExample(),
        ),
        _buildScalingExampleCard(
          title: '스케일링된 이미지 예시',
          subtitle: 'ScaledAssetImage 사용 - baseWidth/Height 기준 스케일링',
          child: _buildImageScalingExample(),
        ),
        _buildScalingExampleCard(
          title: '비교: 일반 vs 스케일링',
          subtitle: '차이점을 명확히 보여주는 비교 예시',
          child: _buildComparisonExample(),
        ),
        _buildImplementationGuideCard(),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return Card(
        elevation: 4.0,
        color: colorScheme.secondaryContainer.withAlpha((255 * 0.5).round()),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.zoom_in,
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 8),
              Text(
                'UI 스케일링 시스템',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'MediaQuery textScaler + UIScaleProvider 조합으로 전체 UI 스케일링',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSecondaryContainer.withAlpha((255 * 0.8).round()),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCurrentScaleCard(FontSizeOption currentFontSize) {
    return Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return Card(
        elevation: 3.0,
        color: colorScheme.primaryContainer.withAlpha((255 * 0.5).round()),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, color: colorScheme.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 스케일 설정',
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${currentFontSize.label}: ${currentFontSize.scale}x',
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              const Text('← Settings에서 변경해보세요'),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildScalingExampleCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.widgets, color: colorScheme.tertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTextScalingExample() {
    return Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer.withAlpha((255 * 0.2).round()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '작은 텍스트 (fontSize: 12)',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              '일반 텍스트 (fontSize: 16)',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '큰 텍스트 (fontSize: 20)',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '매우 큰 텍스트 (fontSize: 24)',
              style: textTheme.titleLarge?.copyWith(color: colorScheme.tertiary),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildIconScalingExample() {
    return Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withAlpha((255 * 0.2).round()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            Column(
              children: [
                const Icon(Icons.home),
                Text('16px', style: textTheme.labelSmall),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.search),
                Text('24px', style: textTheme.labelSmall),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.settings),
                Text('32px', style: textTheme.labelSmall),
              ],
            ),
            Column(
              children: [
                Icon(Icons.favorite, color: colorScheme.error),
                Text('40px', style: textTheme.labelSmall),
              ],
            ),
            Column(
              children: [
                Icon(Icons.star, color: colorScheme.secondary),
                Text('48px', style: textTheme.labelSmall),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildImageScalingExample() {
    return Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withAlpha((255 * 0.2).round()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '실제 프로젝트에서 사용되는 이미지들',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const ScaledAssetImage(
                      assetPath: 'images/exconvert.png',
                      baseWidth: 24,
                      baseHeight: 24,
                    ),
                    const SizedBox(height: 4),
                    Text('24x24', style: textTheme.labelSmall),
                  ],
                ),
                Column(
                  children: [
                    const ScaledAssetImage(
                      assetPath: 'images/exchangerate-api.png',
                      baseWidth: 32,
                      baseHeight: 32,
                    ),
                    const SizedBox(height: 4),
                    Text('32x32', style: textTheme.labelSmall),
                  ],
                ),
                Column(
                  children: [
                    const ScaledAssetImage(
                      assetPath: 'images/exconvert.png',
                      baseWidth: 48,
                      baseHeight: 48,
                    ),
                    const SizedBox(height: 4),
                    Text('48x48', style: textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildComparisonExample() {
    return Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withAlpha((255 * 0.2).round()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  '❌ 스케일링 미적용 (잘못된 사용)',
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.error),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.home, size: 24), // 일반 Icon - 스케일링 안됨
                const SizedBox(width: 16),
                Text('일반 Icon (고정 크기)', style: textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  '✅ 스케일링 적용 (올바른 사용)',
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.home), // ScaledIcon - 스케일링 적용됨
                const SizedBox(width: 16),
                Text('ScaledIcon (반응형 크기)', style: textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildImplementationGuideCard() {
    return Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return Card(
        elevation: 2.0,
        color: colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.code, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '구현 가이드',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildImplementationItem(context, 'Text 위젯', '일반 Text() 사용 - 자동 스케일링', colorScheme.primary),
              _buildImplementationItem(context, '아이콘', 'ScaledIcon() 사용 필수', colorScheme.secondary),
              _buildImplementationItem(context, '이미지', 'ScaledAssetImage() 사용 필수', colorScheme.tertiary),
              _buildImplementationItem(context, '금지 사항', 'Icon(), Image.asset() 직접 사용 금지', colorScheme.error),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha((255 * 0.3).round()),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '핵심 원리:',
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• MediaQuery textScaler: 텍스트 자동 스케일링\n'
                      '• UIScaleProvider: 아이콘/이미지 수동 스케일링\n'
                      '• FontSizeProvider: 사용자 설정 값 제공',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildImplementationItem(BuildContext context, String component, String usage, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 16,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            '$component: ',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          Expanded(child: Text(usage, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
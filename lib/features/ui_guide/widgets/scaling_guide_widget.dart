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
    return Card(
      elevation: 4.0,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ScaledIcon(
              Icons.zoom_in,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            const ScaledText(
              'UI 스케일링 시스템',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const ScaledText(
              'MediaQuery textScaler + UIScaleProvider 조합으로 전체 UI 스케일링',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScaleCard(FontSizeOption currentFontSize) {
    return Card(
      elevation: 3.0,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ScaledIcon(Icons.settings, color: Colors.blue),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScaledText(
                  '현재 스케일 설정',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ScaledText(
                  '${currentFontSize.label}: ${currentFontSize.scale}x',
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(width: 16),
            const ScaledText('← Settings에서 변경해보세요'),
          ],
        ),
      ),
    );
  }

  Widget _buildScalingExampleCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
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
                const ScaledIcon(Icons.widgets, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScaledText(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ScaledText(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
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
  }

  Widget _buildTextScalingExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '작은 텍스트 (fontSize: 12)',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 8),
          Text(
            '일반 텍스트 (fontSize: 16)',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            '큰 텍스트 (fontSize: 20)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '매우 큰 텍스트 (fontSize: 24)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildIconScalingExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          Column(
            children: [
              ScaledIcon(Icons.home, size: 16),
              Text('16px', style: TextStyle(fontSize: 10)),
            ],
          ),
          Column(
            children: [
              ScaledIcon(Icons.search, size: 24),
              Text('24px', style: TextStyle(fontSize: 10)),
            ],
          ),
          Column(
            children: [
              ScaledIcon(Icons.settings, size: 32),
              Text('32px', style: TextStyle(fontSize: 10)),
            ],
          ),
          Column(
            children: [
              ScaledIcon(Icons.favorite, size: 40, color: Colors.red),
              Text('40px', style: TextStyle(fontSize: 10)),
            ],
          ),
          Column(
            children: [
              ScaledIcon(Icons.star, size: 48, color: Colors.amber),
              Text('48px', style: TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageScalingExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        children: [
          Text(
            '실제 프로젝트에서 사용되는 이미지들',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  ScaledAssetImage(
                    assetPath: 'images/exconvert.png',
                    baseWidth: 24,
                    baseHeight: 24,
                  ),
                  SizedBox(height: 4),
                  Text('24x24', style: TextStyle(fontSize: 10)),
                ],
              ),
              Column(
                children: [
                  ScaledAssetImage(
                    assetPath: 'images/exchangerate-api.png',
                    baseWidth: 32,
                    baseHeight: 32,
                  ),
                  SizedBox(height: 4),
                  Text('32x32', style: TextStyle(fontSize: 10)),
                ],
              ),
              Column(
                children: [
                  ScaledAssetImage(
                    assetPath: 'images/exconvert.png',
                    baseWidth: 48,
                    baseHeight: 48,
                  ),
                  SizedBox(height: 4),
                  Text('48x48', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 16),
              SizedBox(width: 8),
              Text(
                '❌ 스케일링 미적용 (잘못된 사용)',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.home, size: 24), // 일반 Icon - 스케일링 안됨
              SizedBox(width: 16),
              Text('일반 Icon (고정 크기)', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text(
                '✅ 스케일링 적용 (올바른 사용)',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              ScaledIcon(Icons.home, size: 24), // ScaledIcon - 스케일링 적용됨
              SizedBox(width: 16),
              Text('ScaledIcon (반응형 크기)', style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImplementationGuideCard() {
    return Card(
      elevation: 2.0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                ScaledIcon(Icons.code, color: Colors.indigo),
                SizedBox(width: 8),
                ScaledText(
                  '구현 가이드',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildImplementationItem('Text 위젯', '일반 Text() 사용 - 자동 스케일링', Colors.blue),
            _buildImplementationItem('아이콘', 'ScaledIcon() 사용 필수', Colors.orange),
            _buildImplementationItem('이미지', 'ScaledAssetImage() 사용 필수', Colors.green),
            _buildImplementationItem('금지 사항', 'Icon(), Image.asset() 직접 사용 금지', Colors.red),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(
                    '핵심 원리:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  SizedBox(height: 4),
                  ScaledText(
                    '• MediaQuery textScaler: 텍스트 자동 스케일링\n'
                    '• UIScaleProvider: 아이콘/이미지 수동 스케일링\n'
                    '• FontSizeProvider: 사용자 설정 값 제공',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImplementationItem(String component, String usage, Color color) {
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
          ScaledText(
            '$component: ',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Expanded(child: ScaledText(usage)),
        ],
      ),
    );
  }
}
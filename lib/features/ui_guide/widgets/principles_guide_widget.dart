// 설계 원칙과 코딩 표준의 실제 적용 예시를 제공합니다.
// docs에서 제거된 설계 원칙 관련 코드 예시들을 실제로 동작하는 형태로 구현합니다.
import 'package:flutter/material.dart';
import 'package:finow/ui_scale_provider.dart';

class PrinciplesGuideWidget extends StatefulWidget {
  const PrinciplesGuideWidget({super.key});

  @override
  State<PrinciplesGuideWidget> createState() => _PrinciplesGuideWidgetState();
}

class _PrinciplesGuideWidgetState extends State<PrinciplesGuideWidget> {
  bool _showConstExample = false;
  bool _showSRPExample = false;
  bool _showOCPExample = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        _buildHeaderCard(),
        const SizedBox(height: 16),
        _buildPrincipleCard(
          title: 'SOLID 원칙',
          subtitle: '객체지향 설계 5원칙 적용 예시',
          child: _buildSOLIDExample(),
        ),
        _buildPrincipleCard(
          title: 'const 생성자 원칙',
          subtitle: '성능 최적화를 위한 const 사용',
          child: _buildConstExample(),
        ),
        _buildPrincipleCard(
          title: '위젯 분리 원칙',
          subtitle: '단일 책임과 가독성을 위한 위젯 분리',
          child: _buildWidgetSeparationExample(),
        ),
        _buildPrincipleCard(
          title: '성능 최적화 원칙',
          subtitle: '60FPS 유지를 위한 최적화 기법',
          child: _buildPerformanceExample(),
        ),
        _buildPrincipleCard(
          title: '에러 처리 원칙',
          subtitle: '견고한 앱을 위한 에러 처리',
          child: _buildErrorHandlingExample(),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return Card(
          elevation: 4.0,
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ScaledIcon(
                  Icons.rule,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 8),
                ScaledText(
                  'Finow 개발 원칙',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ScaledText(
                  '코드 품질과 유지보수성을 위한 핵심 개발 원칙들',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withAlpha(204),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrincipleCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ScaledIcon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScaledText(
                            title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          ScaledText(
                            subtitle,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withAlpha(178),
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
      },
    );
  }

  Widget _buildSOLIDExample() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSOLIDPrinciple(
          'S',
          'Single Responsibility',
          '단일 책임: 각 클래스는 하나의 책임만',
          '''ExchangeRateScreen → UI만
ExchangeRateRepository → 데이터만''',
          _showSRPExample,
          () => setState(() => _showSRPExample = !_showSRPExample),
          colorScheme.error,
        ),
        _buildSOLIDPrinciple(
          'O', 'Open/Closed',
          '개방/폐쇄: 확장에는 열려있고 수정에는 닫혀있게',
          'ApiClient 인터페이스로 ExConvert, ExchangeRate 구현체 분리',
          _showOCPExample,
          () => setState(() => _showOCPExample = !_showOCPExample),
          colorScheme.primary,
        ),
        _buildSOLIDPrinciple(
          'L', 'Liskov Substitution',
          '리스코프 치환: 하위 타입으로 대체 가능하게',
          'StorageService 인터페이스로 Hive, Secure 구현체 교체 가능',
          false,
          null,
          colorScheme.secondary,
        ),
        _buildSOLIDPrinciple(
          'I', 'Interface Segregation',
          '인터페이스 분리: 사용하지 않는 메서드 의존 방지',
          'ReadableStorage, WritableStorage 인터페이스 분리',
          false,
          null,
          colorScheme.tertiary,
        ),
        _buildSOLIDPrinciple(
          'D', 'Dependency Inversion',
          '의존 역전: 구체적인 것이 아닌 추상화에 의존',
          'Provider로 서비스 주입, 구현체 교체 용이',
          false,
          null,
          colorScheme.surfaceTint,
        ),
      ],
    );
  }

  Widget _buildSOLIDPrinciple(
    String letter,
    String name,
    String description,
    String example,
    bool isExpanded,
    VoidCallback? onTap,
    Color color,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Color onColor;
    if (color == colorScheme.primary || color == colorScheme.surfaceTint) {
      onColor = colorScheme.onPrimary;
    } else if (color == colorScheme.secondary) {
      onColor = colorScheme.onSecondary;
    } else if (color == colorScheme.tertiary) {
      onColor = colorScheme.onTertiary;
    } else if (color == colorScheme.error) {
      onColor = colorScheme.onError;
    } else {
      onColor = colorScheme.onSurface;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: ScaledText(
                        letter,
                        style: textTheme.titleMedium?.copyWith(
                          color: onColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScaledText(
                          name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        ScaledText(
                          description,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha(178),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    ScaledIcon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: color,
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded && onTap != null)
            Container(
              margin: const EdgeInsets.only(left: 44, top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ScaledText(
                example,
                style: textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConstExample() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ScaledText(
              'const 사용 예시',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _showConstExample = !_showConstExample),
              icon: ScaledIcon(_showConstExample ? Icons.visibility_off : Icons.visibility, size: 16),
              label: ScaledText(_showConstExample ? '숨기기' : '코드 보기'),
            ),
          ],
        ),
        if (_showConstExample) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText(
                  '✅ 올바른 예시',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ScaledText(
                      '''const ScaledText('정적 텍스트')
const ScaledIcon(Icons.home)
const SizedBox(height: 16)''',
                      style: TextStyle(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText(
                  '❌ 잘못된 예시',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.error, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withAlpha(128),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ScaledText(
                      '''ScaledText('정적 텍스트')  // const 누락
ScaledIcon(Icons.home)     // const 누락''',
                      style: textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        _buildLiveConstExample(),
      ],
    );
  }

  Widget _buildLiveConstExample() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(51),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaledText(
            '실제 const 적용 예시:',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ScaledIcon(Icons.check, color: colorScheme.secondary),
              const SizedBox(width: 8),
              const ScaledText('const ScaledIcon 사용'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              ScaledIcon(Icons.text_fields, color: colorScheme.primary),
              const SizedBox(width: 8),
              const ScaledText('const ScaledText 사용'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              ScaledIcon(Icons.space_bar, color: colorScheme.onSurface.withAlpha(153)),
              const SizedBox(width: 8),
              const ScaledText('const SizedBox 사용'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetSeparationExample() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaledText(
                '✅ 올바른 위젯 분리',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildWidgetStructureItem('ExchangeRateScreen', 'build() 메서드', colorScheme.primary),
              _buildWidgetStructureItem('  └─ _buildAppBar()', 'AppBar 구성', colorScheme.secondary),
              _buildWidgetStructureItem('  └─ _buildBody()', 'Body 구성', colorScheme.secondary),
              _buildWidgetStructureItem('      └─ _buildFilterChips()', '필터 버튼들', colorScheme.tertiary),
              _buildWidgetStructureItem('      └─ _buildPriceList()', '환율 리스트', colorScheme.tertiary),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaledText(
                '❌ 잘못된 예시: 모든 것을 build()에',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.error, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const ScaledText(
                '''• 100줄 이상의 복잡한 build() 메서드
• 가독성 저하 및 유지보수 어려움
• 재사용성 부족''',
                style: TextStyle(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetStructureItem(String name, String description, Color color) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          ScaledText(
            name,
            style: textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ScaledText(
              description,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withAlpha(153)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceExample() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPerformanceItem(
          'const 생성자',
          '위젯 재생성 방지',
          'const Text(), const Icon()',
          colorScheme.secondary,
        ),
        _buildPerformanceItem(
          'RepaintBoundary',
          '불필요한 리페인트 방지',
          'RepaintBoundary(child: ComplexWidget())',
          colorScheme.primary,
        ),
        _buildPerformanceItem(
          'ListView.builder',
          '가상화로 메모리 최적화',
          '큰 리스트에는 builder 패턴',
          colorScheme.tertiary,
        ),
        _buildPerformanceItem(
          'Provider.select',
          '필요한 상태만 구독',
          'ref.watch(provider.select((s) => s.field))',
          colorScheme.surfaceTint,
        ),
        _buildPerformanceItem(
          'autoDispose',
          '사용하지 않는 Provider 해제',
          'AsyncNotifierProvider.autoDispose',
          colorScheme.error,
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(String technique, String purpose, String example, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText(
                  technique,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                ScaledText(
                  '$purpose: $example',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorHandlingExample() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ScaledIcon(Icons.error_outline, color: colorScheme.tertiary, size: 16),
                  const SizedBox(width: 8),
                  ScaledText(
                    'AsyncValue.when 패턴',
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.tertiary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ScaledText(
                    '''asyncData.when(
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(
    error: error,
    onRetry: () => ref.refresh(provider),
  ),
  data: (data) => DataWidget(data: data),
)''',
                    style: TextStyle(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ScaledIcon(Icons.warning, color: colorScheme.error, size: 16),
                  const SizedBox(width: 8),
                  ScaledText(
                    '에러 처리 원칙',
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.error),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const ScaledText(
                '''• 모든 API 호출에 try-catch 적용
• 사용자에게 명확한 에러 메시지 제공
• 재시도 메커니즘 구현
• FlutterError.onError로 앱 크래시 방지''',
                style: TextStyle(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

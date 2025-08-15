import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ArchitectureGuideWidget extends StatelessWidget {
  const ArchitectureGuideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        _buildHeaderCard(),
        const SizedBox(height: 16),
        _buildArchitectureCard(
          title: '폴더 구조',
          subtitle: 'features/ 기반 모듈화 구조',
          child: _buildFolderStructureExample(),
        ),
        _buildArchitectureCard(
          title: '파일 명명 규칙',
          subtitle: 'snake_case.dart 기반 일관된 네이밍',
          child: _buildNamingConventionExample(),
        ),
        _buildArchitectureCard(
          title: 'Model 구조',
          subtitle: 'Hive + JSON 이중 직렬화 패턴',
          child: _buildModelStructureExample(),
        ),
        _buildArchitectureCard(
          title: '메뉴 시스템',
          subtitle: 'Repository 패턴 기반 동적 메뉴',
          child: _buildMenuSystemExample(),
        ),
        _buildArchitectureCard(
          title: '라우팅 구조',
          subtitle: 'ShellRoute + GoRoute 조합',
          child: _buildRoutingStructureExample(),
        ),
        _buildArchitectureCard(
          title: 'Service 패턴',
          subtitle: 'Repository + Local Service 분리',
          child: _buildServicePatternExample(),
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
                Icon(
                  Icons.architecture,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Finow 아키텍처 패턴',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '실제 프로젝트에서 사용되는 아키텍처 패턴과 구조',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withAlpha((255 * 0.8).round()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArchitectureCard({
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
                    Icon(
                      Icons.folder_open,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withAlpha((255 * 0.7).round()),
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

  Widget _buildFolderStructureExample() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '실제 프로젝트 폴더 구조',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(_getFolderStructureText()),
                    icon: Icon(
                      Icons.copy,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: '복사',
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    _getFolderStructureText(),
                    style: textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNamingConventionExample() {
    return Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withAlpha((255 * 0.2).round()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNamingItem(context, '파일명', 'exchange_rate_screen.dart', 'snake_case.dart'),
            _buildNamingItem(context, '클래스명', 'ExchangeRateScreen', 'PascalCase'),
            _buildNamingItem(context, '변수명', 'filteredRates', 'camelCase'),
            _buildNamingItem(context, '상수명', 'API_BASE_URL', 'UPPER_SNAKE_CASE'),
            _buildNamingItem(context, 'Provider명', 'exchangeRateProvider', '[feature]Provider'),
          ],
        ),
      );
    });
  }

  Widget _buildNamingItem(BuildContext context, String type, String example, String rule) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              type,
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha((255 * 0.4).round()),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              example,
              style: textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($rule)',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withAlpha((255 * 0.6).round())),
          ),
        ],
      ),
    );
  }

  Widget _buildModelStructureExample() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ExchangeRate 모델 예시',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _copyToClipboard(_getModelStructureText()),
                  icon: const Icon(Icons.copy),
                  tooltip: '복사',
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  _getModelStructureText(),
                  style: textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.onInverseSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '🔸 Hive 로컬 저장 + JSON API 통신 모두 지원\n'
              '🔸 build_runner로 자동 코드 생성',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuSystemExample() {
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
              '동적 메뉴 구조',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildMenuCategory(context, '기본 메뉴', [
              'Home (/home)',
              'Exchange Rate (/exchange)',
              'Menu (/menu)',
              'Settings (/settings)',
            ], colorScheme.primary),
            const SizedBox(height: 8),
            _buildMenuCategory(context, 'Admin 전용 메뉴', [
              'Storage (/storage)',
              'UI Guide (/ui_guide)',
            ], colorScheme.error),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer.withAlpha((255 * 0.4).round()),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '💡 AdminModeProvider 상태에 따라 MenuRepository에서 동적으로 메뉴 제공',
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuCategory(BuildContext context, String title, List<String> menus, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        ...menus.map((menu) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 2),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(menu, style: textTheme.bodySmall),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildRoutingStructureExample() {
    return Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withAlpha((255 * 0.2).round()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '라우팅 구조',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _copyToClipboard(_getRoutingStructureText()),
                  icon: const Icon(Icons.copy),
                  tooltip: '복사',
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRoutingItem(context, 'ShellRoute', '하단 네비게이션 화면들', colorScheme.primary),
            _buildRoutingItem(context, 'GoRoute', '상세 화면 (파라미터 전달)', colorScheme.secondary),
            _buildRoutingItem(context, 'NoTransitionPage', '전환 애니메이션 제거', colorScheme.tertiary),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  _getRoutingStructureText(),
                  style: textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.onInverseSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRoutingItem(BuildContext context, String component, String description, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            '$component: ',
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          Expanded(
            child: Text(description, style: textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildServicePatternExample() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '서비스 레이어 분리',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildServiceLayer(context, 'API Client', 'ExConvertApiClient', '외부 API 통신', colorScheme.error),
            _buildServiceLayer(context, 'Repository', 'ExchangeRateRepository', '비즈니스 로직', colorScheme.primary),
            _buildServiceLayer(context, 'Local Service', 'ExchangeRateLocalService', '로컬 저장소', colorScheme.secondary),
            _buildServiceLayer(context, 'Update Service', 'ExchangeRateUpdateService', '백그라운드 작업', colorScheme.tertiary),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withAlpha((255 * 0.4).round()),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '📋 단일 책임 원칙에 따라 역할별로 명확하게 분리\n'
                '🔄 Provider에서 각 서비스를 주입받아 협업',
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildServiceLayer(BuildContext context, String layer, String className, String responsibility, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              layer,
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              '$className ($responsibility)',
              style: textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  String _getFolderStructureText() {
    return '''features/
├── [feature_name]/
│   ├── [feature]_screen.dart          # UI Layer
│   ├── [feature]_provider.dart        # State Management
│   ├── [feature]_repository.dart      # Business Logic
│   ├── [feature]_local_service.dart   # Local Storage
│   ├── [feature]_api_client.dart      # External API
│   ├── [feature]_update_service.dart  # Background Service
│   └── [feature].dart                 # Model/Entity''';
  }

  String _getModelStructureText() {
    return '''@HiveType(typeId: 1)
@JsonSerializable()
class ExchangeRate extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'time_last_update_unix')
  final int lastUpdatedUnix;
  
  // ... other fields

  factory ExchangeRate.fromJson(Map<String, dynamic> json) =>
      _\$ExchangeRateFromJson(json);
      
  Map<String, dynamic> toJson() => _\$ExchangeRateToJson(this);
}''';
  }

  String _getRoutingStructureText() {
    return '''GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      pageBuilder: (context, state, child) {
        return NoTransitionPage(child: MainScreen(child: child));
      },
      routes: [...shellRoutes],
    ),
    GoRoute(
      path: '/exchange/:quoteCode',
      pageBuilder: (context, state) {
        final exchangeRate = state.extra as ExchangeRate;
        return NoTransitionPage(child: ExchangeRateDetailScreen(exchangeRate: exchangeRate));
      },
    ),
  ],
)''';
  }
}
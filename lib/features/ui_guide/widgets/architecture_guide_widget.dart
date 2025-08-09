

// 프로젝트 아키텍처 패턴들의 실제 구현 예시를 제공합니다.
// docs에서 제거된 아키텍처 관련 코드 예시들을 실제로 동작하는 형태로 구현합니다.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finow/ui_scale_provider.dart';

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
                ScaledIcon(
                  Icons.architecture,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 8),
                ScaledText(
                  'Finow 아키텍처 패턴',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ScaledText(
                  '실제 프로젝트에서 사용되는 아키텍처 패턴과 구조',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withAlpha(204), // withOpacity(0.8)
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
                    ScaledIcon(
                      Icons.folder_open, 
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
                              color: colorScheme.onSurface.withAlpha(178), // withOpacity(0.7)
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
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest, // surfaceVariant -> surfaceContainerHighest
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ScaledText(
                    '실제 프로젝트 폴더 구조',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(_getFolderStructureText()),
                    icon: ScaledIcon(
                      Icons.copy, 
                      size: 16,
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
              child: ScaledText(
                'features/\n'
                '├── [feature_name]/\n'
                '│   ├── [feature]_screen.dart          # UI Layer\n'
                '│   ├── [feature]_provider.dart        # State Management\n'
                '│   ├── [feature]_repository.dart      # Business Logic\n'
                '│   ├── [feature]_local_service.dart   # Local Storage\n'
                '│   ├── [feature]_api_client.dart      # External API\n'
                '│   ├── [feature]_update_service.dart  # Background Service\n'
                '│   └── [feature].dart                 # Model/Entity',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: colorScheme.onInverseSurface,
                      fontSize: 12,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNamingItem('파일명', 'exchange_rate_screen.dart', 'snake_case.dart'),
          _buildNamingItem('클래스명', 'ExchangeRateScreen', 'PascalCase'),
          _buildNamingItem('변수명', 'filteredRates', 'camelCase'),
          _buildNamingItem('상수명', 'API_BASE_URL', 'UPPER_SNAKE_CASE'),
          _buildNamingItem('Provider명', 'exchangeRateProvider', '[feature]Provider'),
        ],
      ),
    );
  }

  Widget _buildNamingItem(String type, String example, String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: ScaledText(
              type,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const ScaledText(': '),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(3),
            ),
            child: ScaledText(
              example,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          ScaledText(
            '($rule)',
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildModelStructureExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ScaledText(
                'ExchangeRate 모델 예시',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => _copyToClipboard(_getModelStructureText()),
                icon: const ScaledIcon(Icons.copy, size: 16),
                tooltip: '복사',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ScaledText(
                '@HiveType(typeId: 1)\n'
                '@JsonSerializable()\n'
                'class ExchangeRate extends HiveObject {\n'
                '  @HiveField(0)\n'
                '  @JsonKey(name: \'time_last_update_unix\')\n'
                '  final int lastUpdatedUnix;\n'
                '  \n'
                '  factory ExchangeRate.fromJson(Map<String, dynamic> json) =>\n'
                '      _\$ExchangeRateFromJson(json);\n'
                '  Map<String, dynamic> toJson() => _\$ExchangeRateToJson(this);\n'
                '}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.green,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const ScaledText(
            '🔸 Hive 로컬 저장 + JSON API 통신 모두 지원\n'
            '🔸 build_runner로 자동 코드 생성',
            style: TextStyle(fontSize: 12, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSystemExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScaledText(
            '동적 메뉴 구조',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildMenuCategory('기본 메뉴', [
            'Home (/home)',
            'Exchange Rate (/exchange)', 
            'Menu (/menu)',
            'Settings (/settings)',
          ], Colors.blue),
          const SizedBox(height: 8),
          _buildMenuCategory('Admin 전용 메뉴', [
            'Storage (/storage)',
            'UI Guide (/ui_guide)',
          ], Colors.red),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const ScaledText(
              '💡 AdminModeProvider 상태에 따라 MenuRepository에서 동적으로 메뉴 제공',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCategory(String title, List<String> menus, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScaledText(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
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
              ScaledText(menu, style: const TextStyle(fontSize: 12)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRoutingStructureExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ScaledText(
                '라우팅 구조',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => _copyToClipboard(_getRoutingStructureText()),
                icon: const ScaledIcon(Icons.copy, size: 16),
                tooltip: '복사',
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRoutingItem('ShellRoute', '하단 네비게이션 화면들', Colors.blue),
          _buildRoutingItem('GoRoute', '상세 화면 (파라미터 전달)', Colors.green),
          _buildRoutingItem('NoTransitionPage', '전환 애니메이션 제거', Colors.orange),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ScaledText(
                'GoRouter(\n'
                '  initialLocation: \'/home\',\n'
                '  routes: [\n'
                '    ShellRoute(pageBuilder: MainScreen),\n'
                '    GoRoute(path: \'/exchange/:code\'),\n'
                '  ],\n'
                ')',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.green,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutingItem(String component, String description, Color color) {
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
          ScaledText(
            '$component: ',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Expanded(
            child: ScaledText(description, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildServicePatternExample() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScaledText(
            '서비스 레이어 분리',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildServiceLayer('API Client', 'ExConvertApiClient', '외부 API 통신', Colors.red),
          _buildServiceLayer('Repository', 'ExchangeRateRepository', '비즈니스 로직', Colors.blue),
          _buildServiceLayer('Local Service', 'ExchangeRateLocalService', '로컬 저장소', Colors.green),
          _buildServiceLayer('Update Service', 'ExchangeRateUpdateService', '백그라운드 작업', Colors.orange),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const ScaledText(
              '📋 단일 책임 원칙에 따라 역할별로 명확하게 분리\n'
              '🔄 Provider에서 각 서비스를 주입받아 협업',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceLayer(String layer, String className, String responsibility, Color color) {
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
            child: ScaledText(
              layer,
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12),
            ),
          ),
          const ScaledText(': '),
          Expanded(
            child: ScaledText(
              '$className ($responsibility)',
              style: const TextStyle(fontSize: 12),
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
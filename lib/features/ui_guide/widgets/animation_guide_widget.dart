// 이 위젯은 다양한 애니메이션 구현 예시를 제공하여, 프로젝트 내 애니메이션 스타일의 기준점 역할을 합니다.
// 실제 서비스 적용 전, 애니메이션 효과의 방향성과 일관성을 확인하는 용도로 사용하세요.
import 'package:finow/ui_scale_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimationGuideWidget extends StatefulWidget {
  const AnimationGuideWidget({super.key});

  @override
  State<AnimationGuideWidget> createState() => _AnimationGuideWidgetState();
}

class _AnimationGuideWidgetState extends State<AnimationGuideWidget>
    with TickerProviderStateMixin {
  bool _isToggled = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 16, // Horizontal spacing between items
      runSpacing: 16, // Vertical spacing between lines
      children: [
        _buildAnimationExample(
          context,
          'AnimatedContainer',
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            width: _isToggled ? 150 : 75,
            height: _isToggled ? 75 : 150,
            color: _isToggled ? colorScheme.primary : colorScheme.secondary,
          ),
        ),
        _buildAnimationExample(
          context,
          'AnimatedOpacity',
          AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: _isToggled ? 0.2 : 1.0,
            child: const FlutterLogo(size: 75),
          ),
        ),
        _buildAnimationExample(
          context,
          'Hero Animation',
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo',
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const _HeroDetailPage())),
                  child: const FlutterLogo(size: 50),
                ),
              ),
            ],
          ),
        ),
        _buildAnimationExample(
          context,
          'AnimatedCrossFade',
          AnimatedCrossFade(
            duration: const Duration(seconds: 1),
            firstChild:
                const FlutterLogo(style: FlutterLogoStyle.horizontal, size: 75.0),
            secondChild:
                const FlutterLogo(style: FlutterLogoStyle.stacked, size: 75.0),
            crossFadeState: _isToggled
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          ),
        ),
        _buildAnimationExample(
          context,
          'Custom Animation (Tween)',
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(1.5, 0.0),
            ).animate(CurvedAnimation(
              parent: _controller,
              curve: Curves.elasticIn,
            )),
            child: const FlutterLogo(size: 50),
          ),
        ),
        _buildAnimationExample(
          context,
          'Lottie Animation',
          Lottie.network(
            'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json',
            width: 75,
            height: 75,
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 32 - 16) / 2, // Half width minus padding and spacing
          child: ElevatedButton(
              onPressed: () => setState(() => _isToggled = !_isToggled),
              child: const ScaledText('Toggle Animations')),
        ),
      ],
    );
  }

  Widget _buildAnimationExample(BuildContext context, String title, Widget exampleWidget) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final itemWidth = (MediaQuery.of(context).size.width - 32 - 16) / 2; // Half width minus padding and spacing

    return SizedBox(
      width: itemWidth,
      child: Column(
        children: [
          ScaledText(title, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: exampleWidget),
          ),
        ],
      ),
    );
  }
}

class _HeroDetailPage extends StatelessWidget {
  const _HeroDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Hero Detail')),
      body: const Center(
        child: Hero(
          tag: 'logo',
          child: FlutterLogo(size: 200),
        ),
      ),
    );
  }
}
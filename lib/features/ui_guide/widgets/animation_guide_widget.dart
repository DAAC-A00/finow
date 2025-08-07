// 이 위젯은 다양한 애니메이션 구현 예시를 제공하여, 프로젝트 내 애니메이션 스타일의 기준점 역할을 합니다.
// 실제 서비스 적용 전, 애니메이션 효과의 방향성과 일관성을 확인하는 용도로 사용하세요.
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimationGuideWidget extends StatefulWidget {
  const AnimationGuideWidget({super.key});

  @override
  State<AnimationGuideWidget> createState() => _AnimationGuideWidgetState();
}

class _AnimationGuideWidgetState extends State<AnimationGuideWidget> with TickerProviderStateMixin {
  bool _isToggled = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('AnimatedContainer'),
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          width: _isToggled ? 200 : 100,
          height: _isToggled ? 100 : 200,
          color: _isToggled ? Colors.blue : Colors.red,
        ),
        const SizedBox(height: 10),
        const Text('AnimatedOpacity'),
        AnimatedOpacity(
          duration: const Duration(seconds: 1),
          opacity: _isToggled ? 0.2 : 1.0,
          child: const FlutterLogo(size: 100),
        ),
        const SizedBox(height: 10),
        const Text('Hero Animation'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _HeroDetailPage())),
                child: const FlutterLogo(size: 50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text('AnimatedCrossFade'),
        AnimatedCrossFade(
          duration: const Duration(seconds: 1),
          firstChild: const FlutterLogo(style: FlutterLogoStyle.horizontal, size: 100.0),
          secondChild: const FlutterLogo(style: FlutterLogoStyle.stacked, size: 100.0),
          crossFadeState: _isToggled ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
        const SizedBox(height: 10),
        const Text('Custom Animation (Tween)'),
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
        const SizedBox(height: 10),
        const Text('Lottie Animation'),
        Lottie.network(
          'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json',
          width: 100,
          height: 100,
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () => setState(() => _isToggled = !_isToggled), child: const Text('Toggle Animations')),
      ],
    );
  }
}

class _HeroDetailPage extends StatelessWidget {
  const _HeroDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Detail')),
      body: const Center(
        child: Hero(
          tag: 'logo',
          child: FlutterLogo(size: 200),
        ),
      ),
    );
  }
}

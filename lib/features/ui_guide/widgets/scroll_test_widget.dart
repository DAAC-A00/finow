// 이 위젯은 스크롤 및 리스트 UI의 구현 예시를 제공하여, 프로젝트 내 스크롤/리스트 컴포넌트의 기준점 역할을 합니다.
// 실제 서비스 적용 전, 스크롤 동작과 리스트 UI의 일관성을 확인하는 용도로 사용하세요.
import 'package:flutter/material.dart';

class ScrollGuideWidget extends StatefulWidget {
  const ScrollGuideWidget({super.key});

  @override
  State<ScrollGuideWidget> createState() => _ScrollGuideWidgetState();
}

class _ScrollGuideWidgetState extends State<ScrollGuideWidget> {
  final List<String> _items = List.generate(20, (i) => 'Item ${i + 1}');
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMoreData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _items.addAll(List.generate(10, (i) => 'Item ${_items.length + i + 1}'));
      _isLoading = false;
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _items.clear();
      _items.addAll(List.generate(20, (i) => 'Item ${i + 1}'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          const SliverAppBar(
            title: Text('SliverAppBar'),
            floating: true,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: FlutterLogo(),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _items.length + 1,
            itemBuilder: (context, index) {
              if (index == _items.length) {
                return _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox.shrink();
              }
              return ListTile(title: Text(_items[index]));
            },
          ),
        ),
      ),
    );
  }
}

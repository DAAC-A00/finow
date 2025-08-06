import 'package:flutter/material.dart';

class ScrollTestWidget extends StatefulWidget {
  const ScrollTestWidget({super.key});

  @override
  State<ScrollTestWidget> createState() => _ScrollTestWidgetState();
}

class _ScrollTestWidgetState extends State<ScrollTestWidget> {
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

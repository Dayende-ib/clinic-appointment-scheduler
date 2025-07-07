import 'package:flutter/material.dart';

class PaginationHelper<T> {
  final List<T> _items = [];
  final int pageSize;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  PaginationHelper({this.pageSize = 20});

  List<T> get items => List.unmodifiable(_items);
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;

  void addItems(List<T> newItems) {
    _items.addAll(newItems);
    _hasMore = newItems.length >= pageSize;
    _currentPage++;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void reset() {
    _items.clear();
    _currentPage = 0;
    _hasMore = true;
    _isLoading = false;
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  int get length => _items.length;

  T operator [](int index) => _items[index];
}

class LazyLoadingWidget<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) loadData;
  final Widget Function(T item, int index) itemBuilder;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final int pageSize;
  final bool enablePullToRefresh;
  final bool enableLoadMore;

  const LazyLoadingWidget({
    super.key,
    required this.loadData,
    required this.itemBuilder,
    this.emptyWidget,
    this.loadingWidget,
    this.pageSize = 20,
    this.enablePullToRefresh = true,
    this.enableLoadMore = true,
  });

  @override
  State<LazyLoadingWidget<T>> createState() => _LazyLoadingWidgetState<T>();
}

class _LazyLoadingWidgetState<T> extends State<LazyLoadingWidget<T>> {
  final PaginationHelper<T> _pagination = PaginationHelper<T>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    if (widget.enableLoadMore) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_pagination.isLoading) return;

    setState(() {
      _pagination.setLoading(true);
    });

    try {
      final items = await widget.loadData(0, widget.pageSize);
      setState(() {
        _pagination.reset();
        _pagination.addItems(items);
        _pagination.setLoading(false);
      });
    } catch (e) {
      setState(() {
        _pagination.setLoading(false);
      });
      // TODO: Show error message
    }
  }

  Future<void> _loadMoreData() async {
    if (_pagination.isLoading || !_pagination.hasMore) return;

    setState(() {
      _pagination.setLoading(true);
    });

    try {
      final items = await widget.loadData(
        _pagination.currentPage,
        widget.pageSize,
      );
      setState(() {
        _pagination.addItems(items);
        _pagination.setLoading(false);
      });
    } catch (e) {
      setState(() {
        _pagination.setLoading(false);
      });
      // TODO: Show error message
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pagination.isEmpty && !_pagination.isLoading) {
      return widget.emptyWidget ??
          const Center(child: Text('Aucune donnée disponible'));
    }

    final listView = ListView.builder(
      controller: _scrollController,
      itemCount: _pagination.length + (_pagination.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _pagination.length) {
          return widget.loadingWidget ??
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
        }

        return widget.itemBuilder(_pagination[index], index);
      },
    );

    if (widget.enablePullToRefresh) {
      return RefreshIndicator(
        onRefresh: () async => await _loadInitialData(),
        child: listView,
      );
    }

    return listView;
  }
}

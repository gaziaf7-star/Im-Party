import 'package:general/src/core/index.dart';

class ReversibleAutoScrollListWidget<T> extends StatefulWidget {
  final List<T> items;
  final double? size;

  const ReversibleAutoScrollListWidget({
    super.key,
    required this.items,
    this.size,
  });

  @override
  ReversibleAutoScrollListWidgetState<T> createState() =>
      ReversibleAutoScrollListWidgetState<T>();
}

class ReversibleAutoScrollListWidgetState<T>
    extends State<ReversibleAutoScrollListWidget<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.items.length > 3) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {}

  @override
  void dispose() {
    // if (_timer.isActive) {
    //   // _timer.cancel();
    // }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: widget.items.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final dynamic item = widget.items[index];
        final String imageUrl =
            item is String ? item : item.image?.toString() ?? '';
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.5.w),
          child: SizedBox(
            child: imageUrl.contains('.svg')
                ? CacheSvgaWidget(
                    height: widget.size?.h ?? 25.h,
                    width: widget.size?.w ?? 25.w,
                    url: imageUrl,
                    boxFit: BoxFit.cover,
                  )
                : ImageViewWidget(
                    height: widget.size?.h ?? 25.h,
                    width: widget.size?.w ?? 25.w,
                    url: imageUrl,
                    boxFit: BoxFit.cover,
                  ),
          ),
        );
      },
    );
  }
}

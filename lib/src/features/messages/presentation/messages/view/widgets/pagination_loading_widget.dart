import '../../../../../../../reels_viewer/reels_viewer.dart';
import '../../../../../../core/widgets/GradientLoader.dart';

class PaginationLoader extends StatefulWidget {
  final bool isVisible;

  const PaginationLoader({super.key, required this.isVisible});

  @override
  State<PaginationLoader> createState() => _PaginationLoaderState();
}

class _PaginationLoaderState extends State<PaginationLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, -0.05), // slight up
      end: const Offset(0, 0.05), // slight down
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox();

    return SlideTransition(
      position: _animation,
      child: Center(
        child: Container(
          height: 50.h,
          width: ScreenUtil().screenWidth,
          alignment: Alignment.center,
          child: Center(
            child: GradientLoader(size: 24.h, strokeWidth: 3),
          ),
        ),
      ),
    );
  }
}
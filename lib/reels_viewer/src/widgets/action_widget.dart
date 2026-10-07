
part of 'package:general/reels_viewer/src/reels_viewer.dart';

class _ReelsActionWidget extends StatefulWidget {
  const _ReelsActionWidget({
    required this.onTap,
    required this.image,
    required this.color,
    required this.size,
    this.isActive = false,
    this.enableHaptic = false,
    this.semanticLabel,
    this.semanticValue,
  });

  final VoidCallback onTap;
  final String image;
  final Color color;
  final double size;

  /// When this flips (e.g. like toggled on), the icon plays a scale-pop bounce.
  final bool isActive;

  /// Fire a light haptic on tap (rail like / follow).
  final bool enableHaptic;

  /// A11Y label (localized) e.g. "Like" / "Comment".
  final String? semanticLabel;

  /// A11Y value (localized count) read alongside the label where relevant.
  final String? semanticValue;

  @override
  State<_ReelsActionWidget> createState() => _ReelsActionWidgetState();
}

class _ReelsActionWidgetState extends State<_ReelsActionWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _popController;
  late final Animation<double> _popScale;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _popScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 55,
      ),
    ]).animate(_popController);
  }

  @override
  void didUpdateWidget(covariant _ReelsActionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Bounce when the active state turns on (e.g. isLiked false -> true).
    if (widget.isActive && !oldWidget.isActive) {
      _popController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    _popController.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = GestureDetector(
      onTap: _handleTap,
      onDoubleTap: _handleTap,
      child: Container(
        color: ColorManager.transparent,
        child: ScaleTransition(
          scale: _popScale,
          child: Image.asset(
            widget.image,
            color: widget.color,
            height: widget.size,
            width: widget.size,
          ),
        ),
      ),
    );

    if (widget.semanticLabel != null) {
      icon = Semantics(
        button: true,
        label: widget.semanticLabel,
        value: widget.semanticValue,
        child: icon,
      );
    }

    return Padding(
      padding: context.paddingOnly(end: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [icon],
      ),
    );
  }
}

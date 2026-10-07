import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';

// Custom Auto-Scrolling Text Widget using Animation (No ScrollController!)
class AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final double velocity;
  final Duration pauseDuration;

  const AutoScrollText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign,
    this.velocity = 50.0,
    this.pauseDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _textWidth = 0;
  double _containerWidth = 0;
  bool _needsScrolling = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void didUpdateWidget(AutoScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _stopAnimation();
      _textWidth = 0;
      _needsScrolling = false;
    }
  }

  void _stopAnimation() {
    _isAnimating = false;
    _animationController.reset();
  }

  void _startScrollAnimation(double containerWidth, double textWidth) {
    if (_isAnimating || !mounted) return;

    _containerWidth = containerWidth;
    _textWidth = textWidth;
    _needsScrolling = textWidth > containerWidth;

    if (_needsScrolling) {
      _isAnimating = true;
      final distance = textWidth - containerWidth;
      final duration = Duration(
        milliseconds: ((distance / widget.velocity) * 1000).round(),
      );

      _animationController.duration = duration;
      _animateLoop();
    }
  }

  Future<void> _animateLoop() async {
    while (mounted && _isAnimating && _needsScrolling) {
      // Pause at start
      await Future.delayed(widget.pauseDuration);
      if (!mounted || !_isAnimating) return;

      // Animate to end
      await _animationController.forward();
      if (!mounted || !_isAnimating) return;

      // Pause at end
      await Future.delayed(widget.pauseDuration);
      if (!mounted || !_isAnimating) return;

      // Animate back to start
      await _animationController.reverse();
      if (!mounted || !_isAnimating) return;
    }
  }

  @override
  void dispose() {
    _stopAnimation();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;

        return ClipRect(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // Names are user-generated and can carry lone UTF-16 surrogates
              // that crash the paragraph builder ("string is not well-formed
              // UTF-16") — sanitize at this shared render choke point.
              final safeText = widget.text.sanitizedForDisplay;
              // Measure text width after first build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _textWidth == 0) {
                  final textPainter = TextPainter(
                    text: TextSpan(text: safeText, style: widget.style),
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                  )..layout();

                  if (textPainter.width > 0) {
                    _startScrollAnimation(containerWidth, textPainter.width);
                  }
                }
              });

              final offset = _needsScrolling
                  ? -(_textWidth - _containerWidth) * _animation.value
                  : 0.0;

              return Transform.translate(
                offset: Offset(offset, 0),
                child: Text(
                  safeText,
                  style: widget.style,
                  textAlign: widget.textAlign,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Updated GradientTextVip
class GradientTextVip extends StatelessWidget {
  final bool isVip;
  final String text;
  final Color? color;
  final int? typeUser;
  final int? myType;
  final TextStyle textStyle;
  final TextAlign? textAlign;
  final double? width;
  final double? spase;
  final double? sizeIconManagement;
  final double? scaleIconAllOfAgent;
  final double? height;
  final TextOverflow? textOverflow;
  final ManagerTypeEntity? managerTypeEntity;
  final MainAxisAlignment? mainAxisAlignment;

  const GradientTextVip({
    super.key,
    required this.text,
    this.color,
    required this.textStyle,
    this.typeUser,
    required this.isVip,
    this.textAlign,
    this.myType,
    this.width,
    this.height,
    this.spase,
    this.sizeIconManagement,
    this.mainAxisAlignment,
    this.scaleIconAllOfAgent,
    this.textOverflow,
    this.managerTypeEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        isVip
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width ?? 200.w,
                  minWidth: 0,
                ),
                // VIP names use the same brand gradient as every other name.
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) =>
                      ColorManager.brandGradient1.createShader(bounds),
                  child: AutoScrollText(
                    text: text,
                    style: textStyle,
                    textAlign: textAlign,
                    velocity: 50.0,
                    pauseDuration: const Duration(milliseconds: 1000),
                  ),
                ),
              )
            : Align(
                alignment: AlignmentDirectional.centerStart,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: width ?? 200.w,
                    minWidth: 0,
                  ),
                  // Every user name is painted with the brand gradient.
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) =>
                        ColorManager.brandGradient1.createShader(bounds),
                    child: AutoScrollText(
                      text: text,
                      style: textStyle,
                      textAlign: textAlign,
                      velocity: 50.0,
                      pauseDuration: const Duration(milliseconds: 1000),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
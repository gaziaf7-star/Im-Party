import 'package:general/src/core/index.dart';

/// WhatsApp-style collapsible long message. Short messages render as plain text;
/// messages longer than [threshold] characters show a clamped preview
/// ([collapsedLines] lines + ellipsis) with an inline "Read more" toggle that
/// expands to the full text (and back via "Show less"). The text style matches the
/// surrounding bubble so only the toggle is styled differently.
class ExpandableText extends StatefulWidget {
  const ExpandableText(
    this.text, {
    super.key,
    required this.style,
    this.threshold = 300,
    this.collapsedLines = 9,
    this.toggleColor,
  });

  final String text;
  final TextStyle style;
  final int threshold;
  final int collapsedLines;
  final Color? toggleColor;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.text.length > widget.threshold;
    if (!isLong) {
      return Text(widget.text, style: widget.style);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.text,
          style: widget.style,
          maxLines: _expanded ? null : widget.collapsedLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        4.hBox,
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded
                ? StringManager.showLess.tr()
                : StringManager.readMore.tr(),
            style: widget.style.copyWith(
              fontWeight: FontWeight.w700,
              color: widget.toggleColor ?? ColorManager.primary,
            ),
          ),
        ),
      ],
    );
  }
}

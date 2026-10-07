import 'package:general/src/core/index.dart';

class TextWidget extends StatelessWidget {
  const TextWidget(
    this.text, {
    super.key,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.style,
    this.isTranslate = true,
    this.padding,
  });

  final String text;
  final int? maxLines;
  final bool isTranslate;
  final EdgeInsetsGeometry? padding;
  final TextOverflow? overflow;
  final TextStyle? style;

  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = (style ?? context.bodyMedium).copyWith(
      fontFamily: 'AppFont',
      fontFamilyFallback: const [
        'SegoeUI',
        'sans-serif',
      ],
    );

    // Strip lone UTF-16 surrogates / bidi overrides / control chars before the
    // string reaches the native paragraph builder. Malformed user content (the
    // _NativeParagraphBuilder.addText "string is not well-formed UTF-16" crash)
    // would otherwise abort layout for the whole frame. Clean text is returned
    // unchanged (no allocation), so this is free for the common case.
    final resolved = (isTranslate ? tr(text) : text).sanitizedForDisplay;

    return Padding(
      padding: padding ?? context.paddingZero(),
      child: Text(
        resolved,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: defaultStyle,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Glossy 3D gold "LUDO" logo: extruded dark edge, gold gradient face, white
/// highlight, crown on top and a small dice underneath.
class LudoLogoWidget extends StatelessWidget {
  final double scale;
  final bool showSubtitle;

  const LudoLogoWidget({super.key, this.scale = 1.0, this.showSubtitle = true});

  @override
  Widget build(BuildContext context) {
    final fs = 54.0 * scale;
    TextStyle base({Color? color, Paint? foreground, List<Shadow>? shadows}) =>
        TextStyle(
          fontSize: fs,
          fontWeight: FontWeight.w900,
          letterSpacing: 2 * scale,
          height: 1,
          color: color,
          foreground: foreground,
          shadows: shadows,
        );
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * scale
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF8A3B00);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFFFF3B0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('👑', style: TextStyle(fontSize: 26 * scale)),
        SizedBox(height: 2 * scale),
        Stack(
          alignment: Alignment.center,
          children: [
            // extrusion
            Transform.translate(
              offset: Offset(0, 6 * scale),
              child: Text(
                'LUDO',
                style: base(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 7 * scale
                    ..strokeJoin = StrokeJoin.round
                    ..color = const Color(0xFF4A1D00),
                ),
              ),
            ),
            Text('LUDO', style: base(foreground: outline)),
            Text('LUDO', style: base(foreground: edge)),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF59D),
                  Color(0xFFFFC928),
                  Color(0xFFFF9800),
                ],
              ).createShader(r),
              child: Text(
                'LUDO',
                style: base(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(0, 2 * scale),
                      blurRadius: 3 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * scale),
        Text('🎲', style: TextStyle(fontSize: 22 * scale)),
        if (showSubtitle)
          Text(
            'Play • Meet • Win',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10.5 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
      ],
    );
  }
}

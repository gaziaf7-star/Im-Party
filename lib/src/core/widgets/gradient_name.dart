import 'package:flutter/material.dart';
import 'package:general/src/core/constants/color_manager.dart';

/// Paints a user's display name (any [Text]/[TextWidget] passed as [child])

class GradientName extends StatelessWidget {
  const GradientName({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => ColorManager.brandGradient1.createShader(bounds),
      child: child,
    );
  }
}






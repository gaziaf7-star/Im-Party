import 'package:general/src/core/index.dart';

/// The app's single "professional" loading spinner, used everywhere a
/// loading state needs one (on request, replacing the mix of
/// staggeredDotsWave/threeArchedCircle/flat-colour CircularProgressIndicator
/// spinners previously scattered across the app).
///
/// A plain circular indicator painted with the app's own brand gradient
/// (pink -> purple, [ColorManager.brandGradientColors]) via a [ShaderMask] —
/// Flutter's [CircularProgressIndicator] only accepts a flat [Color], not a
/// [Gradient], so this is the standard way to get a gradient-coloured ring.
/// Deliberately spinner-only: never pairs this with a text/caption, per the
/// request that loading states show only the spinner.
class GradientLoader extends StatelessWidget {
  const GradientLoader({super.key, this.size = 28, this.strokeWidth = 3});

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => SweepGradient(
          colors: [
            ColorManager.brandGradientColors.first,
            ColorManager.brandGradientColors.last,
            ColorManager.brandGradientColors.first,
          ],
        ).createShader(bounds),
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
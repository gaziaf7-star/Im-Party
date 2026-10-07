import '../../../../../../core/index.dart';

class LockAndPkIcon extends StatelessWidget {
  final bool isPK, isPassword, isHasLuckyBox;

  const LockAndPkIcon({
    super.key,
    required this.isPassword,
    required this.isPK,
    required this.isHasLuckyBox,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
       
          if (isPK) ...[
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  ColorManager.iconColor,
                  ColorManager.iconColor,
                  ColorManager.iconColor.withValues(alpha: (0.685)),
                  ColorManager.iconColor.withValues(alpha: (0.15)),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Container(
                decoration: ColorManager.cardDecoration(
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: context.paddingAll(5),
                  child: ImageWidget(
                   image:  AssetsManager.pkIcon,
                    color: ColorManager.primary,
                    height: 25.h,
                    width: 25.h,
                  ),
                ),
              ),
            ),
            5.wBox,
          ],
          if (isPassword) ...[
            // Clean lock badge. The old ShaderMask painted the whole circular
            // card a solid (dark) colour, so the lock read as a black blob —
            // use a plain themed circle + a guaranteed Material lock icon.
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.black.withValues(alpha: 0.35),
              ),
              padding: context.paddingAll(5),
              child: Icon(
                Icons.lock,
                color: ColorManager.white,
                size: 18.h,
              ),
            ),
            2.5.wBox,
          ],
        
        if (isHasLuckyBox)
          ImageWidget(
           image:  AssetsManager.icLuckyBag,
            width: 35.h,
            height: 35.h,
          ),
      ],
    );
  }
}

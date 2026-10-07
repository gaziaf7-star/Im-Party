import 'package:general/src/core/index.dart';

class LuckyBoxWinnerView extends StatelessWidget {
  final String name, coins;
  final double fontSize;
  const LuckyBoxWinnerView({
    super.key,
    required this.name,
    required this.coins,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingOnly(
        top: 10.h,
        bottom: 10.h,
        end: 15.w,
        start: 15.w,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsManager.winBubble),
          fit: BoxFit.fill,
        ),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              // User-generated name: strip lone surrogates before the native
              // paragraph builder (addText not-well-formed-UTF-16 crash).
              text: name.sanitizedForDisplay,
              style: context.bodyMedium
                  .size(fontSize)
                  .copyWith(fontWeight: FontWeight.bold)
                  .colorExt(ColorManager.textPrimary),
            ),
            TextSpan(
              text: " ${StringManager.win.tr()} ",
              style: context.bodyMedium.size(fontSize).colorExt(ColorManager.textPrimary),
            ),
            TextSpan(
              text: coins,
              style: const TextStyle(
                fontFamily: "BungeeSpice",
              ),
            ),
            TextSpan(
              text: StringManager.coinsInLuckyBag.tr(),
              style: context.bodyMedium.size(fontSize).colorExt(ColorManager.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

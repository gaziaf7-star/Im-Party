import 'package:general/src/core/index.dart';

class ErrorLuckWidget extends StatelessWidget {
  final bool isNotLucky;
  final String ownerName;
  final String ownerImage;
  const ErrorLuckWidget({
    required this.isNotLucky,
    super.key,
    required this.ownerName,
    required this.ownerImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsManager.luckyBoxWinner),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 25.h),
            child: Image.asset(
              AssetsManager.badLucky,
              scale: 1.8,
            ),
          ),
          5.hBox,
          Text(
            StringManager.missedTheLuckyBag.tr(),
            style: context.bodyMedium
                .colorExt(ColorManager.textPrimary)
                .w600
                .size(14)
                .copyWith(
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

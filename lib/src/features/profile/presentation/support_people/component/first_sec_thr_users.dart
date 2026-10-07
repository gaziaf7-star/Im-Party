import 'package:general/src/core/index.dart';

import '../../../data/model/top.dart';

class FirstSecThrUsers extends StatelessWidget {
  final double position;
  final double leftPosition;
  final double bottomPosition;
  final double height;
  final double? frameSize;
  final int topNumber;

  final Top userData;

  const FirstSecThrUsers(
      {required this.userData,
      required this.height,
      required this.leftPosition,
      required this.position,
      required this.topNumber,
      super.key,
      required this.bottomPosition,
      this.frameSize});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Methods().userProfileNavigator(
          context: context,
          userId: '${userData.id}',
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          userData.id != 0
              ? Container(
                  margin: EdgeInsets.only(
                    top: position,
                    left: leftPosition,
                  ),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage(
                      topNumber == 1
                          ? AssetsManager.frameOneRank
                          : topNumber == 2
                              ? AssetsManager.frameTowRank
                              : AssetsManager.frameThreeRank,
                    ),
                    fit: BoxFit.fill,
                  )),
                  height: height,
                  width: 90,
                  child: UserImage(
                    imageSize: topNumber == 1 ? 60 : 60,
                    //frameSize: frameSize,
                    image: userData.image ?? "",
                    displayName: userData.name ?? '',
                  ))
              : 70.wBox,
          10.hBox,
          GradientTextVip(
            text: userData.name ?? "",
            textStyle: context.bodySmall.colorExt(ColorManager.textPrimary),
            textAlign: TextAlign.center,
            isVip: false, // userData.hasColorName??false,
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: bottomPosition,
            ),
            padding: context.paddingSymmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AssetsManager.supporterCoin,
                  scale: 2.5,
                ),
                TextWidget(
                  userData.total.toString(),
                  style: context.bodySmall.w500.colorExt(ColorManager.textPrimary),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

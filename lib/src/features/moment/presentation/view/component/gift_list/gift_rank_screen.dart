import 'package:general/src/core/index.dart';

class GiftRankScreen extends StatelessWidget {
  final GiftRankArguments args;

  const GiftRankScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final momentGiftList = args.momentGiftList;
    final topIndexes = args.topIndexes;
    return Scaffold(
      appBar: AppBarWidget(
        title: TextWidget(
          StringManager.giftRank,
          style: context.bodyMedium.colorExt(ColorManager.white),
        ),
        // Brand gradient app bar + white bg (was the flat panel-driven
        // scaffoldBg for both) — matches every other page redesigned this
        // round.
        backgroundGradient: ColorManager.brandGradient,
        iconColor: ColorManager.white,
      ),
      backgroundColor: ColorManager.white,
      body: Column(
        children: [
          momentGiftList.isNotEmpty
              ? Expanded(
            child: ListView.builder(
              itemCount: momentGiftList.length, // Use the passed list
              itemBuilder: (context, index) {
                final gift = momentGiftList[index];
                final isTopUser = index == topIndexes;

                return Padding(
                  padding: context.paddingSymmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Rank number (you might need to implement ranking logic based on totalNumGift)
                      TextWidget(
                        '${index + 1}',
                        // Fixed light-black — was an unstyled default
                        // TextStyle with no colour of its own.
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: ColorManager.momentPostTextColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Avatar or placeholder
                      Stack(
                        children: [
                          ImageViewWidget(
                            url: gift.image,
                            boxFit: BoxFit.cover,
                            width: 45.w,
                            height: 45.h,
                            shape: BoxShape.circle,
                          ),
                          if (isTopUser)
                            const Positioned(
                              top: 0,
                              left: 0,
                              child: Icon(
                                Icons.star,
                                color: ColorManager.orange,
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Name and subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              gift.name, // Use name from MomentGiftModel
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.momentPostTextColor),
                            ),
                            TextWidget(
                              "${gift.totalNumGift} ${StringManager.giftSent}",
                              // Use totalNumGift
                              style: TextStyle(
                                  fontSize: 13,
                                  color:
                                  ColorManager.grey.withAlpha(200)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
              : Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Rank number (you might need to implement ranking logic based on totalNumGift)
                TextWidget(
                  '${1}',
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorManager.momentPostTextColor,
                  ),
                ),
                const SizedBox(width: 12),
                // Avatar or placeholder
                CircleAvatar(
                  radius: 24,
                  backgroundColor: ColorManager.grey.withAlpha(70),
                  child: Image.asset(
                    AssetsManager.seat,
                    width: 30,
                    height: 30,
                  ),
                ),
                const SizedBox(width: 12),
                // Name and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        StringManager
                            .giftList, // Use name from MomentGiftModel
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: ColorManager.momentPostTextColor),
                      ),
                      TextWidget(
                        StringManager.giveGift, // Use totalNumGift
                        style: TextStyle(
                            fontSize: 13,
                            color: ColorManager.grey.withAlpha(200)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
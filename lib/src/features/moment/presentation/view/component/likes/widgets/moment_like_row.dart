import 'package:general/src/core/index.dart';

import '../../../../../data/models/moment_like_model.dart';

class MomentLikes extends StatelessWidget {
  final ScrollController scrollController;

  final List<MomentLikeModel> data;

  const MomentLikes(
      {required this.data, required this.scrollController, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: data.length,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            /* Methods.userProfileNavigator(
              context: context,
              userId: data[index].userId.toString(),
            );
            */
          },
          child: Container(
            width: ScreenUtil().screenWidth,
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Spacer(flex: 1),
                    ImageViewWidget(
                      boxFit: BoxFit.cover,
                      url: data[index].userImage,
                      displayName: data[index].userName,
                      height: 50.w,
                      width: 50.w,
                    ),
                    const Spacer(flex: 1),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientTextVip(
                          text: (data[index].userName),
                          textStyle: Theme.of(context).textTheme.bodyLarge!,
                          isVip: false,
                          width: 180.w,
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(
                          width: 65.w,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // UserLevelContainer(
                              //   image: data[index].receiverImage ?? '',
                              //   height: ConfigSize.defaultSize! * 2,
                              //   width: ConfigSize.defaultSize! * 3,
                              // ),
                              // UserLevelContainer(
                              //   image: data[index].senderImage ?? '',
                              //   height: ConfigSize.defaultSize! * 2,
                              //   width: ConfigSize.defaultSize! * 3,
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(flex: 11),
                    Text(data[index].createdAt,
                        // Methods.instance.formatDateTime(
                        //     dateTime: data[index].createdAt ?? '',
                        //     locale: context.locale.languageCode),
                        style: context.bodyMedium
                            .colorExt(ColorManager.grey2)
                            .size(11)),
                    const Spacer(flex: 2),
                  ],
                ),
                Divider(
                  thickness: 2.w,
                  color: ColorManager.grey2.withValues(alpha: (0.3)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/level_container.dart';
import 'package:general/src/core/widgets/vip_container.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_state.dart';

class MyVipCard extends StatelessWidget {
  const MyVipCard({super.key, required this.vipLength});

  final int vipLength;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 10, vertical: 20),
      margin: context.paddingSymmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: 10.radius,
        color: ColorManager.scaffoldBg,
      ),
      child: Row(
        children: [
          UserImage(
            image: MyDataModel.getInstance().profile?.image ?? '',
            displayName: MyDataModel.getInstance().name ?? '',
            imageSize: 60,
            borderRadius: 50.radius,
          ),
          10.wBox,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ScreenUtil().screenWidth * 0.6,
                  minWidth: 1.w,
                ),
                child: GradientName(child: TextWidget(
                  MyDataModel.getInstance().name ?? '',
                  style: context.bodyMedium.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ),
              BlocBuilder<GetUserBadgesBloc, GetUserBadgesState>(
                bloc: di<GetUserBadgesBloc>(),
                buildWhen: (prev, curr) => prev.userBadge != curr.userBadge,
                builder: (context, state) {
                  final userBadgesData = state.userBadge?.top ?? [];

                  return SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.6,
                    child: Wrap(
                      spacing: 5.w,
                      runSpacing: 3.h,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (((MyDataModel.getInstance().vip1?.level ?? 0) >
                            0)) ...[
                          VipContainer(
                            vip: MyDataModel.getInstance().vip1?.img1 ?? "",
                            height: 20.h,
                            width: 38.w,
                          ),
                        ],
                        LevelContainer(
                            image:
                                MyDataModel.getInstance().level?.senderImage ??
                                    ''),
                        LevelContainer(
                            image: MyDataModel.getInstance()
                                    .level
                                    ?.receiverImage ??
                                ''),

                        // User badges from BlocBuilder
                        if (userBadgesData.isNotEmpty)
                          ...userBadgesData.map(
                            (badgeData) {
                              return badgeData.imageType == "svga"
                                  ? CacheSvgaWidget(
                                      url: EndPoints.getImage(badgeData.image),
                                      boxFit: BoxFit.fill,
                                      height: 22.5.h,
                                      width: 70.h,
                                    )
                                  : ImageViewWidget(
                                      url: EndPoints.getImage(badgeData.image),
                                      height: 22.5.h,
                                      width: 70.w,
                                      boxFit: BoxFit.fill,
                                    );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
              Text('${StringManager.youNowHave.tr()}$vipLength'),
            ],
          ),
        ],
      ),
    );
  }
}

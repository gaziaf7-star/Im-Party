import 'package:general/src/core/widgets/show_svga.dart';
import 'dart:ui' as ui;
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/cp/cp.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../../../../../core/index.dart';

class CpBlockView extends StatefulWidget {
  final UserEntity userEntity;
  final bool myProfile;
  final CpProfileBloc cpProfileBloc;

  const CpBlockView({
    required this.myProfile,
    required this.userEntity,
    required this.cpProfileBloc,
    super.key,
  });

  @override
  State<CpBlockView> createState() => _CpBlockViewState();
}

class _CpBlockViewState extends State<CpBlockView> {
  final List<String> frames = [
    AssetsManager.cpFrame2,
    AssetsManager.cpFrame3,
    AssetsManager.cpFrame1,
  ];

  final List<String> title_ = [
    StringManager.friend.tr(),
    StringManager.brother.tr(),
    StringManager.couple.tr(),
  ];

  final List<Color> colors_ = [
    const Color(0xFF239FFE),
    const Color(0xFFFF8F1B),
    const Color(0xFFE6115D),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CpProfileBloc, CpProfileStates>(
      bloc: widget.cpProfileBloc,
      listener: (context, state) {
        if (state.buyCpReqStates == RequestState.loaded) {
          Methods.showToast(
            context,
            message: state.buyCpMessage,
          );
          widget.cpProfileBloc.add(
            GetCpProfileEvents(
              userId: widget.userEntity.id.toString(),
              forceRefresh: true,
            ),
          );
        } else if (state.buyCpReqStates == RequestState.error) {
          Methods.showToast(
            context,
            isError: true,
            message: state.buyCpErrorMessage,
          );
        } else if (state.buyCpReqStates == RequestState.loading) {
          Methods.showToast(
            context,
            isLoading: true,
          );
        }
      },
      builder: (context, state) {
        return HandlingDataWidget(
          reqState: state.reqStates,
          title: state.message,
          subTitle: state.message,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.hBox,
              Padding(
                padding: context.paddingSymmetric(
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    TextWidget(
                      StringManager.cP.tr(),
                      style: context.bodyMedium
                          .size(16)
                          .colorExt(ColorManager.textPrimary),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.cpStorePage);
                      },
                      child: Row(
                        children: [
                          TextWidget(
                            StringManager.cpSpace.tr(),
                            style: context.bodyMedium
                                .size(14)
                                .colorExt(ColorManager.trailingColor),
                          ),
                          5.wBox,
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: ColorManager.trailingColor,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              5.hBox,
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Padding(
                      padding: context.paddingSymmetric(horizontal: 8),
                      child: Image.asset(
                        AssetsManager.cpBackGround,
                        fit: BoxFit.fill,
                        height: 95.h,
                        width: double.infinity,
                      ),
                    ),
                    Row(
                      children: [
                        state.data?.mainCp != null ? 30.wBox : 50.wBox,
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            state.data?.mainCp != null
                                ? ImageViewWidget(
                                    url: widget.userEntity.profile?.image ?? '',
                                    displayName: widget.userEntity.name ?? '',
                                    height: 55.h,
                                    width: 55.w,
                                    radius: 60.r,
                                    padding: EdgeInsetsDirectional.zero,
                                    margin: EdgeInsetsDirectional.zero,
                                    boxFit: BoxFit.cover,
                                  )
                                : CircleAvatar(
                                    radius: 32.r,
                                    backgroundColor: ColorManager.scaffoldBg,
                                    child: ImageViewWidget(
                                      url: widget.userEntity.profile?.image ??
                                          '',
                                      displayName:
                                          widget.userEntity.name ?? '',
                                      height: 60.w,
                                      width: 60.w,
                                      radius: 60.r,
                                      padding: EdgeInsetsDirectional.zero,
                                    ),
                                  ),
                            if (state.data?.mainCp != null)
                              ShowSVGA(
                                svgaAssetPath: AssetsManager.cpHeartAvatar,
                                height: 110.h,
                                width: 110.w,
                              ),
                          ],
                        ),
                        15.wBox,
                        Expanded(
                          child: ShowSVGA(
                            svgaAssetPath: AssetsManager.cpLoveIcon,
                            fit: BoxFit.cover,
                            height: 60.w,
                            width: 80.w,
                          ),
                        ),
                        15.wBox,
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            if (state.data?.mainCp == null) ...{
                              CircleAvatar(
                                radius: 32.r,
                                backgroundColor: ColorManager.scaffoldBg,
                                child: Image.asset(
                                  AssetsManager.emptyUserRelation,
                                  height: 60.w,
                                  width: 60.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            } else ...{
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Methods().userProfileNavigator(
                                    context: context,
                                    userId:
                                        state.data?.mainCp!.user!.id.toString(),
                                  );
                                },
                                child: ImageViewWidget(
                                  url: state.data?.mainCp?.user?.image ?? "",
                                  displayName:
                                      state.data?.mainCp?.user?.name ?? '',
                                  height: 55.h,
                                  width: 55.w,
                                  padding: EdgeInsetsDirectional.zero,
                                  radius: 60.r,
                                ),
                              ),
                              IgnorePointer(
                                child: ShowSVGA(
                                  svgaAssetPath: AssetsManager.cpHeartAvatar,
                                  height: 110.w,
                                  width: 110.w,
                                ),
                              ),
                            },
                          ],
                        ),
                        state.data?.mainCp != null ? 30.wBox : 50.wBox,
                      ],
                    ),
                  ],
                ),
              ),
              /* if (ConstantsManager.isShowCpExtension) ...[ */
              (!widget.myProfile && (state.data?.remainingCp ?? []).isEmpty)
                  ? const SizedBox()
                  : Padding(
                      padding: context.paddingSymmetric(
                        horizontal: 5,
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: context.paddingZero(),
                        itemCount: widget.myProfile
                            ? state.data?.seats != 9
                                ? (state.data?.seats ?? 0) + 1
                                : state.data?.seats!
                            : state.data?.seats!,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                          childAspectRatio: .82,
                        ),
                        itemBuilder: (context, index) {
                          if (index < (state.data?.seats ?? 0)) {
                            if (state.data!.remainingCp!.length > index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Methods().userProfileNavigator(
                                    context: context,
                                    userId: state
                                        .data!.remainingCp![index].user!.id
                                        .toString(),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        state.data?.remainingCp?[index].relation
                                                    ?.type ==
                                                "bro"
                                            ? frames[1]
                                            : state.data?.remainingCp?[index]
                                                        .relation?.type ==
                                                    "friend"
                                                ? frames[0]
                                                : frames[2],
                                      ),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ImageViewWidget(
                                        url: state.data?.remainingCp?[index]
                                                .user?.image ??
                                            "",
                                        border: Border.all(
                                          color: state.data?.remainingCp?[index]
                                                      .relation?.type ==
                                                  "bro"
                                              ? colors_[1]
                                              : state.data?.remainingCp?[index]
                                                          .relation?.type ==
                                                      "friend"
                                                  ? colors_[0]
                                                  : colors_[2],
                                          width: 2,
                                        ),
                                        height: 40.h,
                                        width: 40.w,
                                        shape: BoxShape.circle,
                                      ),
                                      5.hBox,
                                      SizedBox(
                                        width: 88.w,
                                        child: TextWidget(
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          state.data?.remainingCp?[index].user
                                                  ?.name ??
                                              "",
                                          style: context.bodySmall.w400
                                              .colorExt(ColorManager.onDark),
                                        ),
                                      ),
                                      Padding(
                                        padding: context.paddingSymmetric(
                                          vertical: 8.h,
                                          horizontal: 10.w,
                                        ),
                                        child: LinearPercentIndicator(
                                          lineHeight: 12.h,
                                          percent: double.parse(state
                                                      .data
                                                      ?.remainingCp?[index]
                                                      .ratio
                                                      .toString() ??
                                                  "0") /
                                              100,
                                          center: Text(
                                            "${state.data?.remainingCp?[index].ratio ?? 0}%",
                                            style: context.bodySmall.bold
                                                .colorExt(ColorManager.onDark)
                                                .size(10),
                                          ),
                                          barRadius: const Radius.circular(16),
                                          animation: true,
                                          animationDuration: 2000,
                                          backgroundColor: Colors.white
                                              .withValues(alpha: .5),
                                          progressColor: state
                                                      .data
                                                      ?.remainingCp?[index]
                                                      .relation
                                                      ?.type ==
                                                  "bro"
                                              ? colors_[1]
                                              : state.data?.remainingCp?[index]
                                                          .relation?.type ==
                                                      "friend"
                                                  ? colors_[0]
                                                  : colors_[2],
                                        ),
                                      ),
                                      Text(
                                          "LV.${state.data?.remainingCp?[index].level ?? "0"}",
                                          style: context.bodyMedium
                                              .colorExt(ColorManager.onDark)),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(frames[index % 3]),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextWidget(
                                      title_[index % 3],
                                      textAlign: TextAlign.center,
                                      style: context.bodySmall.w400
                                          .colorExt(ColorManager.onDark),
                                    ),
                                    5.hBox,
                                    Image.asset(
                                      AssetsManager.emptyUserRelation,
                                      height: 40,
                                      width: 40,
                                    ),
                                    5.hBox,
                                    TextWidget(
                                      StringManager.empty,
                                      textAlign: TextAlign.center,
                                      style: context.bodySmall.w400
                                          .colorExt(ColorManager.onDark),
                                    ),
                                    5.hBox,
                                  ],
                                ),
                              );
                            }
                          } else {
                            return Container(
                              margin: context.paddingSymmetric(
                                  horizontal: 7, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: 2.radius,
                                gradient: const LinearGradient(
                                  colors:
                                      ColorManager.backgroundGradientFamilyPro,
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: context.paddingSymmetric(
                                        horizontal: 25, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: ColorManager.offWhite
                                            .withValues(alpha: 0.5),
                                        shape: BoxShape.circle),
                                    child: IconButton(
                                      onPressed: () {
                                        if (state.data?.wares != null) {
                                          showDialog(
                                            context: context,
                                            builder: (_) {
                                              return AnimatedDialog(
                                                title:
                                                    "${StringManager.expandCp.tr()} ${state.data?.wares?.price ?? "0"} ${StringManager.coins.tr()}",
                                                onTap: () {
                                                  widget.cpProfileBloc.add(
                                                    BuyCpSeatsEvents(
                                                      wareId: state
                                                              .data?.wares?.id
                                                              .toString() ??
                                                          "",
                                                    ),
                                                  );
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          );
                                        } else {
                                          Methods.showToast(
                                            context,
                                            isError: true,
                                            message:
                                                "No Cp available to expand",
                                          );
                                        }
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        color: ColorManager.primary,
                                        size: 30.w,
                                      ),
                                    ),
                                  ),
                                  TextWidget(
                                    StringManager.expandable,
                                    style: context.bodyMedium
                                        .colorExt(ColorManager.textPrimary),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
              /* ], */
            ],
          ),
        );
      },
    );
  }
}

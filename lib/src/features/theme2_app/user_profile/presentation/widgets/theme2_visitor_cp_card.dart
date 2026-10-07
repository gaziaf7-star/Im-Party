import 'package:general/src/core/widgets/gradient_name.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'dart:ui' as ui;
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/cp/cp.dart';
import 'package:general/src/core/index.dart';

/// Theme2 version of CpBlockView - uses CP background + corner images
class Theme2VisitorCpCard extends StatefulWidget {
  final UserEntity userEntity;
  final bool myProfile;
  final CpProfileBloc cpProfileBloc;

  const Theme2VisitorCpCard({
    required this.myProfile,
    required this.userEntity,
    required this.cpProfileBloc,
    super.key,
  });

  @override
  State<Theme2VisitorCpCard> createState() => _Theme2VisitorCpCardState();
}

class _Theme2VisitorCpCardState extends State<Theme2VisitorCpCard> {
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
          Methods.showToast(context, message: state.buyCpMessage);
          widget.cpProfileBloc.add(
            GetCpProfileEvents(
                userId: widget.userEntity.id.toString(), forceRefresh: true),
          );
        } else if (state.buyCpReqStates == RequestState.error) {
          Methods.showToast(context,
              isError: true, message: state.buyCpErrorMessage);
        } else if (state.buyCpReqStates == RequestState.loading) {
          Methods.showToast(context, isLoading: true);
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
              // CP title row
              // Padding(
              //   padding: context.paddingSymmetric(horizontal: 1),
              //   child: Row(
              //     children: [
              //       // TextWidget(
              //       //   StringManager.cP.tr(),
              //       //   style: context.bodyMedium
              //       //       .size(16)
              //       //       .colorExt(ColorManager.theme2TextPrimary),
              //       // ),
              //       // const Spacer(),
              //       InkWell(
              //         onTap: () =>
              //             Navigator.pushNamed(context, Routes.cpStorePage),
              //         child: Row(
              //           children: [
              //             TextWidget(
              //               StringManager.cpSpace.tr(),
              //               style: context.bodyMedium
              //                   .size(14)
              //                   .colorExt(ColorManager.black),
              //             ),
              //             5.wBox,
              //             Icon(
              //               Icons.arrow_forward_ios,
              //               color: ColorManager.black,
              //               size: 14.sp,
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              5.hBox,
              // CP card with background
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Padding(
                  padding: context.paddingSymmetric(horizontal: 1),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: AlignmentDirectional.center,
                    children: [
                      // CP Background
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.asset(
                          AssetsManager.profileRelationshipCpBg,
                          fit: BoxFit.fill,
                          height: 120.h,
                          width: double.infinity,
                        ),
                      ),
                      // Corner decoration (top-right)
                      Positioned(
                        top: -15,
                        left: 5,
                        child: Image.asset(
                          AssetsManager.profileRelationshipCpCorner,
                          height: 100.h,
                          width: 100.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Corner decoration (top-left - mirrored)
                      Positioned(
                        top: -15,
                        right: 5,
                        child: Transform.flip(
                          flipX: true,
                          child: Image.asset(
                            AssetsManager.profileRelationshipCpCorner,
                            height: 100.h,
                            width: 100.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Corner decoration (bottom-right - rotated)
                      Positioned(
                        bottom: -15,
                        left: 5,
                        child: Transform.flip(
                          flipY: true,
                          child: Image.asset(
                            AssetsManager.profileRelationshipCpCorner,
                            height: 100.h,
                            width: 100.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Corner decoration (bottom-left - rotated + mirrored)
                      Positioned(
                        bottom: -15,
                        right: 5,
                        child: Transform.flip(
                          flipX: true,
                          flipY: true,
                          child: Image.asset(
                            AssetsManager.profileRelationshipCpCorner,
                            height: 100.h,
                            width: 100.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Avatars + Love icon
                      Row(
                        children: [
                          state.data?.mainCp != null ? 30.wBox : 50.wBox,
                          // User avatar
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              state.data?.mainCp != null
                                  ? ImageViewWidget(
                                url: widget.userEntity.profile?.image ??
                                    '',
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
                                backgroundColor: ColorManager.theme2BgDark,
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
                          // Love icon
                          Expanded(
                            child: ShowSVGA(
                              svgaAssetPath: AssetsManager.cpLoveIcon,
                              fit: BoxFit.cover,
                              height: 60.w,
                              width: 80.w,
                            ),
                          ),
                          15.wBox,
                          // CP partner avatar
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              if (state.data?.mainCp == null) ...{
                                CircleAvatar(
                                  radius: 32.r,
                                  backgroundColor: ColorManager.theme2BgDark,
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
                                    Methods().userProfileNavigator(
                                      context: context,
                                      userId: state.data?.mainCp!.user!.id
                                          .toString(),
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
              ),
              10.hBox,
              // Remaining CP relations grid
              (!widget.myProfile && (state.data?.remainingCp ?? []).isEmpty)
                  ? const SizedBox()
                  : Padding(
                padding: context.paddingSymmetric(horizontal: 5),
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
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: .82,
                  ),
                  itemBuilder: (context, index) {
                    if (index < (state.data?.seats ?? 0)) {
                      final cpList = state.data?.remainingCp ?? [];
                      if (index < cpList.length) {
                        final cp = cpList[index];
                        return _buildCpCard(cp, context);
                      }
                      return _buildEmptyCpSlot(context, state, index);
                    }
                    // Buy more seats button
                    return _buildBuySeatButton(context, state);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCpCard(RemainingCp cp, BuildContext context) {
    final typeIndex = cp.relation?.type == 'friend'
        ? 0
        : cp.relation?.type == 'brother'
        ? 1
        : 2;

    final bgAsset = typeIndex == 0
        ? AssetsManager.profileRelationshipFriendBg
        : typeIndex == 1
        ? AssetsManager.profileRelationshipBestieBg
        : AssetsManager.profileRelationshipCpBg;

    return InkWell(
      onTap: () {
        Methods().userProfileNavigator(
          context: context,
          userId: cp.user?.id.toString(),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: DecorationImage(
            image: AssetImage(bgAsset),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Title label at top
                const Spacer(),
                // Avatar circle
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorManager.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: ImageViewWidget(
                        url: cp.user?.image ?? '',
                        displayName: cp.user?.name ?? '',
                        height: 50.h,
                        width: 50.h,
                        boxFit: BoxFit.cover,
                        padding: EdgeInsetsDirectional.zero,
                        margin: EdgeInsetsDirectional.zero,
                      ),
                    ),
                  ),
                ),
                6.hBox,
                // Name
                GradientName(child: Text(
                  cp.user?.name ?? '',
                  style: TextStyle(
                    color: ColorManager.onDark,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )),
                // Days
                Text(
                  '${cp.di ?? 0}D',
                  style: TextStyle(
                    color: ColorManager.onDark.withValues(alpha: 0.7),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Positioned(
              top: -5.h,
              right: 20.w,
              left: 20.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: ColorManager.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.r),
                    bottomRight: Radius.circular(10.r),
                  ),
                ),
                child: Text(
                  title_[typeIndex],
                  style: TextStyle(
                    color: ColorManager.onDark,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCpSlot(
      BuildContext context, CpProfileStates state, int index) {
    if (widget.myProfile) {
      return InkWell(
        onTap: () => Navigator.pushNamed(context, Routes.cpStorePage),
        child: CustomPaint(
          // Professional "Add" slot: soft gradient card + a dashed border
          // drawn with a CustomPainter, instead of the old flat dark tile.
          painter: _DashedBorderPainter(
            color: ColorManager.white.withValues(alpha: 0.55),
            radius: 12.r,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8E6BFF), Color(0xFFC084FC)],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AssetsManager.profileRelationshipAddCpIc,
                  height: 40.h,
                  width: 40.w,
                ),
                4.hBox,
                Text(
                  StringManager.add.tr(),
                  style: TextStyle(
                    color: ColorManager.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D1C42),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Icon(
          Icons.person_outline,
          color: ColorManager.theme2TextSecondary.withValues(alpha: 0.3),
          size: 30.sp,
        ),
      ),
    );
  }

  Widget _buildBuySeatButton(BuildContext context, CpProfileStates state) {
    return InkWell(
      onTap: () {
        widget.cpProfileBloc.add(
          BuyCpSeatsEvents(
            wareId: '${state.data?.wares?.id ?? 0}',
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D1C42),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                color: const Color(0xFF8B5CF6), size: 28.sp),
            4.hBox,
            Text(
              '${StringManager.expandCp.tr()}\n${state.data?.wares?.price ?? 0}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorManager.theme2TextSecondary,
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws a soft dashed rounded-rect border over its child — used to give
/// the CP "Add" slot a more professional, intentional look on top of its
/// gradient background.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.dashWidth = 5,
    this.dashGap = 4,
    this.strokeWidth = 1.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/cp/domain/entities/cp_entity.dart';
import 'package:general/src/features/cp/presentation/cp_rank/view/components/bottom_user_cp_widget.dart';

class ListBodyCp extends StatelessWidget {
  final List<CpUserRankEntity> topUsers;
  final List<CpUserRankEntity> otherUsers;
  final MyUserCpEntity? usersRankCp;

  const ListBodyCp({
    super.key,
    this.topUsers = const [],
    this.otherUsers = const [],
    this.usersRankCp,
  });

  @override
  Widget build(BuildContext context) {
    final List<CpUserRankEntity> combinedList = [...topUsers, ...otherUsers];
    return Stack(
      children: [
        ListView.builder(
          itemCount: combinedList.length,
          shrinkWrap: true,
          padding: context.paddingOnly(bottom: 120, start: 4, top: 10),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final user = combinedList[index];

            return Padding(
              padding: context.paddingSymmetric(vertical: 10),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextWidget("${index + 1}",
                      padding: context.paddingOnly(bottom: 25, start: 10),
                      style: context.bodyMedium
                          .colorExt(ColorManager.textPrimary)
                          .w600),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          ImageViewWidget(
                            url: user.userOne?.image ??
                                AssetsManager.emptyUserRelation,
                            displayName: user.userOne?.name ?? '',
                            height: 60.h,
                            width: 60.w,
                            padding: EdgeInsetsDirectional.zero,
                            radius: 60.r,
                          ),
                          10.hBox,
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth: 100.w, maxWidth: 100.w),
                            child: GradientName(child: Text(
                              user.userOne?.name ?? 'Unknown',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: context.bodyMedium
                                  .colorExt(ColorManager.textPrimary),
                            )),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          ShowSVGA(
                            svgaAssetPath:
                                AssetsManager.cpRelationLevelHeart(level: 0),
                            fit: BoxFit.cover,
                            height: 60.h,
                            width: 80.w,
                          ),
                          5.hBox,
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  ColorManager.white.withValues(alpha: (0.1)),
                              borderRadius: 30.radius,
                            ),
                            padding: context.paddingSymmetric(
                                horizontal: 10, vertical: 0),
                            child: Row(
                              children: [
                                Image.asset(
                                  AssetsManager.heartCp,
                                  width: 13.w,
                                  height: 13.h,
                                ),
                                5.wBox,
                                TextWidget(formatNumber(user.exp ?? 0),
                                    style: context.bodyMedium
                                        .colorExt(ColorManager.textPrimary)
                                        .copyWith(height: 1.2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          ImageViewWidget(
                            url: user.userTwo?.image ??
                                AssetsManager.emptyUserRelation,
                            displayName: user.userTwo?.name ?? '',
                            height: 60.h,
                            width: 60.w,
                            padding: EdgeInsetsDirectional.zero,
                            radius: 60.r,
                          ),
                          10.hBox,
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth: 100.w, maxWidth: 100.w),
                            child: Text(
                              user.userTwo?.name ?? 'Unknown',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: context.bodyMedium
                                  .colorExt(ColorManager.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BottomUserCpWidget(
            userEntity: usersRankCp,
          ),
        ),
      ],
    );
  }

  static final RegExp _trailingDotZeroRegex = RegExp(r"\.0$");
  static final RegExp _trailingZerosRegex = RegExp(r"([.]0+|0+)$");

  String formatNumber(num value) {
    double number = value.toDouble();

    if (number >= 1e18) {
      return "${(number / 1e18).toStringAsFixed(1).replaceAll(_trailingDotZeroRegex, "")}Qn";
    } else if (number >= 1e15) {
      return "${(number / 1e15).toStringAsFixed(1).replaceAll(_trailingDotZeroRegex, "")}Q";
    } else if (number >= 1e12) {
      return "${(number / 1e12).toStringAsFixed(1).replaceAll(_trailingDotZeroRegex, "")}T";
    } else if (number >= 1e9) {
      return "${(number / 1e9).toStringAsFixed(1).replaceAll(_trailingDotZeroRegex, "")}B";
    } else if (number >= 1e6) {
      return "${(number / 1e6).toStringAsFixed(1).replaceAll(_trailingDotZeroRegex, "")}M";
    } else if (number >= 1e3) {
      return "${(number / 1e3).toStringAsFixed(1).replaceAll(_trailingDotZeroRegex, "")}K";
    } else {
      return number.toStringAsFixed(2).replaceAll(_trailingZerosRegex, "");
    }
  }
}

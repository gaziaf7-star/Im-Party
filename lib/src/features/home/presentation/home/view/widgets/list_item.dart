import 'package:general/src/core/widgets/reversible_auto_scroll_list_widget.dart';
import 'package:general/src/features/home/presentation/home/view/widgets/visitors_count.dart';

import '../../../../../../core/index.dart';
import '../../../../../../core/widgets/country_icon.dart';
import '../../../../domain/entities/room_entity.dart';
import 'lock_pk_icon.dart';

class ListItem extends StatelessWidget {
  final RoomEntity roomEntity;
  final int index;
  final bool isShowFirstLabels;
  final bool? coloring;
  final bool? isFamily;

  const ListItem({
    super.key,
    required this.roomEntity,
    required this.isShowFirstLabels,
    this.coloring = false,
    this.isFamily = false,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        Row(
          children: [
            37.wBox,
            Card(
              color: ColorManager.surfaceCardColor,
              shadowColor: ColorManager.transparent,
              elevation: 0,
              child: Container(
                width: ScreenUtil().screenWidth *
                    (isFamily == true ? 0.805 : 0.83),
                height: 100.h,
                padding: context.paddingSymmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: 8.radius,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: context.paddingOnly(end: 10),
          child: Row(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: ImageViewWidget(
                  url: roomEntity.cover ?? '',
                  boxFit: BoxFit.cover,
                  width: 88.w,
                  height: 88.h,
                  radius: 8.r,
                  // No cover → first letter of room name; isRoomCover only if nameless.
                  displayName: roomEntity.name ?? '',
                  isRoomCover: true,
                ),
              ),
              10.wBox,
              Expanded(
                child: Padding(
                  padding: context.paddingOnly(
                    top: 1,
                    bottom: 1,
                    end: 10,

                    //  vertical: 1
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        roomEntity.name ?? '',
                        style:
                            context.bodyLarge.colorExt(ColorManager.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.hBox,
                      Row(
                        children: [
                          Container(
                            padding: context.paddingSymmetric(
                                horizontal: 10, vertical: 1),
                            decoration: BoxDecoration(
                                color: ColorManager.primary
                                    .withValues(alpha: (0.4)),
                                borderRadius: 20.radius),
                            child: TextWidget(
                              'ID: ${roomEntity.id}',
                              style: context.bodySmall
                                  .colorExt(ColorManager.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          5.wBox,
                          CountryIcon(
                            country: roomEntity.country?.flag ?? '',
                            countryId:
                                (roomEntity.country?.id ?? '-1').toString(),
                          ),
                          5.wBox,
                          if (roomEntity.achievementImages?.isNotEmpty == true)
                            Expanded(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 1.0.w,
                                  maxHeight: 20.h,
                                  minHeight: 20.h,
                                ),
                                child: ReversibleAutoScrollListWidget(
                                  items: roomEntity.achievementImages ?? [],
                                ),
                              ),
                            ),
                          5.wBox,
                          if (roomEntity.achievementImages?.isNotEmpty == false)
                            const Spacer(),
                          LockAndPkIcon(
                            isPassword: roomEntity.passwordStatus ?? false,
                            isPK: roomEntity.isPK ?? false,
                            isHasLuckyBox: roomEntity.hasLuckyBox ?? false,
                          ),
                        ],
                      ),
                      8.hBox,
                      Row(
                        children: [
                          Expanded(
                            child: TextWidget(
                              roomEntity.roomIntro ?? '',
                              maxLines: 1,
                              style: context.bodyMedium
                                  .colorExt(ColorManager.textPrimary),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          10.wBox,
                          VisitorsCount(
                            count: (roomEntity.visitorsCount ?? 0).toString(),
                            fontSize: 12.sp,
                            isList: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // if (isShowFirstLabels)
        //   PositionedDirectional(
        //     end: 6.5,
        //     top: 6.5,
        //     child: index == 0
        //         ? Image.asset(
        //             AssetsManager.top1,
        //             fit: BoxFit.cover,
        //             width: 100.w,
        //           )
        //         : index == 1
        //             ? Image.asset(
        //                 AssetsManager.top2,
        //                 fit: BoxFit.fill,
        //                 width: 100.w,
        //               )
        //             : index == 2
        //                 ? Image.asset(
        //                     AssetsManager.top3,
        //                     fit: BoxFit.fill,
        //                     width: 100.w,
        //                   )
        //                 : const SizedBox.shrink(),
        //   ),
      ],
    );
  }
}

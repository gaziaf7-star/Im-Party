import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/country_icon.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/home/domain/entities/room_entity.dart';

class NewRoomCardWidget extends StatelessWidget {
  final RoomEntity roomEntity;
  final bool isShowSVGA;

  // Cache static gradients and decorations
  static final _bottomGradientColorsSVGA = [
    ColorManager.blackColor.withValues(alpha: 0.0),
    ColorManager.blackColor.withValues(alpha: 0.4),
    ColorManager.blackColor.withValues(alpha: 0.5),
    ColorManager.blackColor.withValues(alpha: 0.7),
  ];

  static final _agencyBadgeColor =
      ColorManager.blackColor.withValues(alpha: 0.4);
  static final _agencyBorderColor = ColorManager.white.withValues(alpha: 0.5);

  const NewRoomCardWidget({
    required this.roomEntity,
    required this.isShowSVGA,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Cache dimension calculations
    final borderRadiusValue = isShowSVGA ? 10.r : 5.r;
    final topPadding = isShowSVGA ? 12.h : 5.h;
    final sidePadding = isShowSVGA ? 12.w : 5.w;
    final bottomPadding = isShowSVGA ? 10.h : 5.h;

    return Container(
      decoration: ColorManager.cardDecoration(
        borderRadius: BorderRadius.circular(borderRadiusValue),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadiusValue),
            child: ImageViewWidget(
              url: roomEntity.cover ?? '',
              boxFit: BoxFit.cover,
              width: double.infinity,
              // No cover → first letter of room name; isRoomCover only if nameless.
              displayName: roomEntity.name ?? '',
              isRoomCover: true,
            ),
          ),
          // Top row with visitors and agency
          Positioned(
            top: topPadding,
            left: sidePadding,
            right: sidePadding,
            child: _TopRowContent(
              roomEntity: roomEntity,
              agencyBadgeColor: _agencyBadgeColor,
              agencyBorderColor: _agencyBorderColor,
            ),
          ),
          // Room level image
          if (roomEntity.roomLevelImage != null &&
              roomEntity.roomLevelImage!.isNotEmpty)
            Positioned(
              top: isShowSVGA ? 30.h : 20.h,
              left: sidePadding,
              right: sidePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ImageViewWidget(
                    url: roomEntity.roomLevelImage!,
                    boxFit: BoxFit.contain,
                    width: 34.w,
                    height: 18.h,
                  ),
                ],
              ),
            ),
          // Bottom gradient with room info
          Positioned(
            bottom: 0.h,
            left: 0.w,
            right: 0.w,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadiusValue),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _bottomGradientColorsSVGA,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: bottomPadding,
                  left: sidePadding,
                  right: sidePadding,
                ),
                child: _BottomRowContent(roomEntity: roomEntity),
              ),
            ),
          ),
          // SVGA overlay
          if (isShowSVGA)
            Positioned(
              top: -15.h,
              right: -10.w,
              left: -10.w,
              bottom: -15.h,
              child: SizedBox(
                height: ScreenUtil().screenWidth,
                width: ScreenUtil().screenWidth,
                child: ShowSVGA(
                  svgaAssetPath: AssetsManager.grid1,
                  fit: BoxFit.fill,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Extracted top row widget for better performance
class _TopRowContent extends StatelessWidget {
  final RoomEntity roomEntity;
  final Color agencyBadgeColor;
  final Color agencyBorderColor;

  const _TopRowContent({
    required this.roomEntity,
    required this.agencyBadgeColor,
    required this.agencyBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visitors count
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              roomEntity.visitorsCount.toString(),
              style: context.bodyMedium
                  .colorExt(ColorManager.textPrimary)
                  .size(12)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            Image.asset(
              AssetsManager.newSoundWave,
              color: ColorManager.onDark,
              height: 18.h,
              width: 18.w,
            ),
          ],
        ),
        // Agency badge
        Container(
          decoration: BoxDecoration(
            color: agencyBadgeColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: agencyBorderColor, width: 0.5.w),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 1.w, maxWidth: 80.w),
                child: TextWidget(
                  roomEntity.agency?.name ?? StringManager.noAgen.tr(),
                  style: context.bodySmall
                      .colorExt(ColorManager.textPrimary)
                      .size(11.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              3.wBox,
              Image.asset(
                AssetsManager.usersIcon24,
                color: ColorManager.onDark,
                width: 20.w,
                height: 20.h,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Extracted bottom row widget for better performance
class _BottomRowContent extends StatelessWidget {
  final RoomEntity roomEntity;

  const _BottomRowContent({required this.roomEntity});

  @override
  Widget build(BuildContext context) {
    final showCountry = roomEntity.country?.id != 0 &&
        (roomEntity.country?.name ?? '').isNotEmpty &&
        roomEntity.isCountryHidden == false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showCountry)
          CountryIcon(
            country: roomEntity.country?.flag ?? '',
            countryId: (roomEntity.country?.id ?? '-1').toString(),
            borderRadius: 3.radius,
          )
        else
          const SizedBox.shrink(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 1.w, maxWidth: 100.w),
              child: TextWidget(
                roomEntity.name ?? '',
                style: context.bodyMedium
                    .colorExt(ColorManager.textPrimary)
                    .size(12.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            3.wBox,
            ImageViewWidget(
              url: roomEntity.ownerImage ?? '',
              displayName: roomEntity.ownerName ?? '',
              boxFit: BoxFit.cover,
              width: 30.w,
              height: 30.h,
              shape: BoxShape.circle,
            ),
          ],
        ),
      ],
    );
  }
}

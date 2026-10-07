import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/close_effect_entity.dart';
import 'package:general/src/features/room/presentation/manager/clear_mode_manager/clear_mode_bloc.dart';
import 'package:general/src/features/room/presentation/manager/clear_mode_manager/clear_mode_event.dart';
import 'package:general/src/features/room/presentation/manager/clear_mode_manager/clear_mode_state.dart';

class RoomEffectDailog extends StatelessWidget {
  const RoomEffectDailog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().screenHeight * 0.45,
      width: ScreenUtil().screenWidth,
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.r),
          topRight: Radius.circular(15.r),
        ),
      ),
      child: BlocConsumer<ClearModeBloc, ClearModeState>(
        bloc: di<ClearModeBloc>(),
        listener: (context, state) {
          if (state is ClearModeSuccessState) {
            final roomEffects = MyDataModel.getInstance().roomEffects;
            if (roomEffects != null) {
              roomEffects.showBanner = state.data.showBanner;
              roomEffects.showGift = state.data.showGift;
              roomEffects.showEntring = state.data.showEntring;
            }
          }
        },
        builder: (context, state) {
          if (state is ClearModeSuccessState) {
            return roomEffectBody(context, state.data);
          }
          final roomEffects = MyDataModel.getInstance().roomEffects;
          if (roomEffects == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return roomEffectBody(context, roomEffects);
        },
      ),
    );
  }

  Widget roomEffectBody(BuildContext context, CloseEffectEntity data) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.hBox,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0.h),
            child: Row(
              children: [
                Text(
                  StringManager.blockGift.tr(),
                  style: context.bodyMedium.w400.colorExt(
                    ColorManager.black,
                  ),
                ),
                const Spacer(),
                Transform.scale(
                  scaleY: 0.9,
                  child: CupertinoSwitch(
                    // Matches the brand-gradient buttons used elsewhere in
                    // this sheet, on request -- CupertinoSwitch can't take a
                    // gradient track, so this uses the gradient's own
                    // (more saturated) end color as the closest solid match.
                    activeTrackColor: ColorManager.brandGradientColors.last,
                    inactiveTrackColor: ColorManager.black.withValues(alpha: 0.15),
                    value: data.showGift ?? false,
                    onChanged: (value) {
                      di<ClearModeBloc>()
                          .add(const ClearModeEvent(key: "show_git"));
                    },
                  ),
                ),
              ],
            ),
          ),
          5.hBox,
          Container(
            width: ScreenUtil().screenWidth,
            color: ColorManager.black.withValues(alpha: 0.04),
            padding:
                context.paddingOnly(start: 15, end: 15, top: 10, bottom: 30),
            child: Text(
              StringManager.giftEffect.tr(),
              style: context.bodySmall.size(10).colorExt(
                    ColorManager.black.withValues(
                      alpha: (0.6),
                    ),
                  ),
            ),
          ),
          5.hBox,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0.h),
            child: Row(
              children: [
                Text(
                  StringManager.entries.tr(),
                  style: context.bodyMedium.w400.colorExt(
                    ColorManager.black,
                  ),
                ),
                const Spacer(),
                Transform.scale(
                  scaleY: 0.9,
                  child: CupertinoSwitch(
                    // Matches the brand-gradient buttons used elsewhere in
                    // this sheet, on request -- CupertinoSwitch can't take a
                    // gradient track, so this uses the gradient's own
                    // (more saturated) end color as the closest solid match.
                    activeTrackColor: ColorManager.brandGradientColors.last,
                    inactiveTrackColor: ColorManager.black.withValues(alpha: 0.15),
                    value: data.showEntring ?? false,
                    onChanged: (value) {
                      di<ClearModeBloc>().add(
                        const ClearModeEvent(key: "show_intro"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          5.hBox,
          Container(
            width: ScreenUtil().screenWidth,
            color: ColorManager.black.withValues(alpha: 0.04),
            padding: context.paddingOnly(
              start: 15,
              end: 15,
              top: 10,
              bottom: 30,
            ),
            child: Text(
              StringManager.entriesEffect.tr(),
              style: context.bodySmall.size(10).colorExt(
                    ColorManager.black.withValues(alpha: (0.6)),
                  ),
            ),
          ),
          5.hBox,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0.h),
            child: Row(
              children: [
                Text(
                  StringManager.banners.tr(),
                  style: context.bodyMedium.w400.colorExt(
                    ColorManager.black,
                  ),
                ),
                const Spacer(),
                Transform.scale(
                  scaleY: 0.9,
                  child: CupertinoSwitch(
                    // Matches the brand-gradient buttons used elsewhere in
                    // this sheet, on request -- CupertinoSwitch can't take a
                    // gradient track, so this uses the gradient's own
                    // (more saturated) end color as the closest solid match.
                    activeTrackColor: ColorManager.brandGradientColors.last,
                    inactiveTrackColor: ColorManager.black.withValues(alpha: 0.15),
                    value: data.showBanner ?? false,
                    onChanged: (value) {
                      di<ClearModeBloc>().add(
                        const ClearModeEvent(key: "show_banner"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          5.hBox,
          Container(
            width: ScreenUtil().screenWidth,
            color: ColorManager.black.withValues(alpha: 0.04),
            padding: context.paddingOnly(
              start: 15,
              end: 15,
              top: 10,
              bottom: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringManager.bannersEffect.tr(),
                  style: context.bodySmall.size(10).colorExt(
                        ColorManager.black.withValues(alpha: (0.6)),
                      ),
                ),
                5.hBox,
                Text(
                  StringManager.bannersEffectAlert.tr(),
                  style: context.bodySmall
                      .size(10)
                      .colorExt(ColorManager.redIndicator),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

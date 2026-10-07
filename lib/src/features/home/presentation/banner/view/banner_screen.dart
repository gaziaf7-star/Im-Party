import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/presentation/banner/banner_bloc/banner_bloc.dart';
import 'package:general/src/features/home/presentation/banner/banner_bloc/banner_event.dart';

import '../banner_bloc/banner_state.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerBloc, BannerState>(
      bloc: di<BannerBloc>()..add(StartCountdownEvent()),
      buildWhen: (prev, curr) =>
          prev.bannerEntity != curr.bannerEntity ||
          prev.countdown != curr.countdown,
      builder: (context, state) {
        final eventType = state.bannerEntity?.eventType ?? "";

        if (eventType == "cp_event") {
          return _CpBannerWidget(state: state);
        } else {
          return _GenericBannerWidget(state: state);
        }
      },
    );
  }
}

/// -------------------- PRIVATE WIDGETS --------------------

class _SkipButton extends StatelessWidget {
  final int countdown;

  const _SkipButton({required this.countdown});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: InkWell(
        onTap: () {
          di<BannerBloc>().add(OnSkipEvent());
        },
        child: Container(
          width: ScreenUtil().screenWidth * .22,
          height: ScreenUtil().screenHeight * .04,
          margin: context.paddingSymmetric(horizontal: 10, vertical: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withValues(alpha: 0.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                countdown.toString(),
                style: context.bodyMedium
                    .colorExt(ColorManager.onDark)
                    .bold
                    .size(13)
                    .copyWith(decoration: TextDecoration.none),
              ),
              10.wBox,
              Text(
                StringManager.skip.tr(),
                style: context.bodyMedium
                    .colorExt(ColorManager.onDark)
                    .bold
                    .size(13)
                    .copyWith(decoration: TextDecoration.none),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenericBannerWidget extends StatelessWidget {
  final BannerState state;

  const _GenericBannerWidget({required this.state});

  double _getBottomPosition(String type) {
    switch (type) {
      case "weekly_star":
      case "charge_event":
        return 255.h;
      case "pk_event":
        return 180.h;
      default:
        return 200.h;
    }
  }

  double _getImageSize(String type) {
    return type == "pk_event" ? 160.w : 130.w;
  }

  @override
  Widget build(BuildContext context) {
    final banner = state.bannerEntity!;
    final bottomPosition = _getBottomPosition(banner.eventType);
    final imageSize = _getImageSize(banner.eventType);

    return Material(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          if ((banner.userEventWinner).isNotEmpty)
            Positioned(
              bottom: bottomPosition,
              child: UserImage(
                image: banner.userEventWinner,
                imageSize: imageSize,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          if ((banner.imageUrl).isNotEmpty)
            SizedBox(
              width: ScreenUtil().screenWidth,
              height: ScreenUtil().screenHeight,
              child: ImageViewWidget(
                height: ScreenUtil().screenHeight,
                width: ScreenUtil().screenWidth,
                url: EndPoints.getImage(banner.imageUrl),
              ),
            ),
          _SkipButton(countdown: state.countdown),
        ],
      ),
    );
  }
}

class _CpBannerWidget extends StatelessWidget {
  final BannerState state;

  const _CpBannerWidget({required this.state});

  @override
  Widget build(BuildContext context) {
    final banner = state.bannerEntity!;

    return Material(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          if ((banner.cpImage1 ?? '').isNotEmpty)
            Positioned(
              bottom: 340.h,
              right: 70.w,
              child: UserImage(
                image: banner.cpImage1 ?? '',
                displayName: banner.cpName1 ?? '',
                imageSize: 110.w,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          if ((banner.cpImage2 ?? '').isNotEmpty)
            Positioned(
              bottom: 340.h,
              left: 70.w,
              child: UserImage(
                image: banner.cpImage2 ?? '',
                displayName: banner.cpName2 ?? '',
                imageSize: 110.w,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          if ((banner.imageUrl).isNotEmpty)
            SizedBox(
              width: ScreenUtil().screenWidth,
              height: ScreenUtil().screenHeight,
              child: ImageViewWidget(
                height: ScreenUtil().screenHeight,
                width: ScreenUtil().screenWidth,
                url: EndPoints.getImage(banner.imageUrl),
              ),
            ),
          if ((banner.cpName1 ?? '') != '')
            Positioned(
              bottom: 305.h,
              right: 70.w,
              child: Text(
                trimTo12(banner.cpName1),
              ),
            ),
          if ((banner.cpName2 ?? '') != '')
            Positioned(
              bottom: 305.h,
              left: 70.w,
              child: Text(
                trimTo12(banner.cpName2 ?? ''),
              ),
            ),
          _SkipButton(countdown: state.countdown),
        ],
      ),
    );
  }

  String trimTo12(String? input) {
    if (input == null || input.isEmpty) return '';
    return input.length <= 12 ? input : input.substring(0, 12);
  }
}

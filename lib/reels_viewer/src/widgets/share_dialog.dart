import 'package:share_plus/share_plus.dart';
import 'package:general/reels_viewer/reels_viewer.dart';
import '../../../src/core/services/dynamic_link_handler.dart';
import '../../../src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import '../../../src/features/home/presentation/search_screen/bloc/search_manager/search_events.dart';

/// SHARE-01: a draggable dark share sheet for a reel.
///
/// Public name + [reelEntity] param are part of the route/modal contract
/// (opened via showModalBottomSheet from the reels screens) and must not change.
class ShareDialog extends StatelessWidget {
  const ShareDialog({
    super.key,
    required this.reelEntity,
  });
  final ReelsEntity reelEntity;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.32,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: ColorManager.black12,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: ColorManager.grey,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              16.hBox,
              TextWidget(
                StringManager.share.tr(),
                style: context.bodyMedium.bold
                    .size(18)
                    .colorExt(ColorManager.white),
              ),
              20.hBox,
              Wrap(
                spacing: 24.w,
                runSpacing: 20.h,
                children: [
                  _ShareAction(
                    icon: AssetsManager.shareFriends,
                    label: StringManager.friends.tr(),
                    onTap: () => _openInternalShare(context),
                  ),
                  _ShareAction(
                    iconData: Icons.link_rounded,
                    label: StringManager.copy.tr(),
                    onTap: () => _copyLink(context),
                  ),
                  _ShareAction(
                    icon: AssetsManager.shareIcon,
                    label: StringManager.more.tr(),
                    onTap: () => _systemShare(context),
                  ),
                ],
              ),
              16.hBox,
            ],
          ),
        );
      },
    );
  }

  void _openInternalShare(BuildContext context) {
    if (di<SearchBloc>().state.reqState == RequestState.loaded) {
      di<SearchBloc>().add(const SearchEvent(
          isFriend: true, page: '1', keyWord: ' ', loading: false));
    } else {
      di<SearchBloc>()
          .add(const SearchEvent(isFriend: true, page: '1', keyWord: ' '));
    }

    Navigator.pushNamed(context, Routes.shareScreenInternal,
        arguments: reelEntity);
  }

  Future<void> _copyLink(BuildContext context) async {
    try {
      final String dynamicLink = await DynamicLinkHandler.instance
          .createDynamicLink(reelEntity.id.toString(), 'reel');

      await Clipboard.setData(ClipboardData(text: dynamicLink));

      if (!context.mounted) return;
      Methods.showToast(
        context,
        message: StringManager.theTextHasBeenCopied.tr(),
      );
    } catch (error) {
      if (!context.mounted) return;
      Methods.showToast(
        context,
        message: StringManager.unableToShare.tr(),
        isError: true,
      );
    }
  }

  Future<void> _systemShare(BuildContext context) async {
    try {
      final String dynamicLink = await DynamicLinkHandler.instance
          .createDynamicLink(reelEntity.id.toString(), 'reel');

      await SharePlus.instance.share(
        ShareParams(
          uri: Uri.parse(dynamicLink),
          subject: StringManager.amazingReel.tr(),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      Methods.showToast(
        context,
        message: StringManager.unableToShare.tr(),
        isError: true,
      );
    }
  }
}

/// A single labeled icon tile in the share sheet.
///
/// Supply either an asset [icon] or a Material [iconData].
class _ShareAction extends StatelessWidget {
  const _ShareAction({
    this.icon,
    this.iconData,
    required this.label,
    required this.onTap,
  });

  final String? icon;
  final IconData? iconData;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: SizedBox(
          width: 64.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: ColorManager.primary,
                child: icon != null
                    ? ImageWidget(
                        image: icon!,
                        height: 22.h,
                        width: 22.h,
                        color: ColorManager.white,
                      )
                    : Icon(
                        iconData,
                        size: 24.sp,
                        color: ColorManager.white,
                      ),
              ),
              8.hBox,
              TextWidget(
                label,
                isTranslate: false,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: context.bodySmall.colorExt(ColorManager.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

part of 'package:general/reels_viewer/src/reels_viewer.dart';

class _ReelDescription extends StatelessWidget {
  const _ReelDescription({
    required this.reelsEntity,
    required this.height,
    required this.readMore,
  });

  final ReelsEntity reelsEntity;
  final double height;
  final bool readMore;

  @override
  Widget build(BuildContext context) {
    return reelsEntity.description != "" && reelsEntity.description != null
        ? readMore
            ? Padding(
                padding: context.paddingOnly(start: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.68,
                      child: Text(
                        reelsEntity.description ?? "",
                        style: context.bodyMedium.colorExt(ColorManager.whiteColor),
                        maxLines: readMore ? null : 1,
                        overflow: readMore ? null : TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        di<GetReelsBloc>().add(const ToggleReadMoreEvent());
                      },
                      child: Text(
                        readMore
                            ? StringManager.seeLess.tr()
                            : StringManager.more.tr(),
                        style: context.bodyMedium
                            .colorExt(ColorManager.greyText)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: context.paddingOnly(start: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.66,
                      child: Text(
                        reelsEntity.description ?? "",
                        style: context.bodyMedium.colorExt(ColorManager.whiteColor),
                        maxLines: readMore ? null : 1,
                        overflow: readMore ? null : TextOverflow.ellipsis,
                      ),
                    ),
                    5.wBox,
                    GestureDetector(
                      onTap: () {
                        di<GetReelsBloc>().add(const ToggleReadMoreEvent());
                      },
                      child: Text(
                        readMore
                            ? StringManager.seeLess.tr()
                            : StringManager.more.tr(),
                        style: context.bodyMedium
                            .colorExt(ColorManager.greyText)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
        : const SizedBox();
  }
}

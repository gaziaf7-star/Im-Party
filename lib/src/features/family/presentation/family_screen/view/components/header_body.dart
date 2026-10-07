part of '../family_screen.dart';

class _HeaderBody extends StatelessWidget {
  const _HeaderBody({
    required this.familyEntity,
    required this.exitFamilyBloc,
    required this.familyId,
    required this.showFamilyBloc,
  });

  final String familyId;
  final ShowFamilyEntity? familyEntity;
  final ShowFamilyBloc showFamilyBloc;
  final ExitFamilyBloc exitFamilyBloc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingOnly(start: 10, end: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: context.paddingSymmetric(horizontal: 10),
            child: Row(
              children: [
                ImageViewWidget(
                  url: familyEntity?.img ?? '',
                  displayName: familyEntity?.name ?? '',
                  height: 90.w,
                  width: 90.w,
                  radius: 150.r,
                ),
                10.wBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          familyEntity?.name ?? "",
                          style: context.bodyMedium.w600
                              .colorExt(ColorManager.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      7.hBox,
                      Row(
                        children: [
                          TextWidget(
                            "ID: ${familyEntity?.id ?? 0}",
                            style: context.bodyMedium
                                .colorExt(ColorManager.textPrimary
                                    .withValues(alpha: (0.7)))
                                .w400
                                .size(10),
                          ),
                          5.wBox,
                          ImageWidget(
                            height: 13.h,
                            width: 13.w,
                            image: AssetsManager.copyFamily1,
                            color: Colors.black,
                          ),
                          10.wBox,
                          LevelContainer(
                            image:
                                familyEntity?.familyLevelEntity?.levelImage ??
                                    '',
                          ),
                        ],
                      ),
                      7.hBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ImageWidget(
                            height: 13.h,
                            width: 13.w,
                            image: AssetsManager.fire2,
                          ),
                          5.wBox,
                          TextWidget(
                            "${familyEntity?.familyLevelEntity?.familyExp ?? 0}/${familyEntity?.familyLevelEntity?.nextExp ?? 0}",
                            style: context.bodySmall.w600.size(14),
                          ),
                        ],
                      ),
                      8.hBox,
                      LinearPercentIndicator(
                        padding: EdgeInsets.zero,
                        barRadius: 10.radiusCircular,
                        width: 150.w,
                        lineHeight: 6.h,
                        percent: familyEntity?.familyLevelEntity?.per ?? 0.0,
                        backgroundColor:
                            ColorManager.grey.withValues(alpha: (0.5)),
                        progressColor: ColorManager.primary,
                      ),
                      8.hBox,
                      TextWidget(
                          "${StringManager.currentLevelIs.tr()} ${familyEntity?.familyLevelEntity?.levelName ?? ""} ${StringManager.andNextLevelIs.tr()} ${familyEntity?.familyLevelEntity?.nextName ?? ""}",
                          style: context.bodyMedium.w400.size(12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

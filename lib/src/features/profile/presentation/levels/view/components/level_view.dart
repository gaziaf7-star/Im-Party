part of '../level_page.dart';

class LevelView extends StatelessWidget {
  final List<LevelBadgesEntity> data;

  const LevelView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    _createRows();
    final theme = _levelThemeFor('sender');
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LevelCard(
            type: "sender",
            isSender: true,
            color: ColorManager.coinsAccent,
            text: StringManager.wealth.tr(),
          ),
          Padding(
            padding: context.paddingAll(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  StringManager.wealthDescription.tr(),
                  style: context.bodyMedium
                      .colorExt(ColorManager.black)
                      .size(15)
                      .w600,
                ),
                10.hBox,
                TextWidget(
                  " ${StringManager.wealthDescriptionBody.tr()}",
                  style: context.bodyMedium
                      .size(15)
                      .colorExt(ColorManager.black.withValues(alpha: 0.65)),
                )
              ],
            ),
          ),
          20.hBox,
          _BadgeRewardSection(data: data, theme: theme),
          20.hBox,
          _LevelRangeTable(data: data, theme: theme),
        ],
      ),
    );
  }

  List<List<LevelBadgesEntity>> _createRows() {
    List<List<LevelBadgesEntity>> rows = [];
    List<LevelBadgesEntity> currentRow = [];
    int rowIndex = 0;

    for (var i = 0; i < data.length; i++) {
      int itemsPerRow = rowIndex % 2 == 0 ? 5 : 4;
      currentRow.add(data[i]);

      if (currentRow.length == itemsPerRow || i == data.length - 1) {
        rows.add(List.from(currentRow));
        currentRow.clear();
        rowIndex++;
      }
    }

    return rows;
  }
}

/// "Badge reward" showcase: reuses the same level-badges data already
/// fetched for the table below, laid out as a grid of small badge chips
/// (icon + unlock level) inside a light tinted panel — same content, on
/// request styled like a proper HD/professional design.
class _BadgeRewardSection extends StatelessWidget {
  const _BadgeRewardSection({required this.data, required this.theme});

  final List<LevelBadgesEntity> data;
  final _LevelTheme theme;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: context.paddingSymmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextWidget(
            StringManager.badgeReward.tr(),
            style: context.bodyLarge.bold.size(18).colorExt(ColorManager.black),
          ),
          6.hBox,
          TextWidget(
            "Higher level gets better-looking badges",
            isTranslate: false,
            textAlign: TextAlign.center,
            style: context.bodyMedium
                .size(13)
                .colorExt(ColorManager.black.withValues(alpha: 0.5)),
          ),
          16.hBox,
          Container(
            width: double.infinity,
            padding: context.paddingAll(14),
            decoration: BoxDecoration(
              color: theme.trackColor,
              borderRadius: 16.radius,
            ),
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              alignment: WrapAlignment.center,
              children: data.map((badge) {
                final level = badge.maxlevel ?? badge.minlevel ?? 0;
                return Container(
                  padding: context.paddingSymmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: 20.radius,
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.black.withValues(alpha: 0.05),
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageViewWidget(
                        url: badge.badge ?? "",
                        width: 26.w,
                        height: 20.h,
                        boxFit: BoxFit.contain,
                      ),
                      6.wBox,
                      TextWidget(
                        "$level",
                        isTranslate: false,
                        style: context.bodyMedium
                            .bold
                            .size(13)
                            .colorExt(theme.textColor),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// The level-range → badge breakdown, restyled as a clean bordered table
/// (white/light-tint rows) instead of the previous dark navy panel.
class _LevelRangeTable extends StatelessWidget {
  const _LevelRangeTable({required this.data, required this.theme});

  final List<LevelBadgesEntity> data;
  final _LevelTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: context.paddingSymmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: 16.radius,
        border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: context.paddingSymmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.trackColor,
              borderRadius: BorderRadius.only(
                topLeft: 16.radiusCircular,
                topRight: 16.radiusCircular,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  StringManager.theLevel.tr(),
                  style:
                  context.bodyMedium.w600.colorExt(theme.textColor),
                ),
                Text(
                  StringManager.icLevel.tr(),
                  style:
                  context.bodyMedium.w600.colorExt(theme.textColor),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var item = index % 2 == 0;
              return Container(
                padding:
                context.paddingSymmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: item
                      ? ColorManager.white
                      : theme.trackColor.withValues(alpha: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "${data[index].minlevel}-${data[index].maxlevel}",
                      style: context.bodyMedium.copyWith(
                        color: ColorManager.black,
                        fontSize: 16,
                      ),
                    ),
                    ImageViewWidget(
                      url: data[index].badge ?? "",
                      width: 70.w,
                      height: 25.h,
                      boxFit: BoxFit.contain,
                    ),
                  ],
                ),
              );
            },
            itemCount: data.length,
          )
        ],
      ),
    );
  }
}
part of 'package:general/src/features/profile/presentation/levels/view/level_page.dart';

class CharmView extends StatelessWidget {
  final List<LevelBadgesEntity> data;

  const CharmView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    _createRows();
    final theme = _levelThemeFor('reciever');
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LevelCard(
            type: "reciever",
            isSender: false,
            color: ColorManager.diamondsAccent,
            text: StringManager.charm.tr(),
          ),
          Padding(
            padding: context.paddingAll(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  StringManager.charmDescription.tr(),
                  style: context.bodyMedium
                      .colorExt(ColorManager.black)
                      .size(15)
                      .w600,
                ),
                10.hBox,
                TextWidget(
                  " ${StringManager.charmDescriptionBody.tr()}",
                  style: context.bodyMedium
                      .size(15)
                      .colorExt(ColorManager.black.withValues(alpha: 0.65)),
                ),
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
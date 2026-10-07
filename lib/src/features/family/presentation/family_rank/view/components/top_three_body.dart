part of '../family_rank_page.dart';

class TopThreeFamiliesBody extends StatelessWidget {
  final List<FamilyRankEntity> families;

  const TopThreeFamiliesBody({required this.families, super.key});

  @override
  Widget build(BuildContext context) {
    if (families.isEmpty) {
      return const EmptyStateWidget();
    }
    return SizedBox(
      height: 420.h,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            top: 5.h,
            child: TopUserItem(
              familyRankEntity: families.isNotEmpty ? families[0] : null,
              frameImage: AssetsManager.charmRank1Frame,
              isUpper: true,
            ),
          ),
          Positioned(
            bottom: 0.h,
            child: SizedBox(
              width: ScreenUtil().screenWidth,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: TopUserItem(
                      familyRankEntity:
                          families.length >= 2 ? families[1] : null,
                      frameImage: AssetsManager.charmRank2Frame,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: TopUserItem(
                      familyRankEntity:
                          families.length >= 3 ? families[2] : null,
                      frameImage: AssetsManager.charmRank3Frame,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

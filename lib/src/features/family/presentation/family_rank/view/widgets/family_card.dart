import '../../../../../../../reels_viewer/reels_viewer.dart';
import '../../../../family.dart';

class FamilyCard extends StatelessWidget {
  final List<FamilyRankEntity>? allFamily;

  const FamilyCard({
    super.key,
    required this.allFamily
  });

  @override
  Widget build(BuildContext context) {
    return  Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: TopThreeFamiliesBody(
                  families: List.of(allFamily?.take(3) ?? []),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: context.paddingOnly(top: 10),
                  child: RankContainerWidgetFamily(
                    familiesRank: List.of(allFamily?.skip(3) ?? []),
                  ),
                ),
              ),
            ],
          ),
        ],
    );
    }
}
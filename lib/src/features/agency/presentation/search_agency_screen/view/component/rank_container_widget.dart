

import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

import 'user_info_rank_widget.dart';

class RankContainerWidgetAgency extends StatelessWidget {
  final List<StarEntity>? usersRank;
  final bool isRankRoom;
  final bool? isCp;
  final bool? isSender;
  final bool? isWealth;
  final bool? isCharm;
  final Color? bgColor;

  const RankContainerWidgetAgency({
    required this.usersRank,
    this.isRankRoom = false,
    super.key,
    this.bgColor,
    this.isSender,
    this.isWealth,
    this.isCharm,
    this.isCp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: (usersRank??[]).isEmpty || (usersRank??[]).length<=3 ?280.h:null,
          decoration: BoxDecoration(
              color: ColorManager.white,
              border: Border.all(color: ColorManager.white),
              borderRadius: BorderRadius.only(
                topLeft: 20.radiusCircular,
                topRight: 20.radiusCircular,
              )),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            padding: context.paddingOnly(bottom: 10.h, top: isRankRoom ? 20 : 0, start: 10, end: 10),
            itemBuilder: (context, index) {
              return UserInfoRankWidgetAgency(
                index: index + 4,
                userTopEntity: usersRank?[index],
              );
            },
            itemCount: usersRank?.length ?? 0,
          ),
        ),
      ],
    );
  }
}

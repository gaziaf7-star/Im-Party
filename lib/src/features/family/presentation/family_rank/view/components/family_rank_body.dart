part of '../family_rank_page.dart';

class RankContainerWidgetFamily extends StatelessWidget {
  final List<FamilyRankEntity> familiesRank;

  const RankContainerWidgetFamily({super.key,
    required this.familiesRank,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height:
              (familiesRank).isEmpty || (familiesRank).length <= 4
                  ? 280.h
                  : null,
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
            padding: context.paddingOnly(bottom: 100.h, start: 10, end: 10),
            itemBuilder: (context, index) {
              return UserInfoRankWidget(
                index: index + 4,
                familyRankEntity: familiesRank[index],
              );
            },
            itemCount: familiesRank.length,
          ),
        ),
      ],
    );
  }
}

class UserInfoRankWidget extends StatelessWidget {
  final FamilyRankEntity? familyRankEntity;
  final void Function()? onTap;
  final int index;

  const UserInfoRankWidget({
    this.onTap,
    required this.familyRankEntity,
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: onTap ??
          () {
            if (familyRankEntity != null && familyRankEntity!.id != 0) {
              Navigator.pushNamed(
                context,
                Routes.familyScreen,
                arguments: familyRankEntity!.id.toString(),
              );
            }
          },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.only(bottom: 6.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              '$index',
              style: context.bodyMedium.w700.colorExt(ColorManager.secondaryText),
            ),
            const SizedBox(width: 10),
            UserImage(
              boxFit: BoxFit.cover,
              image: familyRankEntity?.img ?? "",
              displayName: familyRankEntity?.name ?? '',
              imageSize: 55,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextWidget(
                            familyRankEntity?.name ?? "",
                            // This card's background is white, but the style
                            // never overrode the theme's default text color
                            // (white on this build) — the name rendered but
                            // was invisible. Explicit black, on request.
                            style: context.bodyMedium.bold
                                .colorExt(Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            5.wBox,
            TextWidget(
              '${familyRankEntity?.rank ?? 0}',
              style: context.bodySmall.bold
                  .colorExt(const Color(0xffF54E77))
                  .size(13),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            5.wBox,
            ImageWidget(
                height: 20.h,
                width: 17.w,
                image: AssetsManager.rankHeartIcon),
          ],
        ),
      ),
    );
  }
}

// class FamilyRankBody extends StatelessWidget {
//   final GetFamilyRankingBloc getFamilyRankingBloc;
//   final TabController controller;
//
//   const FamilyRankBody({
//     required this.getFamilyRankingBloc,
//     required this.controller,
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: ScreenUtil().screenWidth,
//       height: ScreenUtil().screenHeight,
//       child: BlocBuilder<GetFamilyRankingBloc, GetFamilyRankingState>(
//         bloc: getFamilyRankingBloc,
//         builder: (context, state) {
//           return CustomScrollView(
// physics: const AlwaysScrollableScrollPhysics(),
//             slivers: [
//               SliverToBoxAdapter(
//
//                 child: Column(
//                   children: [
//                     25.hBox,
//                     _FamilyTabBar(
//                       controller: controller,
//                     ),
//                   ],
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: SizedBox(
//                   width: ScreenUtil().screenWidth,
//                   height: ScreenUtil().screenHeight,
//                   child: TabBarView(
//                     controller: controller,
//                     children: [
//                       _FamilyRankTabBarView(
//                         otherFamilyRankList: state.dailyOtherFamilies,
//
//                         requestState: state.dailyRequestState,
//                         rankingType: RankingType.daily,
//                         // onTap: () {
//                         //   di<GetFamilyRankingBloc>().add(
//                         //       const GetDailyFamilyRankingEvent(
//                         //           isFirstLoading: false));
//                         // },
//                       ),
//                       _FamilyRankTabBarView(
//                         otherFamilyRankList: state.weeklyOtherFamilies,
//
//                         requestState: state.weeklyRequestState,
//                         rankingType: RankingType.weekly,
//                         // onTap: () {
//                         //   di<GetFamilyRankingBloc>().add(
//                         //       const GetWeeklyFamilyRankingEvent(
//                         //           isFirstLoading: false));
//                         // },
//                       ),
//                       _FamilyRankTabBarView(
//                         otherFamilyRankList: state.monthlyOtherFamilies,
//
//                         requestState: state.monthlyRequestState,
//                         rankingType: RankingType.monthly,
//                         // onTap: () {
//                         //   di<GetFamilyRankingBloc>().add(
//                         //       const GetMonthlyFamilyRankingEvent(
//                         //           isFirstLoading: false));
//                         // },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

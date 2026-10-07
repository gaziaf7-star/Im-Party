import 'package:general/src/core/index.dart';
import 'package:general/src/features/cp/cp.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/cp_design.dart';

class MyRelationSpecialFriendsView extends StatefulWidget {
  const MyRelationSpecialFriendsView({super.key});

  @override
  State<MyRelationSpecialFriendsView> createState() =>
      _MyRelationSpecialFriendsViewState();
}

class _MyRelationSpecialFriendsViewState
    extends State<MyRelationSpecialFriendsView> {
  @override
  void initState() {
    BlocProvider.of<CpRelationsLevelsBloc>(context)
        .add(GetCpRelationsSpecialFriendLevelsEvent());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(vertical: 10),
      child: Column(
        children: [
          const SpecialFriendWidget(),
          10.hBox,
          const MyRelationSpecialFriendWidget(),
        ],
      ),
    );
  }
}

class MyRelationSpecialFriendWidget extends StatelessWidget {
  const MyRelationSpecialFriendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CpRelationsLevelsBloc, CpRelationsLevelsState>(
      buildWhen: (prev, curr) => prev.reqStateSpecialFriendsGift != curr.reqStateSpecialFriendsGift || prev.specialFriendsGift != curr.specialFriendsGift,
      builder: (context, state) {
        return HandlingDataWidget(
          reqState: state.reqStateSpecialFriendsGift,
          title: StringManager.noDataYet.tr(),
          subTitle: StringManager.pleaseTryAgine.tr(),
          child: CpLegendBox(
            label: StringManager.relationSpecialFriendPrivileges.tr(),
            backgroundGradient: const [Color(0xFF1F7A6B), Color(0xFF11423B)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (int i = 0; i < (state.specialFriendsGift?.length ?? 0); i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          i == (state.specialFriendsGift!.length - 1) ? 0 : 8.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CpLevelBadge(
                          level: state.specialFriendsGift![i].level,
                          topConnector: i != 0,
                          bottomConnector:
                              i != state.specialFriendsGift!.length - 1,
                        ),
                        10.wBox,
                        CpLevelTile(
                          title: state.specialFriendsGift![i].gifts!.first.title!,
                          rewardImageUrl:
                              state.specialFriendsGift![i].gifts?.first.images
                                          ?.isNotEmpty ==
                                      true
                                  ? state.specialFriendsGift![i].gifts!.first
                                      .images![0]
                                  : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SpecialFriendWidget extends StatelessWidget {
  const SpecialFriendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CpLegendBox(
      label: StringManager.specialFriend.tr(),
      backgroundGradient: const [Color(0xFF1F7A6B), Color(0xFF11423B)],
      child: BlocBuilder<CpProfileBloc, CpProfileStates>(
        buildWhen: (prev, curr) => prev.reqStates != curr.reqStates || prev.data != curr.data,
        builder: (context, state) {
          final List<RemainingCp>? filteredItems = state.data?.remainingCp
              ?.where((item) => item.relation?.type == "friend")
              .toList();
          return HandlingDataWidget(
            reqState: state.reqStates,
            title: StringManager.noDataYet.tr(),
            subTitle: StringManager.pleaseTryAgine.tr(),
            child: filteredItems != null && filteredItems.isNotEmpty
                ? GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return ImageViewWidget(
                        url: filteredItems[index].user?.image ?? "",
                        displayName: filteredItems[index].user?.name ?? '',
                        height: 55.h,
                        width: 55.w,
                        radius: 60.h,
                      );
                    },
                  )
                : Column(
                    children: [
                      Padding(
                        padding: context.paddingAll(16),
                        child: Text(
                          StringManager.noSpecialFriends.tr(),
                          style: context.bodyMedium.bold.colorExt(Colors.white),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.cpStorePage);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            gradient: LinearGradient(colors: CpPalette.accent),
                          ),
                          child: Padding(
                            padding: context.paddingSymmetric(
                                vertical: 8, horizontal: 18),
                            child: Text(
                              StringManager.invite.tr(),
                              style:
                                  context.bodySmall.bold.colorExt(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

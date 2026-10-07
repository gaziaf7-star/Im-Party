part of '../family_screen.dart';

class _RoomsBody extends StatelessWidget {
  const _RoomsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FamilyRoomBloc, FamilyRoomState>(
      bloc: di<FamilyRoomBloc>(),
      buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.data != curr.data,
      builder: (context, state) {
        return HandlingDataWidget(
          reqState: state.reqState,
          title: StringManager.noRooms.tr(),
          subTitle: StringManager.noRoomsMsg.tr(),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeLeft: true,
            removeBottom: true,
            removeRight: true,
            child: ListView.separated(
              padding: context.paddingZero(),
              itemCount: state.data?.length ?? 0,
              itemBuilder: (context, index) {
                return MultiTapCard(
                  onTap: () {
                    di<RoomStateManager>().navigateToRoom(
                      RoomEntryRequest(
                        context: context,
                        roomData: state.data![index],
                        isLive: state.data![index].streamType == "live",
                      ),
                    );
                  },
                  child: CardLiveWidget(
                    roomEntity: state.data![index],
                    index: index,
                    isFamily: true,
                  ),
                );
              },
              separatorBuilder: (context, index) => 10.hBox,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
        );
      },
    );
  }
}

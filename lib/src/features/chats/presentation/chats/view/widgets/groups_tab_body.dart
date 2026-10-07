import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/presentation/groups_list/bloc/groups_list_bloc.dart';
import 'package:general/src/features/groups/presentation/groups_list/view/widgets/group_list_card.dart';

/// Groups tab content for the chats screen. Embeds the realtime groups list
/// (GroupsListBloc + GroupListCard) without its own Scaffold/AppBar so it can
/// live inside the chats TabBarView. Always live now that Centrifugo is the sole
/// chat transport.
class GroupsTabBody extends StatefulWidget {
  const GroupsTabBody({super.key});

  @override
  State<GroupsTabBody> createState() => _GroupsTabBodyState();
}

class _GroupsTabBodyState extends State<GroupsTabBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (!di<GroupsListBloc>().state.reqState.isLoaded) {
      di<GroupsListBloc>().add(const FetchGroupsEvent());
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      di<GroupsListBloc>().add(const LoadMoreGroupsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsListBloc, GroupsListState>(
      bloc: di<GroupsListBloc>(),
      builder: (context, state) {
        return HandlingDataWidget(
          reqState: state.reqState,
          title: StringManager.noGroupsYet,
          subTitle: StringManager.noGroupsYetMsg,
          titleStyle: context.bodyLarge
              .colorExt(ColorManager.momentPostTextColor)
              .w600,
          subTitleStyle:
          context.bodyMedium.colorExt(ColorManager.momentPostTextColor),
          buttonBackgroundColors: ColorManager.brandGradientColors,
          buttonBorderColor: ColorManager.transparent,
          onTap: () => di<GroupsListBloc>().add(const FetchGroupsEvent()),
          child: RefreshIndicatorWidget(
            onRefresh: () async =>
                di<GroupsListBloc>().add(const RefreshGroupsEvent()),
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: context.paddingSymmetric(vertical: 8),
              itemCount: state.groups.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: ColorManager.divider,
                indent: 80.w,
              ),
              itemBuilder: (context, index) {
                if (index >= state.groups.length) {
                  return Padding(
                    padding: context.paddingAll(12),
                    child: const LoadingWidget(),
                  );
                }
                final group = state.groups[index];
                return GroupListCard(
                  group: group,
                  onTap: () => context.pushNamedRoute(
                    Routes.groupChatDetailScreen,
                    arguments: group,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
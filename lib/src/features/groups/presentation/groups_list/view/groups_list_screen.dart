import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/presentation/groups_list/bloc/groups_list_bloc.dart';
import 'package:general/src/features/groups/presentation/groups_list/view/widgets/group_list_card.dart';

class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
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
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBg,
      appBar: AppBarWidget(
        title: StringManager.groups.tr(),
        backgroundColor: ColorManager.scaffoldBg,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorManager.primary,
        onPressed: () async {
          final created =
              await context.pushNamedRoute<dynamic>(Routes.createGroupScreen);
          if (created == true) {
            di<GroupsListBloc>().add(const RefreshGroupsEvent());
          }
        },
        child:
            Icon(Icons.group_add, color: ColorManager.buttonTextColor, size: 24.h),
      ),
      body: BlocBuilder<GroupsListBloc, GroupsListState>(
        bloc: di<GroupsListBloc>(),
        builder: (context, state) {
          return HandlingDataWidget(
            reqState: state.reqState,
            title: StringManager.noGroupsYet,
            subTitle: StringManager.noGroupsYetMsg,
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
      ),
    );
  }
}

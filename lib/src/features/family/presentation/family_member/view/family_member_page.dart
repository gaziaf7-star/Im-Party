import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';
import 'package:general/src/features/family/family.dart';
import 'package:general/src/features/family/presentation/family_member/view/widgets/family_member.dart';

part 'components/family_members_body.dart';
part 'components/make_action_dialog.dart';
part 'components/percent_indicator_body.dart';

class FamilyMemberPage extends StatefulWidget {
  final MemberFamilyParam param;

  const FamilyMemberPage({required this.param, super.key});

  @override
  State<FamilyMemberPage> createState() => _FamilyMemberPageState();
}

class _FamilyMemberPageState extends State<FamilyMemberPage> {
  late final ScrollController _scrollController;

  List<MemberFamilyEntity> members = [];
  int _currentPage = 1;
  ShowFamilyModel? data;
  MyDataEntity? myData;
  int? removeUserIndex;

  @override
  void initState() {
    _scrollController = ScrollController();

    if (!di<FamilyMemberBloc>().state.reqState.isLoaded) {
      di<FamilyMemberBloc>().add(
        GetFamilyMemberEvent(familyId: '${widget.param.familyId ?? "0"}'),
      );
    }
    _scrollController.addListener(_listener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_listener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: StringManager.familyMember.tr(),
        backgroundColor: ColorManager.scaffoldBg,
      ),
      body: BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
        bloc: di<FetchUserDataBloc>(),
        buildWhen: (prev, curr) =>
            prev.reqState != curr.reqState ||
            prev.userEntity != curr.userEntity,
        builder: (context, state) {
          if (state.reqState.isLoaded) myData = state.userEntity;

          return BlocListener<FamilyRemoveUserBloc, RemoveUserStates>(
            bloc: di<FamilyRemoveUserBloc>(),
            listener: (context, state) {
              if (state.reqState.isError) {
                Methods.showToast(
                  context,
                  message: state.message,
                );
              }
            },
            child: BlocListener<ChangeUserTypeBloc, ChangeUserTypeState>(
              bloc: di<ChangeUserTypeBloc>(),
              listener: (context, state) {
                if (state.reqState.isError) {
                  Methods.showToast(
                    context,
                    isError: true,
                    message: state.message,
                  );
                } else if (state.reqState.isLoading) {
                  Methods.showToast(
                    context,
                    isLoading: true,
                  );
                } else if (state.reqState.isLoaded) {
                  Methods.showToast(
                    context,
                    message: state.message,
                  );
                  di<FamilyMemberBloc>().add(
                    GetFamilyMemberEvent(
                        familyId: '${widget.param.familyId ?? "0"}'),
                  );
                }
              },
              child: Column(
                children: [
                  20.hBox,
                  Expanded(
                    child: BlocBuilder<FamilyMemberBloc, FamilyMemberState>(
                      bloc: di<FamilyMemberBloc>(),
                      buildWhen: (prev, curr) =>
                          prev.reqState != curr.reqState ||
                          prev.data != curr.data,
                      builder: (context, state) {
                        return HandlingDataWidget(
                          reqState: state.reqState,
                          title: StringManager.noDataYet.tr(),
                          subTitle: StringManager.noUsersInFamily.tr(),
                          child: RefreshIndicatorWidget(
                            onRefresh: () async {
                              di<FamilyMemberBloc>().add(
                                GetFamilyMemberEvent(
                                  familyId: '${widget.param.familyId ?? '0'}',
                                ),
                              );
                            },
                            child: _FamilyMembersBody(
                              data: state.data?.owner,
                              admins: (state.data?.admin ?? []),
                              members: (state.data?.members ?? []),
                              removeUserIndex: (value) =>
                                  removeUserIndex = value,
                              scrollController: _scrollController,
                              familyId: widget.param.familyId ?? 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _listener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _currentPage++;
      di<FamilyMemberBloc>().add(
        GetMoreFamilyMemberEvent(
          familyId: widget.param.familyId.toString(),
          page: _currentPage.toString(),
        ),
      );
    }
  }
}

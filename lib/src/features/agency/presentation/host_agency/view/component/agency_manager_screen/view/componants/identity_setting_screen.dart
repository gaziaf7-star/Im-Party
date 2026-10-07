part of 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

class IdentitySetting extends StatefulWidget {
  const IdentitySetting({super.key});

  @override
  State<IdentitySetting> createState() => _IdentitySettingState();
}

class _IdentitySettingState extends State<IdentitySetting> {
  int currentPage = 1;
  late final ScrollController _scrollController;
  final _memberBloc = di<AgencyMemberBloc>();
  final _makeUserAdminBloc = di<MakeUserAdminBloc>();

  @override
  void initState() {
    if (!_memberBloc.state.requestState.isLoaded) {
      _memberBloc.add(const AgnecyMemberEvent(page: "1", isFirsLoading: true));
    }
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<MakeUserAdminBloc, MakeUserAdminState>(
          bloc: _makeUserAdminBloc,
          listener: (context, state) {
            if (state.requestState.isLoaded) {
              Methods.showToast(
                context,
                message: state.message ?? '',
              );
            } else if (state.requestState.isError) {
              Methods.showToast(context,
                  message: state.error ?? '', isError: true);
            }
          },
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _memberBloc.add(const AgnecyMemberEvent(page: "1"));
                  },
                  child: BlocBuilder<AgencyMemberBloc, AgencyMemberState>(
                    bloc: _memberBloc,
                    buildWhen: (prev, curr) =>
                        prev.requestState != curr.requestState ||
                        prev.data != curr.data,
                    builder: (context, state) {
                      return HandlingDataWidget(
                          reqState: state.requestState,
                          title: StringManager.noAgencyHostsNowTitle.tr(),
                          subTitle: StringManager.noAgencyHostsNowSubTitle.tr(),
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: state.data?.length ?? 0,
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    context.paddingSymmetric(horizontal: 10),
                                child: UserRowMember(
                                  agencyMemberModel: state.data?[index] ??
                                      const AgencyMemberModel(),
                                  endIcon: ButtonWidget(
                                    onPressed: () => _showRemoveDialog(
                                      context,
                                      state.data?[index].id ?? 0,
                                    ),
                                    title: Center(
                                      child: TextWidget(
                                        StringManager.addAdmin.tr(),
                                        //StringManager.addAdmin.tr(),
                                        style: context.bodyMedium
                                            .copyWith(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                            )
                                            .colorExt(ColorManager.onDark),
                                      ),
                                    ),
                                    height: 40.h,
                                    width: 90.w,
                                    isFittedBox: false,
                                    backgroundColor: ColorManager.primary,
                                    padding: context.paddingAll(5),
                                    paddingButton: context.paddingAll(5),
                                  ),
                                ),
                              );
                            },
                          ));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showRemoveDialog(BuildContext context, int id) {
    return showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        title: StringManager.confirmation.tr(),
        description: StringManager.addUserAgent.tr(),
        onTap: () {
          _makeUserAdminBloc.add(MakeUserAdminEvent(id: id, type: 'add'));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      currentPage++;
      _memberBloc.add(LoadMoreAgnecyMemberEvent(page: currentPage.toString()));
    }
  }
}

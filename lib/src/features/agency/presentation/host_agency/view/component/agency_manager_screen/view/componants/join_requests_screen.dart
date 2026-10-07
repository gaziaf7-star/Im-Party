part of 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

class JoinRequestsScreen extends StatefulWidget {
  const JoinRequestsScreen({super.key});

  @override
  State<JoinRequestsScreen> createState() => _JoinRequestsScreenState();
}

class _JoinRequestsScreenState extends State<JoinRequestsScreen> {
  @override
  void initState() {
    if (!di<AgencyRequestsBloc>().state.requestsState.isLoaded) {
      di<AgencyRequestsBloc>().add(
          const AgencyRequestsEvent(type: 'application', isFirstLoading: true));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: BlocListener<AgencyRequestsActionBloc, AgencyRequestsActionState>(
        bloc: di<AgencyRequestsActionBloc>(),
        listener: (context, state) {
          if (state.state.isLoaded) {
            di<AgencyRequestsBloc>().add(const AgencyRequestsEvent(
                type: 'application', isFirstLoading: true));
            Methods.showToast(context, message: state.message ?? '');
          } else if (state.state.isError) {
            Methods.showToast(context,
                message: state.error ?? '', isError: true);
          } else if (state.state.isLoading) {
            Methods.showToast(context, isLoading: true);
          }
        },
        child: BlocBuilder<AgencyRequestsBloc, AgencyRequestsState>(
          bloc: di<AgencyRequestsBloc>(),
          buildWhen: (prev, curr) => prev.requestsState != curr.requestsState || prev.requestsList != curr.requestsList,
          builder: (context, state) {
            return HandlingDataWidget(
              reqState: state.requestsState,
              title: StringManager.noRequestsNowTitle.tr(),
              subTitle: StringManager.noRequestsNowSubTitle.tr(),
              onTap: () => di<AgencyRequestsBloc>().add(
                const AgencyRequestsEvent(
                    type: 'application', isFirstLoading: true),
              ),
              child: RefreshIndicator(
                onRefresh: () async {
                  di<AgencyRequestsBloc>().add(const AgencyRequestsEvent(
                    type: 'application',
                  ));
                },
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        controller: di<AgencyRequestsBloc>()
                            .state
                            .applicationScrollController,
                        padding: context.paddingZero(),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) =>
                            UserRowApplication(
                                userDataModel: state.requestsList![index]),
                        itemCount: state.requestsList?.length ?? 0,
                        separatorBuilder: (BuildContext context, int index) {
                          return 10.hBox;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}

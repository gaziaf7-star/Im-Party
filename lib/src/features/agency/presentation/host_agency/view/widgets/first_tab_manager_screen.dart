part of 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

class FirstTabManagerScreen extends StatefulWidget {
  const FirstTabManagerScreen({super.key});

  @override
  State<FirstTabManagerScreen> createState() => _FirstTabManagerScreenState();
}

class _FirstTabManagerScreenState extends State<FirstTabManagerScreen> {
  @override
  void initState() {
    if (!di<AgencyHostReportBloc>().state.requestState.isLoaded) {
      di<AgencyHostReportBloc>().add(
        AgencyHostReportEvent(
            isFirsLoading: true,
            mounth: '${DateTime.now().month}',
            year: '${DateTime.now().year}'),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: BlocBuilder<AgencyHostReportBloc, AgencyHostReportState>(
        bloc: di<AgencyHostReportBloc>(),
        builder: (context, state) {
          return HandlingDataWidget(
            reqState: state.requestState,
            title: StringManager.noAgencyDataNowTitle.tr(),
            subTitle: StringManager.noAgencyDataNowSubTitle.tr(),
            onTap: () {
              di<AgencyHostReportBloc>().add(
                AgencyHostReportEvent(
                    isFirsLoading: true,
                    mounth: '${DateTime.now().month}',
                    year: '${DateTime.now().year}'),
              );
            },
            child: Column(
              children: [
                Padding(
                  padding: context.paddingSymmetric(
                    horizontal: 15,
                  ),
                  child: Row(
                    children: [
                      DateWidget(
                        isFirstNotifier: true,
                        selectedDate: (value) {
                          firstTabAgencyTimeFilter.value = value;
                          firstTabAgencyTimeFilter.notifyListeners();
                        },
                        onPressed: () {
                          di<AgencyHostReportBloc>().add(AgencyHostReportEvent(
                            mounth:
                                firstTabAgencyTimeFilter.value.split('/')[1],
                            year: firstTabAgencyTimeFilter.value.split('/')[0],
                          ));
                          Navigator.pop(context);
                        },
                        isNeedTitle: false,
                      ),
                    ],
                  ),
                ),
                10.hBox,
                MonthlyData(
                  state: state,
                ),
                DailyData(
                  isAdmin:
                      (di<InformationAgencyBloc>().state.data?.userStates ??
                              0) ==
                          1,
                  state: state,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

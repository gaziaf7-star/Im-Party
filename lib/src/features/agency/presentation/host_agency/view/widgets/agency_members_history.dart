import '../../../../../../../reels_viewer/reels_viewer.dart';
import '../../../../agency.dart';

class AgencyMembersHistoryScreen extends StatefulWidget {
  const AgencyMembersHistoryScreen({super.key});

  @override
  State<AgencyMembersHistoryScreen> createState() =>
      _AgencyMembersHistoryScreenState();
}

class _AgencyMembersHistoryScreenState
    extends State<AgencyMembersHistoryScreen> {
  @override
  void initState() {
    super.initState();
    if (!di<AgencyRequestsBloc>().state.recordsState.isLoaded) {
      di<AgencyRequestsBloc>()
          .add(const AgencyRequestsEvent(type: 'record', isFirstLoading: true));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: StringManager.record2.tr().toUpperCase(),
        backgroundColor: Colors.white,
      ),
      body: BlocBuilder<AgencyRequestsBloc, AgencyRequestsState>(
        bloc: di<AgencyRequestsBloc>(),
        buildWhen: (prev, curr) =>
            prev.recordsState != curr.recordsState ||
            prev.recordsList != curr.recordsList,
        builder: (context, state) {
          return HandlingDataWidget(
            reqState: state.recordsState,
            title: StringManager.noRecordsNowTitle.tr(),
            subTitle: StringManager.noRecordsNowSubTitle.tr(),
            onTap: () => di<AgencyRequestsBloc>().add(
              const AgencyRequestsEvent(type: 'record', isFirstLoading: true),
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                di<AgencyRequestsBloc>().add(
                  const AgencyRequestsEvent(type: 'record'),
                );
              },
              child: ListView.separated(
                controller:
                    di<AgencyRequestsBloc>().state.recordScrollController,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) =>
                    UserRowRecord(userDataModel: state.recordsList![index])
                        .agencyEntrance(index),
                separatorBuilder: (BuildContext context, int index) {
                  return 4.hBox;
                },
                itemCount: state.recordsList?.length ?? 0,
              ),
            ),
          );
        },
      ),
    );
  }
}

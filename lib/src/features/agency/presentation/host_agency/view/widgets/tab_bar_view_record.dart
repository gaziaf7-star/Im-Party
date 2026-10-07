part of 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

class TabBarViewRecord extends StatelessWidget {
  const TabBarViewRecord({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgencyRequestsBloc, AgencyRequestsState>(
      bloc: di<AgencyRequestsBloc>(),
      buildWhen: (prev, curr) => prev.recordsState != curr.recordsState || prev.recordsList != curr.recordsList,
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
              controller: di<AgencyRequestsBloc>().state.recordScrollController,
              padding: context.paddingZero(),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) =>
                  UserRowRecord(userDataModel: state.recordsList![index]),
              separatorBuilder: (BuildContext context, int index) {
                return 10.hBox;
              },
              itemCount: state.recordsList?.length ?? 0,
            ),
          ),
        );
      },
    );
  }
}

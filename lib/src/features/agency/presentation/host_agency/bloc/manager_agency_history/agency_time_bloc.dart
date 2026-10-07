
import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'agency_time_event.dart';

part 'agency_time_state.dart';

class AgencyTimeBloc extends Bloc<BaseAgencyTimeEvent, AgencyTimeState> {
  final AgencyHistoryUC agencyHistoryUC;

  AgencyTimeBloc({required this.agencyHistoryUC})
      : super(AgencyTimeState(
      agencyHistoryScrollController: ScrollController())) {
    on<AgencyHistoryEvent>(_agencyHistory);
    on<AgencyHistoryAddListenerEvent>(_agencyHistoryAddListener);
    // on<SetAgencyTimeHistoryEvent>(_setAgencyTimeHistory);
    on<AgencyHistoryRemoveListenerEvent>(_agencyHistoryRemoveListener);
    on<AgencyHistoryEditListLocallyEvent>(_agencyHistoryEditListLocally);
  }

  Future<void> _agencyHistory(
      AgencyHistoryEvent event, Emitter<AgencyTimeState> emit) async {
    if (event.isFirstLoading == true) {
      emit(state.copyWith(requestState: RequestState.loading));
    }
    final result = await agencyHistoryUC(
      AgencyHistoryParam(
          month: event.month,
          year: event.year,
          agencyId: MyDataModel.getInstance().id.toString()
      ),
    );
    result.fold(
          (failure) => emit(
        state.copyWith(
          requestState: handleErrorResponse(failure),
          error: NetworkExceptions.getErrorMessage(failure),
        ),
      ),
          (right) => emit(state.copyWith(
          month: event.month,
          year: event.year,
          requestState:
          handleLoadedResponse<List<AgencyHistoryModel>?>(right.data ?? []),
          agencyHistoryLastPage: right.paginates?.lastPage ?? -1,
          data: right.data)),
    );
  }

  void _agencyHistoryAddListener(
      AgencyHistoryAddListenerEvent event, Emitter<AgencyTimeState> emit) {
    final agencyHistoryScrollController = state.agencyHistoryScrollController
      ..addListener(() => _listener());
    emit(state.copyWith(
        agencyHistoryScrollController: agencyHistoryScrollController));
  }

  // Remove Listener for Waiting
  void _agencyHistoryRemoveListener(
      AgencyHistoryRemoveListenerEvent event, Emitter<AgencyTimeState> emit) {
    final agencyHistoryScrollController = state.agencyHistoryScrollController
      ..removeListener(() => _listener());
    emit(state.copyWith(
        agencyHistoryScrollController: agencyHistoryScrollController));
  }

  void _listener() {
    handleScrollListener(
      controller: state.agencyHistoryScrollController,
      currentPage: state.agencyHistoryCurrentPage,
      lastPage: state.agencyHistoryLastPage,
      fun: () {
        final int currentPage = state.agencyHistoryCurrentPage + 1;
        emit(state.copyWith(agencyHistoryCurrentPage: currentPage));
        add(AgencyHistoryEvent(
            year: state.year ?? '', month: state.month ?? ''));
      },
    );
  }

  void _agencyHistoryEditListLocally(
      AgencyHistoryEditListLocallyEvent event, Emitter<AgencyTimeState> emit) {
    final List<AgencyHistoryEntity> updatedList =
    List.of(state.data ?? <AgencyHistoryEntity>[]);


    if (event.type == '-') {
      AgencyHistoryEntity user = updatedList.firstWhere(
              (element) {


            return  element.id.toString() == event.userId;
          }
      );
      updatedList.remove(user);
    } else {
      updatedList.insert((state.data?.length??2-1), event.userAdded!);
    }

    emit(state.copyWith(data: updatedList));
  }
}
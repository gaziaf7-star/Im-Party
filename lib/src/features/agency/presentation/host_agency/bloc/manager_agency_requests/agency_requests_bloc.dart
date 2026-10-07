import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'agency_requests_event.dart';

part 'agency_requests_state.dart';

class AgencyRequestsBloc
    extends Bloc<BaseAgencyRequestsEvent, AgencyRequestsState> {
  final AgencyRequestsUC agencyRequestsUC;

  AgencyRequestsBloc({required this.agencyRequestsUC})
      : super(AgencyRequestsState(
          applicationScrollController: ScrollController(),
          recordScrollController: ScrollController(),
        )) {
    on<AgencyRequestsEvent>((event, emit) async {
      if (event.type == "application") {
        await _handleApplicationRequests(event, emit);
      } else if (event.type == "record") {
        await _handleRecordsRequests(event, emit);
      }
    });
    on<AgencyRequestsMakeActionHandelerLocallyEvent>(_agencyRequestsMakeAction);

    on<ApplicationAddListenerEvent>(_applicationAddListener);
    on<ApplicationRemoveListenerEvent>(_applicationRemoveListener);
    on<RecordAddListenerEvent>(_recordAddListener);
    on<RecordRemoveListenerEvent>(_recordRemoveListener);
  }

  Future<void> _handleApplicationRequests(AgencyRequestsEvent event, Emitter<AgencyRequestsState> emit) async {
    if (event.isFirstLoading == true) {
      emit(state.copyWith(requestsState: RequestState.loading));
    }
    final result = await agencyRequestsUC('application');

    result.fold(
      (left) => emit(
        state.copyWith(
          requestsState: handleErrorResponse(left),
          error: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) {
        emit(state.copyWith(
          applicationLastPage: right.paginates?.lastPage,
          requestsList: right.data ?? [],
          requestsState:
              handleLoadedResponse<List<ShowAgencyRequestModel>?>(right.data),
        ));
      },
    );
  }

  Future<void> _handleRecordsRequests(AgencyRequestsEvent event, Emitter<AgencyRequestsState> emit) async {
    if (event.isFirstLoading == true) {
      emit(state.copyWith(recordsState: RequestState.loading));
    }
    final result = await agencyRequestsUC('record');

    result.fold(
      (left) => emit(
        state.copyWith(
          recordsState: handleErrorResponse(left),
          error: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) => emit(state.copyWith(
        recordLastPage: right.paginates?.lastPage,
        recordsList: right.data ?? [],
        recordsState:
            handleLoadedResponse<List<ShowAgencyRequestModel>?>(right.data),
      )),
    );
  }

  void _agencyRequestsMakeAction(
    AgencyRequestsMakeActionHandelerLocallyEvent event,
    Emitter<AgencyRequestsState> emit,
  ) {
    // Clone the requests list for modification
    final List<ShowAgencyRequestModel> requestsListUpdated =
        List.of(state.requestsList ?? []);
    final request = requestsListUpdated.firstWhere(
      (element) => element.id.toString() == event.userId,
      orElse: () =>
          const ShowAgencyRequestModel(), // Placeholder if no match found
    );

    requestsListUpdated.remove(request);

    if (event.type == '-') {
      emit(state.copyWith(requestsList: requestsListUpdated));
    } else {
      final List<ShowAgencyRequestModel> recordsListUpdated =
          List.of(state.recordsList ?? []);
      recordsListUpdated.insert(0, request);
      di<AgencyTimeBloc>().add(
        AgencyHistoryEditListLocallyEvent(
          type: '+',
          userAdded: AgencyHistoryEntity(
            name: request.name ?? '',
            image: request.profile?.image ?? '',
            uuid: request.uuid ?? '',
            diamonds: 0,
            totalUsed: 0,
            id: request.id ?? -1,
          ),
        ),
      );
      //
      // di<InformationAgencyBloc>().add(
      //   const EditAgencyInformationLocallyEvent(type: '+'),
      // );

      emit(state.copyWith(
        requestsList: requestsListUpdated,
        recordsList: recordsListUpdated,
      ));
    }
  }

  void _applicationAddListener(
      ApplicationAddListenerEvent event, Emitter<AgencyRequestsState> emit) {
    final applicationScrollController = state.applicationScrollController
      ..addListener(() => _applicationListener());
    emit(state.copyWith(
        applicationScrollController: applicationScrollController));
  }

  // Remove Listener for Application
  void _applicationRemoveListener(
      ApplicationRemoveListenerEvent event, Emitter<AgencyRequestsState> emit) {
    final applicationScrollController = state.applicationScrollController
      ..removeListener(() => _applicationListener());
    emit(state.copyWith(
        applicationScrollController: applicationScrollController));
  }

  // Application Scroll Listener
  void _applicationListener() {
    handleScrollListener(
      controller: state.applicationScrollController,
      currentPage: state.applicationCurrentPage,
      lastPage: state.applicationLastPage,
      fun: () {
        final int currentPage = state.applicationCurrentPage + 1;
        emit(state.copyWith(applicationCurrentPage: currentPage));
        add(const AgencyRequestsEvent(type: "application"));
      },
    );
  }

  // Add Listener for Record
  void _recordAddListener(
      RecordAddListenerEvent event, Emitter<AgencyRequestsState> emit) {
    final recordScrollController = state.recordScrollController
      ..addListener(() => _recordListener());
    emit(state.copyWith(recordScrollController: recordScrollController));
  }

  // Remove Listener for Record
  void _recordRemoveListener(
      RecordRemoveListenerEvent event, Emitter<AgencyRequestsState> emit) {
    final recordScrollController = state.recordScrollController
      ..removeListener(() => _recordListener());
    emit(state.copyWith(recordScrollController: recordScrollController));
  }

  // Record Scroll Listener
  void _recordListener() {
    handleScrollListener(
      controller: state.recordScrollController,
      currentPage: state.recordCurrentPage,
      lastPage: state.recordLastPage,
      fun: () {
        final int currentPage = state.recordCurrentPage + 1;
        emit(state.copyWith(recordCurrentPage: currentPage));
        add(const AgencyRequestsEvent(type: "record"));
      },
    );
  }
}

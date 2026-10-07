part of 'agency_requests_bloc.dart';

class AgencyRequestsState extends Equatable {
  final List<ShowAgencyRequestModel>? requestsList; // Holds the data in success states
  final List<ShowAgencyRequestModel>? recordsList; // Holds the data in success states
  final String? error; // Holds the error message in error state
  final RequestState requestsState; // Indicates loading state
  final RequestState recordsState; // Indicates loading state
  final ScrollController applicationScrollController;
  final ScrollController recordScrollController;
  final int applicationCurrentPage;
  final int applicationLastPage;
  final int recordCurrentPage;
  final int recordLastPage;

  const AgencyRequestsState({
    required this.applicationScrollController,
    required this.recordScrollController,
    this.applicationCurrentPage = 1,
    this.applicationLastPage = 1,
    this.recordCurrentPage = 1,
    this.recordLastPage = 1,
    this.requestsList,
    this.recordsList,
    this.error,
    this.requestsState = RequestState.idle,
    this.recordsState = RequestState.idle,
  });

  // CopyWith method to create a new instance with modified values
  AgencyRequestsState copyWith({
    List<ShowAgencyRequestModel>? requestsList,
    List<ShowAgencyRequestModel>? recordsList,
    String? error,
    RequestState? requestsState,
    RequestState? recordsState,
    ScrollController? applicationScrollController,
    ScrollController? recordScrollController,
    int? applicationCurrentPage,
    int? applicationLastPage,
    int? recordCurrentPage,
    int? recordLastPage,
  }) {
    return AgencyRequestsState(
      requestsList: requestsList ?? this.requestsList,
      recordsList: recordsList ?? this.recordsList,
      error: error ?? this.error,
      requestsState: requestsState ?? this.requestsState,
      recordsState: recordsState ?? this.recordsState,
      applicationScrollController:
      applicationScrollController ?? this.applicationScrollController,
      recordScrollController: recordScrollController ?? this.recordScrollController,
      applicationCurrentPage: applicationCurrentPage ?? this.applicationCurrentPage,
      applicationLastPage: applicationLastPage ?? this.applicationLastPage,
      recordCurrentPage: recordCurrentPage ?? this.recordCurrentPage,
      recordLastPage: recordLastPage ?? this.recordLastPage,
    );
  }

  @override
  List<Object?> get props => [
    requestsList,
    recordsList,
    error,
    requestsState,
    recordsState,
    applicationScrollController,
    recordScrollController,
    applicationCurrentPage,
    applicationLastPage,
    recordCurrentPage,
    recordLastPage,
  ];
}

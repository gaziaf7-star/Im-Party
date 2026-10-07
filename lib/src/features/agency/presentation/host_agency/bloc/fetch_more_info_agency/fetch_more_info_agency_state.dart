part of 'package:general/src/features/agency/presentation/host_agency/bloc/fetch_more_info_agency/fetch_more_info_agency_bloc.dart';

class FetchMoreInfoAgencyState extends Equatable {
  final OverallStatsEntity? entity;
  final String? message;
  final RequestState requestState;

  final HostSAgencyDataModel? hostSAgencyDataModel;
  final String? hostsMessage;
  final RequestState hostsRequestState;

  // ✅ Pagination-related state
  final ScrollController userTargetScrollCtrl;
  final int userTargetCurrentPage;
  final int userTargetLastPage;
  final bool isPagination;

  const FetchMoreInfoAgencyState({
    this.entity,
    this.message,
    this.requestState = RequestState.idle,
    this.hostSAgencyDataModel,
    this.hostsMessage,
    this.hostsRequestState = RequestState.idle,

  required  this.userTargetScrollCtrl ,
    this.userTargetCurrentPage = 1,
    this.userTargetLastPage = 1,
    this.isPagination = false,
  });

  FetchMoreInfoAgencyState copyWith({
    OverallStatsEntity? entity,
    String? message,
    RequestState? requestState,
    HostSAgencyDataModel? hostSAgencyDataModel,
    String? hostsMessage,
    RequestState? hostsRequestState,

    ScrollController? userTargetScrollCtrl,
    int? userTargetCurrentPage,
    int? userTargetLastPage,
    bool? isPagination,
  }) {
    return FetchMoreInfoAgencyState(
      entity: entity ?? this.entity,
      message: message ?? this.message,
      requestState: requestState ?? this.requestState,
      hostSAgencyDataModel: hostSAgencyDataModel ?? this.hostSAgencyDataModel,
      hostsMessage: hostsMessage ?? this.hostsMessage,
      hostsRequestState: hostsRequestState ?? this.hostsRequestState,
      userTargetScrollCtrl: userTargetScrollCtrl ?? this.userTargetScrollCtrl,
      userTargetCurrentPage: userTargetCurrentPage ?? this.userTargetCurrentPage,
      userTargetLastPage: userTargetLastPage ?? this.userTargetLastPage,
      isPagination: isPagination ?? this.isPagination,
    );
  }

  @override
  List<Object?> get props => [
    entity,
    message,
    requestState,
    hostSAgencyDataModel,
    hostsMessage,
    hostsRequestState,
    userTargetScrollCtrl,
    userTargetCurrentPage,
    userTargetLastPage,
    isPagination,
  ];
}

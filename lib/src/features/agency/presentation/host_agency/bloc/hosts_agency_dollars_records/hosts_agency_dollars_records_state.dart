part of 'hosts_agency_dollars_records_bloc.dart';



class HostsAgencyDollarsRecordsState extends Equatable {
  final List<HostsAgencyDollarsRecordsEntity>? senderData;
  final RequestState senderState;
  final String senderError;

  final List<HostsAgencyDollarsRecordsEntity>? receiverData;
  final RequestState receiverState;
  final String receiverError;

  final ScrollController senderScrollCtrl;
  final ScrollController receiverScrollCtrl;

  final int senderCurrentPage;
  final int receiverCurrentPage;
  final int senderLastPage;
  final int receiverLastPage;

  const HostsAgencyDollarsRecordsState({
    this.senderData,
    this.senderState = RequestState.loading,
    this.senderError = "",
    this.receiverData,
    this.receiverState = RequestState.loading,
    this.receiverError = "",
    required this.senderScrollCtrl,
    required this.receiverScrollCtrl,
    this.senderCurrentPage = 1,
    this.receiverCurrentPage = 1,
    this.senderLastPage = -1,
    this.receiverLastPage = -1,
  });

  HostsAgencyDollarsRecordsState copyWith({
    List<HostsAgencyDollarsRecordsEntity>? senderData,
    RequestState? senderState,
    String? senderError,
    List<HostsAgencyDollarsRecordsEntity>? receiverData,
    RequestState? receiverState,
    String? receiverError,
    int? senderCurrentPage,
    int? receiverCurrentPage,
    int? senderLastPage,
    int? receiverLastPage,
    ScrollController? senderScrollCtrl,
    ScrollController? receiverScrollCtrl,
  }) {
    return HostsAgencyDollarsRecordsState(
      senderData: senderData ?? this.senderData,
      senderState: senderState ?? this.senderState,
      senderError: senderError ?? this.senderError,
      receiverData: receiverData ?? this.receiverData,
      receiverState: receiverState ?? this.receiverState,
      receiverError: receiverError ?? this.receiverError,
      senderScrollCtrl: senderScrollCtrl ?? this.senderScrollCtrl,
      receiverScrollCtrl: receiverScrollCtrl ?? this.receiverScrollCtrl,
      senderCurrentPage: senderCurrentPage ?? this.senderCurrentPage,
      receiverCurrentPage: receiverCurrentPage ?? this.receiverCurrentPage,
      senderLastPage: senderLastPage ?? this.senderLastPage,
      receiverLastPage: receiverLastPage ?? this.receiverLastPage,
    );
  }

  @override
  List<Object?> get props => [
    senderData,
    senderState,
    senderError,
    receiverData,
    receiverState,
    receiverError,
    senderScrollCtrl,
    receiverScrollCtrl,
    senderCurrentPage,
    receiverCurrentPage,
    senderLastPage,
    receiverLastPage,
  ];
}





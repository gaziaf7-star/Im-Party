part of 'get_charge_agency_details_bloc.dart';

class GetChargeAgencyDetailsStates extends Equatable {
  final List<DetailsChargeAgencyModel>? senderData;
  final RequestState senderState;
  final String senderError;
  final List<DetailsChargeAgencyModel>? receiverData;
  final RequestState receiverState;
  final String receiverError;
  final ScrollController senderScrollCtrl, receiverScrollCtrl;
  final int senderCurrentPage,
      receiverCurrentPage,
      senderLastPage,
      receiverLastPage;

  const GetChargeAgencyDetailsStates({
    this.senderData = const [],
    this.senderState = RequestState.loading,
    this.senderError = "",
    this.receiverData = const [],
    this.receiverState = RequestState.loading,
    this.receiverError = "",
    required this.senderScrollCtrl,
    required this.receiverScrollCtrl,
    this.senderCurrentPage = 1,
    this.receiverCurrentPage = 1,
    this.senderLastPage = -1,
    this.receiverLastPage = -1,
  });

  GetChargeAgencyDetailsStates copyWith(
      {List<DetailsChargeAgencyModel>? senderData,
      RequestState? senderState,
      String? senderError,
      List<DetailsChargeAgencyModel>? receiverData,
      RequestState? receiverState,
      String? receiverError,
      int? senderCurrentPage,
      int? receiverCurrentPage,
      int? senderLastPage,
      int? receiverLastPage,
      ScrollController? senderScrollCtrl,
      ScrollController? receiverScrollCtrl}) {
    return GetChargeAgencyDetailsStates(
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
        receiverScrollCtrl,
        senderScrollCtrl,
        senderCurrentPage,
        receiverCurrentPage,
        senderLastPage,
        receiverLastPage
      ];
}

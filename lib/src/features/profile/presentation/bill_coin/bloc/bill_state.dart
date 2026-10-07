part of 'bill_bloc.dart';

class BillState extends Equatable {
  final List<BillEntity> billRecharge;
  final RequestState billRechargeRequest;
  final String billRechargeMassage;

  final List<BillEntity> billReceived;
  final RequestState billReceivedRequest;
  final String billReceivedMassage;

  final List<BillEntity> billGiving;
  final RequestState billGivingRequest;
  final String billGivingMassage;

  final String startDate;
  final String endDate;

  final ScrollController rechargeScrollCtrl,
      givingScrollCtrl,
      receivedScrollCtrl;

  final int rechargeCurrentPage,
      givingCurrentPage,
      receivedCurrentPage,
      rechargeLastPage,
      givingLastPage,
      receivedLastPage;

  const BillState({
    this.billRecharge = const [],
    this.billRechargeRequest = RequestState.idle,
    this.billRechargeMassage = "",
    this.billReceived = const [],
    this.billReceivedRequest = RequestState.idle,
    this.billReceivedMassage = "",
    this.billGiving = const [],
    this.billGivingRequest = RequestState.idle,
    this.billGivingMassage = "",
    this.startDate = "",
    this.endDate = "",
    required this.rechargeScrollCtrl,
    required this.receivedScrollCtrl,
    required this.givingScrollCtrl,
    this.rechargeCurrentPage = 1,
    this.givingCurrentPage = 1,
    this.receivedCurrentPage = 1,
    this.rechargeLastPage = -1,
    this.givingLastPage = -1,
    this.receivedLastPage = -1,
  });

  BillState copyWith({
    List<BillEntity>? billRecharge,
    RequestState? billRechargeRequest,
    String? billRechargeMassage,
    List<BillEntity>? billReceived,
    RequestState? billReceivedRequest,
    String? billReceivedMassage,
    List<BillEntity>? billGiving,
    RequestState? billGivingRequest,
    String? billGivingMassage,
    String? startDate,
    String? endDate,
    ScrollController? rechargeScrollCtrl,
    ScrollController? givingScrollCtrl,
    ScrollController? receivedScrollCtrl,
    int? rechargeCurrentPage,
    int? givingCurrentPage,
    int? receivedCurrentPage,
    int? rechargeLastPage,
    int? givingLastPage,
    int? receivedLastPage,
  }) {
    return BillState(
      billRecharge: billRecharge ?? this.billRecharge,
      billRechargeRequest: billRechargeRequest ?? this.billRechargeRequest,
      billRechargeMassage: billRechargeMassage ?? this.billRechargeMassage,
      billReceived: billReceived ?? this.billReceived,
      billReceivedRequest: billReceivedRequest ?? this.billReceivedRequest,
      billReceivedMassage: billReceivedMassage ?? this.billReceivedMassage,
      billGiving: billGiving ?? this.billGiving,
      billGivingRequest: billGivingRequest ?? this.billGivingRequest,
      billGivingMassage: billGivingMassage ?? this.billGivingMassage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rechargeScrollCtrl: rechargeScrollCtrl ?? this.rechargeScrollCtrl,
      givingScrollCtrl: givingScrollCtrl ?? this.givingScrollCtrl,
      receivedScrollCtrl: receivedScrollCtrl ?? this.receivedScrollCtrl,
      rechargeCurrentPage: rechargeCurrentPage ?? this.rechargeCurrentPage,
      givingCurrentPage: givingCurrentPage ?? this.givingCurrentPage,
      receivedCurrentPage: receivedCurrentPage ?? this.receivedCurrentPage,
      rechargeLastPage: rechargeLastPage ?? this.rechargeLastPage,
      givingLastPage: givingLastPage ?? this.givingLastPage,
      receivedLastPage: receivedLastPage ?? this.receivedLastPage,
    );
  }

  @override
  List<Object?> get props => [
        billRecharge,
        billRechargeRequest,
        billRechargeMassage,
        billReceived,
        billReceivedRequest,
        billReceivedMassage,
        billGiving,
        billGivingRequest,
        billGivingMassage,
        startDate,
        endDate,
        rechargeScrollCtrl,
        givingScrollCtrl,
        receivedScrollCtrl,
        rechargeCurrentPage,
        givingCurrentPage,
        receivedCurrentPage,
        rechargeLastPage,
        givingLastPage,
        receivedLastPage
      ];
}

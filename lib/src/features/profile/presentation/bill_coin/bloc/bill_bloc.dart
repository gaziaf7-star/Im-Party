import 'dart:async';
import 'package:general/src/core/index.dart';

import 'package:general/src/features/profile/profile.dart';

part 'bill_event.dart';
part 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final GetBillHistoryUC getBillHistoryUC;

  BillBloc({required this.getBillHistoryUC})
      : super(BillState(
          rechargeScrollCtrl: ScrollController(),
          givingScrollCtrl: ScrollController(),
          receivedScrollCtrl: ScrollController(),
        )) {
    on<GetBillGivingEvent>(_getGiving);
    on<GetBillRechargeEvent>(_getRecharge);
    on<GetBillReceivedEvent>(_getReceived);

    on<AddListenerRechargeEvent>(_addListenerRechargeEvent);
    on<RemoveListenerRechargeEvent>(_removeListenerRechargeEvent);
    on<AddListenerBillReceivedEvent>(_addListenerBillReceivedEvent);
    on<RemoveListenerBillReceivedEvent>(_removeListenerBillReceivedEvent);
    on<AddListenerBillGivingEvent>(_addListenerBillGivingEvent);
    on<RemoveListenerBillGivingEvent>(_removeListenerBillGivingEvent);

    on<BillSelectEvent>(_selectDate);
  }

  FutureOr<void> _getGiving(
      GetBillGivingEvent event, Emitter<BillState> emit) async {
    if (event.param?.isLoading != false) {
      emit(state.copyWith(billGivingRequest: RequestState.loading));
    }
    if (event.param?.isRefresh == true) {
      emit(state.copyWith(givingCurrentPage: 1));
    }

    final result = await getBillHistoryUC(BillParam(
      type: event.param!.type,
      startDate: event.param!.startDate,
      endDate: event.param!.endDate,
      page: state.givingCurrentPage,
    ));
    result.fold(
        (l) => emit(state.copyWith(
            billGivingRequest: handleErrorResponse(l),
            billGivingMassage: NetworkExceptions.getErrorMessage(l))), (r) {
      emit(state.copyWith(
        billGivingRequest: handleLoadedResponse<List<BillModel>>(r.data),
        givingLastPage: r.paginates?.lastPage,
        billGiving: handlePaginationResponse<BillEntity>(
          result: r.data,
          currentList: state.billGiving,
          currentPage: state.givingCurrentPage,
        ),
      ));
    });
  }

  FutureOr<void> _getRecharge(
      GetBillRechargeEvent event, Emitter<BillState> emit) async {
    if (event.param?.isLoading != false) {
      emit(state.copyWith(billRechargeRequest: RequestState.loading));
    }
    if (event.param?.isRefresh == true) {
      emit(state.copyWith(rechargeCurrentPage: 1));
    }

    final result = await getBillHistoryUC(BillParam(
      type: event.param!.type,
      startDate: event.param!.startDate,
      endDate: event.param!.endDate,
      page: state.rechargeCurrentPage,
      shippingType: event.param?.shippingType
    ));
    result.fold(
        (l) => emit(state.copyWith(
            billRechargeRequest: handleErrorResponse(l),
            billRechargeMassage: NetworkExceptions.getErrorMessage(l))), (r) {
      emit(state.copyWith(
          billRecharge: handlePaginationResponse<BillEntity>(
            result: r.data,
            currentList: state.billRecharge,
            currentPage: state.rechargeCurrentPage,
          ),
          receivedLastPage: r.paginates?.lastPage,
          billRechargeRequest: handleLoadedResponse<List<BillModel>>(r.data)));
    });
  }

  FutureOr<void> _getReceived(
      GetBillReceivedEvent event, Emitter<BillState> emit) async {
    if (event.param?.isLoading != false) {
      emit(state.copyWith(billReceivedRequest: RequestState.loading));
    }
    if (event.param?.isRefresh == true) {
      emit(state.copyWith(receivedCurrentPage: 1));
    }

    final result = await getBillHistoryUC(BillParam(
      type: event.param!.type,
      startDate: event.param!.startDate,
      endDate: event.param!.endDate,
      page: state.receivedCurrentPage,
    ));
    result.fold(
        (l) => emit(state.copyWith(
            billReceivedRequest: handleErrorResponse(l),
            billReceivedMassage: NetworkExceptions.getErrorMessage(l))), (r) {
      emit(state.copyWith(
          billReceived: handlePaginationResponse<BillEntity>(
            result: r.data,
            currentList: state.billReceived,
            currentPage: state.receivedCurrentPage,
          ),
          receivedLastPage: r.paginates?.lastPage,
          billReceivedRequest: handleLoadedResponse<List<BillModel>>(r.data)));
    });
  }

  FutureOr<void> _selectDate(
      BillSelectEvent event, Emitter<BillState> emit) async {
    if (event.start != null) {
      emit(state.copyWith(startDate: event.start));
    }
    if (event.end != null) {
      emit(state.copyWith(endDate: event.end));
    }
  }

  void _addListenerRechargeEvent(
    AddListenerRechargeEvent event,
    Emitter<BillState> emit,
  ) {
    final rechargeScrollCtrl = state.rechargeScrollCtrl
      ..addListener(_listenerRecharge);
    emit(state.copyWith(rechargeScrollCtrl: rechargeScrollCtrl));
  }

  void _removeListenerRechargeEvent(
    RemoveListenerRechargeEvent event,
    Emitter<BillState> emit,
  ) {
    final rechargeScrollCtrl = state.rechargeScrollCtrl
      ..removeListener(_listenerRecharge);
    emit(state.copyWith(rechargeScrollCtrl: rechargeScrollCtrl));
  }

  void _addListenerBillGivingEvent(
    AddListenerBillGivingEvent event,
    Emitter<BillState> emit,
  ) {
    final givingScrollCtrl = state.givingScrollCtrl
      ..addListener(_listenerGiving);
    emit(state.copyWith(givingScrollCtrl: givingScrollCtrl));
  }

  void _removeListenerBillGivingEvent(
    RemoveListenerBillGivingEvent event,
    Emitter<BillState> emit,
  ) {
    final givingScrollCtrl = state.givingScrollCtrl
      ..removeListener(_listenerGiving);
    emit(state.copyWith(givingScrollCtrl: givingScrollCtrl));
  }

  void _addListenerBillReceivedEvent(
    AddListenerBillReceivedEvent event,
    Emitter<BillState> emit,
  ) {
    final receivedScrollCtrl = state.receivedScrollCtrl
      ..addListener(_listenerReceived);
    emit(state.copyWith(receivedScrollCtrl: receivedScrollCtrl));
  }

  void _removeListenerBillReceivedEvent(
    RemoveListenerBillReceivedEvent event,
    Emitter<BillState> emit,
  ) {
    final receivedScrollCtrl = state.receivedScrollCtrl
      ..removeListener(_listenerReceived);
    emit(state.copyWith(receivedScrollCtrl: receivedScrollCtrl));
  }

  void _listenerReceived() {
    handleScrollListener(
      controller: state.receivedScrollCtrl,
      currentPage: state.receivedCurrentPage,
      lastPage: state.receivedLastPage,
      fun: () {
        final int currentPage = state.receivedCurrentPage + 1;
        emit(state.copyWith(receivedCurrentPage: currentPage));
        add(const GetBillReceivedEvent(
            param: BillParam(isLoading: false, type: 'receving')));
      },
    );
  }

  void _listenerRecharge() {
    handleScrollListener(
      controller: state.rechargeScrollCtrl,
      currentPage: state.rechargeCurrentPage,
      lastPage: state.rechargeLastPage,
      fun: () {
        final int currentPage = state.rechargeCurrentPage + 1;
        emit(state.copyWith(rechargeCurrentPage: currentPage));
        add(const GetBillRechargeEvent(
            param: BillParam(isLoading: false, type: 'recharge')));
      },
    );
  }

  void _listenerGiving() {
    handleScrollListener(
      controller: state.givingScrollCtrl,
      currentPage: state.givingCurrentPage,
      lastPage: state.givingLastPage,
      fun: () {
        final int currentPage = state.givingCurrentPage + 1;
        emit(state.copyWith(givingCurrentPage: currentPage));
        add(const GetBillGivingEvent(
            param: BillParam(isLoading: false, type: 'givin')));
      },
    );
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'get_charge_agency_details_events.dart';

part 'get_charge_agency_details_states.dart';

class GetChargeAgencyDetailsBloc extends Bloc<BaseGetChargeAgencyDetailsEvent,
    GetChargeAgencyDetailsStates> {
  final GetChargeAgencyDetailsUC getAgencyDetailsInfoUseCase;

  GetChargeAgencyDetailsBloc({required this.getAgencyDetailsInfoUseCase})
      : super(GetChargeAgencyDetailsStates(
          receiverScrollCtrl: ScrollController(),
          senderScrollCtrl: ScrollController(),
        )) {
    on<GetChargeAgencyDetailsSenderEvent>(_handleSenderEvent);
    on<GetChargeAgencyDetailsReceiverEvent>(_handleReceiverEvent);
    on<ClearDataSenderEvent>(_handleClearDataSenderEvent);
    on<ClearDataReceiverEvent>(_handleClearDataReceiverEvent);

    on<SenderAddListenerEvent>(_senderAddListenerEvent);
    on<SenderRemoveListenerEvent>(_senderRemoveListenerEvent);
    on<ReceiverAddListenerEvent>(_receiverAddListenerEvent);
    on<ReceiverRemoveListenerEvent>(_receiverRemoveListenerEvent);
  }

  Future<void> _handleClearDataSenderEvent(
    ClearDataSenderEvent event,
    Emitter<GetChargeAgencyDetailsStates> emit,
  ) async {
    emit(state.copyWith(
      senderData: const [],
      senderState: RequestState.loading,
      senderError: "",
      senderCurrentPage: 1,
      senderLastPage: -1,
    ));
  }

  Future<void> _handleClearDataReceiverEvent(
    ClearDataReceiverEvent event,
    Emitter<GetChargeAgencyDetailsStates> emit,
  ) async {
    emit(state.copyWith(
      receiverData: const [],
      receiverState: RequestState.loading,
      receiverError: "",
      receiverCurrentPage: 1,
      receiverLastPage: -1,
    ));
  }

  Future<void> _handleSenderEvent(
    GetChargeAgencyDetailsSenderEvent event,
    Emitter<GetChargeAgencyDetailsStates> emit,
  ) async {
    if (event.isFirstLoading == true) {
      emit(state.copyWith(senderState: RequestState.loading));
    }
    final result = await getAgencyDetailsInfoUseCase(
      FetchChargeAgencyDetailsParam(
        type: 'sent',
        page: state.senderCurrentPage.toString(),
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          senderError: NetworkExceptions.getErrorMessage(failure),
          senderState: RequestState.error,
        ),
      ),
      (success) => emit(
        state.copyWith(
            senderData: (state.senderData ?? []) + (success.data ?? []),
            senderState: handleLoadedResponse(success.data ?? []),
            senderLastPage: success.paginates?.lastPage ?? 1,
        senderCurrentPage:success.paginates?.currentPage ?? 1,


        ),
      ),
    );
  }

  Future<void> _handleReceiverEvent(
    GetChargeAgencyDetailsReceiverEvent event,
    Emitter<GetChargeAgencyDetailsStates> emit,
  ) async {
      if (event.isFirstLoading == true) {
      emit(state.copyWith(
        receiverState: RequestState.loading,
        receiverData: [],           
        receiverCurrentPage: 1,     
      ));
    }
    final result = await getAgencyDetailsInfoUseCase(
      FetchChargeAgencyDetailsParam(
        type: 'received',
        page: state.receiverCurrentPage.toString(),
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          receiverError: NetworkExceptions.getErrorMessage(failure),
          receiverState: RequestState.error,
        ),
      ),
      (success) => emit(
        state.copyWith(
            receiverData: (state.receiverData ?? []) + (success.data ?? []),
            receiverState: handleLoadedResponse(success.data ?? []),
            receiverLastPage: success.paginates?.lastPage ?? -1,
          receiverCurrentPage:success.paginates?.currentPage ?? 1,



        ),
      ),
    );
  }

  void _senderAddListenerEvent(
    SenderAddListenerEvent event,
    Emitter<GetChargeAgencyDetailsStates> emit,
  ) {
    final senderScrollCtrl = state.senderScrollCtrl
      ..addListener(_listenerSenderDetails);
    emit(state.copyWith(senderScrollCtrl: senderScrollCtrl));
  }

  void _senderRemoveListenerEvent(
    SenderRemoveListenerEvent event,
    Emitter<GetChargeAgencyDetailsStates> emit,
  ) {
    final senderScrollCtrl = state.senderScrollCtrl
      ..removeListener(_listenerSenderDetails);
    emit(state.copyWith(senderScrollCtrl: senderScrollCtrl));
  }

  void _listenerSenderDetails() {
    handleScrollListener(
      controller: state.senderScrollCtrl,
      currentPage: state.senderCurrentPage,
      lastPage: state.senderLastPage,
      fun: () {
        final int currentPage = state.senderCurrentPage + 1;
        emit(state.copyWith(senderCurrentPage: currentPage));
        add(const GetChargeAgencyDetailsSenderEvent());
      },
    );
  }

  void _receiverAddListenerEvent(
    ReceiverAddListenerEvent event,
    Emitter<GetChargeAgencyDetailsStates> emit,
  ) {
    final receiverScrollCtrl = state.receiverScrollCtrl
      ..addListener(_listenerReceiverDetails);
    emit(state.copyWith(receiverScrollCtrl: receiverScrollCtrl));
  }

  void _receiverRemoveListenerEvent(
    ReceiverRemoveListenerEvent event,
    Emitter<GetChargeAgencyDetailsStates> emit,
  ) {
    final receiverScrollCtrl = state.receiverScrollCtrl
      ..removeListener(_listenerReceiverDetails);
    emit(state.copyWith(receiverScrollCtrl: receiverScrollCtrl));
  }

  void _listenerReceiverDetails() {
    handleScrollListener(
      controller: state.receiverScrollCtrl,
      currentPage: state.receiverCurrentPage,
      lastPage: state.receiverLastPage,
      fun: () {
        final int currentPage = state.receiverCurrentPage + 1;
        emit(state.copyWith(receiverCurrentPage: currentPage));
        add(const GetChargeAgencyDetailsReceiverEvent(
          isFirstLoading: false,
        ));
      },
    );
  }
}

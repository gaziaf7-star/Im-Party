import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/domain/entity/hosts_agency_dollars_records_entity.dart';

import '../../../../domain/use_case/hosts_agency_dollars_records_uc.dart';

part 'hosts_agency_dollars_records_event.dart';

part 'hosts_agency_dollars_records_state.dart';

class HostsAgencyDollarsRecordsBloc extends Bloc<HostsAgencyDollarsRecordsEvent,
    HostsAgencyDollarsRecordsState> {
  final HostsAgencyDollarsRecordsUC useCase;

  HostsAgencyDollarsRecordsBloc(this.useCase)
      : super(HostsAgencyDollarsRecordsState(
          senderScrollCtrl: ScrollController(),
          receiverScrollCtrl: ScrollController(),
        )) {
    on<GetSenderHostsAgencyRecordsEvent>(_handleSenderEvent);
    on<GetReceiverHostsAgencyRecordsEvent>(_handleReceiverEvent);

    on<SenderAddListenerEvent>(_senderAddListenerEvent);
    on<SenderRemoveListenerEvent>(_senderRemoveListenerEvent);
    on<ReceiverAddListenerEvent>(_receiverAddListenerEvent);
    on<ReceiverRemoveListenerEvent>(_receiverRemoveListenerEvent);
  }

  Future<void> _handleSenderEvent(
    GetSenderHostsAgencyRecordsEvent event,
    Emitter<HostsAgencyDollarsRecordsState> emit,
  ) async {
    if (event.isFirstLoading) {
      emit(state.copyWith(senderState: RequestState.loading));
    }

    final result = await useCase(FetchHostsAgencyDollarsParam(
      type: 'sent',
      page: state.senderCurrentPage.toString(),
    ));

    result.fold(
      (failure) => emit(
        state.copyWith(
          senderError: NetworkExceptions.getErrorMessage(failure),
          senderState: RequestState.error,
        ),
      ),
      (success) => emit(
        state.copyWith(
          senderData: success.data ?? [],
          senderState: handleLoadedResponse(success.data ?? []),
          senderLastPage: success.paginates?.lastPage ?? -1,
        ),
      ),
    );
  }

  Future<void> _handleReceiverEvent(
    GetReceiverHostsAgencyRecordsEvent event,
    Emitter<HostsAgencyDollarsRecordsState> emit,
  ) async {
    if (event.isFirstLoading) {
      emit(state.copyWith(receiverState: RequestState.loading));
    }

    final result = await useCase(FetchHostsAgencyDollarsParam(
      type: 'received',
      page: state.receiverCurrentPage.toString(),
    ));

    result.fold(
      (failure) => emit(
        state.copyWith(
          receiverError: NetworkExceptions.getErrorMessage(failure),
          receiverState: RequestState.error,
        ),
      ),
      (success) => emit(
        state.copyWith(
          receiverData: success.data ?? [],
          receiverState: handleLoadedResponse(success.data ?? []),
          receiverLastPage: success.paginates?.lastPage ?? -1,
        ),
      ),
    );
  }

  void _senderAddListenerEvent(
    SenderAddListenerEvent event,
    Emitter<HostsAgencyDollarsRecordsState> emit,
  ) {
    final scroll = state.senderScrollCtrl..addListener(_onSenderScroll);
    emit(state.copyWith(senderScrollCtrl: scroll));
  }

  void _senderRemoveListenerEvent(
    SenderRemoveListenerEvent event,
    Emitter<HostsAgencyDollarsRecordsState> emit,
  ) {
    final scroll = state.senderScrollCtrl..removeListener(_onSenderScroll);
    emit(state.copyWith(senderScrollCtrl: scroll));
  }

  void _onSenderScroll() {
    handleScrollListener(
      controller: state.senderScrollCtrl,
      currentPage: state.senderCurrentPage,
      lastPage: state.senderLastPage,
      fun: () {
        final current = state.senderCurrentPage + 1;
        emit(state.copyWith(senderCurrentPage: current));
        add(const GetSenderHostsAgencyRecordsEvent(isFirstLoading: false));
      },
    );
  }

  void _receiverAddListenerEvent(
    ReceiverAddListenerEvent event,
    Emitter<HostsAgencyDollarsRecordsState> emit,
  ) {
    final scroll = state.receiverScrollCtrl..addListener(_onReceiverScroll);
    emit(state.copyWith(receiverScrollCtrl: scroll));
  }

  void _receiverRemoveListenerEvent(
    ReceiverRemoveListenerEvent event,
    Emitter<HostsAgencyDollarsRecordsState> emit,
  ) {
    final scroll = state.receiverScrollCtrl..removeListener(_onReceiverScroll);
    emit(state.copyWith(receiverScrollCtrl: scroll));
  }

  void _onReceiverScroll() {
    handleScrollListener(
      controller: state.receiverScrollCtrl,
      currentPage: state.receiverCurrentPage,
      lastPage: state.receiverLastPage,
      fun: () {
        final current = state.receiverCurrentPage + 1;
        emit(state.copyWith(receiverCurrentPage: current));
        add(const GetReceiverHostsAgencyRecordsEvent(isFirstLoading: false));
      },
    );
  }
}

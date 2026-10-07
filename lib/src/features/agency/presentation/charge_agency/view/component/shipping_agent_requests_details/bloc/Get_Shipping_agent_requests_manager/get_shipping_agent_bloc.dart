import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'get_shipping_agent_event.dart';

part 'get_shipping_agent_state.dart';

class GetShippingAgentsRequestsBloc
    extends Bloc<BaseGetShippingAgentRequestsEvent, GetShippingAgentStates> {
  final GetShippingAgentRequestsUC getShippingAgentRequestsUseCase;

  GetShippingAgentsRequestsBloc({required this.getShippingAgentRequestsUseCase})
      : super(GetShippingAgentStates(
          acceptedScrollController: ScrollController(),
          completedScrollController: ScrollController(),
          rejectedScrollController: ScrollController(),
          transferredScrollController: ScrollController(),
          waitingScrollController: ScrollController(),
        )) {
    on<GetShippingAgentWaitingRequestsEvent>(getWaitingRequests);
    on<GetShippingAgentAcceptedRequestsEvent>(getAcceptedRequests);
    on<GetShippingAgentRejectedRequestsEvent>(getRejectedRequests);
    on<GetShippingAgentCompleteRequestsEvent>(getCompleteRequests);
    on<GetShippingAgentTransferredRequestsEvent>(getTransferedRequests);

    on<WaitingAddListenerEvent>(_waitingAddListenerEvent);
    on<WaitingRemoveListenerEvent>(_waitingRemoveListenerEvent);

    on<AcceptedAddListenerEvent>(_acceptedAddListenerEvent);
    on<AcceptedRemoveListenerEvent>(_acceptedRemoveListenerEvent);

    on<TransferredAddListenerEvent>(_transferredAddListenerEvent);
    on<TransferredRemoveListenerEvent>(_transferredRemoveListenerEvent);

    on<CompletedAddListenerEvent>(_completedAddListenerEvent);
    on<CompletedRemoveListenerEvent>(_completedRemoveListenerEvent);

    on<RejectedAddListenerEvent>(_rejectedAddListenerEvent);
    on<RejectedRemoveListenerEvent>(_rejectedRemoveListenerEvent);


    on<AddListenerForAllEvent>(_addListenerForAll);
    on<RemoveListenerForAllEvent>(_removeListenerForAll);

    on<AcceptRequestLocalEvent>(acceptRequestLocalEvent);
    on<RejectRequestLocalEvent>(rejectRequestLocalEvent);
    on<ConfirmRequestLocalEvent>(confirmRequestLocalEvent);

    on<HandleConfirmationBodyEvent>(handleConfirmationBodyEvent);

    on<PickConfirmationImageEvent>(_onPickImage);
    on<UnPickConfirmationImageEvent>(_unPickImage);
  }

  FutureOr<void> getWaitingRequests(
      GetShippingAgentWaitingRequestsEvent event,
      Emitter<GetShippingAgentStates> emit,
      ) async {
    if (event.isFirstLoading == true) {
      emit(state.copyWith(waitingReqState: RequestState.loading));
    }
    final result = await getShippingAgentRequestsUseCase(0);
    result.fold(
      (failure) => emit(
        state.copyWith(
          waitingReqState: handleErrorResponse(failure),
          waitingRequestsMessage: NetworkExceptions.getErrorMessage(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
            waitingRequests: success.data ?? [],
            waitingReqState: handleLoadedResponse(success.data),
            waitingLastPage: success.paginates?.lastPage ?? -1),
      ),
    );
  }

  FutureOr<void> getAcceptedRequests(
      GetShippingAgentAcceptedRequestsEvent event,
      Emitter<GetShippingAgentStates> emit,
      ) async {
    if (event.isFirstLoading == true) {
      emit(state.copyWith(acceptedReqState: RequestState.loading));
    }
    final result = await getShippingAgentRequestsUseCase(1);
    result.fold(
      (failure) => emit(
        state.copyWith(
          acceptedReqState: handleErrorResponse(failure),
          acceptedRequestsMessage: NetworkExceptions.getErrorMessage(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
            acceptedRequests: success.data ?? [],
            acceptedReqState: handleLoadedResponse(success.data),
            acceptedLastPage: success.paginates?.lastPage ?? -1),
      ),
    );
  }

  FutureOr<void> getRejectedRequests(
      GetShippingAgentRejectedRequestsEvent event,
      Emitter<GetShippingAgentStates> emit,
      ) async {
    if (event.isFirstLoading == true) {
      emit(state.copyWith(rejectedReqState: RequestState.loading));
    }
    final result = await getShippingAgentRequestsUseCase(2);
    result.fold(
      (failure) => emit(
        state.copyWith(
          rejectedReqState: handleErrorResponse(failure),
          rejectedRequestsMessage: NetworkExceptions.getErrorMessage(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
            rejectedRequests: success.data ?? [],
            rejectedReqState: handleLoadedResponse(success.data),
            rejectedLastPage: success.paginates?.lastPage ?? -1),
      ),
    );
  }

  FutureOr<void> getCompleteRequests(
      GetShippingAgentCompleteRequestsEvent event,
      Emitter<GetShippingAgentStates> emit,
      ) async {
    if (event.isFirstLoading == true) {
      emit(state.copyWith(completeReqState: RequestState.loading));
    }
    final result = await getShippingAgentRequestsUseCase(3);
    result.fold(
      (failure) => emit(
        state.copyWith(
          completeReqState: handleErrorResponse(failure),
          completeRequestsMessage: NetworkExceptions.getErrorMessage(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
            completeRequests: success.data ?? [],
            completeReqState: handleLoadedResponse(success.data),
            completedLastPage: success.paginates?.lastPage ?? -1),
      ),
    );
  }

  FutureOr<void> getTransferedRequests(
    GetShippingAgentTransferredRequestsEvent event,
    Emitter<GetShippingAgentStates> emit,
  ) async {
    if (event.isFirstLoading == true) {
      emit(state.copyWith(transferredReqState: RequestState.loading));
    }
    final result = await getShippingAgentRequestsUseCase(4);
    result.fold(
      (failure) => emit(
        state.copyWith(
          transferredReqState: handleErrorResponse(failure),
          transferredRequestsMessage:
              NetworkExceptions.getErrorMessage(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
            transferredRequests: success.data ?? [],
            transferredReqState: handleLoadedResponse(success.data),
            transferredLastPage: success.paginates?.lastPage ?? -1),
      ),
    );
  }

  // Add Listener for Waiting
  void _waitingAddListenerEvent(
      WaitingAddListenerEvent event,
      Emitter<GetShippingAgentStates> emit) {
    final waitingScrollController = state.waitingScrollController
      ..addListener(() => _listenerDetails('waiting'));
    emit(state.copyWith(waitingScrollController: waitingScrollController));
  }

  // Remove Listener for Waiting
  void _waitingRemoveListenerEvent(
      WaitingRemoveListenerEvent event, Emitter<GetShippingAgentStates> emit) {
    final waitingScrollController = state.waitingScrollController
      ..removeListener(() => _listenerDetails('waiting'));
    emit(state.copyWith(waitingScrollController: waitingScrollController));
  }



  void _addListenerForAll(
      AddListenerForAllEvent event, Emitter<GetShippingAgentStates> emit) {
    di<GetShippingAgentsRequestsBloc>().add(const WaitingAddListenerEvent());
    di<GetShippingAgentsRequestsBloc>().add(const AcceptedAddListenerEvent());
    di<GetShippingAgentsRequestsBloc>().add(const TransferredAddListenerEvent());
    di<GetShippingAgentsRequestsBloc>().add(const CompletedAddListenerEvent());
    di<GetShippingAgentsRequestsBloc>().add(const RejectedAddListenerEvent());
  }

  // Remove Listener for Waiting
  void _removeListenerForAll(
      RemoveListenerForAllEvent event, Emitter<GetShippingAgentStates> emit) {
    di<GetShippingAgentsRequestsBloc>().add(const WaitingRemoveListenerEvent());
    di<GetShippingAgentsRequestsBloc>().add(const AcceptedRemoveListenerEvent());
    di<GetShippingAgentsRequestsBloc>().add(const TransferredRemoveListenerEvent());
    di<GetShippingAgentsRequestsBloc>().add(const CompletedRemoveListenerEvent());
    di<GetShippingAgentsRequestsBloc>().add(const RejectedRemoveListenerEvent());
  }

  // Add Listener for Accepted
  void _acceptedAddListenerEvent(
      AcceptedAddListenerEvent event, Emitter<GetShippingAgentStates> emit) {
    final acceptedScrollController = state.acceptedScrollController
      ..addListener(() => _listenerDetails('accepted'));
    emit(state.copyWith(acceptedScrollController: acceptedScrollController));
  }

  // Remove Listener for Accepted
  void _acceptedRemoveListenerEvent(
      AcceptedRemoveListenerEvent event, Emitter<GetShippingAgentStates> emit) {
    final acceptedScrollController = state.acceptedScrollController
      ..removeListener(() => _listenerDetails('accepted'));
    emit(state.copyWith(acceptedScrollController: acceptedScrollController));
  }

  // Add Listener for Transferred
  void _transferredAddListenerEvent(
      TransferredAddListenerEvent event, Emitter<GetShippingAgentStates> emit) {
    final transferredScrollController = state.transferredScrollController
      ..addListener(() => _listenerDetails('transferred'));
    emit(state.copyWith(
        transferredScrollController: transferredScrollController));
  }

  // Remove Listener for Transferred
  void _transferredRemoveListenerEvent(TransferredRemoveListenerEvent event,
      Emitter<GetShippingAgentStates> emit) {
    final transferredScrollController = state.transferredScrollController
      ..removeListener(() => _listenerDetails('transferred'));
    emit(state.copyWith(
        transferredScrollController: transferredScrollController));
  }

  // Add Listener for Completed
  void _completedAddListenerEvent(
      CompletedAddListenerEvent event, Emitter<GetShippingAgentStates> emit) {
    final completedScrollController = state.completedScrollController
      ..addListener(() => _listenerDetails('completed'));
    emit(state.copyWith(completedScrollController: completedScrollController));
  }

  // Remove Listener for Completed
  void _completedRemoveListenerEvent(CompletedRemoveListenerEvent event,
      Emitter<GetShippingAgentStates> emit) {
    final completedScrollController = state.completedScrollController
      ..removeListener(() => _listenerDetails('completed'));
    emit(state.copyWith(completedScrollController: completedScrollController));
  }

  // Add Listener for Rejected
  void _rejectedAddListenerEvent(
      RejectedAddListenerEvent event, Emitter<GetShippingAgentStates> emit) {
    final rejectedScrollController = state.rejectedScrollController
      ..addListener(() => _listenerDetails('rejected'));
    emit(state.copyWith(rejectedScrollController: rejectedScrollController));
  }

  // Remove Listener for Rejected
  void _rejectedRemoveListenerEvent(
      RejectedRemoveListenerEvent event, Emitter<GetShippingAgentStates> emit) {
    final rejectedScrollController = state.rejectedScrollController
      ..removeListener(() => _listenerDetails('rejected'));
    emit(state.copyWith(rejectedScrollController: rejectedScrollController));
  }

  // Listener Method for all types
  void _listenerDetails(String type) {

    // Handle scroll logic based on the type
    switch (type) {
      case 'waiting':
        handleScrollListener(
          controller: state.waitingScrollController,
          currentPage: state.waitingCurrentPage,
          lastPage: state.waitingLastPage,
          fun: () {

            final int currentPage = state.waitingCurrentPage + 1;
            emit(state.copyWith(waitingCurrentPage: currentPage));
            add(const GetShippingAgentWaitingRequestsEvent());
          },
        );
        break;

      case 'accepted':
        handleScrollListener(
          controller: state.acceptedScrollController,
          currentPage: state.acceptedCurrentPage,
          lastPage: state.acceptedLastPage,
          fun: () {
            final int currentPage = state.acceptedCurrentPage + 1;
            emit(state.copyWith(acceptedCurrentPage: currentPage));
            add(const GetShippingAgentAcceptedRequestsEvent());
          },
        );
        break;

      case 'transferred':
        handleScrollListener(
          controller: state.transferredScrollController,
          currentPage: state.transferredCurrentPage,
          lastPage: state.transferredLastPage,
          fun: () {
            final int currentPage = state.transferredCurrentPage + 1;
            emit(state.copyWith(transferredCurrentPage: currentPage));
            add(const GetShippingAgentTransferredRequestsEvent());
          },
        );
        break;

      case 'completed':
        handleScrollListener(
          controller: state.completedScrollController,
          currentPage: state.completedCurrentPage,
          lastPage: state.completedLastPage,
          fun: () {
            final int currentPage = state.completedCurrentPage + 1;
            emit(state.copyWith(completedCurrentPage: currentPage));
            add(const GetShippingAgentCompleteRequestsEvent());
          },
        );
        break;

      case 'rejected':
        handleScrollListener(
          controller: state.rejectedScrollController,
          currentPage: state.rejectedCurrentPage,
          lastPage: state.rejectedLastPage,
          fun: () {
            final int currentPage = state.rejectedCurrentPage + 1;
            emit(state.copyWith(rejectedCurrentPage: currentPage));
            add(const GetShippingAgentRejectedRequestsEvent());
          },
        );
        break;
    }
  }

  Future<void> _onPickImage(
    PickConfirmationImageEvent event,
    Emitter<GetShippingAgentStates> emit,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? result =
          await Methods.pickImageSafely(picker, source: ImageSource.gallery);

      if (result != null) {
        if (result.path.toLowerCase().endsWith('.gif')) {
          result = null;
        } else {
          File res = File(result.path);
          emit(state.copyWith(image: res));
        }
      }
    } catch (error) {
      throw '$error';
    }
  }

  Future<void> _unPickImage(
    UnPickConfirmationImageEvent event,
    Emitter<GetShippingAgentStates> emit,
  ) async {
    emit(state.copyWith(image: null));
  }

  void acceptRequestLocalEvent(
    AcceptRequestLocalEvent event,
    Emitter<GetShippingAgentStates> emit,
  ) {
    final updatedLists = moveItemBetweenLists<ShippingAgentRequestEntity>(
      sourceList: state.waitingRequests,
      destinationList: state.acceptedRequests,
      condition: (item) => item.id == event.id,
    );

    emit(state.copyWith(
      waitingRequests: updatedLists[0],
      acceptedRequests: updatedLists[1],
    ));
  }

  void rejectRequestLocalEvent(
    RejectRequestLocalEvent event,
    Emitter<GetShippingAgentStates> emit,
  ) {
    final updatedLists = moveItemBetweenLists<ShippingAgentRequestEntity>(
      sourceList: state.waitingRequests,
      destinationList: state.rejectedRequests,
      condition: (item) => item.id == event.id,
    );

    emit(state.copyWith(
      waitingRequests: updatedLists[0],
      rejectedRequests: updatedLists[1],
    ));
  }

  void confirmRequestLocalEvent(
    ConfirmRequestLocalEvent event,
    Emitter<GetShippingAgentStates> emit,
  ) {
    final updatedLists = moveItemBetweenLists<ShippingAgentRequestEntity>(
      sourceList: state.acceptedRequests,
      destinationList: state.transferredRequests,
      condition: (item) => item.id == event.id,
    );

    emit(state.copyWith(
      acceptedRequests: updatedLists[0],
      transferredRequests: updatedLists[1],
    ));
  }

  void handleConfirmationBodyEvent(
    HandleConfirmationBodyEvent event,
    Emitter<GetShippingAgentStates> emit,
  ) {
    emit(state.copyWith(
        requestId: event.id == state.requestId ? -1 : event.id ?? -1));
  }

  List<List<T>> moveItemBetweenLists<T>({
    required List<T> sourceList,
    required List<T> destinationList,
    required bool Function(T) condition,
  }) {
    final source = List.of(sourceList);
    final destination = List.of(destinationList);

    final item = source.firstWhere(
      condition,
    );

    if (item != null) {
      source.remove(item);
      destination.insert(0, item);
    }

    return [source, destination];
  }
}

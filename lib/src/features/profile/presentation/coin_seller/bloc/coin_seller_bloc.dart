import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/coin_seller_model.dart';
import 'package:general/src/features/profile/profile.dart';

import '../../../domain/profile_use_case/coin_seller_use_cases.dart';

part 'coin_seller_event.dart';
part 'coin_seller_state.dart';

class CoinSellerBloc extends Bloc<CoinSellerEvent, CoinSellerState> {
  final GetCoinSellerProfileUC getCoinSellerProfileUC;
  final TransferCoinSellerUC transferCoinSellerUC;
  final GetCoinSellerHistoryUC getCoinSellerHistoryUC;

  CoinSellerBloc({
    required this.getCoinSellerProfileUC,
    required this.transferCoinSellerUC,
    required this.getCoinSellerHistoryUC,
  }) : super(const CoinSellerState()) {
    on<GetCoinSellerProfileEvent>(_getProfile);
    on<TransferCoinSellerEvent>(_transfer);
    on<GetCoinSellerHistoryEvent>(_getHistory);
    on<LoadMoreCoinSellerHistoryEvent>(_loadMoreHistory);
    on<FilterCoinSellerHistoryEvent>(_filterHistory);
  }

  Future<void> _getProfile(
      GetCoinSellerProfileEvent event,
      Emitter<CoinSellerState> emit,
      ) async {
    if (event.isLoading) {
      emit(state.copyWith(reqStateProfile: RequestState.loading));
    }
    final result = await getCoinSellerProfileUC();
    result.fold(
          (error) => emit(state.copyWith(
        reqStateProfile: handleErrorResponse(error),
        messageProfile: NetworkExceptions.getErrorMessage(error),
      )),
          (success) => emit(state.copyWith(
        profile: success.data,
        reqStateProfile: RequestState.loaded,
      )),
    );
  }

  Future<void> _transfer(
      TransferCoinSellerEvent event,
      Emitter<CoinSellerState> emit,
      ) async {
    emit(state.copyWith(reqStateTransfer: RequestState.loading));
    final result = await transferCoinSellerUC(
      TransferCoinSellerParams(
        userId: event.userId,
        amount: event.amount,
        note: event.note,
      ),
    );
    result.fold(
          (error) {
        emit(state.copyWith(
          reqStateTransfer: handleErrorResponse(error),
          messageTransfer: NetworkExceptions.getErrorMessage(error),
        ));
        Methods.showToast(
          event.context,
          message: NetworkExceptions.getErrorMessage(error),
          isError: true,
        );
      },
          (success) {
        emit(state.copyWith(
          reqStateTransfer: RequestState.loaded,
          messageTransfer: success,
        ));
        Methods.showToast(
          event.context,
          message: success.isNotEmpty ? success : StringManager.success.tr(),
        );
        // Reflect the new balance and the new entry right away, without
        // making the seller pull-to-refresh manually.
        add(const GetCoinSellerProfileEvent());
        add(const GetCoinSellerHistoryEvent());
      },
    );
  }

  Future<void> _getHistory(
      GetCoinSellerHistoryEvent event,
      Emitter<CoinSellerState> emit,
      ) async {
    if (event.isLoading) {
      emit(state.copyWith(reqStateHistory: RequestState.loading));
    }
    final result = await getCoinSellerHistoryUC(
      GetCoinSellerHistoryParams(
        page: 1,
        fromDate: state.fromDate,
        toDate: state.toDate,
        searchKey: state.searchKey,
      ),
    );
    result.fold(
          (error) => emit(state.copyWith(
        reqStateHistory: handleErrorResponse(error),
        messageHistory: NetworkExceptions.getErrorMessage(error),
      )),
          (success) => emit(state.copyWith(
        history: success.data ?? [],
        reqStateHistory:
        handleLoadedResponse<List<CoinSellerHistoryItemModel>?>(
          success.data,
        ),
        currentPage: success.paginates?.currentPage ?? 1,
        lastPage: success.paginates?.lastPage ?? 1,
      )),
    );
  }

  Future<void> _loadMoreHistory(
      LoadMoreCoinSellerHistoryEvent event,
      Emitter<CoinSellerState> emit,
      ) async {
    if (!state.hasMoreHistory || state.isPaginating) return;
    emit(state.copyWith(isPaginating: true));

    final nextPage = state.currentPage + 1;
    final result = await getCoinSellerHistoryUC(
      GetCoinSellerHistoryParams(
        page: nextPage,
        fromDate: state.fromDate,
        toDate: state.toDate,
        searchKey: state.searchKey,
      ),
    );
    result.fold(
          (error) => emit(state.copyWith(isPaginating: false)),
          (success) => emit(state.copyWith(
        history: [...state.history, ...success.data ?? []],
        currentPage: success.paginates?.currentPage ?? nextPage,
        lastPage: success.paginates?.lastPage ?? state.lastPage,
        isPaginating: false,
      )),
    );
  }

  Future<void> _filterHistory(
      FilterCoinSellerHistoryEvent event,
      Emitter<CoinSellerState> emit,
      ) async {
    emit(state.copyWith(
      fromDate: event.fromDate,
      toDate: event.toDate,
      searchKey: event.searchKey,
      clearFromDate: event.clearFromDate,
      clearToDate: event.clearToDate,
      clearSearchKey: event.clearSearchKey,
    ));
    add(const GetCoinSellerHistoryEvent(isLoading: true));
  }
}
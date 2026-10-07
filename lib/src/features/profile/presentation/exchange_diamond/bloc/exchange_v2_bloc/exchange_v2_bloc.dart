import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/profile/profile.dart';

import '../../../../data/model/exchange_log_model.dart';
import '../../../../data/model/exchange_settings_model.dart';
import '../../../../domain/profile_use_case/get_exchange_logs_uc.dart';
import '../../../../domain/profile_use_case/get_exchange_settings_uc.dart';
import '../../../../domain/profile_use_case/make_exchange_v2_uc.dart';

part 'exchange_v2_event.dart';

part 'exchange_v2_state.dart';

/// New, dynamic diamond -> coin exchange flow (v2 API), built alongside the
/// existing v1 `DiamondBloc` rather than replacing it -- per request, the
/// Wallet screen's Diamond tab now points its "Exchange" button at this
/// bloc/flow instead of the old fixed-tier list, while `DiamondBloc` itself
/// (and any other still-live screens using it) is left untouched.
class ExchangeV2Bloc extends Bloc<ExchangeV2Event, ExchangeV2State> {
  final GetExchangeSettingsUC getExchangeSettingsUseCase;
  final MakeExchangeV2UC makeExchangeUseCase;
  final GetExchangeLogsUC getExchangeLogsUseCase;

  ExchangeV2Bloc({
    required this.getExchangeSettingsUseCase,
    required this.makeExchangeUseCase,
    required this.getExchangeLogsUseCase,
  }) : super(const ExchangeV2State()) {
    on<GetExchangeSettingsEvent>(_getSettings);
    on<MakeExchangeEvent>(_makeExchange);
    on<GetExchangeLogsEvent>(_getLogs);
  }

  void _getSettings(
      GetExchangeSettingsEvent event, Emitter<ExchangeV2State> emit) async {
    emit(state.copyWith(reqStateSettings: RequestState.loading));
    final result = await getExchangeSettingsUseCase.call();
    result.fold(
          (error) => emit(state.copyWith(
        reqStateSettings: handleErrorResponse(error),
        messageSettings: NetworkExceptions.getErrorMessage(error),
      )),
          (success) => emit(state.copyWith(
        reqStateSettings: RequestState.loaded,
        settings: success,
      )),
    );
  }

  void _makeExchange(
      MakeExchangeEvent event, Emitter<ExchangeV2State> emit) async {
    emit(state.copyWith(reqStateExchange: RequestState.loading));
    final result = await makeExchangeUseCase.call(
      MakeDiamondExchangeParams(
        diamonds: event.diamonds,
        exchange: event.exchange,
      ),
    );
    result.fold(
          (error) {
        emit(state.copyWith(
          reqStateExchange: handleErrorResponse(error),
          messageExchange: NetworkExceptions.getErrorMessage(error),
        ));
        if (event.context.mounted) {
          Methods.showToast(event.context,
              message: NetworkExceptions.getErrorMessage(error),
              isError: true);
        }
      },
          (success) {
        emit(state.copyWith(
          reqStateExchange: RequestState.loaded,
          messageExchange: success,
        ));
        // Optimistic local balance update -- same pattern the existing v1
        // exchange flow uses (EditMyCoinsAndDiamondsLocally: coins is
        // ADDED, diamonds is SUBTRACTED).
        di<MyStoreBloc>().add(EditMyCoinsAndDiamondsLocally(
          coins: event.exchange,
          diamonds: event.diamonds,
        ));
        // Refresh the live rate/balance from the server too, so the screen
        // doesn't drift from the backend's own numbers.
        add(const GetExchangeSettingsEvent());
        if (event.context.mounted) {
          Methods.showToast(event.context, message: StringManager.success.tr());
        }
      },
    );
  }

  void _getLogs(
      GetExchangeLogsEvent event, Emitter<ExchangeV2State> emit) async {
    emit(state.copyWith(reqStateLogs: RequestState.loading));
    final result = await getExchangeLogsUseCase.call(event.type);
    result.fold(
          (error) => emit(state.copyWith(
        reqStateLogs: handleErrorResponse(error),
        messageLogs: NetworkExceptions.getErrorMessage(error),
      )),
          (success) => emit(state.copyWith(
        reqStateLogs: success.data.isEmpty
            ? RequestState.empty
            : RequestState.loaded,
        logs: success,
      )),
    );
  }
}
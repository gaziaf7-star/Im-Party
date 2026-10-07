import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'make_sha_to_admin_request_event.dart';

part 'make_sha_to_admin_request_state.dart';

class MakeShippingAgentToAdminWithdrawalRequestBloc extends Bloc<
    MakeShippingAgentToAdminWithdrawalRequestEvent,
    MakeShippingAgentToAdminWithdrawalRequestState> {
  final MakeShippingAgentToAdminWithdrawalRequestUC useCase;

  MakeShippingAgentToAdminWithdrawalRequestBloc({required this.useCase})
      : super(MakeShippingAgentToAdminWithdrawalRequestState(
            controller: TextEditingController())) {
    on<MakeShippingAgentToAdminWithdrawalRequest>(
      (event, emit) async {
        emit(state.copyWith(requestState: RequestState.loading));

        final result = await useCase(event.param);

        result.fold((left) {
          emit(
            state.copyWith(
              requestState: RequestState.error,
              error: NetworkExceptions.getErrorMessage(left),
                isDollars: false,
                isCoins: false
            ),
          );
          Methods.showToast(event.context,
              message: state.error ?? '', isError: true);
          state.controller.clear();
        }, (right) {
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              message: right.message,
              isDollars: false,
              isCoins: false
            ),
          );
          di<GetChargeAgencyBloc>().add(ChargeAgencyEditDollarsLocallyEvent(
              dollarsValue: int.parse(event.param.amount)));
          Methods.showToast(
            event.context,
            message: state.message ?? '',
          );
          state.controller.clear();
        });
      },
    );
    on<EditCoinsSwitchValue>(
      (event, emit) async {
        if (state.isDollars == true) {
          emit(state.copyWith(isCoins: event.value, isDollars: false));
        } else {
          emit(state.copyWith(isCoins: event.value));
        }
      },
    );
    on<EditDollarsSwitchValue>(
      (event, emit) async {
        if (state.isCoins == true) {
          emit(state.copyWith(isDollars: event.value, isCoins: false));
        } else {
          emit(state.copyWith(isDollars: event.value));
        }
      },
    );
  }
}

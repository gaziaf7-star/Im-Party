import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'charge_coin_for_user_event.dart';

part 'charge_coin_for_user_state.dart';

class ChargeCoinForUserBloc
    extends Bloc<ChargeCoinForUserEvent, ChargeCoinForUserState> {
  final ChargeCoinForUserUC chargeCoinForUserUC;

  ChargeCoinForUserBloc({required this.chargeCoinForUserUC})
      : super(const ChargeCoinForUserState()) {
    on<ChargeCoinForUserEvent>(
      (event, emit) async {
        // Emit Loading State
        emit(state.copyWith(requestState: RequestState.loading));

        // Call the UseCase
        final result = await chargeCoinForUserUC(
            ChargeToParam(userId: event.id, amount: event.amount,userType: event.type));

        // Handle result
        result.fold(
            // On failure, emit Error State with error message
            (left) {
          emit(
            state.copyWith(
              requestState: RequestState.error,
              error: NetworkExceptions.getErrorMessage(left),
            ),
          );
        }, (right) {
          emit(
            state.copyWith(
              requestState: RequestState.loaded,
              data: right,
            ),
          );
          di<GetChargeAgencyBloc>().add(ChargeAgencyEditCoinsLocallyEvent(
              coinsValue: int.parse(event.amount)));
          di<GetChargeAgencyDetailsBloc>()
              .add(const GetChargeAgencyDetailsSenderEvent());
          Navigator.pushNamed(
            event.context,
            Routes.successTransferScreen,
            arguments:
                SuccessTransferScreenParam(value: event.amount, isCoins: true),
          );
        });
      },
    );
  }
}

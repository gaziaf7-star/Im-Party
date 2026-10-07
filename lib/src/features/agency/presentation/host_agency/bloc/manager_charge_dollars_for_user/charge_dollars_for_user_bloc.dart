import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'charge_dollars_for_user_event.dart';

part 'charge_dollars_for_user_state.dart';

class ChargeDollarsForUserBloc
    extends Bloc<ChargeDollarsForUserEvent, ChargeDollarsForUserState> {
  final ChargeDollarsForUserUC chargeDollarsForUserUC;

  ChargeDollarsForUserBloc({required this.chargeDollarsForUserUC})
      : super(const ChargeDollarsForUserState()) {
    on<ChargeDollarsForUserEvent>(
      (event, emit) async {
        emit(state.copyWith(state: RequestState.loading));
        Methods.showToast(
          event.context,
          isLoading: true,
        );
        final result = await chargeDollarsForUserUC(
          ChargeToParam(
            userId: event.id,
            amount: event.amount,
            userType: event.type,
          ),
        );

        // Handle the result
        result.fold(
          (left) {
            emit(
              state.copyWith(
                state: RequestState.error,
                error: NetworkExceptions.getErrorMessage(left),
              ),
            );

            Methods.showToast(event.context,
                message: state.error ?? "An error occurred", isError: true);
          },
          (right) {
            emit(
              state.copyWith(
                state: RequestState.loaded,
                data: right.data ?? const ChargeModel(),
              ),
            );
          },
        );
      },
    );
  }
}

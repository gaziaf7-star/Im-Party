import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

part 'charge_to_event.dart';

part 'charge_to_state.dart';

class ChargeToBloc extends Bloc<ChargeToEvents, ChargeToState> {
  final ChargeToUC chargeToUseCases;

  ChargeToBloc({required this.chargeToUseCases})
      : super(const ChargeToState()) {
    on<SendCharge>(_sendChargeEvent);
  }

  Future<void> _sendChargeEvent(
    SendCharge event,
    Emitter<ChargeToState> emit,
  ) async {
    emit(state.copyWith(state: RequestState.loading));

    final result = await chargeToUseCases.call(
      ChargeToParam(userId: event.uId, amount: event.usd, userType: event.type),
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
        Methods.showToast(
          event.context,
          message: state.error ?? "An error occurred",
          isError: true,
        );
      },
      (right) {
        emit(
          state.copyWith(
            state: RequestState.loaded,
            chargeToModel: right.data ?? const ChargeModel(),
          ),
        );

        // // Update AgencyHostReportBloc if current month matches
        // final currentMonth = DateTime.now().month;
        // final reportMonth =
        //     int.tryParse(di<AgencyHostReportBloc>().state.month ?? '') ?? -1;
        //
        // if (reportMonth == currentMonth) {
        //   di<AgencyHostReportBloc>()
        //       .add(EditCutOutLocallyEvent(usd: int.parse(event.usd)));
        // }
        //
        // // Update MyStoreBloc with the user USD
        di<MyStoreBloc>().add(const GetMyStoreEvent());

        // Navigate to success screen
        // Navigator.pushNamed(
        //   event.context,
        //   Routes.successTransferScreen,
        //   arguments: SuccessTransferScreenParam(value: event.usd),
        // );
      },
    );
  }
}

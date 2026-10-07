import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'get_charge_agency_events.dart';

part 'get_charge_agency_states.dart';

class GetChargeAgencyBloc
    extends Bloc<BaseGetChargeAgencyEvent, GetChargeAgencyStates> {
  final GetAgencyInfoUC getAgencyInfoUC;

  GetChargeAgencyBloc({required this.getAgencyInfoUC})
      : super(const GetChargeAgencyStates()) {
    on<ChargeAgencyEditCoinsLocallyEvent>(_chargeAgencyEditCoinsLocally);
    on<ChargeAgencyEditDollarsLocallyEvent>(_chargeAgencyEditDollarsLocally);
    on<EditChargeAgencyLocallyEvent>(_editChargeAgencyLocally);
    on<GetChargeAgencyEvent>(
      (event, emit) async {
        if (event.isFirstLoading == true) {
          emit(state.copyWith(requestState: RequestState.loading));
        }
        final result = await getAgencyInfoUC(event.agencyId);
        result.fold(
          (left) => emit(
            state.copyWith(
              requestState: RequestState.error,
              message: NetworkExceptions.getErrorMessage(left),
            ),
          ),
          (right) {
            if (event.agencyId != null) {
              emit(
                state.copyWith(
                    requestState: RequestState.loaded,
                    data: right.data ?? const ChargeAgencyInfoModel()),
              );
            } else {
              emit(
                state.copyWith(
                    requestState: RequestState.loaded,
                    myChargeAgencyData:
                        right.data ?? const ChargeAgencyInfoModel()),
              );
            }
          },
        );
      },
    );
  }

  void _chargeAgencyEditCoinsLocally(ChargeAgencyEditCoinsLocallyEvent event,
      Emitter<GetChargeAgencyStates> emit) {
    if (state.data == null) return;
    final int coinsUpdated = (state.data?.coins ?? 0) - event.coinsValue;
    emit(state.copyWith(data: state.data?.copyWith(coins: coinsUpdated)));
  }

  void _chargeAgencyEditDollarsLocally(
      ChargeAgencyEditDollarsLocallyEvent event,
      Emitter<GetChargeAgencyStates> emit) {
    if (state.data == null) return;
    final int dollarsUpdated = (state.data?.usd ?? 0) - event.dollarsValue;
    emit(state.copyWith(data: state.data?.copyWith(usd: dollarsUpdated)));
  }

  void _editChargeAgencyLocally(
      EditChargeAgencyLocallyEvent event, Emitter<GetChargeAgencyStates> emit) {
    emit(state.copyWith(myChargeAgencyData: event.entity));
  }
}

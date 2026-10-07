import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'leave_agency_event.dart';

part 'leave_agency_state.dart';

class LeaveAgencyBloc extends Bloc<BaseLeaveAgencyEvent, LeaveAgencyState> {
  final LeaveAgencyUC leaveAgencyUC;

  LeaveAgencyBloc({required this.leaveAgencyUC})
      : super(const LeaveAgencyState()) {
    on<LeaveAgencyEvent>((event, emit) async {
      emit(state.copyWith(state: RequestState.loading));

      final result = await leaveAgencyUC();

      result.fold((left) {
        emit(
          state.copyWith(
            state: RequestState.error,
            error: NetworkExceptions.getErrorMessage(left),
          ),
        );

        Methods.showToast(event.context, message: state.message ?? '');
      }, (right) {
        emit(
          state.copyWith(
            state: RequestState.loaded,
            message: right.message,
          ),
        );
        Navigator.pop(event.context);
        Methods.showToast(event.context, message: right.message);
      });
    });
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/use_case/check_admin_owner_uc.dart';

part 'check_admin_owner_event.dart';
part 'check_admin_owner_state.dart';

class CheckAdminOwnerBloc
    extends Bloc<BaseCheckAdminOwnerEvent, CheckAdminOwnerState> {
  final CheckAdminOwnerUc _checkAdminOwnerUc;

  CheckAdminOwnerBloc(this._checkAdminOwnerUc)
      : super(const CheckAdminOwnerState()) {
    on<CheckAdminOwnerEvent>((event, emit) async {
      final result = await _checkAdminOwnerUc(
        event.params,
      );
      result.fold(
        (l) {
          emit(state.copyWith(
              requestState: RequestState.error,
              message: NetworkExceptions.getErrorMessage(l)));
          Methods.showToast(event.context,
              message: NetworkExceptions.getErrorMessage(l), isError: true);
        },
        (r) {
          emit(state.copyWith(
              requestState: RequestState.loaded, message: r.message));
          event.callback!();
        },
      );
    });
  }
}

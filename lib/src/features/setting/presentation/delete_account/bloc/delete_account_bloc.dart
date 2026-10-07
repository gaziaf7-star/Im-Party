import 'package:firebase_auth/firebase_auth.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/setting/domain/use_case/delete_account_uc.dart';

part 'delete_account_event.dart';
part 'delete_account_state.dart';

class DeleteAccountBloc
    extends Bloc<BaseDeleteAccountEvent, DeleteAccountState> {
  final DeleteAccountUc deleteAccountUc;

  DeleteAccountBloc({required this.deleteAccountUc})
      : super(const DeleteAccountState()) {
    on<DeleteAccountEvent>((event, emit) async {
      final result = await deleteAccountUc();

      result.fold(
        (left) {
          emit(state.copyWith(
          requestState: handleErrorResponse(left),
          message: NetworkExceptions.getErrorMessage(left),
        ));
        },
        (right) async{
          emit(
            state.copyWith(
              requestState: handleLoadedResponse<String>(right),
              message: right,
            ),
          );
          await FirebaseAuth.instance.signOut();
          await DependencyInjectionService.reset();
          await DependencyInjectionService.init();

        },
      );
    });

    on<SelectToReadEvent>((event, emit) {
      emit(state.copyWith(isActive: event.isActive));
    });
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/setting/domain/use_case/log_out_uc.dart';

part 'log_out_event.dart';

part 'log_out_state.dart';

class LogOutBloc extends Bloc<BaseLogOutEvent, BaseLogOutState> {
  final LogOutUseCase logOutUseCase;

  LogOutBloc({required this.logOutUseCase}) : super(const LogOutInitial()) {
    on<LogOutEvent>((event, emit) async {
      final result = await logOutUseCase();

      await result.fold((left) {
        emit(LogOutError(NetworkExceptions.getErrorMessage(left)));
      }, (right) async {
        await FirebaseAuth.instance.signOut();
        await DependencyInjectionService.reset();
        await DependencyInjectionService.init();
        emit(LogOutSuccess(right.message));
      });
    });
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/manager/manager_get_config_key/get_config_keys_event.dart';
import 'package:general/src/features/room/presentation/manager/manager_get_config_key/get_config_keys_state.dart';
import 'package:general/src/features/room/room.dart';

class GetConfigKeysBloc
    extends Bloc<BaseGetConfigKeysEvent, GetConfigKeysState> {
  GetConfigKeyUC getConfigKeyUc;
  GetConfigKeysBloc({required this.getConfigKeyUc})
      : super(GetConfigKeysInitial()) {
    on<GetConfigKeyEvent>((event, emit) async {
      emit(GetConfigKeysLoading());
      final result = await getConfigKeyUc.call(event.getConfigKeyPram);

      result.fold(
        (l) => emit(
            GetConfigKeysError(error: NetworkExceptions.getErrorMessage(l))),
        (r) => emit(GetConfigKeysSucsses(getConfigKey: r.data!)),
      );
    });
  }
}

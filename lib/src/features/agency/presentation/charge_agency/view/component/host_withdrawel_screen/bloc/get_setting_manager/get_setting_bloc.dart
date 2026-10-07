import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/core/index.dart';

part'get_setting_event.dart';
part'get_setting_state.dart';


class GetSettingBloc extends Bloc<BaseGetSettingEvent, GetSettingState> {
  final GetSettingUC getSettingUC;

  GetSettingBloc({required this.getSettingUC})
      : super(const GetSettingState()) {
    on<GetSettingsEvent>((event, emit) async {
      emit(state.copyWith(state: RequestState.loading));

      final result = await getSettingUC();

      result.fold(
            (left) => emit(
          state.copyWith(
            state: RequestState.error,
            message: NetworkExceptions.getErrorMessage(left),
          ),
        ),
            (right) => emit(
          state.copyWith(
            state: RequestState.loaded,
            settingModel: right.data, // Assuming right returns a SettingModel
          ),
        ),
      );
    });
  }
}
import 'package:country_picker/country_picker.dart';
import 'package:general/src/features/auth/domain/use_cases/change_phone_us.dart';

import '../../../../../core/index.dart';

part 'change_number_event.dart';

part 'change_number_state.dart';

class ChangePhoneBloc extends Bloc<ChangePhoneEvent, ChangePhoneState> {
  final ChangeNumberUseCase changeNumberUseCase;

  ChangePhoneBloc({
    required this.changeNumberUseCase,
  }) : super(ChangePhoneState(
          formKeyRP: GlobalKey<FormState>(),
          formKeyCP: GlobalKey<FormState>(),
          phoneControllerNew: TextEditingController(),
          phoneController: PhoneController(
            initialValue: const PhoneNumber(isoCode: IsoCode.EG, nsn: ""),
          ),
        )) {
    on<FetchPhoneEvent>(phoneEvent);
    on<ChangeCountryChangePhone>(changeCountryEvent);
    on<ChangeNumberEvent>((event, emit) async {
      final result = await changeNumberUseCase(event.bindAccountParam);
      result.fold(
          (l) => emit(state.copyWith(
              changeNumberState: RequestState.error,
              changeNumberError: NetworkExceptions.getErrorMessage(l))), (r) {
        event.context.pushNamedAndRemoveUntil(Routes.layout);
        Methods.showToast(event.context,
            message: StringManager.resetSuccessful.tr());

        emit(state.copyWith(
            changeNumberState: RequestState.loaded,
            changeNumberSuccessMessage: r.message));
      });
    });
  }
  void phoneEvent(FetchPhoneEvent event, Emitter<ChangePhoneState> emit) =>
      emit(
        state.copyWith(
          phoneController: PhoneController(initialValue: event.phone!),
          validatePhoneNumber: event.validatePhoneNumber,
        ),
      );

  void changeCountryEvent(
      ChangeCountryChangePhone event, Emitter<ChangePhoneState> emit) {
    emit(state.copyWith(selectedCountry: event.newCountry));
  }
}

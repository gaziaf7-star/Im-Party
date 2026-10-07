import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

part 'update_charge_agency_event.dart';

part 'update_charge_agency_state.dart';

class UpdateChargeAgencyBloc
    extends Bloc<BaseUpdateChargeAgencyEvent, UpdateChargeAgencyState> {
  final UpdateAgencyInfoUC updateChargeAgencyUC;
  final ImagePicker _imagePicker = ImagePicker();

  UpdateChargeAgencyBloc({required this.updateChargeAgencyUC})
      : super(UpdateChargeAgencyState(
            textEditingController: TextEditingController())) {
    on<UpdateChargeAgencyEvent>(
      (event, emit) async {
        if (event.isFirstLoading == true) {
          emit(state.copyWith(pathImg: state.pathImg));
        }
        Methods.showToast(
          event.context!,
          message: StringManager.loading,
        );
        List<int?> countriesIds = di<UpdateChargeAgencyBloc>()
            .state
            .selectedCountries
            .map((country) => country?.id)
            .toList();
        List<int?> paymentsIds = di<UpdateChargeAgencyBloc>()
            .state
            .selectedPayments
            .map((payment) => payment?.id)
            .toList();
        final result = await updateChargeAgencyUC(UpdateChargeAgencyParam(
          appOwnerId: MyDataModel.getInstance().id!,
          phone: MyDataModel.getInstance().phone!,
          agencyId: event.agencyId,
          image: state.imageFile,
          name: state.textEditingController.text,
          paymentIds:
              di<UpdateChargeAgencyBloc>().state.selectedPayments.isEmpty
                  ? null
                  : paymentsIds.join(','),
          countriesIds:
              di<UpdateChargeAgencyBloc>().state.selectedCountries.isEmpty
                  ? null
                  : countriesIds.join(','),
        ));

        result.fold(
            (failure) {
          emit(
            state.copyWith(
              message: NetworkExceptions.getErrorMessage(failure),

              state: RequestState.error, // Using NetworkExceptions
            ),
          );

          Methods.showToast(event.context,
              message: state.message, isError: true);
        },
            // Success case
            (success) {
          emit(
            state.copyWith(
                message: success.message,
                pathImg: state.pathImg,
                state: RequestState.loaded),
          );

          di<GetChargeAgencyBloc>()
              .add(EditChargeAgencyLocallyEvent(entity: success.data));
          Methods.showToast(
            event.context,
            message: state.message,
          );
        });
      },
    );

    on<PickImageEvent>(_onPickImage);
    on<UnPickImageEvent>(_unPickImageEvent);

    on<ShowCountriesEvent>(_showCountriesEvent);
    on<SelectCountryEvent>(_selectCountryEvent);
    on<RemoveCountrySelectionEvent>(_removeCountrySelection);

    on<ShowPaymentsEvent>(_showPaymentsEvent);
    on<SelectPaymentEvent>(_selectPaymentEvent);
    on<RemovePaymentSelectionEvent>(_removePaymentSelection);

    on<SetNameEvent>(_setName);
    // on<ControllerDisposeEvent>(_controllerDispose);
  }



  Future<void> _onPickImage(
      PickImageEvent event,
      Emitter<UpdateChargeAgencyState> emit,
      ) async {
    try {
      final pickedFile =
          await Methods.pickImageSafely(_imagePicker, source: event.source);

      if (pickedFile == null) {
        emit(state.copyWith(message: 'No image selected'));
        return;
      }

      final filePath = pickedFile.path;
      final file = File(filePath);

      // ✅ Extension whitelist
      final allowedExtensions = ['.jpg', '.jpeg', '.png'];
      final ext = p.extension(filePath).toLowerCase();

      if (!allowedExtensions.contains(ext)) {
        Methods().showWaringGifDialog(); // Reuse for all invalid formats
        return;
      }

      // ✅ MIME type check (for safety)
      final mimeType = lookupMimeType(filePath) ?? '';
      if (!mimeType.startsWith('image/')) {
        Methods().showWaringGifDialog();
        return;
      }

      // ✅ All good
      emit(
        state.copyWith(
          pathImg: file.path,
          imageFile: file,
          phone: event.phone,
          id: event.id,
        ),
      );
    } catch (error) {
      emit(state.copyWith(message: '$error'));
    }
  }


  Future<void> _unPickImageEvent(
    UnPickImageEvent event,
    Emitter<UpdateChargeAgencyState> emit,
  ) async {
    emit(
      state.copyWith(
        pathImg: '',
      ),
    );
  }

  void _showCountriesEvent(
    ShowCountriesEvent event,
    Emitter<UpdateChargeAgencyState> emit,
  ) {
    emit(state.copyWith(showCountries: !state.showCountries));
  }

  void _showPaymentsEvent(
    ShowPaymentsEvent event,
    Emitter<UpdateChargeAgencyState> emit,
  ) {
    emit(state.copyWith(showPayments: !state.showPayments));
  }

  void _selectCountryEvent(
    SelectCountryEvent event,
    Emitter<UpdateChargeAgencyState> emit,
  ) {
    if (event.countryList != null) {
      emit(state.copyWith(selectedCountries: event.countryList));
    } else {
      final updatedCountries =
          List<CountryEntity?>.from(state.selectedCountries);

      // Check if the selected country ID is already in the list
      final index = updatedCountries
          .indexWhere((country) => country?.id == event.country?.id);

      if (index != -1) {
        // If it exists, remove it
        updatedCountries.removeAt(index);
      } else {
        // If it doesn't exist, add it
        updatedCountries.add(event.country);
      }

      // log('_selectCountryEvent 3:');
      // final updatedCountries = List<CountryEntity?>.from(state.selectedCountries);
      // log('_selectCountryEvent 4:${updatedCountries}');
      //
      // if (updatedCountries.contains(event.country)) {
      //
      //   updatedCountries.remove(event.country);
      //   log('_selectCountryEvent 5:${updatedCountries}');
      //
      // } else {
      //   updatedCountries.add(event.country);
      //   log('_selectCountryEvent 6:${updatedCountries}');
      //
      // }

      emit(state.copyWith(selectedCountries: updatedCountries));
    }
  }

  //  void _selectCountryEvent(
  //       SelectCountryEvent event,
  //       Emitter<UpdateChargeAgencyState> emit,
  //       ) {
  //     log('_selectCountryEvent 1:');
  //
  //     final updatedCountries = List<CountryEntity?>.from(state.selectedCountries);
  //
  //     // Check if the selected country ID is already in the list
  //     final index = updatedCountries.indexWhere((country) => country?.id == event.country?.id);
  //
  //     if (index != -1) {
  //       // If it exists, remove it
  //       updatedCountries.removeAt(index);
  //       log('_selectCountryEvent - Removing country with ID: ${updatedCountries}');
  //     } else {
  //       // If it doesn't exist, add it
  //       updatedCountries.add(event.country);
  //       log('_selectCountryEvent - Adding country with ID: ${updatedCountries}');
  //     }
  //
  //     // Emit the updated state with the modified selectedCountries list
  //     emit(state.copyWith(selectedCountries: updatedCountries));
  //     log('_selectCountryEvent - Updated countries list: $updatedCountries');
  //   }
  void _removeCountrySelection(
    RemoveCountrySelectionEvent event,
    Emitter<UpdateChargeAgencyState> emit,
  ) {
    emit(state.copyWith(selectedCountries: []));
  }

  void _selectPaymentEvent(
    SelectPaymentEvent event,
    Emitter<UpdateChargeAgencyState> emit,
  ) {
    if (event.paymentList != null) {
      emit(state.copyWith(selectedPayments: event.paymentList));
    } else {
      final updatedPayments =
          List<PaymentsGetwaysEntity?>.from(state.selectedPayments);

      if (updatedPayments.contains(event.payment)) {
        updatedPayments.remove(event.payment);
      } else {
        updatedPayments.add(event.payment);
      }

      emit(state.copyWith(selectedPayments: updatedPayments));
    }
  }

  void _removePaymentSelection(
    RemovePaymentSelectionEvent event,
    Emitter<UpdateChargeAgencyState> emit,
  ) {
    emit(state.copyWith(selectedPayments: []));
  }

  void _setName(
    SetNameEvent event,
    Emitter<UpdateChargeAgencyState> emit,
  ) {
    emit(state.copyWith(controllerText: event.name));
  }

//   @override
//   Future<void> close() {
// state.textEditingController.dispose();    return super.close();
//   }
// void _controllerDispose(
//     ControllerDisposeEvent event,
//   Emitter<UpdateChargeAgencyState> emit,
// ) {
//
//
//
//
// }
}

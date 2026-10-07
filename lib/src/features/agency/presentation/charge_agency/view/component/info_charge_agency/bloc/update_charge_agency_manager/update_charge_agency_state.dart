part of 'update_charge_agency_bloc.dart';

class UpdateChargeAgencyState extends Equatable {
  final String message;
  final String phone;
  final String id;
  final String pathImg;
  final RequestState state;
  final bool showCountries;
  final bool showPayments;
  final List<CountryEntity?> selectedCountries;
  final List<PaymentsGetwaysEntity?> selectedPayments;
final TextEditingController textEditingController;
final File? imageFile;
  const UpdateChargeAgencyState({
    this.message = '',
    this.phone = '',
    this.id = '',
    this.pathImg = '',
    this.imageFile ,
    this.state = RequestState.idle,
    this.showCountries = false,
    this.showPayments = false,
    this.selectedCountries = const [],
    this.selectedPayments = const [],
    required  this.textEditingController ,

  });

  @override
  List<Object?> get props =>
      [message, phone, id, pathImg, state,showPayments, showCountries, selectedCountries,selectedPayments];

  // Adding the copyWith method
  UpdateChargeAgencyState copyWith({
    String? message,
    String? phone,
    String? id,
    String? pathImg,
    RequestState? state,
    bool? showCountries,
    bool? showPayments,
    List<CountryEntity?>? selectedCountries,
    List<PaymentsGetwaysEntity?>? selectedPayments,
    String? controllerText,
    File? imageFile
  }) {
    return UpdateChargeAgencyState(
      message: message ?? this.message,
      phone: phone ?? this.phone,
      id: id ?? this.id,
      pathImg: pathImg ?? this.pathImg,
      state: state ?? this.state,
      showCountries: showCountries ?? this.showCountries,
      showPayments: showPayments ?? this.showPayments,
      selectedCountries: selectedCountries ?? this.selectedCountries,
      selectedPayments: selectedPayments ?? this.selectedPayments,
      textEditingController: textEditingController.copyWith(text: controllerText) ,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}

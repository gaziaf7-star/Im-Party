part of 'add_information_bloc.dart';

class AddInformationState extends Equatable {
  final TextEditingController name, birthday, country , gender,email;
  final File? image;
  final RequestState requestState;
  final String message;
  final GlobalKey<FormState> formKey;
  final ThirdPartyEntity? kThirdPartyEntity;

  /// The country the user picked, as the backend's own country id.
  ///
  /// The `country` TextEditingController next to it only ever held the display
  /// NAME; there was nowhere to keep the id, which is why countryId was
  /// commented out at the call site and no account was created with a country.
  final int? selectedCountryId;

  const AddInformationState({
    required this.formKey,
    required this.name,
    required this.birthday,
    required this.email,
    required this.country,
    required this.gender,
    this.image,
    this.requestState = RequestState.idle,
    this.message = '',
    this.kThirdPartyEntity ,
    this.selectedCountryId,
  });

  AddInformationState copyWith({
    String? name,
    String? birthday,
    String? country,
    String? gender,
    String? email,
    RequestState? requestState,
    File? image,
    String? message,
    bool isImageNull = false,
    GlobalKey<FormState>? formKey,
    ThirdPartyEntity? kThirdPartyEntity,
    int? selectedCountryId,
  }) {
    return AddInformationState(
      name: this.name.copyWith(text: name),
      birthday: this.birthday.copyWith(text: birthday),
      country: this.country.copyWith(text: country),
      gender: this.gender.copyWith(text: gender),
      email: this.email.copyWith(text: email),
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      image: isImageNull ? null : image ?? this.image,
      formKey: formKey ?? this.formKey,
      kThirdPartyEntity: kThirdPartyEntity ?? this.kThirdPartyEntity,
      selectedCountryId: selectedCountryId ?? this.selectedCountryId,
    );
  }

  @override
  List<Object?> get props => [
        formKey,
        name,
        birthday,
        country,
        selectedCountryId,
        gender,
        email,
        image,
        requestState,
        message,
    kThirdPartyEntity
      ];
}

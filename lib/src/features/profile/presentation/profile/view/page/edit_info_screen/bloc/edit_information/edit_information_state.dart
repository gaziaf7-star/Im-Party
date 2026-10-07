part of 'edit_information_bloc.dart';

class EditInformationState extends Equatable {
  final TextEditingController name, gender,birthday, country,bio;
  final File? image;
  final File? coverImage;
  final RequestState requestState , reqStateChangeCountry;
  final String message;
  final List<File> multiImages;
  final List<String> coverImages;
  final bool isSaveButtonActive;

  final GlobalKey<FormState> formKey;

  const EditInformationState( {
    required this.formKey,
    required this.name,
    required this.bio,
    required this.birthday,
    required this.country,
    required this.gender,
    this.image,
    this.coverImage,
    this.requestState = RequestState.idle,
    this.reqStateChangeCountry =RequestState.idle,
    this.message = '',
    this.multiImages = const [],
    this.coverImages = const [],
    this.isSaveButtonActive =false,
  });

  EditInformationState copyWith({
    String? name,
    String? bio,
    String? birthday,
    String? country,
    String? gender,
    RequestState? requestState,
    File? image,
    File? coverImage,
    String? message,
    bool isImageNull = false,
    bool isCoverImageNull = false,
    GlobalKey<FormState>? formKey,
    List<File>? multiImages,
    List<String>? coverImages,
    bool? isSaveButtonActive,
    RequestState? reqStateChangeCountry,

  }) {
    return EditInformationState(
      name: this.name..text = name ?? this.name.text,
      bio: this.bio..text = bio ?? this.bio.text,
      birthday: this.birthday..text = birthday ?? this.birthday.text,
      country: this.country..text = country ?? this.country.text,
      gender: this.gender..text = gender ?? this.gender.text,
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      image: isImageNull ? null : image ?? this.image,
      coverImage: isCoverImageNull ? null : coverImage ?? this.coverImage,
      multiImages:multiImages ?? this.multiImages,
      coverImages:coverImages ?? this.coverImages,
      formKey: formKey ?? this.formKey,
      isSaveButtonActive: isSaveButtonActive ?? this.isSaveButtonActive,
      reqStateChangeCountry: reqStateChangeCountry?? this.reqStateChangeCountry,

    );
  }

  @override
  List<Object?> get props => [
    formKey,
        name,
        birthday,
        country,
        gender,
        image,
        coverImage,
        requestState,
        message,
        multiImages,
        coverImages,
        bio,
        isSaveButtonActive,
        reqStateChangeCountry

      ];
}

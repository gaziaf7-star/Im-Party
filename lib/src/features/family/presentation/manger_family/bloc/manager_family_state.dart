part of 'manager_family_bloc.dart';

class ManagerFamilyStates extends Equatable {
  final TextEditingController name, bio;
  final GlobalKey<FormState> formKey;
  final String pathImage;
  final ShowFamilyEntity? showFamilyEntity;
  final RequestState reqState;
  final String message;
  final int familyId;

  const ManagerFamilyStates({
    this.familyId = 0,
    this.reqState = RequestState.idle,
    this.pathImage = '',
    this.message = '',
    this.showFamilyEntity,
    required this.name,
    required this.bio,
    required this.formKey,
  });

  ManagerFamilyStates copyWith({
    String? name,
    String? bio,
    GlobalKey<FormState>? formKey,
    String? pathImage,
    ShowFamilyEntity? showFamilyEntity,
    RequestState? reqState,
    String? message,
    int? familyId,
  }) {
    return ManagerFamilyStates(
      name: this.name.copyWith(text: name),
      bio: this.bio.copyWith(text: bio),
      familyId: familyId ?? this.familyId,
      pathImage: pathImage ?? this.pathImage,
      showFamilyEntity: showFamilyEntity ?? this.showFamilyEntity,
      formKey: formKey ?? this.formKey,
      message: message ?? this.message,
      reqState: reqState ?? this.reqState,
    );
  }

  @override
  List<Object?> get props => [
        message,
        familyId,
        reqState,
        pathImage,
        showFamilyEntity,
        name,
        bio,
        formKey,
      ];
}

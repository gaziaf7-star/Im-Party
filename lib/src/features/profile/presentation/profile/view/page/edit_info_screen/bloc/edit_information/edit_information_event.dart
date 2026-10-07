part of 'edit_information_bloc.dart';

sealed class BaseEditInformationEvent extends Equatable {
  final DateTime? dateTime;

  const BaseEditInformationEvent({this.dateTime});

  @override
  List<Object?> get props => [
        dateTime,
      ];
}

final class SelectedGenderEvent extends BaseEditInformationEvent {
  final String gender;
  const SelectedGenderEvent({required this.gender});
  @override
  List<Object?> get props => [gender];
}

final class InitialStateEvent extends BaseEditInformationEvent {
  const InitialStateEvent();
}

final class SelectedBirthdayEvent extends BaseEditInformationEvent {
  const SelectedBirthdayEvent({required super.dateTime});
}

final class PickImageEvent extends BaseEditInformationEvent {
  final bool fromCamera;

  const PickImageEvent({
    required this.fromCamera,
  });
  @override
  List<Object?> get props => [
        fromCamera,
      ];
}

final class PickCoverImageEvent extends BaseEditInformationEvent {
  final bool fromCamera;
  final bool isReplace;
  final int? previousImageId;

  const PickCoverImageEvent(
      {required this.fromCamera,
      required this.isReplace,
      this.previousImageId});
  @override
  List<Object?> get props => [fromCamera, isReplace, previousImageId];
}

final class DeleteCoverImageEvent extends BaseEditInformationEvent {
  final int imageIndex;
  final String imageUrl;
  const DeleteCoverImageEvent(
      {required this.imageIndex, required this.imageUrl});
  @override
  List<Object?> get props => [imageIndex, imageUrl];
}

final class PickMultiPicBloc extends BaseEditInformationEvent {
  final bool fromCamera;
  const PickMultiPicBloc({required this.fromCamera});
  @override
  List<Object?> get props => [fromCamera];
}

class CropImageEvent extends BaseEditInformationEvent {
  final XFile image;
  final bool isCover;
  final bool? isGif;
  final bool isReplace;
  final int? previousImageId;

  const CropImageEvent(
      this.image, this.isCover, this.isReplace, this.previousImageId,this.isGif);
  @override
  List<Object?> get props => [image, isCover, isReplace, previousImageId,isGif];
}

final class EditInformationEvent extends BaseEditInformationEvent {
  final String? bio;
  final String? name;
  final String? date;
  final File? image;
  final int? genders;
  final int? countryId;
  final String? age;
  final String? email;
  final List<File>? multiImages;

  const EditInformationEvent({
    this.bio,
    this.name,
    this.date,
    this.image,
    this.genders,
    this.countryId,
    this.age,
    this.email,
    this.multiImages,
  });
}

final class AssignInformationEvent extends BaseEditInformationEvent {}
final class ChangeCountryEvent extends BaseEditInformationEvent {
  const ChangeCountryEvent();
}

final class ActiveSaveButtonEvent extends BaseEditInformationEvent {
  final bool isUserName;
  const ActiveSaveButtonEvent({required this.isUserName});
  @override
  List<Object?> get props => [isUserName];
}

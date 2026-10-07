import 'package:equatable/equatable.dart';

abstract class AddImageState extends Equatable {
  final String imagePath;
  const AddImageState({this.imagePath = ''});

  @override
  List<Object> get props => [imagePath];
}

class AddImageInitial extends AddImageState {
  const AddImageInitial();
}
// pick image
class ImagePickerSuccess extends AddImageState {
  const ImagePickerSuccess({super.imagePath});

}
class ImagePickerLoading extends AddImageState {
  const ImagePickerLoading();
}

class ImagePickerFailure extends AddImageState {
  final String error;
  const ImagePickerFailure({required this.error});

  @override
  List<Object> get props => [error];
}

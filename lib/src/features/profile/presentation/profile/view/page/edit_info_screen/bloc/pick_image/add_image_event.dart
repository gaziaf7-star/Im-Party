import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class BaseAddImageEvent extends Equatable {
  const BaseAddImageEvent();

  @override
  List<Object?> get props => const [];
}

// pick image
class PickImageEvent extends BaseAddImageEvent {
  final ImageSource source;
  const PickImageEvent({required this.source});

  @override
  List<Object> get props => [source];
}

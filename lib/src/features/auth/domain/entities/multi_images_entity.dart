import 'package:general/src/core/index.dart';

class MultiImagesEntity extends Equatable {
  final String img;
  final int id;

  const MultiImagesEntity({required this.img,required this.id});

  @override
  List<Object?> get props => [img,id];
}

import 'package:equatable/equatable.dart';

class BackGroundEntity extends Equatable {
  final int id;
  final String img;

  const BackGroundEntity({required this.id, required this.img});

  @override
  List<Object?> get props => [id, img];
}
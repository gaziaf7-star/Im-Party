

import 'package:equatable/equatable.dart';

class DeleteChatEntity extends Equatable {
  final List<String>? files;

  const DeleteChatEntity({this.files});

  @override
  List<Object?> get props => [
    files,
  ];
}

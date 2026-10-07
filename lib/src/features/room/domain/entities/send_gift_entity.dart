import 'package:equatable/equatable.dart';

class SendGiftEntity extends Equatable {
  final bool success;
  final String message;
  final SendGiftDataEntity? data;

  const SendGiftEntity({
    required this.success,
    required this.message,
    this.data,
  });

  @override
  List<Object?> get props => [success, message, data];
}

class SendGiftDataEntity extends Equatable {
  final List<int> ids;

  const SendGiftDataEntity({
    required this.ids,
  });

  @override
  List<Object?> get props => [ids];
}
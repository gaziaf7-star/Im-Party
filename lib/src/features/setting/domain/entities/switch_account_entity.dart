import 'package:equatable/equatable.dart';

class SwitchLoginAccountEntity extends Equatable {
  final int id;
  final bool isFirst;
  final String authToken;

  const SwitchLoginAccountEntity({
    required this.id,
    required this.isFirst,
    required this.authToken,
  });

  @override
  List<Object?> get props => [id, isFirst, authToken];
}

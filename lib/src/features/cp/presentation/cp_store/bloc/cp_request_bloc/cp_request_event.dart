part of 'cp_request_bloc.dart';
abstract class BaseCpRequestEvents extends Equatable {}

class CpRequestEvents extends BaseCpRequestEvents {
  final String userId;
  final String relationId;
  final BuildContext context;

  CpRequestEvents({
    required this.userId,
    required this.relationId,
    required this.context,
  });

  @override
  List<Object?> get props => [userId, relationId];
}

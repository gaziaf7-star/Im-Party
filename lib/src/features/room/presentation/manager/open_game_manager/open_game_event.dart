abstract class BaseOpenGameEvent {}

class OpenGameEvent extends BaseOpenGameEvent {

  final int id;
  OpenGameEvent({required this.id});

}

part of'daily_prizes_bloc.dart';

abstract class GetDailyPrizesEvents extends Equatable{
  const GetDailyPrizesEvents();
  @override
  List<Object?> get props => [];
}


class GetDailyPrizesEvent extends GetDailyPrizesEvents {
  final BuildContext context;
  const GetDailyPrizesEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class OpenDailyPrizesEvent extends GetDailyPrizesEvents {}
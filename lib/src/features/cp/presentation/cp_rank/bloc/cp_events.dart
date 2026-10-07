part of 'cp_bloc.dart';

abstract class CpEvents extends Equatable {
  const CpEvents();
  @override
  List<Object?> get props => [];
}


class FetchFriendsCpDayEvent extends CpEvents {
  const FetchFriendsCpDayEvent();
}

class FetchFriendsCpWeeklyEvent extends CpEvents {
  const FetchFriendsCpWeeklyEvent();
}

class FetchFriendsCpMonthlyEvent extends CpEvents {
  const FetchFriendsCpMonthlyEvent();
}

class FetchBroCpDayEvent extends CpEvents {
  const FetchBroCpDayEvent();
}

class FetchBroCpWeeklyEvent extends CpEvents {
  const FetchBroCpWeeklyEvent();
}

class FetchBroCpMonthlyEvent extends CpEvents {
  const FetchBroCpMonthlyEvent();
}
class FetchLoveCpDayEvent extends CpEvents {
  const FetchLoveCpDayEvent();
}

class FetchLoveCpWeeklyEvent extends CpEvents {
  const FetchLoveCpWeeklyEvent();
}

class FetchLoveCpMonthlyEvent extends CpEvents {
  const FetchLoveCpMonthlyEvent();
}

// class HandleInfoCurrentRankEvent extends CpEvents {
//   final int currentIndex;
//
//   const HandleInfoCurrentRankEvent({required this.currentIndex});
//
//   @override
//   List<Object> get props => [currentIndex];
// }

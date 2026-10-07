part of 'ranking_bloc.dart';

abstract class RankingEvents extends Equatable {
  const RankingEvents();
  @override
  List<Object?> get props => [];
}

class FetchDiamondsHourEvent extends RankingEvents {
  const FetchDiamondsHourEvent();
}

class FetchDiamondsDayEvent extends RankingEvents {
  const FetchDiamondsDayEvent();
}

class FetchDiamondsWeeklyEvent extends RankingEvents {
  const FetchDiamondsWeeklyEvent();
}

class FetchDiamondsMonthlyEvent extends RankingEvents {
  const FetchDiamondsMonthlyEvent();
}

class FetchCoinsHourEvent extends RankingEvents {
  const FetchCoinsHourEvent();
}

class FetchCoinsDayEvent extends RankingEvents {
  const FetchCoinsDayEvent();
}

class FetchCoinsWeeklyEvent extends RankingEvents {
  const FetchCoinsWeeklyEvent();
}

class FetchCoinsMonthlyEvent extends RankingEvents {
  const FetchCoinsMonthlyEvent();
}

class FetchCpDayEvent extends RankingEvents {
  const FetchCpDayEvent();
}

class FetchCpWeeklyEvent extends RankingEvents {
  const FetchCpWeeklyEvent();
}

class FetchCpMonthlyEvent extends RankingEvents {
  const FetchCpMonthlyEvent();
}

class FetchGamersHourEvent extends RankingEvents {
  const FetchGamersHourEvent();
}

class FetchGamersDayEvent extends RankingEvents {
  const FetchGamersDayEvent();
}

class FetchGamersWeeklyEvent extends RankingEvents {
  const FetchGamersWeeklyEvent();
}

class FetchGamersMonthlyEvent extends RankingEvents {
  const FetchGamersMonthlyEvent();
}

class FetchRoomsDayEvent extends RankingEvents {
  const FetchRoomsDayEvent();
}

class FetchRoomWeeklyEvent extends RankingEvents {
  const FetchRoomWeeklyEvent();
}

class FetchRoomHourEvent extends RankingEvents {
  const FetchRoomHourEvent();
}

class FetchRoomMonthlyEvent extends RankingEvents {
  const FetchRoomMonthlyEvent();
}

class FetchAgencyHourEvent extends RankingEvents {
  const FetchAgencyHourEvent();
}

class FetchAgencyDayEvent extends RankingEvents {
  const FetchAgencyDayEvent();
}

class FetchAgencyWeeklyEvent extends RankingEvents {
  const FetchAgencyWeeklyEvent();
}

class FetchAgencyMonthlyEvent extends RankingEvents {
  const FetchAgencyMonthlyEvent();
}

class FetchLuckyHourEvent extends RankingEvents {
  const FetchLuckyHourEvent();
}

class FetchLuckyDayEvent extends RankingEvents {
  const FetchLuckyDayEvent();
}

class FetchLuckyWeeklyEvent extends RankingEvents {
  const FetchLuckyWeeklyEvent();
}

class FetchLuckyMonthlyEvent extends RankingEvents {
  const FetchLuckyMonthlyEvent();
}

class HandleInfoCurrentRankEvent extends RankingEvents {
  final int currentIndex;

  const HandleInfoCurrentRankEvent({required this.currentIndex});

  @override
  List<Object> get props => [currentIndex];
}

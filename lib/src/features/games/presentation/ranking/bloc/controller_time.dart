// import 'dart:async';
// import 'package:general/src/features/games/presentation/ranking/components/rank_timer.dart';

// class RankTimeController {
//   // Private constructor
//   RankTimeController._privateConstructor();

//   // Singleton instance
//   static final RankTimeController _instance =
//       RankTimeController._privateConstructor();

//   // Getter to access the single instance
//   static RankTimeController get instance => _instance;

//   // Stream subscriptions
//   StreamSubscription<Duration>? dailyStreamSubscription;
//   StreamSubscription<Duration>? weeklyStreamSubscription;
//   StreamSubscription<Duration>? monthlyStreamSubscription;

//   void onUpdateDailyTimeLeft() {
//     dailyStreamSubscription?.cancel();
//     dailyStreamSubscription = Stream.periodic(const Duration(seconds: 1), (_) {
//       final nowUtc = DateTime.now().toUtc();
//       DateTime targetTime;
//       if (nowUtc.hour >= 22) {
//         targetTime = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, 24);
//       } else {
//         targetTime = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day + 1);
//       }
//       final timeLeft = targetTime.difference(nowUtc);
//       return timeLeft;
//     }).listen((updatedState) {
//       RankTimer.hoursNotifier.value = updatedState.inHours;
//       RankTimer.secondNotifier.value = updatedState.inSeconds % 60;
//       RankTimer.minuteNotifier.value = updatedState.inMinutes % 60;
//     });
//   }

//   void onUpdateWeeklyTimeLeft() async {
//     weeklyStreamSubscription?.cancel();
//     weeklyStreamSubscription = Stream.periodic(const Duration(seconds: 1), (_) {
//       final nowUtc = DateTime.now().toUtc();
//       DateTime targetTime;
//       int daysUntilSaturday;
//       if (nowUtc.weekday <= DateTime.friday) {
//         daysUntilSaturday = DateTime.friday - nowUtc.weekday;
//       } else {
//         daysUntilSaturday = 7 - nowUtc.weekday + DateTime.friday;
//       }
//       if (nowUtc.hour >= 22) {
//         targetTime = DateTime.utc(
//           nowUtc.year,
//           nowUtc.month,
//           nowUtc.day + daysUntilSaturday,
//           24,
//         );
//       } else {
//         targetTime = DateTime.utc(
//           nowUtc.year,
//           nowUtc.month,
//           nowUtc.day + daysUntilSaturday + 1,
//         );
//       }

//       final timeLeft = targetTime.difference(nowUtc);

//       return timeLeft;
//     }).listen((updatedState) {
//       RankTimer.daysWeeklyNotifier.value = updatedState.inDays;
//     });
//   }

//   void onUpdateMonthlyTimeLeft() async {
//     monthlyStreamSubscription?.cancel();
//     monthlyStreamSubscription =
//         Stream.periodic(const Duration(seconds: 1), (_) {
//       final nowUtc = DateTime.now().toUtc();
//       DateTime targetTime;
//       if (nowUtc.hour >= 22) {
//         targetTime = DateTime.utc(nowUtc.year, nowUtc.month + 1, 1, 24);
//       } else {
//         targetTime = DateTime.utc(nowUtc.year, nowUtc.month + 1, 1);
//       }
//       final timeLeft = targetTime.difference(nowUtc);

//       return timeLeft;
//     }).listen((updatedState) {
//       RankTimer.daysMonthlyNotifier.value = updatedState.inDays;
//     });
//   }

//   void dispose() {
//     dailyStreamSubscription?.cancel();
//     weeklyStreamSubscription?.cancel();
//     monthlyStreamSubscription?.cancel();
//   }
// }

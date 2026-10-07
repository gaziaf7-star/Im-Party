import 'package:equatable/equatable.dart';

class EarnInviteEntity extends Equatable {
  final int totalEarned;
  final int dayEarned;
  final int totalInvited;
  final int dayInvited;

  /// Commission percentage applied on the invitee's charges (earn_from_invitation).
  final int commissionPercent;

  /// Accumulated commission balance that can be manually extracted to the wallet.
  final int claimableIncome;

  /// One-time invitee join bonus the user can still claim (0 when none/claimed).
  final int claimableBonus;

  /// Maximum coins that can be extracted per request (default 50000).
  final int withdrawalLimit;

  const EarnInviteEntity({
    required this.totalEarned,
    required this.dayEarned,
    required this.totalInvited,
    required this.dayInvited,
    this.commissionPercent = 0,
    this.claimableIncome = 0,
    this.claimableBonus = 0,
    this.withdrawalLimit = 50000,
  });

  @override
  List<Object> get props => [
        totalEarned,
        dayEarned,
        totalInvited,
        dayInvited,
        commissionPercent,
        claimableIncome,
        claimableBonus,
        withdrawalLimit,
      ];
}

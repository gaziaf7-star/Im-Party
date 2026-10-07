import 'package:general/src/features/setting/domain/entities/earn_invite_entity.dart';

class EarnInviteModel extends EarnInviteEntity {
  const EarnInviteModel({
    required super.totalEarned,
    required super.dayEarned,
    required super.totalInvited,
    required super.dayInvited,
    super.commissionPercent,
    super.claimableIncome,
    super.claimableBonus,
    super.withdrawalLimit,
  });

  /// Maps the unified `GET /invitations/summary` response (see
  /// UserService::getInvitationSummary) onto the entity. The backend keys are
  /// the source of truth; figures arrive as numbers (possibly with decimals),
  /// so parsing tolerates both `5` and `5.0`.
  factory EarnInviteModel.fromMap(Map<String, dynamic> map) {
    int parseValue(dynamic value, [int fallback = 0]) {
      if (value == null) return fallback;
      if (value is num) return value.round();
      return num.tryParse(value.toString())?.round() ?? fallback;
    }

    return EarnInviteModel(
      totalEarned: parseValue(map['total_earned']),
      dayEarned: parseValue(map['day_earned']),
      totalInvited: parseValue(map['total_invited']),
      dayInvited: parseValue(map['day_invited']),
      commissionPercent: parseValue(map['commission_percent']),
      claimableIncome: parseValue(map['extractable_now']),
      claimableBonus: parseValue(map['invitee_bonus']),
      withdrawalLimit: parseValue(map['withdrawal_limit'], 50000),
    );
  }
}

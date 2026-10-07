import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/entities/lucky_gift_entity.dart';

class LuckyGiftModel extends LuckyGiftEntity {
  const LuckyGiftModel({
    super.giftImage,
    super.giftName,
    super.receiverName,
    super.senderId,
    super.senderName,
    super.senderImg,
    super.position,
    super.receiversId,
    super.combo,
    super.giftPrice,
    super.userCoins,
    super.giftNum,
    super.giftPriceT,
    super.winTimes,
    super.totalWin,
    super.totalPk,
  });

  factory LuckyGiftModel.fromJson(Map<String, dynamic> json) {
    final combo = json['combo'] is List
        ? List<Combo>.from((json['combo'] as List).whereType<Map<String, dynamic>>().map((e) => Combo.fromJson(e)))
        : <Combo>[];

    // Real biggest single-win multiplier of this request (server-sent per hit).
    // cashback_percentage was the SUM of multipliers across the combo — two 5x
    // wins displayed as a 10x banner. Old responses without win_multiplier
    // fall back to the legacy field.
    int maxMultiplier = 0;
    for (final c in combo) {
      final m = c.data?.winMultiplier ?? 0;
      if (m > maxMultiplier) maxMultiplier = m;
    }

    return LuckyGiftModel(
      giftImage: parseValue<String>(json['gift_image'], ''),
      giftName: parseValue<String>(json['gift_name'], ''),
      receiverName: parseValue<String>(json['receiver_name'], ''),
      senderId: parseValue<int>(json['sender_id'], 0),
      senderName: parseValue<String>(json['sender_name'], ''),
      senderImg: parseValue<String>(json['sender_img'], ''),
      giftPrice: parseValue<String>(json['session']?.toString(), ''),
      winTimes: maxMultiplier > 0
          ? maxMultiplier
          : parseValue<int>(json['cashback_percentage'], 0),
      totalWin: parseValue<int>(
          json['win_total'] ?? json['total_user_win'], 0),
      // charged_total = the ACTUAL deduction (server now promises == charges).
      giftPriceT: parseValue<int>(
          json['charged_total'] ?? json['total_price'], 0),
      totalPk: parseValue<int>(json['total_pk'], 0),
      // changed from 'session' to 'gift_price'
      userCoins: parseValue<String>(json['user_coins']?.toString(), ''),
      position: json['position'] != null
          ? parseValue<List<int>>(
              json['position'],
              <int>[],
            )
          : null,
      receiversId: json['receivers_ids'] != null
          ? parseValue<List<String>>(
              json['receivers_ids'],
              <String>[],
            )
          : null,

      giftNum: parseValue<int>(json['gift_num'], 0),
      combo: combo,
    );
  }
}

class Combo extends ComboEntity {
  const Combo({super.status, super.data, super.errorMessage});

  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      status: parseValue<int>(json['status'], 0),
      data: json['data'] is Map<String, dynamic> ? WinData.fromJson(json['data']) : null,
      errorMessage: parseValue<String>(json['error_message'], ''),
    );
  }
}

class WinData extends WinDataEntity {
  const WinData(
      {super.winCoins,
      super.isWin,
      super.winMultiplier,
      super.isPopular,
      super.commentMessage,
      super.winnerMessage});

  factory WinData.fromJson(Map<String, dynamic> json) {
    return WinData(
      winCoins: parseValue<int>(json['win_coins'], 0),
      isWin: parseValue<bool>(json['is_win'], false),
      winMultiplier: parseValue<int>(json['win_multiplier'], 0),
      isPopular: parseValue<bool>(json['is_popular'], false),
      commentMessage: parseValue<String>(json['comment_message'], ''),
      winnerMessage: parseValue<String>(json['winner_comment'], ''),
    );
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/domain/entities/coin_seller_entity.dart';

class CoinSellerModel extends CoinSellerEntity {
  const CoinSellerModel({
    super.id,
    super.uuid,
    super.name,
    super.whatsapp,
    super.phone,
    super.avatar,
    super.bio,
  });

  factory CoinSellerModel.fromJson(Map<String, dynamic> json) {
    return CoinSellerModel(
      id: parseValue<int>(json['id'], 0),
      uuid: parseValue<String>(json['uuid'], ''),
      name: parseValue<String>(json['name'], ''),
      whatsapp: parseValue<String>(json['whatsapp'], ''),
      phone: parseValue<String>(json['phone'], ''),
      avatar: parseValue<String>(
        json['avatar'] ?? json['img_1'] ?? json['image'],
        '',
      ),
      bio: parseValue<String>(json['bio'], ''),
    );
  }
}

class CoinSellerProfileModel extends CoinSellerProfileEntity {
  const CoinSellerProfileModel({
    super.sellerBalance,
    super.coinBalance,
    super.totalTransferred,
    super.todayTransferred,
  });

  factory CoinSellerProfileModel.fromJson(Map<String, dynamic> json) {
    final rawStats = json['stats'];

    final stats = rawStats is Map
        ? rawStats.map(
          (key, value) => MapEntry(
        key.toString(),
        value,
      ),
    )
        : <String, dynamic>{};

    return CoinSellerProfileModel(
      sellerBalance: _toNumber(
        json['seller_balance'] ?? json['balance'],
      ),
      coinBalance: _toNumber(
        json['coin_balance'] ?? json['coins'],
      ),

      // Current backend response:
      // stats.total_transferred_coins
      totalTransferred: _toNumber(
        json['total_transferred'] ??
            json['total_transfer'] ??
            stats['total_transferred_coins'],
      ),

      // Current backend response:
      // stats.today_transferred_coins
      todayTransferred: _toNumber(
        json['today_transferred'] ??
            json['today_transfer'] ??
            stats['today_transferred_coins'],
      ),
    );
  }
}

class CoinSellerHistoryItemModel extends CoinSellerHistoryItemEntity {
  const CoinSellerHistoryItemModel({
    super.id,
    super.recipientId,
    super.recipientName,
    super.recipientAvatar,
    super.amount,
    super.note,
    super.createdAt,
  });

  factory CoinSellerHistoryItemModel.fromJson(
      Map<String, dynamic> json,
      ) {
    // Current history API sends recipient info inside "user".
    // Older builds may use "recipient", so support both.
    final rawRecipient = json['user'] ?? json['recipient'];

    final recipient = rawRecipient is Map
        ? rawRecipient.map(
          (key, value) => MapEntry(
        key.toString(),
        value,
      ),
    )
        : <String, dynamic>{};

    // IMPORTANT:
    // Use the PUBLIC user ID first (uuid/original_uuid).
    // Do not show the database id (e.g. 19) when the real public ID is 5000.
    final publicId =
        recipient['uuid'] ??
            recipient['original_uuid'] ??
            json['recipient_uuid'] ??
            json['user_uuid'] ??
            json['uuid'] ??
            recipient['id'] ??
            json['user_id'];

    return CoinSellerHistoryItemModel(
      id: parseValue<int>(json['id'], 0),
      recipientId: publicId?.toString() ?? '',
      recipientName: parseValue<String>(
        recipient['name'] ??
            recipient['nickname'] ??
            json['recipient_name'],
        '',
      ),
      recipientAvatar: parseValue<String>(
        recipient['avatar'] ??
            recipient['img_1'] ??
            recipient['profile_image'] ??
            recipient['image'] ??
            json['recipient_avatar'],
        '',
      ),

      // API can return "2555.00" as a String.
      amount: _toNumber(json['amount']),

      note: parseValue<String>(
        json['note'],
        '',
      ),
      createdAt: parseValue<String>(
        json['created_at'] ?? json['date'],
        '',
      ),
    );
  }
}

num _toNumber(dynamic value) {
  if (value is num) return value;

  final parsed = num.tryParse(
    value?.toString().trim() ?? '',
  );

  return parsed ?? 0;
}

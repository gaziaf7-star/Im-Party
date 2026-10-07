import 'package:equatable/equatable.dart';

/// One entry in the public Coin Seller directory
/// (`GET /api/v1/coin-seller/list`) -- an active seller a user can contact
/// (WhatsApp/phone) to buy coins from outside the app's own recharge flow.
class CoinSellerEntity extends Equatable {
  final int? id;
  final String? uuid;
  final String? name;
  final String? whatsapp;
  final String? phone;
  final String? avatar;
  final String? bio;

  const CoinSellerEntity({
    this.id,
    this.uuid,
    this.name,
    this.whatsapp,
    this.phone,
    this.avatar,
    this.bio,
  });

  @override
  List<Object?> get props => [id, uuid, name, whatsapp, phone, avatar, bio];
}

/// A signed-in seller's own dashboard stats
/// (`GET /api/v1/coin-seller/profile`): their remaining seller balance
/// (what they can still transfer out), their own coin balance, and how much
/// they've transferred in total / today.
class CoinSellerProfileEntity extends Equatable {
  final dynamic sellerBalance;
  final dynamic coinBalance;
  final dynamic totalTransferred;
  final dynamic todayTransferred;

  const CoinSellerProfileEntity({
    this.sellerBalance,
    this.coinBalance,
    this.totalTransferred,
    this.todayTransferred,
  });

  @override
  List<Object?> get props =>
      [sellerBalance, coinBalance, totalTransferred, todayTransferred];
}

/// One row of a seller's past transfers
/// (`GET /api/v1/coin-seller/history`) -- who they sent coins/diamonds to,
/// how much, and when.
class CoinSellerHistoryItemEntity extends Equatable {
  final int? id;
  final String? recipientId;
  final String? recipientName;
  final String? recipientAvatar;
  final dynamic amount;
  final String? note;
  final String? createdAt;

  const CoinSellerHistoryItemEntity({
    this.id,
    this.recipientId,
    this.recipientName,
    this.recipientAvatar,
    this.amount,
    this.note,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    recipientId,
    recipientName,
    recipientAvatar,
    amount,
    note,
    createdAt,
  ];
}
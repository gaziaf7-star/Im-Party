import 'package:general/src/core/index.dart';

num _number(dynamic value) =>
    value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;
int _id(dynamic value) => _number(value).toInt();
Map<String, dynamic> _map(dynamic value) => value is Map
    ? value.map((key, value) => MapEntry(key.toString(), value))
    : <String, dynamic>{};

class WithdrawSystemStatus extends Equatable {
  const WithdrawSystemStatus({required this.isOn});
  final bool isOn;

  factory WithdrawSystemStatus.fromJson(dynamic json) {
    if (json is bool) return WithdrawSystemStatus(isOn: json);
    if (json is num) return WithdrawSystemStatus(isOn: json != 0);
    final map = _map(json);
    final raw = map['is_withdraw_system_on'];
    return WithdrawSystemStatus(isOn: raw == true || raw == 1 || raw?.toString() == '1' || raw?.toString().toLowerCase() == 'true');
  }

  @override
  List<Object?> get props => [isOn];
}

class WithdrawMethod extends Equatable {
  const WithdrawMethod({
    required this.id,
    required this.name,
    required this.details,
    required this.minimumCoin,
    required this.maximumCoin,
  });
  final int id;
  final String name;
  final String details;
  final num minimumCoin;
  final num maximumCoin;

  factory WithdrawMethod.fromJson(dynamic json) {
    final map = _map(json);
    return WithdrawMethod(
      id: _id(map['id']),
      name: map['name']?.toString() ?? '',
      details: map['details']?.toString() ?? '',
      minimumCoin: _number(map['minimum_coin']),
      maximumCoin: _number(map['maximum_coin']),
    );
  }

  @override
  List<Object?> get props => [id, name, details, minimumCoin, maximumCoin];
}

class UserPaymentMethod extends Equatable {
  const UserPaymentMethod({
    required this.id,
    required this.userId,
    required this.methodName,
    required this.methodAccount,
  });
  final int id;
  final int userId;
  final String methodName;
  final String methodAccount;

  factory UserPaymentMethod.fromJson(dynamic json) {
    final map = _map(json);
    return UserPaymentMethod(
      id: _id(map['id']),
      userId: _id(map['user_id']),
      methodName: map['method_name']?.toString() ?? '',
      methodAccount: map['method_account']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, userId, methodName, methodAccount];
}

class WithdrawUser extends Equatable {
  const WithdrawUser({
    this.id = 0,
    this.name = '',
    this.image = '',
    this.publicId = '',
  });
  final int id;
  final String name;
  final String image;

  // The user-facing ID shown across the app (profile screens, mentions,
  // etc.) is `uuid`/`unique_id`/`user_id` — a separate, stable-looking
  // string distinct from `id`, which is just the row's internal DB primary
  // key and was never meant to be shown to users.
  final String publicId;

  /// The ID to show on screen: the public one, or the row id as a fallback.
  String get displayId => publicId.isNotEmpty ? publicId : '$id';

  factory WithdrawUser.fromJson(dynamic json) {
    final map = _map(json);
    // The full user object (e.g. the raw `reseller_list` rows) carries the
    // avatar nested under `profile.avatar` rather than a top-level field.
    final profile = _map(map['profile']);
    return WithdrawUser(
      id: _id(map['id'] ?? map['user_id']),
      name: map['name']?.toString() ?? '',
      image: (map['image'] ?? map['avatar'] ?? map['img_1'] ?? profile['avatar'])
              ?.toString() ??
          '',
      publicId:
          (map['uuid'] ?? map['unique_id'] ?? map['user_id'])?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, image, publicId];
}

class WithdrawHistoryItem extends Equatable {
  const WithdrawHistoryItem({
    required this.id,
    required this.amount,
    required this.status,
    required this.receivedType,
    required this.methodName,
    required this.methodAccount,
    required this.createdAt,
    this.user,
  });
  final int id;
  final num amount;
  final String status;
  final String receivedType;
  final String methodName;
  final String methodAccount;
  final String createdAt;
  final WithdrawUser? user;

  factory WithdrawHistoryItem.fromJson(dynamic json) {
    final map = _map(json);
    // The saved payment method (bKash/Nagad/... + number) can arrive as a
    // nested relation under several names, or flat on the row.
    final payment = _map(map['payment_method'] ??
        map['paymentMethod'] ??
        map['user_payment_method'] ??
        map['userPaymentMethod'] ??
        map['payment'] ??
        (map['method'] is Map ? map['method'] : null));
    String? pick(Map<String, dynamic> m, List<String> keys) {
      for (final k in keys) {
        final v = m[k]?.toString().trim() ?? '';
        if (v.isNotEmpty && v != 'null') return v;
      }
      return null;
    }

    const nameKeys = ['method_name', 'name', 'type', 'method_type'];
    const accountKeys = [
      'method_account',
      'account',
      'account_number',
      'number',
      'phone',
      'wallet_number',
    ];
    final user = map['user'] ?? map['requester'];
    return WithdrawHistoryItem(
      id: _id(map['id']),
      amount: _number(map['amount']),
      status: map['status']?.toString() ?? '',
      receivedType: map['received_type']?.toString() ?? '',
      methodName: pick(map, ['method_name']) ??
          pick(payment, nameKeys) ??
          (map['method'] is String ? map['method'] as String : ''),
      methodAccount:
          pick(map, ['method_account', 'account_number', 'number']) ??
              pick(payment, accountKeys) ??
              '',
      createdAt: (map['created_at'] ?? map['date'])?.toString() ?? '',
      user: user is Map ? WithdrawUser.fromJson(user) : null,
    );
  }

  @override
  List<Object?> get props => [id, amount, status, receivedType, methodName, methodAccount, createdAt, user];
}

class WithdrawReseller extends WithdrawUser {
  const WithdrawReseller({
    super.id,
    super.name,
    super.image,
    super.publicId,
    this.whatsappNumber = '',
  });
  final String whatsappNumber;

  bool get hasWhatsapp => whatsappNumber.isNotEmpty;

  factory WithdrawReseller.fromJson(dynamic json) {
    final map = _map(json);
    final source = map['user'] ?? map['reseller'] ?? json;
    final user = WithdrawUser.fromJson(source);
    final sourceMap = _map(source);
    return WithdrawReseller(
      id: user.id,
      name: user.name,
      image: user.image,
      publicId: user.publicId,
      whatsappNumber: _whatsapp(sourceMap),
    );
  }

  // Backend sends this field inconsistently — sometimes a clean international
  // number, sometimes a bare local number prefixed with a literal "N/A"
  // (seen live as "N/A01778094160"), sometimes null. Strip anything that
  // isn't a digit or a leading '+' so a wa.me link never breaks on it.
  static String _whatsapp(Map<String, dynamic> map) {
    final raw = (map['whatsapp_number'] ?? map['whatsapp'])?.toString() ?? '';
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    return digits.replaceAll(RegExp(r'\++'), '+');
  }

  @override
  List<Object?> get props => [id, name, image, whatsappNumber, publicId];
}

class WithdrawCreateResponse extends Equatable {
  const WithdrawCreateResponse({required this.message, required this.earnedCoins});
  final String message;
  final num? earnedCoins;

  factory WithdrawCreateResponse.fromJson(dynamic json) {
    final map = _map(json);
    final data = _map(map['data']);
    final raw = data['earned_coins'] ?? map['earned_coins'];
    return WithdrawCreateResponse(
      message: map['message']?.toString() ?? '',
      earnedCoins: raw == null ? null : _number(raw),
    );
  }

  @override
  List<Object?> get props => [message, earnedCoins];
}

class WithdrawPage<T> extends Equatable {
  const WithdrawPage({required this.items, this.currentPage = 1, this.lastPage = 1});
  final List<T> items;
  final int currentPage;
  final int lastPage;
  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [items, currentPage, lastPage];
}

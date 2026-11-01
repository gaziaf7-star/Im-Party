import 'package:general/src/core/index.dart';

num _num(dynamic v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;
String _str(dynamic v) {
  final s = v?.toString().trim() ?? '';
  return s == 'null' ? '' : s;
}

Map<String, dynamic> _map(dynamic v) => v is Map
    ? v.map((key, value) => MapEntry(key.toString(), value))
    : <String, dynamic>{};

/// The list inside a response: `data` itself, or `data.<key>` (the server
/// wraps them, e.g. `data.methods`), or a paginated `data.data`.
List<dynamic> manualPaymentList(dynamic body, String key) {
  final data = body is Map ? body['data'] : body;
  if (data is List) return data;
  if (data is Map) {
    for (final k in [key, 'data', 'items', 'list']) {
      final v = data[k];
      if (v is List) return v;
      if (v is Map && v['data'] is List) return v['data'] as List;
    }
  }
  return const [];
}

/// A gateway the user pays into (bKash, Nagad, Bank...).
class ManualPaymentMethod extends Equatable {
  const ManualPaymentMethod({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.accountType,
    required this.qrCodeUrl,
    required this.instructions,
    required this.logo,
  });

  final int id;
  final String name;
  final String accountNumber;
  final String accountType;
  final String qrCodeUrl;
  final String instructions;
  final String logo;

  factory ManualPaymentMethod.fromJson(dynamic json) {
    final m = _map(json);
    return ManualPaymentMethod(
      id: _num(m['id']).toInt(),
      name: _str(m['name']),
      accountNumber: _str(m['account_number'] ?? m['number']),
      accountType: _str(m['account_type']),
      qrCodeUrl:
          EndPoints.getImage(_str(m['qr_code_url'] ?? m['qr_code'] ?? m['qr'])),
      instructions: _str(m['instructions']),
      logo: EndPoints.getImage(_str(m['logo'] ?? m['image'] ?? m['icon'])),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, accountNumber, accountType, qrCodeUrl, instructions, logo];
}

/// A coin bundle the user can buy manually.
class ManualPaymentPackage extends Equatable {
  const ManualPaymentPackage({
    required this.id,
    required this.name,
    required this.coins,
    required this.bonusCoins,
    required this.totalCoins,
    required this.price,
    required this.currency,
    this.targetType = 'user',
  });

  final int id;
  final String name;
  /// Who may buy this package: 'user' or a coin-seller value.
  final String targetType;
  final int coins;
  final int bonusCoins;
  final int totalCoins;
  final num price;
  final String currency;

  factory ManualPaymentPackage.fromJson(dynamic json) {
    final m = _map(json);
    final coins = _num(m['coins']).toInt();
    final bonus = _num(m['bonus_coins']).toInt();
    final total = _num(m['total_coins']).toInt();
    return ManualPaymentPackage(
      id: _num(m['id']).toInt(),
      name: _str(m['name']),
      coins: coins,
      bonusCoins: bonus,
      totalCoins: total > 0 ? total : coins + bonus,
      price: _num(m['price']),
      currency: _str(m['currency']).isEmpty ? 'BDT' : _str(m['currency']),
      targetType: _str(m['target_type']).isEmpty
          ? 'user'
          : _str(m['target_type']).toLowerCase(),
    );
  }

  /// True when the package is meant for coin sellers.
  bool get isForCoinSeller =>
      const {'coinseller', 'coin_seller', 'seller'}.contains(targetType);

  @override
  List<Object?> get props =>
      [id, name, targetType, coins, bonusCoins, totalCoins, price, currency];
}

/// One submitted manual-recharge request.
class ManualPaymentHistoryItem extends Equatable {
  const ManualPaymentHistoryItem({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.coins,
    required this.senderNumber,
    required this.userTrxId,
    required this.screenshotUrl,
    required this.status,
    required this.adminNote,
    required this.createdAt,
    required this.methodName,
  });

  final int id;
  final String transactionId;
  final num amount;
  final String currency;
  final int coins;
  final String senderNumber;
  final String userTrxId;
  final String screenshotUrl;

  /// pending, approved or rejected.
  final String status;
  final String adminNote;
  final String createdAt;
  final String methodName;

  factory ManualPaymentHistoryItem.fromJson(dynamic json) {
    final m = _map(json);
    final method = m['method'];
    return ManualPaymentHistoryItem(
      id: _num(m['id']).toInt(),
      transactionId: _str(m['transaction_id']),
      amount: _num(m['amount']),
      currency: _str(m['currency']).isEmpty ? 'BDT' : _str(m['currency']),
      coins: _num(m['coins'] ?? m['total_coins']).toInt(),
      senderNumber: _str(m['sender_number']),
      userTrxId: _str(m['user_trx_id']),
      screenshotUrl: EndPoints.getImage(
          _str(m['screenshot_url'] ?? m['screenshot'])),
      status: _str(m['status']).toLowerCase().isEmpty
          ? 'pending'
          : _str(m['status']).toLowerCase(),
      adminNote: _str(m['admin_note']),
      createdAt: _str(m['created_at']),
      methodName: method is Map
          ? _str(method['name'])
          : _str(m['method_name'] ?? method),
    );
  }

  @override
  List<Object?> get props => [
        id,
        transactionId,
        amount,
        currency,
        coins,
        senderNumber,
        userTrxId,
        screenshotUrl,
        status,
        adminNote,
        createdAt,
        methodName,
      ];
}

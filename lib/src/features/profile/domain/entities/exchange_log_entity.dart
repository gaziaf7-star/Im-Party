import 'package:equatable/equatable.dart';

/// One row of `GET /wallets/exchange/logs` -- a past diamond -> coin
/// exchange. Field names on the real response weren't part of the spec
/// shared for this feature, so the model parsing this accepts several
/// likely key spellings (see ExchangeLogModel.fromJson).
class ExchangeLogItemEntity extends Equatable {
  final int id;
  final num diamonds;
  final num exchange;
  final String? date;
  final String? status;

  const ExchangeLogItemEntity({
    required this.id,
    required this.diamonds,
    required this.exchange,
    this.date,
    this.status,
  });

  @override
  List<Object?> get props => [id, diamonds, exchange, date, status];
}

class ExchangeLogEntity extends Equatable {
  final List<ExchangeLogItemEntity> data;

  const ExchangeLogEntity({required this.data});

  @override
  List<Object?> get props => [data];
}
import 'package:general/src/core/index.dart';

class MyHostsAgencyEntity extends Equatable {
  final int? id;
  final String? name;
  final String? notice;
  final String? img;
  final int? memberCount;
  final List<String>? topStars;

  const MyHostsAgencyEntity({
    this.id,
    this.name,
    this.notice,
    this.img,
    this.memberCount,
    this.topStars,
  });

  @override
  List<Object?> get props => [name, notice, img, id, memberCount, topStars];
}

class MyShippingAgencyEntity extends Equatable {
  final int? id;
  final String? name;
  final String? img;
  final int? successTransaction;

  const MyShippingAgencyEntity({
    this.id,
    this.name,
    this.img,
    this.successTransaction,
  });

  @override
  List<Object?> get props => [name, img, id, successTransaction];
}

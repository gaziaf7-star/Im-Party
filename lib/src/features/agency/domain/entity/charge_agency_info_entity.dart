import 'package:equatable/equatable.dart';
import 'package:general/src/features/auth/auth.dart';


class ChargeAgencyInfoEntity extends Equatable {
  final int? id;
  final String? name;
  final String? notice;
  final int? status;
  final int? usd;
  final int? coins;
  final String? phone;
  final String? url;
  final String? img;
  final String? contents;
  final List<PaymentsGetwaysEntity>? payments;
  final List<CountryEntity>? countries;
  final OwnerEntity? owner;

  const ChargeAgencyInfoEntity({
    this.id,
    this.name,
    this.notice,
    this.status,
    this.usd,
    this.coins,
    this.phone,
    this.url,
    this.img,
    this.contents,
    this.payments,
    this.countries,
    this.owner,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    notice,
    status,
    usd,
    coins,
    phone,
    url,
    img,
    contents,
    payments,
    countries,
    owner,
  ];

  ChargeAgencyInfoEntity copyWith({
    int? id,
    String? name,
    String? notice,
    int? status,
    int? usd,
    int? coins,
    String? phone,
    String? url,
    String? img,
    String? contents,
    List<PaymentsGetwaysEntity>? payments,
    List<CountryEntity>? countries,
  }) {
    return ChargeAgencyInfoEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      notice: notice ?? this.notice,
      status: status ?? this.status,
      usd: usd ?? this.usd,
      coins: coins ?? this.coins,
      phone: phone ?? this.phone,
      url: url ?? this.url,
      img: img ?? this.img,
      contents: contents ?? this.contents,
      payments: payments ?? this.payments,
      countries: countries ?? this.countries,
    );
  }
}


class PaymentsGetwaysEntity extends Equatable {
  final int? id;
  final String? name;
  final String? photo;
  final bool? isSelected;

  const PaymentsGetwaysEntity({
    this.id,
    this.name,
    this.photo,
    this.isSelected,
  });

  @override
  List<Object?> get props => [id, name, photo, isSelected];

  PaymentsGetwaysEntity copyWith({
    int? id,
    String? name,
    String? photo,
    bool? isSelected,
  }) {
    return PaymentsGetwaysEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
class OwnerEntity extends Equatable {
  final int? id;
  final String? name;
  final String? uuid;
  final String? image;
  final bool? hasColorName;

  const OwnerEntity({
    this.id,
    this.name,
    this.uuid,
    this.image,
    this.hasColorName,
  });

  @override
  List<Object?> get props => [id, name, image, uuid,hasColorName];


}


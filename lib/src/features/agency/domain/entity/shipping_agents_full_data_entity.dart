import 'package:equatable/equatable.dart';
import 'package:general/src/features/agency/domain/entity/charge_agency_info_entity.dart';
import 'package:general/src/features/auth/auth.dart';

class ShippingAgentsFullDataEntity extends Equatable {
  final int? id;
  final int? ownerId;
  final String? name;
  final String? ownerName;
  final String? ownerImage;
  final String? phone;
  final String? image;
  final String? uuid;
  final List<PaymentsGetwaysEntity>? paymentGetaway;
  final List<CountryEntity>? countries;
  final String? frame;
  final int? frameId;
  final int? level;
  final int? vip;
  final int? chargeCount;
  final String? idImage;
  final String? specialId;
  final int? status;
  final ImageColorEntity? imageColorEntity;

  const ShippingAgentsFullDataEntity({
    this.id,
    this.ownerId,
    this.ownerName,
    this.ownerImage,
    this.name,
    this.phone,
    this.image,
    this.uuid,
    this.paymentGetaway,
    this.countries,
    this.frame,
    this.frameId,
    this.level,
    this.vip,
    this.chargeCount,
    this.idImage,
    this.specialId,
    this.status,
    this.imageColorEntity,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        phone,
        image,
        uuid,
        paymentGetaway,
        countries,
        frame,
        frameId,
        level,
        vip,
        chargeCount,
        idImage,
        specialId,
        status,
        imageColorEntity
      ];

  ShippingAgentsFullDataEntity copyWith({
    int? id,
    String? name,
    String? phone,
    String? image,
    String? uuid,
    List<PaymentsGetwaysEntity>? paymentGetaway,
    List<CountryEntity>? countries,
    String? frame,
    int? frameId,
    int? level,
    int? vip,
    int? chargeCount,
    String? idImage,
    int? status,
    String? specialId,
  }) {
    return ShippingAgentsFullDataEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      uuid: uuid ?? this.uuid,
      paymentGetaway: paymentGetaway ?? this.paymentGetaway,
      countries: countries ?? this.countries,
      frame: frame ?? this.frame,
      frameId: frameId ?? this.frameId,
      level: level ?? this.level,
      vip: vip ?? this.vip,
      chargeCount: chargeCount ?? this.chargeCount,
      idImage: idImage ?? this.idImage,
      status: status ?? this.status,
      specialId: specialId ?? this.specialId,
    );
  }
}

part of 'get_charge_agency_bloc.dart';

abstract class BaseGetChargeAgencyEvent extends Equatable {
  const BaseGetChargeAgencyEvent();

  @override
  List<Object?> get props => [];
}

class GetChargeAgencyEvent extends BaseGetChargeAgencyEvent {
  final bool isFirstLoading;
final int? agencyId;
  const GetChargeAgencyEvent({
    this.isFirstLoading = false,
    this.agencyId ,
  });
}

class ChargeAgencyEditCoinsLocallyEvent extends BaseGetChargeAgencyEvent {
  final int coinsValue;

  const ChargeAgencyEditCoinsLocallyEvent({
    required this.coinsValue,
  });
}



class ChargeAgencyEditDollarsLocallyEvent extends BaseGetChargeAgencyEvent {
  final int dollarsValue;

  const ChargeAgencyEditDollarsLocallyEvent({
    required this.dollarsValue,
  });
}

class EditChargeAgencyLocallyEvent extends BaseGetChargeAgencyEvent {
  final ChargeAgencyInfoEntity? entity;

  const EditChargeAgencyLocallyEvent({
    required this.entity,
  });
}

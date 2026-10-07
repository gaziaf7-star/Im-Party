part of 'update_charge_agency_bloc.dart';

abstract class BaseUpdateChargeAgencyEvent extends Equatable {
  final BuildContext? context;

  const BaseUpdateChargeAgencyEvent({this.context});

  @override
  List<Object?> get props => [];
}

class UpdateChargeAgencyEvent extends BaseUpdateChargeAgencyEvent {
  final String? phone;
  final String? name;
  final int? appOwnerId;
  final int? agencyId;
  final File? image;
  final String? paymentIds;
  final String? countriesIds;
  final bool isFirstLoading;

  const UpdateChargeAgencyEvent(
      {super.context,
      this.image,
      this.appOwnerId,
      this.agencyId,
      this.name,
      this.phone,
      this.countriesIds,
      this.paymentIds,
      this.isFirstLoading = false});

  @override
  List<Object?> get props => [
        appOwnerId,
        agencyId,
        name,
        phone,
        countriesIds,
        paymentIds,
        context,
        isFirstLoading
      ];
}

class ShowCountriesEvent extends BaseUpdateChargeAgencyEvent {
  const ShowCountriesEvent();

  @override
  List<Object?> get props => [];
}
class ShowPaymentsEvent extends BaseUpdateChargeAgencyEvent {
  const ShowPaymentsEvent();

  @override
  List<Object?> get props => [];
}

class SelectCountryEvent extends BaseUpdateChargeAgencyEvent {
  final CountryEntity? country;
  final List<CountryEntity>? countryList;

  const SelectCountryEvent({required this.country,this.countryList});

  @override
  List<Object?> get props => [country];
}

class SelectPaymentEvent extends BaseUpdateChargeAgencyEvent {
  final PaymentsGetwaysEntity? payment;
  final List<PaymentsGetwaysEntity>? paymentList;

  const SelectPaymentEvent({required this.payment,this.paymentList});

  @override
  List<Object?> get props => [id];
}

class RemovePaymentSelectionEvent extends BaseUpdateChargeAgencyEvent {
  const RemovePaymentSelectionEvent();

  @override
  List<Object?> get props => [];
}

class RemoveCountrySelectionEvent extends BaseUpdateChargeAgencyEvent {
  const RemoveCountrySelectionEvent();

  @override
  List<Object?> get props => [];
}
class SetNameEvent extends BaseUpdateChargeAgencyEvent {
  final String name;
  const SetNameEvent({required this.name});

  @override
  List<Object?> get props => [];
}
class ControllerDisposeEvent extends BaseUpdateChargeAgencyEvent {
  const ControllerDisposeEvent();

  @override
  List<Object?> get props => [];
}
class UnPickImageEvent extends BaseUpdateChargeAgencyEvent {
  const UnPickImageEvent();

  @override
  List<Object?> get props => [];
}

// pick image
class PickImageEvent extends BaseUpdateChargeAgencyEvent {
  final ImageSource source;
  final String phone, id;

  const PickImageEvent({
    required this.source,
    required this.phone,
    required this.id,
  });

  @override
  List<Object> get props => [source, phone, id];
}

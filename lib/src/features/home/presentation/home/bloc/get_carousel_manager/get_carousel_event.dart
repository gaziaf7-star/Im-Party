part of 'get_carousel_bloc.dart';

sealed class GetCarouselEvent extends Equatable {
  const GetCarouselEvent();

  @override
  List<Object?> get props => [];
}

final class GetDiscoverCarouselEvent extends GetCarouselEvent {
  final bool isLoading;

  const GetDiscoverCarouselEvent({this.isLoading = true});

  @override
  List<Object?> get props => [isLoading];
}

final class GetHomeTopCarouselEvent extends GetCarouselEvent {
  final bool isLoading;

  const GetHomeTopCarouselEvent({this.isLoading = true});

  @override
  List<Object?> get props => [isLoading];
}

final class GetHomeMiddleCarouselEvent extends GetCarouselEvent {
  final bool isLoading;

  const GetHomeMiddleCarouselEvent({this.isLoading = true});

  @override
  List<Object?> get props => [isLoading];
}

final class GetLiveCarouselEvent extends GetCarouselEvent {
  final bool isLoading;

  const GetLiveCarouselEvent({this.isLoading = true});

  @override
  List<Object?> get props => [isLoading];
}

// 🆕 New Event
class GetCountryCarouselEvent extends GetCarouselEvent {
  final bool isLoading;
  final String countryId;

  const GetCountryCarouselEvent(
      {this.isLoading = true, required this.countryId});
}
class ResetCountryCarouselEvent extends GetCarouselEvent {


  const ResetCountryCarouselEvent(
      );
}

final class ChangeCarsouleIndex extends GetCarouselEvent {
  final int index;
  final String type;

  const ChangeCarsouleIndex({
    required this.index,
    required this.type,
  });
}

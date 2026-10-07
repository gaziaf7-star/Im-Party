part of 'get_carousel_bloc.dart';

class GetCarouselState extends Equatable {
  // 🟢 Discover
  final RequestState discoverState;
  final List<CarouselEntity> discoverCarousels;
  final String discoverError;

  // 🟢 Home Top
  final RequestState reqStateHomeTop;
  final List<CarouselEntity> homeTopCarousels;
  final String homeTopError;

  // 🟢 Home Middle
  final RequestState reqStateHomeMiddle;
  final List<CarouselEntity> homeMiddleCarousels;
  final String homeMiddleError;

  // 🟢 Live
  final RequestState liveState;
  final List<CarouselEntity> liveCarousels;
  final String liveError;

  // 🟢 Country Type
  final RequestState countryState;
  final List<CarouselEntity> countryCarousels;
  final String countryError;

  // 🟢 Indexes
  final int topHomeIndex;
  final int middleHomeIndex;

  const GetCarouselState({
    this.discoverState = RequestState.idle,
    this.discoverCarousels = const [],
    this.discoverError = '',
    this.reqStateHomeTop = RequestState.idle,
    this.homeTopCarousels = const [],
    this.homeTopError = '',
    this.reqStateHomeMiddle = RequestState.idle,
    this.homeMiddleCarousels = const [],
    this.homeMiddleError = '',
    this.liveState = RequestState.idle,
    this.liveCarousels = const [],
    this.liveError = '',
    this.countryState = RequestState.idle,
    this.countryCarousels = const [],
    this.countryError = '',
    this.topHomeIndex = 0,
    this.middleHomeIndex = 0,
  });

  @override
  List<Object?> get props => [
        discoverState,
        discoverCarousels,
        discoverError,
        reqStateHomeTop,
        homeTopCarousels,
        homeTopError,
        reqStateHomeMiddle,
        homeMiddleCarousels,
        homeMiddleError,
        liveState,
        liveCarousels,
        liveError,
        countryState,
        countryCarousels,
        countryError,
        topHomeIndex,
        middleHomeIndex,
      ];

  GetCarouselState copyWith({
    RequestState? discoverState,
    List<CarouselEntity>? discoverCarousels,
    String? discoverError,
    RequestState? reqStateHomeTop,
    List<CarouselEntity>? homeTopCarousels,
    String? homeTopError,
    RequestState? reqStateHomeMiddle,
    List<CarouselEntity>? homeMiddleCarousels,
    String? homeMiddleError,
    RequestState? liveState,
    List<CarouselEntity>? liveCarousels,
    String? liveError,
    RequestState? countryState,
    List<CarouselEntity>? countryCarousels,
    String? countryError,
    int? topHomeIndex,
    int? middleHomeIndex,
  }) {
    return GetCarouselState(
      discoverState: discoverState ?? this.discoverState,
      discoverCarousels: discoverCarousels ?? this.discoverCarousels,
      discoverError: discoverError ?? this.discoverError,
      reqStateHomeTop: reqStateHomeTop ?? this.reqStateHomeTop,
      homeTopCarousels: homeTopCarousels ?? this.homeTopCarousels,
      homeTopError: homeTopError ?? this.homeTopError,
      reqStateHomeMiddle: reqStateHomeMiddle ?? this.reqStateHomeMiddle,
      homeMiddleCarousels: homeMiddleCarousels ?? this.homeMiddleCarousels,
      homeMiddleError: homeMiddleError ?? this.homeMiddleError,
      liveState: liveState ?? this.liveState,
      liveCarousels: liveCarousels ?? this.liveCarousels,
      liveError: liveError ?? this.liveError,
      countryState: countryState ?? this.countryState,
      countryCarousels: countryCarousels ?? this.countryCarousels,
      countryError: countryError ?? this.countryError,
      topHomeIndex: topHomeIndex ?? this.topHomeIndex,
      middleHomeIndex: middleHomeIndex ?? this.middleHomeIndex,
    );
  }
}

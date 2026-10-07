import 'package:general/src/core/index.dart'; // Make sure this import path is correct.
import 'package:general/src/features/home/data/model/carousel_model.dart';

import '../../../../domain/entities/carousel_entity.dart';
import '../../../../domain/home_use_case/get_carousel_uc.dart';

part 'get_carousel_event.dart';

part 'get_carousel_state.dart';

class GetCarouselBloc extends Bloc<GetCarouselEvent, GetCarouselState> {
  final GetCarouselUc getCarouselUc;

  GetCarouselBloc({
    required this.getCarouselUc,
  }) : super(const GetCarouselState()) {
    on<GetDiscoverCarouselEvent>(_getDiscoverCarousel);
    on<GetHomeTopCarouselEvent>(_getHomeTopCarousel);
    on<GetHomeMiddleCarouselEvent>(_getHomeMiddleCarousel);
    on<GetLiveCarouselEvent>(_getLiveCarousel);
    on<GetCountryCarouselEvent>(_getCountryCarousel); // 🆕 added here
    on<ResetCountryCarouselEvent>(_resetCountryCarouselEvent); // 🆕 added here

    on<ChangeCarsouleIndex>((event, emit) {
      if (event.type == 'homeTop') {
        emit(state.copyWith(topHomeIndex: event.index));
      } else {
        emit(state.copyWith(middleHomeIndex: event.index));
      }
    });
  }

  Future<void> _getDiscoverCarousel(
    GetDiscoverCarouselEvent event,
    Emitter<GetCarouselState> emit,
  ) async {
    if (event.isLoading) {
      emit(state.copyWith(discoverState: RequestState.loading));
    }

    final result = await getCarouselUc(const CountryParams(type: 'discover'));
    result.fold(
      (failure) {
        emit(state.copyWith(
          discoverState: handleErrorResponse(failure),
          discoverError: NetworkExceptions.getErrorMessage(failure),
        ));
      },
      (success) {
        emit(state.copyWith(
          discoverState:
              handleLoadedResponse<List<CarouselModel>>(success.data),
          discoverCarousels: success.data ?? [],
        ));
      },
    );
  }

  Future<void> _getHomeTopCarousel(
    GetHomeTopCarouselEvent event,
    Emitter<GetCarouselState> emit,
  ) async {
    if (event.isLoading) {
      emit(state.copyWith(reqStateHomeTop: RequestState.loading));
    }

    final result = await getCarouselUc(const CountryParams(type: 'home_top'));

    result.fold(
      (failure) {
        emit(state.copyWith(
          reqStateHomeTop: handleErrorResponse(failure),
          homeTopError: NetworkExceptions.getErrorMessage(failure),
        ));
      },
      (success) {
        emit(state.copyWith(
          reqStateHomeTop: handleLoadedResponse<List<CarouselModel>>(success.data),
          homeTopCarousels: success.data ?? [],
        ));
      },
    );
  }

  Future<void> _getHomeMiddleCarousel(
    GetHomeMiddleCarouselEvent event,
    Emitter<GetCarouselState> emit,
  ) async {
    if (event.isLoading) {
      emit(state.copyWith(reqStateHomeMiddle: RequestState.loading));
    }

    final result =
        await getCarouselUc(const CountryParams(type: 'home_middle'));

    result.fold(
      (failure) {
        emit(state.copyWith(
          reqStateHomeMiddle: handleErrorResponse(failure),
          homeMiddleError: NetworkExceptions.getErrorMessage(failure),
        ));
      },
      (success) {
        emit(state.copyWith(
          reqStateHomeMiddle:
              handleLoadedResponse<List<CarouselModel>>(success.data),
          homeMiddleCarousels: success.data ?? [],
        ));
      },
    );
  }

  Future<void> _getLiveCarousel(
    GetLiveCarouselEvent event,
    Emitter<GetCarouselState> emit,
  ) async {
    if (event.isLoading) {
      emit(state.copyWith(liveState: RequestState.loading));
    }

    final result = await getCarouselUc(const CountryParams(type: 'live'));

    result.fold(
      (failure) {
        emit(state.copyWith(
          liveState: handleErrorResponse(failure),
          liveError: NetworkExceptions.getErrorMessage(failure),
        ));
      },
      (success) {
        emit(state.copyWith(
          liveState: handleLoadedResponse<List<CarouselModel>>(success.data),
          liveCarousels: success.data ?? [],
        ));
      },
    );
  }

  /// 🆕 NEW: Get Country Carousel
  Future<void> _getCountryCarousel(
    GetCountryCarouselEvent event,
    Emitter<GetCarouselState> emit,
  ) async {
    if (event.isLoading) {
      emit(state.copyWith(countryState: RequestState.loading));
    }

    final result = await getCarouselUc(
        CountryParams(type: 'country', countryId: event.countryId));

    result.fold(
      (failure) {
        emit(state.copyWith(
          countryState: handleErrorResponse(failure),
          countryError: NetworkExceptions.getErrorMessage(failure),
        ));
      },
      (success) {
        emit(state.copyWith(
          countryState: handleLoadedResponse<List<CarouselModel>>(success.data),
          countryCarousels: success.data ?? [],
        ));
      },
    );
  }

  /// 🆕 NEW: Get Country Carousel
  Future<void> _resetCountryCarouselEvent(
      ResetCountryCarouselEvent event,
    Emitter<GetCarouselState> emit,
  ) async {
    emit(state.copyWith(
      countryCarousels: [],
    ));
  }
}

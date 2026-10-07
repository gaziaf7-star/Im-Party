import 'dart:async';
import 'package:general/src/features/home/presentation/banner/banner_bloc/banner_event.dart';
import '../../../../../core/index.dart';
import '../../../data/model/banner_model.dart';
import '../../../domain/home_use_case/get_banner_usecase.dart';
import 'banner_state.dart';

class BannerBloc extends Bloc<BaseGetBannerEvents, BannerState> {
  final GetBannerUseCase getBannerUseCase;
  Timer? _timer;

  BannerBloc({
    required this.getBannerUseCase,
  }) : super(const BannerState()) {
    on<StartCountdownEvent>(_onStartCountdown);
    on<OnSkipEvent>(_onSkipEvent);
    on<UpdateCountdownEvent>(_onUpdateCountdown);
    on<GetBannerEvent>((event, emit) async {
      emit(state.copyWith(requestState: RequestState.loading));
      final result = await getBannerUseCase();
      result.fold(
        (failure) {
          emit(state.copyWith(
            requestState: handleErrorResponse(failure),
          ));
        },
        (success) {
          emit(state.copyWith(
            requestState: handleLoadedResponse<BannerModel>(success.data),
            bannerEntity: success.data,
          ));
        },
      );
    });
   /* on<ShowBannerEvent>(_onShowBanner);
    on<HideBannerEvent>(_onHideBanner);*/
    // _showBannerImmediately();
  }

  void _onStartCountdown(
      StartCountdownEvent event, Emitter<BannerState> emit) {
    int countdown = 3;
    emit(state.copyWith(countdown: countdown));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        _timer?.cancel();
        _navigateAfterBanner();
      } else {
        countdown--;
        add(UpdateCountdownEvent(countdown));
      }
    });
  }

  void _onSkipEvent(OnSkipEvent event, Emitter<BannerState> emit) {
    _timer?.cancel();
    _navigateAfterBanner();
  }

  /// This screen is now also reached straight from splash on every launch
  /// (not just when already logged in, for the promo-event banner), so a
  /// logged-out user landing here after the banner needs to go to the
  /// Welcome/login page, not straight into home.
  void _navigateAfterBanner() {
    final token = HiveManager.instance
        .getData<String>(KeysManager.USER_BOX, KeysManager.TOKEN_KEY);
    navKey.currentContext?.pushNamedAndRemoveUntil(
      token == null ? Routes.intro : Routes.layout,
    );
  }

  void _onUpdateCountdown(
    UpdateCountdownEvent event,
    Emitter<BannerState> emit,
  ) {
    emit(state.copyWith(countdown: event.countdown));
  }
 /* void _onShowBanner(ShowBannerEvent event, Emitter<BannerState> emit) {
    emit(state.copyWith(isBannerVisible: true));
    _startAutoHideTimer();
  }

  void _onHideBanner(HideBannerEvent event, Emitter<BannerState> emit) {
    emit(state.copyWith(isBannerVisible: false));
    _restartBannerTimer();
  }



  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(minutes: 7), () {
      add(HideBannerEvent());
    });
  }

  void _restartBannerTimer() {
    _visibilityTimer?.cancel();
    _visibilityTimer = Timer(const Duration(seconds: 5), () {
      add(ShowBannerEvent());
    });
  }*/

  @override
  Future<void> close() {
    /*_visibilityTimer?.cancel();
    _autoHideTimer?.cancel();*/
    _timer?.cancel();
    return super.close();
  }
}


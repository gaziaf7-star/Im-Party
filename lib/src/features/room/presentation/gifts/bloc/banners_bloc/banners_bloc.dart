import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_event.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/banners_bloc/banners_state.dart';

class ShowBannersBloc extends Bloc<BaseShowBannersEvent, ShowBannersState> {
  ShowBannersBloc() : super(const ShowBannersState()) {
    on<ShowBannerInAppEvent>(_showBannerInAppEvent);
  }

  Future<void> _showBannerInAppEvent(
    ShowBannerInAppEvent event,
    Emitter<ShowBannersState> emit,
  ) async {
    emit(
      state.copyWith(bannerData: event.bannerData),
    );
  }
}

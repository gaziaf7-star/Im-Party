import 'package:general/src/features/room/presentation/manager/alpha_gift_manager/alpha_gift_manager_event.dart';
import 'package:general/src/features/room/presentation/manager/alpha_gift_manager/alpha_gift_manager_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AlphaGiftManagerBloc extends Bloc<AlphaGiftManagerEvent, AlphaGiftManagerState> {
  AlphaGiftManagerBloc() : super(AlphaGiftManagerInitial()) {
    on<ShowAlphaGift>((event, emit) {
      emit(AlphaGiftManagerShowGift(giftPath: event.imgFile,isFamousGift: event.isFamousGift??false, isIntro: event.isIntro??false));
    });

    on<EndAlphaGift>((event, emit) {
      emit(AlphaGiftManagerEndGift());
    });
  }
}

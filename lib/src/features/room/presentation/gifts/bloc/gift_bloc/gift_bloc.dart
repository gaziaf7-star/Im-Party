import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/manager/gift_queue_manager.dart';

part 'gift_event.dart';
part 'gift_state.dart';

class GiftBloc extends Bloc<GiftEvent, GiftState> {
  GiftBloc() : super(const GiftState()) {
    on<ShowGiftsEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            gift: event.pathGift,
            isFamousGift: event.isFamousGift ?? false,
            isShowGift: event.isShowGift,
            giftType: event.giftType,
            isShowIntroFullScreen: event.isShowIntroFullScreen ?? true,
          ),
        );

        // If this is showing a gift (not hiding), update showTime for the first gift in queue
        if (event.isShowGift && event.pathGift.isNotEmpty) {
          GiftQueueManager().updateFirstShowTime();
        }
      },
    );

    on<ShowBannerEvent>((event, emit) {
      emit(
        state.copyWith(
          showBanner: event.show,
          bannerData: state.bannerData,
        ),
      );
    });

    on<UpdateRoomGiftsPriceEvent>((event, emit) {
      emit(state.copyWith(price: event.price));
    });

    on<SetVideoVisibilityEvent>((event, emit) {
      emit(state.copyWith(isVisible: event.isVisible));
    });

    on<ChangeGiftDataEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            giftId: event.giftId ?? state.giftId,
            giftPrice: event.giftPrice ?? state.giftPrice,
            numOfGift: event.numOfGift ?? state.numOfGift,
            selectedCategoryId: event.categoryId ?? state.selectedCategoryId,
          ),
        );
      },
    );

    on<SetGiftDownloadingEvent>(
      (event, emit) {
        emit(state.copyWith(isDownloadingGift: event.isDownloading));
      },
    );

    // Single emission that replaces separate UpdateRoomGiftsPriceEvent +
    // ShowGiftsEvent + ShowBannerEvent fired per gift.
    on<ShowGiftCompositeEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            price: event.price.isNotEmpty ? event.price : state.price,
            gift: event.pathGift,
            isShowGift: true,
            isFamousGift: event.isFamousGift,
            giftType: event.giftType,
            isShowIntroFullScreen: event.isShowIntroFullScreen,
            showBanner: event.showBanner,
          ),
        );
        GiftQueueManager().updateFirstShowTime();
      },
    );
  }
}

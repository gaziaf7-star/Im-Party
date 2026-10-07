import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class FetchUserGiftsStates extends Equatable {
  final List<GiftsEntity> appGifts;
  final RequestState appReqState;
  final String appMessage;

  final List<String> appGiftImages;
  final RequestState appGiftImagesReqState;
  final String appGiftImagesMessage;

  const FetchUserGiftsStates({
    this.appGifts = const [],
    this.appReqState = RequestState.loading,
    this.appMessage = "",
    this.appGiftImages = const [],
    this.appGiftImagesReqState = RequestState.loading,
    this.appGiftImagesMessage = "",
  });

  FetchUserGiftsStates copyWith({
    List<GiftsEntity>? appGifts,
    RequestState? appReqState,
    String? appMessage,
    List<String>? appGiftImages,
    RequestState? appGiftImagesReqState,
    String? appGiftImagesMessage,
  }) {
    return FetchUserGiftsStates(
      appGifts: appGifts ?? this.appGifts,
      appMessage: appMessage ?? this.appMessage,
      appReqState: appReqState ?? this.appReqState,
      appGiftImages: appGiftImages ?? this.appGiftImages,
      appGiftImagesReqState: appGiftImagesReqState ?? this.appGiftImagesReqState,
      appGiftImagesMessage: appGiftImagesMessage ?? this.appGiftImagesMessage,
    );
  }

  @override
  List<Object?> get props => [
        appGifts,
        appReqState,
        appMessage,
        appGiftImages,
        appGiftImagesReqState,
        appGiftImagesMessage,
      ];
}

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/entities/gift_category_entity.dart';
import 'package:general/src/features/room/room.dart';

class FetchGiftsStates extends Equatable {
  /// -------------------------------
  /// Category gifts (dynamic by ID)
  /// -------------------------------
  final Map<int, List<GiftsEntity>> categoryGifts;
  final Map<int, RequestState> categoryReqStates;
  final Map<int, String> categoryMessages;

  /// -------------------------------
  /// Bag gifts
  /// -------------------------------
  final List<GiftsEntity> bagGifts;
  final RequestState bagReqState;
  final String bagMessage;
  final int? categoryId;

  /// -------------------------------
  /// Search gifts
  /// -------------------------------
  final List<GiftsEntity> searchGifts;
  final RequestState searchReqState;
  final String searchMessage;

  /// -------------------------------
  /// Gift categories
  /// -------------------------------
  final List<GiftCategoryEntity> giftCategory;
  final RequestState reqStateGiftCategory;
  final String msgGiftCategory;

  const FetchGiftsStates({
    this.categoryGifts = const {},
    this.categoryReqStates = const {},
    this.categoryMessages = const {},
    this.bagGifts = const [],
    this.bagReqState = RequestState.loading,
    this.bagMessage = "",
    this.categoryId = -1,
    this.searchGifts = const [],
    this.searchReqState = RequestState.idle,
    this.searchMessage = "",
    this.giftCategory = const [],
    this.reqStateGiftCategory = RequestState.idle,
    this.msgGiftCategory = "",
  });

  FetchGiftsStates copyWith({
    Map<int, List<GiftsEntity>>? categoryGifts,
    Map<int, RequestState>? categoryReqStates,
    Map<int, String>? categoryMessages,
    List<GiftsEntity>? bagGifts,
    RequestState? bagReqState,
    String? bagMessage,
    int? categoryId,
    List<GiftsEntity>? searchGifts,
    RequestState? searchReqState,
    String? searchMessage,
    List<GiftCategoryEntity>? giftCategory,
    RequestState? reqStateGiftCategory,
    String? msgGiftCategory,
  }) {
    return FetchGiftsStates(
      categoryGifts: categoryGifts ?? this.categoryGifts,
      categoryReqStates: categoryReqStates ?? this.categoryReqStates,
      categoryMessages: categoryMessages ?? this.categoryMessages,
      bagGifts: bagGifts ?? this.bagGifts,
      bagReqState: bagReqState ?? this.bagReqState,
      categoryId: categoryId ?? this.categoryId,
      bagMessage: bagMessage ?? this.bagMessage,
      searchGifts: searchGifts ?? this.searchGifts,
      searchReqState: searchReqState ?? this.searchReqState,
      searchMessage: searchMessage ?? this.searchMessage,
      giftCategory: giftCategory ?? this.giftCategory,
      reqStateGiftCategory: reqStateGiftCategory ?? this.reqStateGiftCategory,
      msgGiftCategory: msgGiftCategory ?? this.msgGiftCategory,
    );
  }

  /// -------------------------------
  /// Helpers
  /// -------------------------------
  List<GiftsEntity> getGiftsById(int id) {
    return categoryGifts[id] ?? [];
  }

  RequestState getReqStateById(int id) {
    return categoryReqStates[id] ?? RequestState.loading;
  }

  String getMessageById(int id) {
    return categoryMessages[id] ?? "";
  }

  bool get isSearching => searchReqState != RequestState.idle;

  @override
  List<Object?> get props => [
        categoryGifts,
        categoryReqStates,
        categoryMessages,
        bagGifts,
        bagReqState,
        bagMessage,
        categoryId,
        searchGifts,
        searchReqState,
        searchMessage,
        giftCategory,
        reqStateGiftCategory,
        msgGiftCategory,
      ];
}

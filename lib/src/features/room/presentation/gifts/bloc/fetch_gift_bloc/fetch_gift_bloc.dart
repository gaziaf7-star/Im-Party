// import 'dart:async';

// import 'package:general/src/core/index.dart';
// import 'package:general/src/features/room/domain/entities/gift_category_entity.dart';
// import 'package:general/src/features/room/domain/use_case/fetch_gift_category_uc.dart';
// import 'package:general/src/features/room/presentation/gifts/gift.dart';
// import 'package:general/src/features/room/room.dart';

// class FetchGiftBloc extends Bloc<FetchGiftEvent, FetchGiftsStates> {
//   final FetchGiftsUC _fetchGiftsUC;
//   final FetchGiftCategoryUC _fetchGiftCategoryUC;

//   FetchGiftBloc(this._fetchGiftsUC, this._fetchGiftCategoryUC)
//       : super(const FetchGiftsStates()) {
//     on<FetchAppGiftEvent>(_fetchAppGiftEvent);
//     on<FetchEventGiftEvent>(_fetchEventGiftEvent);
//     on<FetchLuckyGiftEvent>(_fetchLuckyGiftEvent);
//     on<FetchSpecialGiftEvent>(_fetchSpecialGiftEvent);
//     on<FetchFamousGiftEvent>(_fetchFamousGiftEvent);
//     on<FetchMomentGiftEvent>(_fetchMomentGiftEvent);
//     on<FetchCountryGiftEvent>(_fetchCountryGiftEvent);
//     on<FetchVipGiftEvent>(_fetchVipGiftEvent);
//     on<FetchBagGiftEvent>(_fetchBagGiftEvent);
//     on<FetchGiftCategoryEvent>(_fetchGiftCategoryEvent);
//   }

//   Future<void> _fetchAppGiftEvent(
//     FetchAppGiftEvent event,
//     Emitter<FetchGiftsStates> emit,
//   ) async {
//     final result = await _fetchGiftsUC(event.type);

//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           appMessage: NetworkExceptions.getErrorMessage(failure),
//           appReqState: RequestState.error,
//         ),
//       ),
//       (success) => emit(
//         state.copyWith(
//           appGifts: success.data,
//           appReqState: RequestState.loaded,
//         ),
//       ),
//     );
//   }

//   Future<void> _fetchSpecialGiftEvent(
//     FetchSpecialGiftEvent event,
//     Emitter<FetchGiftsStates> emit,
//   ) async {
//     final result = await _fetchGiftsUC(event.type);
//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           specialMessage: NetworkExceptions.getErrorMessage(failure),
//           specialReqState: RequestState.error,
//         ),
//       ),
//       (success) => emit(
//         state.copyWith(
//           specialGifts: success.data,
//           specialReqState: RequestState.loaded,
//         ),
//       ),
//     );
//   }

//   Future<void> _fetchCountryGiftEvent(
//     FetchCountryGiftEvent event,
//     Emitter<FetchGiftsStates> emit,
//   ) async {
//     final result = await _fetchGiftsUC(event.type);
//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           countryMessage: NetworkExceptions.getErrorMessage(failure),
//           countryReqState: RequestState.error,
//         ),
//       ),
//       (success) => emit(
//         state.copyWith(
//           countryGifts: success.data,
//           countryReqState: RequestState.loaded,
//         ),
//       ),
//     );
//   }

//   Future<void> _fetchVipGiftEvent(
//     FetchVipGiftEvent event,
//     Emitter<FetchGiftsStates> emit,
//   ) async {
//     final result = await _fetchGiftsUC(event.type);
//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           vipMessage: NetworkExceptions.getErrorMessage(failure),
//           vipReqState: RequestState.error,
//         ),
//       ),
//       (success) => emit(
//         state.copyWith(
//           vipGifts: success.data,
//           vipReqState: RequestState.loaded,
//         ),
//       ),
//     );
//   }

//   Future<void> _fetchFamousGiftEvent(
//     FetchFamousGiftEvent event,
//     Emitter<FetchGiftsStates> emit,
//   ) async {
//     final result = await _fetchGiftsUC(event.type);
//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           famousMessage: NetworkExceptions.getErrorMessage(failure),
//           famousReqState: RequestState.error,
//         ),
//       ),
//       (success) => emit(
//         state.copyWith(
//           famousGifts: success.data,
//           famousReqState: RequestState.loaded,
//         ),
//       ),
//     );
//   }

//   Future<void> _fetchLuckyGiftEvent(
//     FetchLuckyGiftEvent event,
//     Emitter<FetchGiftsStates> emit,
//   ) async {
//     final result = await _fetchGiftsUC(event.type);
//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           luckyMessage: NetworkExceptions.getErrorMessage(failure),
//           luckyReqState: RequestState.error,
//         ),
//       ),
//       (success) => emit(
//         state.copyWith(
//           luckyGifts: success.data,
//           luckyReqState: RequestState.loaded,
//         ),
//       ),
//     );
//   }

//   Future<void> _fetchMomentGiftEvent(
//     FetchMomentGiftEvent event,
//     Emitter<FetchGiftsStates> emit,
//   ) async {
//     final result = await _fetchGiftsUC(event.type);
//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           momentMessage: NetworkExceptions.getErrorMessage(failure),
//           momentReqState: RequestState.error,
//         ),
//       ),
//       (success) => emit(
//         state.copyWith(
//           momentGifts: success.data,
//           momentReqState: RequestState.loaded,
//         ),
//       ),
//     );
//   }

//   Future<void> _fetchEventGiftEvent(
//     FetchEventGiftEvent event,
//     Emitter<FetchGiftsStates> emit,
//   ) async {
//     final result = await _fetchGiftsUC(event.type);

//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           eventMessage: NetworkExceptions.getErrorMessage(failure),
//           eventReqState: RequestState.error,
//         ),
//       ),
//       (success) => emit(
//         state.copyWith(
//           eventGifts: success.data,
//           eventReqState: RequestState.loaded,
//         ),
//       ),
//     );
//   }

//   Future<void> _fetchBagGiftEvent(
//     FetchBagGiftEvent event,
//     Emitter<FetchGiftsStates> emit,
//   ) async {
//     final result = await _fetchGiftsUC(11);

//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           bagMessage: NetworkExceptions.getErrorMessage(failure),
//           bagReqState: RequestState.error,
//         ),
//       ),
//       (success) => emit(
//         state.copyWith(
//           bagGifts: success.data,
//           bagReqState: RequestState.loaded,
//         ),
//       ),
//     );
//   }

//   Future<void> _fetchGiftCategoryEvent(
//     FetchGiftCategoryEvent event,
//     Emitter<FetchGiftsStates> emit,
//   ) async {
//     final result = await _fetchGiftCategoryUC();

//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           msgGiftCategory: NetworkExceptions.getErrorMessage(failure),
//           reqStateGiftCategory:
//               handleErrorResponse(NetworkExceptions.getDioException(failure)),
//         ),
//       ),
//       (success) {
//         // for(final data in (success.data??[]))
//         // {
//         //    final typeGift = TypeGift.fromString(data.type);
//         //    Methods.printLog("type ======> $typeGift");
//         // }

//         emit(
//           state.copyWith(
//             giftCategory: success.data,
//             reqStateGiftCategory:
//                 handleLoadedResponse<List<GiftCategoryEntity>>(success.data),
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/entities/gift_category_entity.dart';
import 'package:general/src/features/room/domain/use_case/fetch_gift_category_uc.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/room.dart';

class FetchGiftBloc extends Bloc<FetchGiftEvent, FetchGiftsStates> {
  final FetchGiftsUC _fetchGiftsUC;
  final FetchGiftCategoryUC _fetchGiftCategoryUC;

  FetchGiftBloc(this._fetchGiftsUC, this._fetchGiftCategoryUC)
      : super(const FetchGiftsStates()) {
    on<FetchGiftsByCategoryEvent>(_fetchGiftsByCategoryEvent);
    on<FetchBagGiftEvent>(_fetchBagGiftEvent);
    on<FetchGiftCategoryEvent>(_fetchGiftCategoryEvent);
    on<SearchGiftCategoryEvent>(_searchGiftCategoryEvent);
    on<SetCategoryIdEvent>(_setCategoryIdEvent);
  }

  Future<void> _fetchGiftsByCategoryEvent(
    FetchGiftsByCategoryEvent event,
    Emitter<FetchGiftsStates> emit,
  ) async {
    Methods.printLog(
        "fetch_gifts_by_category_event ----> ID: ${event.categoryId}");
    Methods.printLog(
        "fetch_gifts_by_category_event ----> TypeID: ${event.typeId}");

    final result = await _fetchGiftsUC(event.typeId);

    result.fold(
      (failure) {
        final updatedMessages = Map<int, String>.from(state.categoryMessages);
        updatedMessages[event.categoryId] =
            NetworkExceptions.getErrorMessage(failure);

        final updatedReqStates =
            Map<int, RequestState>.from(state.categoryReqStates);
        updatedReqStates[event.categoryId] = RequestState.error;

        emit(state.copyWith(
          categoryMessages: updatedMessages,
          categoryReqStates: updatedReqStates,
        ));
      },
      (success) {
        final updatedGifts =
            Map<int, List<GiftsEntity>>.from(state.categoryGifts);
        updatedGifts[event.categoryId] = success.data ?? [];

        final updatedReqStates =
            Map<int, RequestState>.from(state.categoryReqStates);
        updatedReqStates[event.categoryId] = RequestState.loaded;

        emit(state.copyWith(
          categoryGifts: updatedGifts,
          categoryReqStates: updatedReqStates,
        ));
      },
    );
  }

  Future<void> _fetchGiftCategoryEvent(
    FetchGiftCategoryEvent event,
    Emitter<FetchGiftsStates> emit,
  ) async {
    final result = await _fetchGiftCategoryUC();

    result.fold(
      (failure) => emit(
        state.copyWith(
          msgGiftCategory: NetworkExceptions.getErrorMessage(failure),
          reqStateGiftCategory:
              handleErrorResponse(NetworkExceptions.getDioException(failure)),
        ),
      ),
      (success) {
        // Initialize all categories with loading state using ID
        final initialReqStates = <int, RequestState>{};
        for (final category in success.data ?? []) {
          initialReqStates[category.id] = RequestState.loading;
        }

        emit(state.copyWith(
          giftCategory: success.data,
          categoryReqStates: initialReqStates,
          reqStateGiftCategory:
              handleLoadedResponse<List<GiftCategoryEntity>>(success.data),
        ));
      },
    );
  }

  Future<void> _fetchBagGiftEvent(
    FetchBagGiftEvent event,
    Emitter<FetchGiftsStates> emit,
  ) async {
    const tag = "[BAG_GIFTS]";

    Methods.printLog("$tag ▶️ Fetch bag gifts started");

    final result = await _fetchGiftsUC(-1);

    result.fold(
      (failure) {
        final errorMessage = NetworkExceptions.getErrorMessage(failure);

        Methods.printLog("$tag ❌ Failed to fetch bag gifts");
        Methods.printLog("$tag ❌ Error: $errorMessage");

        emit(
          state.copyWith(
            bagMessage: errorMessage,
            bagReqState: RequestState.error,
          ),
        );
      },
      (success) {
        Methods.printLog(
          "$tag ✅ Bag gifts fetched successfully | Count: ${success.data}",
        );

        emit(
          state.copyWith(
            bagGifts: success.data,
            bagReqState: RequestState.loaded,
          ),
        );
      },
    );

    Methods.printLog("$tag ⏹️ Fetch bag gifts finished");
  }
  Future<void> _searchGiftCategoryEvent(
      SearchGiftCategoryEvent event,
      Emitter<FetchGiftsStates> emit,
      ) async {
    const tag = "[GIFT_SEARCH]";

    final query = event.keyWord.trim().toLowerCase();
    final categoryId = state.categoryId;

    Methods.printLog("$tag ▶️ Search triggered");
    Methods.printLog("$tag 🔎 Raw keyword: '${event.keyWord}'");
    Methods.printLog("$tag 🔎 Normalized keyword: '$query'");
    Methods.printLog("$tag 📍 Active categoryId: $categoryId");

    /// 🚫 Invalid category
    if (categoryId == -1) {
      Methods.printLog("$tag ⛔ categoryId = -1 → search skipped");
      return;
    }

    /// 🔄 Reset search
    if (query.isEmpty) {
      Methods.printLog("$tag 🔄 Empty keyword → reset search state");

      emit(
        state.copyWith(
          searchGifts: [],
          searchReqState: RequestState.idle,
          searchMessage: "",
        ),
      );
      return;
    }

    /// ⏳ Loading
    Methods.printLog("$tag ⏳ Search loading started");

    emit(
      state.copyWith(
        searchReqState: RequestState.loading,
        searchGifts: [],
        searchMessage: "",
      ),
    );

    try {
      List<GiftsEntity> results = [];

      /// 🧠 SEARCH ONLY CURRENT TAB
      if (categoryId == null) {
        Methods.printLog("$tag 🎒 Searching in BAG gifts");
        Methods.printLog("$tag 🎒 Bag gifts count: ${state.bagGifts.length}");

        results = state.bagGifts.where(
              (gift) => gift.name?.toLowerCase().contains(query) == true,
        ).toList();
      } else {
        final categoryGifts = state.categoryGifts[categoryId] ?? [];

        Methods.printLog("$tag 📦 Searching in CATEGORY");
        Methods.printLog("$tag 📦 CategoryId: $categoryId");
        Methods.printLog("$tag 📦 Category gifts count: ${categoryGifts.length}");

        results = categoryGifts.where(
              (gift) => gift.name?.toLowerCase().contains(query) == true,
        ).toList();
      }

      Methods.printLog("$tag ✅ Matches found: ${results.length}");

      /// ⭐ Order results
      results.sort((a, b) {
        final aName = a.name?.toLowerCase() ?? "";
        final bName = b.name?.toLowerCase() ?? "";

        final aStarts = aName.startsWith(query);
        final bStarts = bName.startsWith(query);

        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;

        return aName.compareTo(bName);
      });

      Methods.printLog("$tag ⭐ Results sorted");

      emit(
        state.copyWith(
          searchGifts: results,
          searchReqState: RequestState.loaded,
          searchMessage: results.isEmpty ? "No results found" : "",
        ),
      );

      Methods.printLog("$tag 🟢 Search completed successfully");
    } catch (e) {
      Methods.printLog("$tag ❌ Search failed");
      Methods.printLog("$tag ❌ Exception: $e");

      emit(
        state.copyWith(
          searchReqState: RequestState.error,
          searchMessage: e.toString(),
        ),
      );
    }
  }



  Future<void> _setCategoryIdEvent(
    SetCategoryIdEvent event,
    Emitter<FetchGiftsStates> emit,
  ) async {
    emit(
      state.copyWith(
        categoryId: event.categoryId,
      ),
    );
  }
}

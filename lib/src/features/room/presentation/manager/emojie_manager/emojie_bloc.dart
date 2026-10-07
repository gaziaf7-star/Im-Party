// import 'package:general/src/features/room/domain/entities/reaction_entity.dart';
// import 'package:general/src/features/room/domain/use_case/fetch_emojis_category_uc.dart';
// import 'package:general/src/features/room/room.dart';
// import 'emojie_state.dart';
// import 'emojie_event.dart';
// import 'package:general/src/core/index.dart';

// class EmojieBloc extends Bloc<EmojieEvents, EmojieState> {
//   final EmojiUC emojieUseCase;
//   final FetchEmojisCategoryUc emojisCategoryUc;

//   EmojieBloc({
//     required this.emojieUseCase,
//     required this.emojisCategoryUc,
//   }) : super(const EmojieState()) {
//     on<GetEmojieEvent>(
//       (event, emit) async {
//         emit(state.copyWith(reqState: RequestState.loading));

//         final result = await emojieUseCase.call();

//         result.fold(
//           (failure) => emit(state.copyWith(
//             reqState:
//                 handleErrorResponse(NetworkExceptions.getDioException(failure)),
//             message: NetworkExceptions.getErrorMessage(failure),
//           )),
//           (success) => emit(state.copyWith(
//             reqState: handleLoadedResponse<List<EmojiEntity>>(success.data),
//             data: success.data ?? [],
//           )),
//         );
//       },
//     );

//     on<FetchEmojisCategoryEvent>(
//       (event, emit) async {
//         emit(state.copyWith(reqStateEmojisCategory: RequestState.loading));

//         final result = await emojisCategoryUc.call();

//         result.fold(
//           (failure) {
//             emit(state.copyWith(
//               reqStateEmojisCategory: handleErrorResponse(
//                   NetworkExceptions.getDioException(failure)),
//               msgEmojisCategory: NetworkExceptions.getErrorMessage(failure),
//             ));
//           },
//           (success) {
//             emit(
//               state.copyWith(
//                 reqStateEmojisCategory:
//                     handleLoadedResponse<List<ReactionEntity>>(success.data),
//                 categories: success.data ?? [],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }


import 'package:general/src/features/room/domain/entities/reaction_entity.dart';
import 'package:general/src/features/room/domain/use_case/fetch_emojis_category_uc.dart';
import 'package:general/src/features/room/room.dart';
import 'emojie_state.dart';
import 'emojie_event.dart';
import 'package:general/src/core/index.dart';

class EmojieBloc extends Bloc<EmojieEvents, EmojieState> {
  final EmojiUC emojieUseCase;
  final FetchEmojisCategoryUc emojisCategoryUc;

  EmojieBloc({
    required this.emojieUseCase,
    required this.emojisCategoryUc,
  }) : super(const EmojieState()) {
    on<FetchEmojisByCategoryEvent>(_fetchEmojisByCategoryEvent);
    on<FetchEmojisCategoryEvent>(_fetchEmojisCategoryEvent);
  }

  Future<void> _fetchEmojisByCategoryEvent(
    FetchEmojisByCategoryEvent event,
    Emitter<EmojieState> emit,
  ) async {
    Methods.printLog("fetch_emojis_by_category_event ----> ID: ${event.categoryId}");
    Methods.printLog("fetch_emojis_by_category_event ----> TypeID: ${event.typeId}");
    
    final result = await emojieUseCase.call('${event.typeId}');

    result.fold(
      (failure) {
        final updatedMessages = Map<int, String>.from(state.categoryMessages);
        updatedMessages[event.categoryId] = NetworkExceptions.getErrorMessage(failure);

        final updatedReqStates = Map<int, RequestState>.from(state.categoryReqStates);
        updatedReqStates[event.categoryId] = RequestState.error;

        emit(state.copyWith(
          categoryMessages: updatedMessages,
          categoryReqStates: updatedReqStates,
        ));
      },
      (success) {
        final updatedEmojis = Map<int, List<EmojiEntity>>.from(state.categoryEmojis);
        updatedEmojis[event.categoryId] = success.data ?? [];

        final updatedReqStates = Map<int, RequestState>.from(state.categoryReqStates);
        updatedReqStates[event.categoryId] = RequestState.loaded;

        emit(state.copyWith(
          categoryEmojis: updatedEmojis,
          categoryReqStates: updatedReqStates,
        ));
      },
    );
  }

  Future<void> _fetchEmojisCategoryEvent(
    FetchEmojisCategoryEvent event,
    Emitter<EmojieState> emit,
  ) async {
    emit(state.copyWith(reqStateEmojisCategory: RequestState.loading));

    final result = await emojisCategoryUc.call();

    result.fold(
      (failure) {
        emit(state.copyWith(
          reqStateEmojisCategory: handleErrorResponse(
              NetworkExceptions.getDioException(failure)),
          msgEmojisCategory: NetworkExceptions.getErrorMessage(failure),
        ));
      },
      (success) {
        // Initialize all categories with loading state using ID
        final initialReqStates = <int, RequestState>{};
        for (final category in success.data ?? []) {
          initialReqStates[category.id] = RequestState.loading;
        }

        emit(
          state.copyWith(
            reqStateEmojisCategory:
                handleLoadedResponse<List<ReactionEntity>>(success.data),
            categories: success.data ?? [],
            categoryReqStates: initialReqStates,
          ),
        );
      },
    );
  }
}
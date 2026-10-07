// import 'package:general/src/core/index.dart';
// import 'package:general/src/features/room/data/model/get_games_images_model.dart';
// import 'package:general/src/features/room/domain/use_case/fetch_games_images.dart';

// part 'games_images_event.dart';

// part 'games_images_state.dart';

// class GamesImagesBloc extends Bloc<FetchGamesImagesEvent, GamesImagesState> {
//   final FetchGamesImagesUc useCase;

//   GamesImagesBloc(this.useCase) : super(const GamesImagesState()) {
//     on<FetchGamesImagesEvent>(_onFetchGamesImages);
//   }

//   Future<void> _onFetchGamesImages(
//     FetchGamesImagesEvent event,
//     Emitter<GamesImagesState> emit,
//   ) async {
//     if (event.isFirstLoad) {
//       emit(state.copyWith(state: RequestState.loading));
//     }

//     final result = await useCase(2);

//     result.fold(
//       (failure) => emit(
//         state.copyWith(
//           state: RequestState.error,
//           message: NetworkExceptions.getErrorMessage(failure),
//         ),
//       ),
//       (response) => emit(
//         state.copyWith(
//           state: RequestState.loaded,
//           data: response.data,
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/get_games_images_model.dart';
import 'package:general/src/features/room/domain/use_case/fetch_games_images.dart';

part 'games_images_event.dart';
part 'games_images_state.dart';

class GamesImagesBloc extends Bloc<FetchGamesImagesEvent, GamesImagesState> {
  final FetchGamesImagesUc useCase;

  GamesImagesBloc(this.useCase) : super(const GamesImagesState()) {
    on<FetchGamesImagesEvent>(_onFetchGamesImages);
  }

  Future<void> _onFetchGamesImages(
    FetchGamesImagesEvent event,
    Emitter<GamesImagesState> emit,
  ) async {
    emit(state.copyWith(state: RequestState.loading));

    final result = await useCase(2);

    await result.fold(
      (failure) async {
        Methods.printLog('❌ API error: $failure');

        final cachedJson = HiveManager().getData<String>(
          KeysManager.GAMES_BOX,
          KeysManager.GAMES_KEY,
        );

        if (cachedJson?.isNotEmpty == true) {
          try {
            final decoded = jsonDecode(cachedJson!);
            final cachedModel = SvgaDataModel.fromJason(decoded);

            emit(state.copyWith(
              state: RequestState.loaded,
              data: cachedModel,
            ));

            Methods.printLog('📦 Loaded Games SVGA from cache.');
          } catch (e) {
            Methods.printLog('❌ Failed to decode cache: $e');
            emit(state.copyWith(state: RequestState.error));
          }
        } else {
          emit(state.copyWith(state: RequestState.error));
        }
      },
      (data) async {
        final newData = data.data;

        emit(state.copyWith(state: RequestState.loaded, data: newData));

        bool hasChanges = false;

        final cachedJson = HiveManager().getData<String>(
          KeysManager.GAMES_BOX,
          KeysManager.GAMES_KEY,
        );

        if (cachedJson?.isNotEmpty == true) {
          try {
            final decoded = jsonDecode(cachedJson!);
            final oldData = SvgaDataModel.fromJason(decoded);

            if (!const DeepCollectionEquality().equals(
              oldData.toJson(),
              newData?.toJson(),
            )) {
              hasChanges = true;
              Methods.printLog('🔁 SVGA Data changed.');
            } else {
              Methods.printLog('✅ SVGA Data unchanged.');
            }
          } catch (e) {
            hasChanges = true;
            Methods.printLog('❌ Error decoding old SVGA cache: $e');
          }
        } else {
          hasChanges = true;
          Methods.printLog('📦 No SVGA cache found.');
        }

        if (hasChanges) {
          await HiveManager().saveData(
            KeysManager.GAMES_BOX,
            KeysManager.GAMES_KEY,
            jsonEncode(newData?.toJson()),
          );
          Methods.printLog('📥 SVGA Data cache updated.');
        }

        Methods().saveCurrentUtcTimeToCache(TypesCache.games);
      },
    );
  }
}

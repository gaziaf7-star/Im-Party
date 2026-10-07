import 'package:general/src/core/index.dart';
import 'package:general/src/core/cache/alpha_cache_manager.dart';
import 'package:general/src/core/cache/video_cache_manager.dart';
import 'package:general/src/core/cache/vap_cache_manager.dart';
import 'package:general/src/core/cache/svga_cache_manager.dart';
import 'package:general/src/features/room/data/model/boom_rules_model.dart';
import 'package:general/src/features/room/data/model/super_bomb_model.dart';
import 'package:general/src/features/room/data/model/super_boom_videos_model.dart';
import 'package:general/src/features/room/domain/use_case/get_super_bomb_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_super_boom_rules_uc.dart';
import 'package:general/src/features/room/domain/use_case/get_super_boom_videos_uc.dart';

part 'get_super_bombs_event.dart';

part 'get_super_bombs_state.dart';

class GetSuperBombsBloc extends Bloc<SuperBombsEvent, GetSuperBombsState> {
  final GetSuperBombUC useCase;
  final GetSuperBoomVideosUC getSuperBoomVideosUC;
  final GetSuperBoomRulesUC getSuperBoomRulesUC;

  GetSuperBombsBloc(
    this.useCase,
    this.getSuperBoomVideosUC,
    this.getSuperBoomRulesUC,
  ) : super(const GetSuperBombsState()) {
    on<GetSuperBombsEvent>((event, emit) async {
      emit(state.copyWith(state: RequestState.loading));

      final result = await useCase(event.roomId);

      result.fold(
        (left) {
          emit(
            state.copyWith(
              state: handleErrorResponse(left),
              message: NetworkExceptions.getErrorMessage(left),
            ),
          );
        },
        (right) {
          emit(
            state.copyWith(
              state: handleLoadedResponse(right.data),
              data: right.data,
            ),
          );
        },
      );
    });

    on<GetSuperBoomVideosEvent>(
      (event, emit) async {
        emit(state.copyWith(videoState: RequestState.loading));

        final result = await getSuperBoomVideosUC();

        result.fold(
          (left) {
            emit(
              state.copyWith(
                videoState: handleErrorResponse(left),
                videoMessage: NetworkExceptions.getErrorMessage(left),
              ),
            );
          },
          (right) {
            emit(
              state.copyWith(
                videoState: handleLoadedResponse(right.data),
                videosData: right.data,
              ),
            );
            for (final video in (right.data?.data ?? [])) {
              switch (video.videoType.toLowerCase()) {
                case 'alpha':
                  AlphaAssetCacheManager().downloadWithProgress(
                    EndPoints.getImage(video.video),
                  );
                  break;
                case 'mp4':
                  VideoAssetCacheManager().downloadWithProgress(
                    EndPoints.getImage(video.video),
                  );
                  break;
                case 'vap':
                  VapAssetCacheManager().downloadWithProgress(
                    EndPoints.getImage(video.video),
                  );
                  break;
                case 'svga':
                  SVGAAssetCacheManager().downloadWithProgress(
                    EndPoints.getImage(video.video),
                  );
                  break;
                default:
                  // Fallback to alpha cache manager for unknown types
                  AlphaAssetCacheManager().downloadWithProgress(
                    EndPoints.getImage(video.video),
                  );
                  break;
              }
            }
            Methods().saveCurrentUtcTimeToCache(TypesCache.boom);
          },
        );
      },
    );

    on<GetSuperBoomRulesEvent>((event, emit) async {
      emit(state.copyWith(rulesState: RequestState.loading));

      final result = await getSuperBoomRulesUC();

      result.fold(
        (left) {
          emit(
            state.copyWith(
              rulesState: handleErrorResponse(left),
              rulesMessage: NetworkExceptions.getErrorMessage(left),
            ),
          );
        },
        (right) {
          emit(
            state.copyWith(
              rulesState: handleLoadedResponse(right.data),
              rulesData: right.data,
            ),
          );
        },
      );
    });

    on<SelectSuperBomb>((event, emit) {
      emit(state.copyWith(selectedIndex: event.index));
    });
  }
}

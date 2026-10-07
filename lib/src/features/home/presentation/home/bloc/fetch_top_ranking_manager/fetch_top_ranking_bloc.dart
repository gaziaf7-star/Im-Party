import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:general/src/core/base/handle_return.dart';
import 'package:general/src/core/constants/enums.dart';
import 'package:general/src/features/home/data/model/top_rank_images_models.dart';
import 'package:general/src/features/home/domain/use_cases/fetch_top_user_image_rank_uc.dart';

part 'fetch_top_ranking_event.dart';
part 'fetch_top_ranking_state.dart';

class FetchTopUserImageBloc
    extends Bloc<FetchTopUserImageEvent, FetchTopRankingState> {
  final FetchTopUserImageRankUc _fetchTopUserImageRankUc;

  FetchTopUserImageBloc(this._fetchTopUserImageRankUc)
      : super(const FetchTopRankingState()) {
    on<FetchTopUserImageEvent>(
      (event, emit) async {
        final result = await _fetchTopUserImageRankUc();
        result.fold(
          (left) =>
              emit(state.copyWith(requestState: handleErrorResponse(left))),
          (right) {
            emit(
              state.copyWith(
                requestState: handleLoadedResponse<TopRankImagesModel>(right.data),
                rankingEntity: right.data,
              ),
            );
          },
        );
      },
    );
  }
}

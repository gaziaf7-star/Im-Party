
import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/home.dart';

import '../../data/model/top_rank_images_models.dart';

class FetchTopUserImageRankUc
    extends UseCaseWithoutParams<BaseResponse<TopRankImagesModel>> {
  final BaseHomeRepository _repo;

  const FetchTopUserImageRankUc(this._repo);

  @override
  ResultFuture<BaseResponse<TopRankImagesModel>> call() async {
    return await _repo.getTopUserImageRank();
  }
}

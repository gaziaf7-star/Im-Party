
import '../../../../../reels_viewer/reels_viewer.dart';
import '../../auth.dart';
import '../../data/model/colors_model.dart';

class FetchColorsUc extends UseCaseWithoutParams<BaseResponse<ColorsModel>> {
  final BaseAuthenticationRepository _repo;

  const FetchColorsUc(this._repo);

  @override
  ResultFuture<BaseResponse<ColorsModel>> call({bool forceRefresh = false}) async {
    return await _repo.fetchColors(forceRefresh: forceRefresh);
  }
}
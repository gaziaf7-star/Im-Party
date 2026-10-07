import 'package:general/src/features/room/data/model/gift_category_model.dart';
import 'package:general/src/features/room/room.dart';
import '../../../../core/index.dart';

class FetchGiftCategoryUC
    extends UseCaseWithoutParams<BaseResponse<List<GiftCategoryModel>>> {
  final RoomBaseRepository _repo;

  const FetchGiftCategoryUC(this._repo);

  @override
  ResultFuture<BaseResponse<List<GiftCategoryModel>>> call() async {
    final result = await _repo.fetchGiftCategory();
    return result;
  }
}

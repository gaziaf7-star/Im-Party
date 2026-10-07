import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/bubble_padding.dart';
import 'package:general/src/features/room/domain/base_repository/room_base_repository.dart';

class GetBubblePaddingUc
    extends UseCaseWithoutParams<BaseResponse<List<BubblePadding>>> {
  final RoomBaseRepository _repo;

  GetBubblePaddingUc(this._repo);

  @override
  ResultFuture<BaseResponse<List<BubblePadding>>> call() async {
    return await _repo.fetchBubblePadding();
  }
}

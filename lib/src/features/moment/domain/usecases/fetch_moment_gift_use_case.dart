import 'package:general/src/features/moment/data/models/moment_gift_model.dart';
import 'package:general/src/features/moment/moment.dart';

import '../../../../core/index.dart';

class FetchMomentGiftUseCase extends UseCaseWithParams<BaseResponse<List<MomentGiftModel>>, int > {
  final BaseMomentRepository baseMomentRepository;
  const FetchMomentGiftUseCase({required this.baseMomentRepository});

  @override
  ResultFuture<BaseResponse<List<MomentGiftModel>>> call(params) async {
    return await baseMomentRepository.fetchGiftMoment(userId: params);
  }
}
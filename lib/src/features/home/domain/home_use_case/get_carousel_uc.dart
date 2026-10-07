import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/domain/repository/base_home_repository.dart';

import '../../data/model/carousel_model.dart';

class GetCarouselUc extends UseCaseWithParams<BaseResponse<List<CarouselModel>>,
    CountryParams> {
  final BaseHomeRepository _repo;

  GetCarouselUc(this._repo);

  @override
  ResultFuture<BaseResponse<List<CarouselModel>>> call(CountryParams param) {
    return _repo.getCarousel(param);
  }
}

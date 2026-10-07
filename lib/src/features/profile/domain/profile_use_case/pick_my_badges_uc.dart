import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';
import '../../../../core/index.dart';

class PickMyBadgesUC extends UseCaseWithParams<String,List<int>>{


  final ProfileBaseRepository _repository ;


  PickMyBadgesUC( this._repository);

  @override
  ResultFuture<String> call(List<int> params)async {
    final result= await _repository.pickMyBadges(params) ;
    return result ;
  }


}
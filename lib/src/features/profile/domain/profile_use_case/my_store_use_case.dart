import 'package:general/src/features/auth/auth.dart';

import '../../../../core/base/base_repository.dart';
import '../../../../core/base/base_use_case.dart';
import '../profile_base_repository/profile_base_repository.dart';

class MyStoreUseCase extends UseCaseWithoutParams <MyStoreModel>{
  final ProfileBaseRepository baseRepositoryProfile
;


  const MyStoreUseCase({required this.baseRepositoryProfile});


  @override
  ResultFuture<MyStoreModel> call() {
    return baseRepositoryProfile.myStore();
  }
}

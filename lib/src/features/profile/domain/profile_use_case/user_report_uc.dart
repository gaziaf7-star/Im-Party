import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/domain/profile_base_repository/profile_base_repository.dart';



class UserReportUseCase extends UseCaseWithParams<String,UserReportParameter>{

  ProfileBaseRepository baseRepositoryProfile;

  UserReportUseCase({ required this.baseRepositoryProfile});

  @override
  ResultFuture <String> call(UserReportParameter params) async {
   final result = await baseRepositoryProfile.userReport(userReport: params);

   return result ;
  }


}

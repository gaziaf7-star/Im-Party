import 'package:general/src/features/auth/data/model/agency_badge_model.dart';
import 'package:general/src/features/auth/domain/repository/base_auth_repository.dart';
import 'package:general/src/features/chats/chats.dart';

class GetAgencyBadgesUc extends UseCaseWithoutParams<List<AgencyBadgeModel>> {
  final BaseAuthenticationRepository _repo;

  GetAgencyBadgesUc(this._repo);

  @override
  ResultFuture<List<AgencyBadgeModel>> call() async {
    final result = await _repo.getAgencyBadges();
    return result;
  }
}

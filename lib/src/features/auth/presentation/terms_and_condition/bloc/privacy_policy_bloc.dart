

import 'package:general/src/core/index.dart';
import 'package:general/src/features/setting/data/model/privacy_policy.dart';
import 'package:general/src/features/setting/domain/use_case/privacy_policy_uc.dart';

part 'privacy_policy_state.dart';
part 'privacy_policy_event.dart';
class PrivacyPolicyBloc
    extends Bloc<BasePrivacyPolicyEvent, PrivacyPolicyState> {
  PrivacyPolicyUseCase privacyPolicyUseCase;
  PrivacyPolicyBloc({
    required this.privacyPolicyUseCase,
  }) : super(const PrivacyPolicyState()) {
    on<PrivacyPolicyEvent>((event, emit) async {
      emit(state.copyWith(requestState: RequestState.loading));
      final result = await privacyPolicyUseCase.call();

      result.fold(
          (l) => emit(state.copyWith(errorPrivacy: NetworkExceptions.getErrorMessage(l),requestState: handleErrorResponse(l))),
          (r) => emit(
              state.copyWith(messagePrivacy: r,requestState: handleLoadedResponse<PrivacyPolicy>(r))));
    });
  }
}

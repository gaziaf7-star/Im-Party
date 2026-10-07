import 'dart:async';
import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/setting/domain/entities/earn_invite_entity.dart';
import 'package:general/src/features/setting/domain/entities/invite_user_entity.dart';
import 'package:general/src/features/setting/domain/use_case/add_invitation_code.dart';
import 'package:general/src/features/setting/domain/use_case/claim_invite_bonus_us.dart';
import 'package:general/src/features/setting/domain/use_case/explain_invitation_us.dart';
import 'package:general/src/features/setting/domain/use_case/extract_invite_coins_us.dart';
import 'package:general/src/features/setting/domain/use_case/get_invite_user_us.dart';
import 'package:general/src/features/setting/domain/use_case/get_my_earn_invite.dart';
import 'package:general/src/features/setting/domain/use_case/send_invitation_code_us.dart';
import '../../../../../core/index.dart';

part 'invite_event.dart';

part 'invite_state.dart';

class SendInviteBloc extends Bloc<BaseInviteEvent, SendInviteState> {
  final SendInvitationCodeUseCase sendInvitationCodeUseCase;
  final GetMyEarnInviteUseCase getMyEarnInviteUseCase;
  final GetInviteUserUseCase getEarnInviteUserUseCase;
  final ExplainInviteUseCase explainInviteUseCase;
  final AddInviteCodeUseCase addInviteCodeUseCase;
  final ExtractInviteCoinsUseCase extractInviteCoinsUseCase;
  final ClaimInviteBonusUseCase claimInviteBonusUseCase;

  SendInviteBloc({
    required this.sendInvitationCodeUseCase,
    required this.getMyEarnInviteUseCase,
    required this.getEarnInviteUserUseCase,
    required this.explainInviteUseCase,
    required this.addInviteCodeUseCase,
    required this.extractInviteCoinsUseCase,
    required this.claimInviteBonusUseCase,
  }) : super(SendInviteState(
            codeController: TextEditingController(),
            formKey: GlobalKey<FormState>())) {
    on<SendCodeEvent>(_sendCodeInvite);
    on<GetMyEarnInviteEvent>(_getMyEarnInvite);
    on<GetEarnInviteUserEvent>(_getEarnInviteUser);
    on<ExplainInviteEvent>(_explainInvite);
    on<AddInviteEvent>(_addInvite);
    on<ExtractInviteCoinsEvent>(_extractInviteCoins);
    on<ClaimInviteBonusEvent>(_claimInviteBonus);
  }

  FutureOr<void> _sendCodeInvite(
      SendCodeEvent event, Emitter<SendInviteState> emit) async {
    if (state.formKey.currentState?.validate() == false) {
      return;
    }
    emit(
      state.copyWith(
        sendInviteCodeRequest: RequestState.loading,
      ),
    );

    final result = await sendInvitationCodeUseCase(event.code);
    result.fold(
      (left) => emit(
        state.copyWith(
          sendInviteCodeRequest: handleErrorResponse(left),
          errorSendInviteMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) async {
        emit(
          state.copyWith(
            sendInviteCodeRequest: handleLoadedResponse(right.data),
            successSendInviteCode: right.data,
          ),
        );
      },
    );
  }

  FutureOr<void> _getMyEarnInvite(
      GetMyEarnInviteEvent event, Emitter<SendInviteState> emit) async {
    emit(state.copyWith(getMyEarnInviteRequest: RequestState.loading));
    final result = await getMyEarnInviteUseCase();

    result.fold(
      (left) => emit(
        state.copyWith(
          getMyEarnInviteRequest: handleErrorResponse(left),
          getMyEarnInvitesError: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) async {
        emit(
          state.copyWith(
            getMyEarnInviteRequest: handleLoadedResponse(right.data),
            getMyEarnInviteSuccess: right.data,
          ),
        );
      },
    );
  }

  FutureOr<void> _getEarnInviteUser(
      GetEarnInviteUserEvent event, Emitter<SendInviteState> emit) async {
    emit(state.copyWith(getInviteUserRequest: RequestState.loading));
    final result = await getEarnInviteUserUseCase();

    result.fold(
      (left) => emit(
        state.copyWith(
          getInviteUserRequest: handleErrorResponse(left),
          getInviteUserError: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) async {
        emit(
          state.copyWith(
            getInviteUserRequest: handleLoadedResponse(right.data),
            getInviteUserSuccess: right.data,
          ),
        );
      },
    );
  }

  FutureOr<void> _explainInvite(
      ExplainInviteEvent event, Emitter<SendInviteState> emit) async {
    emit(state.copyWith(explainInviteRequest: RequestState.loading));
    final result = await explainInviteUseCase();

    result.fold(
      (left) => emit(
        state.copyWith(
          explainInviteRequest: handleErrorResponse(left),
          explainInviteMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) async {
        emit(
          state.copyWith(
            explainInviteRequest: handleLoadedResponse(right.data),
            explainInviteSuccess: right.data,
          ),
        );
      },
    );
  }

  FutureOr<void> _addInvite(
      AddInviteEvent event, Emitter<SendInviteState> emit) async {
    emit(state.copyWith(addInviteRequest: RequestState.loading));
    final result = await addInviteCodeUseCase(event.code);

    result.fold(
      (left) => emit(
        state.copyWith(
          addInviteRequest: handleErrorResponse(left),
          addInviteMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) async {
        emit(
          state.copyWith(
            addInviteRequest: handleLoadedResponse(right.data),
            addInviteSuccess: right.data,
          ),
        );
      },
    );
  }

  FutureOr<void> _extractInviteCoins(
      ExtractInviteCoinsEvent event, Emitter<SendInviteState> emit) async {
    if (state.extractCoinsRequest.isLoading) return;
    emit(state.copyWith(extractCoinsRequest: RequestState.loading));
    final result = await extractInviteCoinsUseCase();

    await result.fold(
      (left) async => emit(
        state.copyWith(
          extractCoinsRequest: handleErrorResponse(left),
          extractCoinsMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) async {
        emit(
          state.copyWith(
            extractCoinsRequest: handleLoadedResponse(right.data),
            extractCoinsMessage: right.message,
          ),
        );
        add(GetMyEarnInviteEvent());
      },
    );
  }

  FutureOr<void> _claimInviteBonus(
      ClaimInviteBonusEvent event, Emitter<SendInviteState> emit) async {
    if (state.claimBonusRequest.isLoading) return;
    emit(state.copyWith(claimBonusRequest: RequestState.loading));
    final result = await claimInviteBonusUseCase();

    await result.fold(
      (left) async => emit(
        state.copyWith(
          claimBonusRequest: handleErrorResponse(left),
          claimBonusMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) async {
        emit(
          state.copyWith(
            claimBonusRequest: handleLoadedResponse(right.data),
            claimBonusMessage: right.message,
          ),
        );
        add(GetMyEarnInviteEvent());
      },
    );
  }

  @override
  Future<void> close() {
    state.codeController.dispose();

    return super.close();
  }
}

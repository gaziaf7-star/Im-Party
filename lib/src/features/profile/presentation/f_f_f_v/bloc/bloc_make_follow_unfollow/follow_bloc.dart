import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/games/presentation/meet/bloc/online_users/online_users_bloc.dart';
import 'package:general/src/features/profile/domain/profile_use_case/follow_unfollow_use_case.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_event.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_event.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_make_follow_unfollow/follow_state.dart';

class FollowBloc extends Bloc<BaseFollowEvent, FollowState> {
  final MakeUnFollowUseCase makeUnFollowUseCase;
  final MakeFollowUseCase makeFollowUseCase;

  FollowBloc({
    required this.makeUnFollowUseCase,
    required this.makeFollowUseCase,
  }) : super(FollowInitial()) {
    on<FollowEvent>(_makeFollowEvent);
    on<UnFollowEvent>(_makeUnFollowEvent);
  }

  Future<void> _makeFollowEvent(
      FollowEvent event, Emitter<FollowState> emit) async {
    // Optimistic update: emit success immediately
    emit(const FollowSuccessState(
      massage: BaseResponse<String>(
        success: true,
        message: '',
        data: null,
      ),
    ));

    final result = await makeFollowUseCase.call(
      event.userEntity.id.toString(),
    );

    result.fold(
      (left) => emit(
          FollowErrorState(error: NetworkExceptions.getErrorMessage(left))),
      (right) {
        di<GetFollowerOrFollowingBloc>().add(
          MakeFollowLocallyEvent(
            userId: event.userEntity.id.toString(),
            relationType: event.relationType ?? RelationType.following,
          ),
        );
        if (event.index != null) {
          di<OnlineUsersBloc>()
              .add(ChangeUserOnlineLocally(index: event.index ?? 0));
        }
      },
    );
  }

  Future<void> _makeUnFollowEvent(
    UnFollowEvent event,
    Emitter<FollowState> emit,
  ) async {
    // Optimistic update: emit success immediately
    emit(const UnFollowSuccessState(
      massage: BaseResponse<String>(
        success: true,
        message: '',
        data: null,
      ),
    ));

    final result = await makeUnFollowUseCase.call(event.userId);

    result.fold(
      (left) => emit(
          UnFollowErrorState(error: NetworkExceptions.getErrorMessage(left))),
      (right) {
        di<GetFollowerOrFollowingBloc>().add(
          MakeUnfollowLocallyEvent(
            userId: event.userId,
            relationType: event.relationType ?? RelationType.following,
          ),
        );
      },
    );
  }

  void updateFollowAndUnfollow({
    UserEntity? userEntity,
    RelationType? relationType,
  }) {
    if (relationType == RelationType.profile) {
    } else {
      di<GetFollowerOrFollowingBloc>().add(
        MakeUnfollowLocallyEvent(
          userId: '${userEntity?.id}',
          relationType: relationType ?? RelationType.following,
        ),
      );
    }
  }
}

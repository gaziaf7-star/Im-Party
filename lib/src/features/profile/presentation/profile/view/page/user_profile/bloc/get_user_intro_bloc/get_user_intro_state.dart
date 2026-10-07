import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/user_intro_model.dart';

class GetUserIntroState extends Equatable {
  final List<UserIntroModel>? userIntroModel;
  final NetworkExceptions? errorMessage;
  final RequestState requestState;
  final String? loadedUserId;


  const GetUserIntroState({
    this.userIntroModel,
    this.errorMessage,
    this.requestState=RequestState.idle,
    this.loadedUserId,

  });

  GetUserIntroState copyWith({
    List<UserIntroModel>? userIntroModel ,
    NetworkExceptions? errorMessage,
    RequestState? requestState,
    String? loadedUserId,
  }) {
    return GetUserIntroState(
      userIntroModel: userIntroModel ?? this.userIntroModel,
      requestState: requestState ?? this.requestState,
      errorMessage: errorMessage ?? this.errorMessage,
      loadedUserId: loadedUserId ?? this.loadedUserId,

    );
  }

  @override
  List<Object?> get props => [
    userIntroModel,
    requestState,
    errorMessage,
    loadedUserId,
  ];
}

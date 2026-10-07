import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/level_model.dart';

class GetMyLevelState extends Equatable {
  final LevelModel? myLevel;
  final RequestState myLevelState;
  final String myLevelMessage;

  const GetMyLevelState({
    this.myLevel,
    this.myLevelState = RequestState.loading,
    this.myLevelMessage = '',
  });

  GetMyLevelState copyWith({
    LevelModel? myLevel,
    RequestState? myLevelState,
    String? myLevelMessage,
  }) {
    return GetMyLevelState(
      myLevel: myLevel ?? this.myLevel,
      myLevelState: myLevelState ?? this.myLevelState,
      myLevelMessage: myLevelMessage ?? this.myLevelMessage,
    );
  }

  @override
  List<Object?> get props => [
        myLevel,
        myLevelState,
        myLevelMessage,
      ];
}

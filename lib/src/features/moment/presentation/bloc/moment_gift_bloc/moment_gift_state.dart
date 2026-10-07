import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/domain/entities/moment_gift.dart'; // Assuming RequestState is in core/index.dart

class MomentGiftState extends Equatable {
  final List<MomentGiftEntity> momentGiftList;
  final RequestState reqState;
  final String message;


  const MomentGiftState({
    this.momentGiftList = const [],
    this.reqState = RequestState.loading,
    this.message = '',
  });

  MomentGiftState copyWith({
    List<MomentGiftEntity>? momentGiftList,
    RequestState? reqState,
    String? message,
  }) {
    return MomentGiftState(
      momentGiftList: momentGiftList ?? this.momentGiftList,
      reqState: reqState ?? this.reqState,
      message: message ?? this.message,

    );
  }

  @override
  List<Object?> get props => [
    momentGiftList,
    reqState,
    message,
  ];
}
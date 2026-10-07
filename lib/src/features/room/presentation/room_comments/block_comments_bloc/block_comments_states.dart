part of 'block_comments_bloc.dart';

class BlockCommentsStates extends Equatable {
  final String blockMessage;
  final RequestState reqState;

  const BlockCommentsStates({
    this.blockMessage = '',
    this.reqState = RequestState.idle,
    
  });

  BlockCommentsStates copyWith({
    String? blockMessage,
    
    RequestState? reqState,
  }) {
    return BlockCommentsStates(
      blockMessage: blockMessage ?? this.blockMessage,
      reqState: reqState ?? this.reqState,
    );
  }

  @override
  List<Object?> get props => [
        reqState,
        blockMessage
      ];
}

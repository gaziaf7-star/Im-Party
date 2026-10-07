part of 'delete_song_bloc.dart';

class DeleteSongState extends Equatable {
  final RequestState? requestState;
  final String? message;

  const DeleteSongState({this.requestState, this.message});

  DeleteSongState copyWith({
    RequestState? requestState,
    String? message,
  }) {
    return DeleteSongState(
      message:
      message ?? this.message ,requestState: requestState ?? this.requestState,

    );
  }

  @override
  List<Object?> get props => [requestState, message];
}


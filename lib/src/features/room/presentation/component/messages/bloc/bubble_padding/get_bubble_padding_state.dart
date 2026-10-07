part of 'get_bubble_padding_bloc.dart';

class GetBubblePaddingState extends Equatable {
  final RequestState state;
  final String message;
  final List<BubblePadding>? data;

  const GetBubblePaddingState({
    this.state = RequestState.idle,
    this.message = '',
    this.data,
  });

  GetBubblePaddingState copyWith({
    RequestState? state,
    String? message,
    List<BubblePadding>? data,
  }) {
    return GetBubblePaddingState(
      state: state ?? this.state,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [state, message, data];
}

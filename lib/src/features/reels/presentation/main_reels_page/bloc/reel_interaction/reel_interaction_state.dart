part of 'reel_interaction_bloc.dart';

class ReelInteractionState extends Equatable {
  final bool readMore;
  final double? height;
  final double bottomPadding;
  final bool isCommentsOpened;
  final ReelsEntity? currentReelCommentsViewed;

  const ReelInteractionState({
    this.readMore = false,
    this.height = 20.0,
    this.bottomPadding = 0.0,
    this.isCommentsOpened = false,
    this.currentReelCommentsViewed,
  });

  ReelInteractionState copyWith({
    bool? readMore,
    double? height,
    double? bottomPadding,
    bool? isCommentsOpened,
    ReelsEntity? currentReelCommentsViewed,
  }) {
    return ReelInteractionState(
      readMore: readMore ?? this.readMore,
      height: height ?? this.height,
      bottomPadding: bottomPadding ?? this.bottomPadding,
      isCommentsOpened: isCommentsOpened ?? this.isCommentsOpened,
      currentReelCommentsViewed:
          currentReelCommentsViewed ?? this.currentReelCommentsViewed,
    );
  }

  @override
  List<Object?> get props => [
        readMore,
        height,
        bottomPadding,
        isCommentsOpened,
        currentReelCommentsViewed,
      ];
}

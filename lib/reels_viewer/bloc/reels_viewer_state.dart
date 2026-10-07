
import '../reels_viewer.dart';

class ReelViewerState extends Equatable {
  final bool isPlaying;
  final int activeReelIndex;
  final ReelsType reelsType;
  final bool isMute;

  const ReelViewerState(
      {this.isPlaying = true, this.activeReelIndex = 0, this.reelsType = ReelsType
          .forYou, this.isMute = false});

  ReelViewerState copyWith(
      {bool? isPlaying, int? activeReelIndex, ReelsType? reelsType, bool? isMute}) {
    return ReelViewerState(
        isPlaying: isPlaying ?? this.isPlaying,
        activeReelIndex: activeReelIndex ?? this.activeReelIndex,
        reelsType: reelsType ?? this.reelsType,
        isMute: isMute ?? this.isMute
    );
  }

  @override
  List<Object> get props => [isPlaying, activeReelIndex, reelsType, isMute];
}

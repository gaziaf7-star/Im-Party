import 'package:general/src/core/index.dart';

class RoomOverlayState extends Equatable {
  final bool showCharisma;
  final bool showPk;

  const RoomOverlayState({
    this.showCharisma = false,
    this.showPk = false,
  });

  RoomOverlayState copyWith({
    bool? showCharisma,
    bool? showPk,
  }) {
    return RoomOverlayState(
      showCharisma: showCharisma ?? this.showCharisma,
      showPk: showPk ?? this.showPk,
    );
  }

  @override
  List<Object?> get props => [showCharisma, showPk];
}

class RoomOverlayCubit extends Cubit<RoomOverlayState> {
  RoomOverlayCubit() : super(const RoomOverlayState());

  void setCharismaVisible(bool visible) {
    if (state.showCharisma != visible) {
      emit(state.copyWith(showCharisma: visible));
    }
  }

  void setShowPk(bool show) {
    if (state.showPk != show) {
      emit(state.copyWith(showPk: show));
    }
  }

  void resetToDefault() {
    emit(const RoomOverlayState());
  }
}

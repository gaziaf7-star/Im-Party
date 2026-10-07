import 'package:general/src/core/index.dart';

part 'layout_event.dart';
part 'layout_state.dart';

class LayoutBloc extends Bloc<LayoutEvent, LayoutState> {
  LayoutBloc() : super(const LayoutState()) {
    on<ChangeIndexEvent>(_changeIndexEvent);
  }

  void _changeIndexEvent(
    ChangeIndexEvent event,
    Emitter<LayoutState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.currentIdex));
  }
}

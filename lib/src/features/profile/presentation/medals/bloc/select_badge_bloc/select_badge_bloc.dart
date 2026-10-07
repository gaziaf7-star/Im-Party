import 'package:general/src/features/profile/presentation/medals/bloc/select_badge_bloc/select_badge_event.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/select_badge_bloc/select_badge_state.dart';

import '../../../../../../core/index.dart';

class SelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  SelectionBloc() : super(const SelectionState(selectedIds: [])) {
    on<SelectBadge>(_onSelectBadge);
    on<ClearSelection>(_onClearSelection);
  }

  void _onSelectBadge(
    SelectBadge event,
    Emitter<SelectionState> emit,
  ) {
    final selectedIds = List<int>.from(state.selectedIds);
    if (selectedIds.length >= 10 && !selectedIds.contains(event.badgeId)) {
      Methods.showToast(event.context, message: StringManager.pickMedals.tr());
    } else {
      if (selectedIds.contains(event.badgeId)) {
        selectedIds.remove(event.badgeId);
      } else if (selectedIds.length < 10) {
        selectedIds.add(event.badgeId);
      }
    }

    emit(state.copyWith(selectedIds: selectedIds));
  }

  void _onClearSelection(
    ClearSelection event,
    Emitter<SelectionState> emit,
  ) {
    emit(const SelectionState(selectedIds: []));
  }
}

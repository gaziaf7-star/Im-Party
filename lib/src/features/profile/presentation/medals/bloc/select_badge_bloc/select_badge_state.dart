import 'package:equatable/equatable.dart';

class SelectionState extends Equatable {
  final List<int> selectedIds;

  const SelectionState({required this.selectedIds});

  SelectionState copyWith({List<int>? selectedIds}) {
    return SelectionState(selectedIds: selectedIds ?? this.selectedIds);
  }

  @override
  List<Object?> get props => [selectedIds];
}

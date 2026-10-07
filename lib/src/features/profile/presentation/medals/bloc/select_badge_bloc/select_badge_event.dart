import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SelectionEvent extends Equatable {
  const SelectionEvent();

  @override
  List<Object?> get props => [];
}

class SelectBadge extends SelectionEvent {
  final int badgeId;
  final BuildContext context;

  const SelectBadge({required this.badgeId, required this.context});

  @override
  List<Object?> get props => [badgeId, context];
}

class ClearSelection extends SelectionEvent {
  const ClearSelection();
}

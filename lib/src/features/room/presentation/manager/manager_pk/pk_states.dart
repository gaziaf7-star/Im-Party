import 'package:equatable/equatable.dart';

abstract class PKStates extends Equatable {}

class InitailPKState extends PKStates {
  @override
  List<Object?> get props => [];
}

class ShowStateSuccess extends PKStates {
  @override
  List<Object?> get props => [];
}

class ShowStateError extends PKStates {
  final String errorMessage;

  ShowStateError({required this.errorMessage});

  @override
  List<Object?> get props => [];
}

class ShowStateLoading extends PKStates {
  @override
  List<Object?> get props => [];
}

class StartPKStateSuccess extends PKStates {
  @override
  List<Object?> get props => [];
}

class StartPKStateError extends PKStates {
  final String errorMessage;

  StartPKStateError({required this.errorMessage});

  @override
  List<Object?> get props => [];
}

class StartPKStateLoading extends PKStates {
  @override
  List<Object?> get props => [];
}

class ClosePKStateSuccess extends PKStates {
  @override
  List<Object?> get props => [];
}

class ClosePKStateError extends PKStates {
  final String errorMessage;

  ClosePKStateError({required this.errorMessage});

  @override
  List<Object?> get props => [];
}

class ClosePKStateLoading extends PKStates {
  @override
  List<Object?> get props => [];
}

class HidePKStateSuccess extends PKStates {
  @override
  List<Object?> get props => [];
}

class HidePKStateError extends PKStates {
  final String errorMessage;

  HidePKStateError({required this.errorMessage});

  @override
  List<Object?> get props => [];
}

class HidePKStateLoading extends PKStates {
  @override
  List<Object?> get props => [];
}

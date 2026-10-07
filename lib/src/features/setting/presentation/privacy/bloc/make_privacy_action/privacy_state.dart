part of'privacy_bloc.dart';

abstract class PrivacyState extends Equatable {
  @override
  List<Object> get props => [];
}

class PrivacyInitial extends PrivacyState {}

class LoadingState extends PrivacyState {}

class SuccessState extends PrivacyState {
  final String massege;

  SuccessState({required this.massege});
}

class ErrorState extends PrivacyState {
  final String massege;
  ErrorState({required this.massege});
}

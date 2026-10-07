import 'package:general/src/core/base/base_response.dart';
import 'package:equatable/equatable.dart';

abstract class FollowState extends Equatable {
  const FollowState();

  @override
  List<Object> get props => [];
}

class FollowInitial extends FollowState {}

class FollowSuccessState extends FollowState {
  final BaseResponse<String>  massage;
  const FollowSuccessState({required this.massage});
}

class FollowErrorState extends FollowState {
  final String error;
  const FollowErrorState({required this.error});
}

class FollowLoadingState extends FollowState {}

class UnFollowSuccessState extends FollowState {
  final BaseResponse<String> massage;
  const UnFollowSuccessState({required this.massage});
}

class UnFollowErrorState extends FollowState {
  final String error;
  const UnFollowErrorState({required this.error});
}

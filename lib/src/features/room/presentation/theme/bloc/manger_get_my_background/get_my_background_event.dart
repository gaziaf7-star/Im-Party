
import 'package:equatable/equatable.dart';

abstract class BaseGetMyBackgroundEvent extends Equatable {
  const BaseGetMyBackgroundEvent();

  @override
  List<Object?> get props => [];
}

class GetMyBackgroundEvent extends BaseGetMyBackgroundEvent{
  final bool isLoading;
  const GetMyBackgroundEvent({this.isLoading = true});
    @override
  List<Object?> get props => [isLoading];
}


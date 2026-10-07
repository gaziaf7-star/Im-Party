import 'package:equatable/equatable.dart';

abstract class BaseGetBlockListEvent extends Equatable {

  const BaseGetBlockListEvent();

  @override
  List<Object?> get props => [

  ];
}

class GetBlockListEvent extends BaseGetBlockListEvent {
  final bool isLoading;
  const GetBlockListEvent({this.isLoading = true});
  @override
  List<Object?> get props => [
    isLoading
  ];
}

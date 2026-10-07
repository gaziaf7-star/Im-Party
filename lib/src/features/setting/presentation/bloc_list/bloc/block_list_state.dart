import '../../../../auth/auth.dart';


import 'package:general/src/core/index.dart';

class GetBlockListState extends Equatable {
  final NetworkExceptions? errorMsg;
  final RequestState requestStateBlockList;
  final List<UserEntity>? blackListModel;



   const GetBlockListState({
    this.errorMsg,
    this.blackListModel =const [],
    this.requestStateBlockList = RequestState.loading,


  });

  GetBlockListState copyWith({
    NetworkExceptions? errorMsg,
    RequestState? requestStateBlockList,
    List<UserEntity>? blackListModel,

  }) {
    return GetBlockListState(
      errorMsg: errorMsg ?? this.errorMsg,
      requestStateBlockList: requestStateBlockList ?? this.requestStateBlockList,
      blackListModel: blackListModel ?? this.blackListModel,

    );
  }

  @override
  List<Object?> get props => [
    errorMsg,
    requestStateBlockList,
    blackListModel,
  ];
}

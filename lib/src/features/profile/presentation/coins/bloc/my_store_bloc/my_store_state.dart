part of'my_store_bloc.dart';

class MyStoreState extends Equatable{
  final MyStoreEntity? myStore;
  final RequestState reqState;
  final String? message;

  const MyStoreState(
      {this.myStore,
        this.reqState = RequestState.idle,
        this.message = '',});

  MyStoreState copyWith({
    MyStoreEntity? myStore,
    RequestState? reqState,
    String? message,
  }) {
    return MyStoreState(
      myStore: myStore??this.myStore,
      reqState: reqState??this.reqState,
      message: message??this.message,
    );
  }

  @override
  List<Object?> get props => [
    myStore,
    reqState,
    message,
  ];
}
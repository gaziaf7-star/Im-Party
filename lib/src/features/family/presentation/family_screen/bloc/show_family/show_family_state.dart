part of 'show_family_bloc.dart';


class ShowFamilyState extends Equatable {
  final ShowFamilyEntity? showFamilyEntity;
  final String? message;
  final RequestState reqState;

  const ShowFamilyState({
    this.showFamilyEntity ,
    this.message ,
    this.reqState = RequestState.loading,
  });

  ShowFamilyState copyWith({
    ShowFamilyEntity? showFamilyEntity,
    String? message,
    RequestState? reqState,
  }) {
    return ShowFamilyState(
      showFamilyEntity: showFamilyEntity ?? this.showFamilyEntity,
      message: message ?? this.message,
      reqState: reqState ?? this.reqState,
    );
  }

  @override
  List<Object?> get props => [
    showFamilyEntity,
    message,
    reqState,
  ];
}
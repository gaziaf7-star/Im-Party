import 'package:general/src/core/index.dart';

class BuyCoinsState extends Equatable {
  final String? data;
  final RequestState reqState;
  final RequestState reqStateRedirect;
  final String error;
  final String errorRedirect;
  final int selectedTab;
  final int controllerIndex;
  final bool changeText;

  const BuyCoinsState({
    this.data,
    this.selectedTab = 0,
    this.controllerIndex = 0,
    this.reqState = RequestState.idle,
    this.reqStateRedirect = RequestState.idle,
    this.error = "",
    this.errorRedirect = "",
    this.changeText = true,
  });

  BuyCoinsState copyWith({
    String? data,
    RequestState? reqState,
    RequestState? reqStateRedirect,
    String? error,
    String? errorRedirect,
    int? selectedTab,
    int? controllerIndex,
    bool? changeText,
  }) {
    return BuyCoinsState(
        data: data ?? this.data,
        reqState: reqState ?? this.reqState,
        reqStateRedirect: reqStateRedirect ?? this.reqStateRedirect,
        error: error ?? this.error,
        errorRedirect: errorRedirect ?? this.errorRedirect,
        selectedTab: selectedTab ?? this.selectedTab,
        controllerIndex: controllerIndex ?? this.controllerIndex,
        changeText: changeText ?? this.changeText);
  }

  @override
  List<Object?> get props => [
        data,
        reqState,
    reqStateRedirect,
        error,
        selectedTab,
        changeText,
        controllerIndex,
    errorRedirect,
      ];
}

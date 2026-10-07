part of 'charisma_bloc.dart';

class CharismaState extends Equatable {
  final List<CharismaModel>? data;
  final String errorMsgStart;
  final String errorMsgReset;
  final String errorMsgExtraData;
  final bool stateCharisma;
  final RequestState reqStateStart;
  final RequestState reqStateExtraData;
  final RequestState reqStateReset;

  const CharismaState({
    this.data,
    this.errorMsgStart = '',
    this.errorMsgReset = '',
    this.errorMsgExtraData = '',
    this.reqStateStart = RequestState.idle,
    this.stateCharisma = false,
    this.reqStateExtraData = RequestState.idle,
    this.reqStateReset = RequestState.idle,
  });

  CharismaState copyWith({
    List<CharismaModel>? data,
    String? errorMsgStart,
    String? errorMsgReset,
    String? errorMsgExtraData,
    bool? stateCharisma,
    RequestState? reqStateStart,
    RequestState? reqStateExtraData,
    RequestState? reqStateReset,
  }) {
    return CharismaState(
      data: data ?? this.data,
      errorMsgStart: errorMsgStart ?? this.errorMsgStart,
      errorMsgReset: errorMsgReset ?? this.errorMsgReset,
      errorMsgExtraData: errorMsgExtraData ?? this.errorMsgExtraData,
      stateCharisma: stateCharisma ?? this.stateCharisma,
      reqStateStart: reqStateStart ?? this.reqStateStart,
      reqStateExtraData: reqStateExtraData ?? this.reqStateExtraData,
      reqStateReset: reqStateReset ?? this.reqStateReset,
    );
  }

  @override
  List<Object?> get props => [
        data,
        errorMsgStart,
        errorMsgReset,
        stateCharisma,
        reqStateStart,
        reqStateExtraData,
        reqStateReset,
        errorMsgExtraData,
      ];
}

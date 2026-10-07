import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/gift_history_model.dart';

class GiftHistoryState extends Equatable {
  final List<GiftHistoryModel>? giftModel ;
  final NetworkExceptions? errorMessage;
  final RequestState requestState;
  final String? lastLoadedId;


  const GiftHistoryState({
    this.giftModel,
    this.errorMessage,
    this.requestState=RequestState.idle,
    this.lastLoadedId,

  });

  GiftHistoryState copyWith({
    List<GiftHistoryModel>? giftModel ,
    NetworkExceptions? errorMessage,
    RequestState? requestState,
    String? lastLoadedId,
  }) {
    return GiftHistoryState(
      giftModel: giftModel ?? this.giftModel,
      requestState: requestState ?? this.requestState,
      errorMessage: errorMessage ?? this.errorMessage,
      lastLoadedId: lastLoadedId ?? this.lastLoadedId,

    );
  }

  @override
  List<Object?> get props => [
    giftModel,
    requestState,
    errorMessage,
    lastLoadedId,
  ];
}

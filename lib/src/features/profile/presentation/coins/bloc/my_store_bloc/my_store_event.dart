part of'my_store_bloc.dart';

abstract class BaseMyStoreEvent extends Equatable {
  const BaseMyStoreEvent();

  @override
  List<Object> get props => [];
}

class GetMyStoreEvent extends BaseMyStoreEvent {
 final bool isLoading;
  const GetMyStoreEvent({this.isLoading=false});

}
class EditMyUserUsdLocally extends BaseMyStoreEvent {
 final int userUsd;
  const EditMyUserUsdLocally({required this.userUsd});

}
class EditMyAgentUsdLocally extends BaseMyStoreEvent {
 final int agentUsd;
  const EditMyAgentUsdLocally({required this.agentUsd});

}
class EditMyCoinsAndDiamondsLocally extends BaseMyStoreEvent {
 final int coins;
 final int diamonds;
  const EditMyCoinsAndDiamondsLocally({
    required this.coins,
    required this.diamonds
  });

}

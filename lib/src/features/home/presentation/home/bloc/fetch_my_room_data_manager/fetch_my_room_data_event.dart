import 'package:general/src/core/index.dart';

sealed class BaseFetchMyRoomDataEvent extends Equatable {
  const BaseFetchMyRoomDataEvent();
  @override
  List<Object?> get props => [];
}
 class FetchMyRoomDataEvent extends BaseFetchMyRoomDataEvent {
  const FetchMyRoomDataEvent();


}

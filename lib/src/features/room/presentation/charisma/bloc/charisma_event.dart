part of'charisma_bloc.dart';

abstract class CharismaEvent extends Equatable {
  const CharismaEvent();
}

class InitCharismaEvent extends CharismaEvent {
  const InitCharismaEvent();
  @override
  List<Object?> get props => [];
}

class StartCharismaEvent extends CharismaEvent {
  final String roomId;

  const StartCharismaEvent({required this.roomId});
  @override
  List<Object?> get props => [roomId];
}

class GetCharismaExtraDataEvent extends CharismaEvent {
  final String roomId;
  const GetCharismaExtraDataEvent({required this.roomId});
  @override
  List<Object?> get props => [roomId];
}

class ResetCharismaEvent extends CharismaEvent {
  final String roomId;
  final String ownerId;
  final BuildContext context;
  const ResetCharismaEvent({required this.roomId,required this.ownerId,required this.context});
  @override
  List<Object?> get props => [roomId,ownerId,context];
}

/// Writes the authoritative server charisma totals into the render state.
/// [data] carries each user's floored cumulative room total (totalValue) shipped
/// by the backend in the gift frame or enter-room payload. The server is the
/// source of truth, so a value always replaces the prior one.
class UpdateCharismaEvent extends CharismaEvent {
  final List<CharismaModel> data;

  const UpdateCharismaEvent({required this.data});
  @override
  List<Object?> get props => [data];
}

class FetchCharismaLevelsEvent extends CharismaEvent {
  const FetchCharismaLevelsEvent();
  @override
  List<Object?> get props => [];
}

/// Client-side accumulation fallback for when a gift frame carries the
/// per-gift value (`userGiftTP`) instead of the server's cumulative
/// `receiver_charisma_totals` map. Adds [giftValue] onto each of
/// [receiverIds]'s current badge total.
///
/// Needed on the SENDER's own device specifically: the sender's own
/// broadcast frame is never echoed back to itself by the realtime
/// transport, so without a local bump here the sender's badge only ever
/// catches up once the room is re-entered and re-seeded from the server.
class AccumulateCharismaFromGiftEvent extends CharismaEvent {
  final List<String> receiverIds;
  final int giftValue;

  const AccumulateCharismaFromGiftEvent({
    required this.receiverIds,
    required this.giftValue,
  });
  @override
  List<Object?> get props => [receiverIds, giftValue];
}

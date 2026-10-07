part of 'moment_gift_bloc.dart';

@immutable
abstract class MomentGiftEvent extends Equatable {
  const MomentGiftEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch a list of moment gifts.
class GetMomentGifts extends MomentGiftEvent {
  final int userId;
  const GetMomentGifts({required this.userId});

  @override
  List<Object> get props => [];
}


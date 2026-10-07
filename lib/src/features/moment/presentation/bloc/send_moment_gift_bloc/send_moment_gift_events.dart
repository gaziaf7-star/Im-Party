part of 'send_moment_gift_bloc.dart';

abstract class SendMomentGiftEvents extends Equatable {
  const SendMomentGiftEvents();

  @override
  List<Object?> get props => [];
}

class SendGiftsEvent extends SendMomentGiftEvents {
  final String momentID;
  final String giftId;
  final String number;

  const SendGiftsEvent({
    required this.momentID,
    required this.giftId,
    required this.number,
  });

  @override
  List<Object?> get props => [
        momentID,
        giftId,
        number,
      ];
}

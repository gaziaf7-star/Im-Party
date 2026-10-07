part of 'send_gift_bloc.dart';

abstract class SendGiftEvents extends Equatable {
  const SendGiftEvents();

  @override
  List<Object?> get props => [];
}

class SendGiftesEvent extends SendGiftEvents {
  final String roomId;
  final String id;
  final String toUid;
  final String num;
  final String typeGift;
  final bool toZego;
  final List<String> userSelected ;
  final List<String> userSelectedName ;
  final int selectedGiftPrice ;
  final int numberOfGifts ;
  final int myCoins ;
  final GiftsEntity? giftData ;

  const SendGiftesEvent({
    required this.roomId,
    required this.id,
    required this.toZego,
    required this.toUid,
    required this.num,
    required this.userSelected,
    required this.userSelectedName,
    required this.selectedGiftPrice,
    required this.numberOfGifts,
    required this.myCoins,
    required this.giftData,
    required this.typeGift,
  });

  @override
  List<Object?> get props => [
        roomId,
        id,
        toUid,
        num,
        toZego,
        userSelected,
        userSelectedName,
        selectedGiftPrice,
        numberOfGifts,
        myCoins,
        giftData,
        typeGift,
      ];
}

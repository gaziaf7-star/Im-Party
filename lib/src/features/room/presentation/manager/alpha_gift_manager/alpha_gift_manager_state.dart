abstract class AlphaGiftManagerState {
  const AlphaGiftManagerState();
}

class AlphaGiftManagerInitial extends AlphaGiftManagerState {}

class AlphaGiftManagerShowGift extends AlphaGiftManagerState {
  final String giftPath;
  final bool? isFamousGift;
  final bool isIntro;
  const AlphaGiftManagerShowGift({required this.giftPath,this.isFamousGift, this.isIntro = false});
}

class AlphaGiftManagerEndGift extends AlphaGiftManagerState {}

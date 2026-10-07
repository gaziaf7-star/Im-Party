abstract class AlphaGiftManagerEvent {
  const AlphaGiftManagerEvent();
}

class ShowAlphaGift extends AlphaGiftManagerEvent {
  final String imgFile;
  final bool? isFamousGift;
  final bool? isIntro;
  const ShowAlphaGift({required this.imgFile,this.isFamousGift,this.isIntro});
}

class EndAlphaGift extends AlphaGiftManagerEvent {
  const EndAlphaGift();
}

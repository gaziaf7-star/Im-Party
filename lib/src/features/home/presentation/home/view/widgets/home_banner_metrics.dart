import '../../../../../../core/index.dart';

/// The geometry of the banner block at the top of the home feed.
///
/// The wide banner and the pair of cards below it have to line up exactly: the
/// same left and right edge, the same rounding, and heights derived from the
/// available width rather than a fixed design height. Sizing them from a fixed
/// height is what left a strip of page background showing under the banner and
/// made the two rows different widths.
///
/// One place for the numbers so the banner and the cards cannot drift apart.
class HomeBannerMetrics {
  const HomeBannerMetrics._();

  /// Side inset, left and right.
  ///
  /// A 2px inset was tried first and is invisible on a 3x screen — the banner
  /// and the cards read as one block bleeding off both edges. These values are
  /// taken off the reference layout: the block sits about 3% of the screen in
  /// from each side, with a clear gap between every row.
  /// Measured off the reference layout (900x2000 screenshot of a 1080x2400
  /// screen, converted back to logical pixels): the block sits 12 in from each
  /// side, the rows are 12 and 8 apart, and the country filter clears the cards
  /// by 16.
  static const double edge = 12.0;

  /// Between the wide banner and the card row.
  static const double gapBannerToCards = 12.0;

  /// Between the two cards.
  static const double gapBetweenCards = 8.0;

  /// Below the card row, before the country filter — without this the chips
  /// read as if they are sitting on the cards.
  static const double gapCardsToFilter = 16.0;

  /// Retained for callers that only need "the standard gap".
  static const double gap = gapBetweenCards;

  /// Wide banner artwork is authored 1440x418 — measured from the art in the
  /// slot, not assumed. The box is sized from this so BoxFit.cover has nothing
  /// to crop and nothing of the page shows above or below the image.
  static const double bannerAspect = 1440 / 418;

  /// Card ratio measured off the reference layout: 163 logical wide by 80 tall.
  ///
  /// Anything portrait dropped into this slot will be cropped hard by
  /// BoxFit.cover — the slot needs art cut to this ratio.
  static const double cardAspect = 163 / 80;

  static double get radius => 12;

  // The constants above are DESIGN units. Everything that has to agree with a
  // real pixel width goes through these scaled getters, because the padding
  // helper the layout uses applies `.w` to whatever it is given — mixing a
  // scaled inset with an unscaled width calculation is how the rows ended up
  // different widths.
  static double get edgeW => edge.w;
  static double get gapCardsW => gapBetweenCards.w;

  /// Width available to the block once the side insets are removed.
  static double contentWidth() => ScreenUtil().screenWidth - (edgeW * 2);

  /// Height that makes the banner image fill its box exactly.
  static double bannerHeight() => contentWidth() / bannerAspect;

  /// Width of one card when two sit side by side with [gapBetweenCards].
  static double cardWidth() => (contentWidth() - gapCardsW) / 2;

  /// Height that makes a card image fill its box exactly.
  static double cardHeight() => cardWidth() / cardAspect;

  // ---------------------------------------------------------------- live strip

  /// The live/video row that interrupts the party list. Portrait tiles, about
  /// two and a half to a screen, matching the reference layout.
  static const double liveCardAspect = 150 / 175;
  static const double liveCardsPerScreen = 2.6;

  static double liveCardWidth() =>
      (contentWidth() - (gapCardsW * (liveCardsPerScreen - 1))) /
      liveCardsPerScreen;

  static double liveCardHeight() => liveCardWidth() / liveCardAspect;
}

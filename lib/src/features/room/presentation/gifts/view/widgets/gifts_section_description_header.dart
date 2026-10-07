import '../../../../../../../reels_viewer/reels_viewer.dart';

class GiftsSectionDescriptionHeader extends StatelessWidget {
  final TypeGift type;
  final Color backgroundColor;
  final double horizontalPadding;

  const GiftsSectionDescriptionHeader({
    super.key,
    required this.type,
    required this.backgroundColor,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    Methods.printLog('GiftsSectionDescriptionHeader type = "$type"');

    // 1️⃣ unknown / custom type (from default TypeGift._)
    if (!_config.containsKey(type)) {
      Methods.printLog('❌ GiftHeader: unsupported type -> $type');
      return const SizedBox.shrink();
    }

    final data = _config[type]!;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      padding: context.paddingSymmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          8.wBox,
          Image.asset(
            data.image,
            scale: 7,
          ),
          8.wBox,
          Expanded(
            child: type == TypeGift.lucky
                ? HighlightNumberText(
                    text: data.text.tr(),
                    highlight: '1000',
                    normalStyle: context.bodySmall.colorExt(Colors.grey),
                    highlightStyle: context.bodySmall.bold
                        .colorExt(ColorManager.countryYellow),
                  )
                : TextWidget(
                    data.text.tr(),
                    style: context.bodySmall.colorExt(Colors.grey),
                  ),
          ),
          if (MyDataModel.getInstance().vip1 == null)
            TextButton(
              onPressed: () {
                navKey.currentContext?.pushNamedRoute(Routes.vipScreen);
              },
              child: TextWidget(
                data.actionText,
                style: context.bodySmall.colorExt(data.actionColor),
              ),
            ),
        ],
      ),
    );
  }
}

final Map<TypeGift, _GiftHeaderConfig> _config = {
  TypeGift.vip: _GiftHeaderConfig(
    image: AssetsManager.crown,
    text: StringManager.vipHeaderText,
    actionText: StringManager.vipHeaderAction,
    actionColor: Colors.orange,
  ),
  TypeGift.cp: _GiftHeaderConfig(
    image: AssetsManager.luckyImage,
    text: StringManager.cpHeaderText,
    actionText: '',
    actionColor: Colors.pink,
  ),
  TypeGift.lucky: _GiftHeaderConfig(
    image: AssetsManager.luckyImage,
    text: StringManager.luckyHeaderText,
    actionText: '',
    actionColor: Colors.green,
  ),
};

class _GiftHeaderConfig {
  final String image;
  final String text;
  final String actionText;
  final Color actionColor;

  const _GiftHeaderConfig({
    required this.image,
    required this.text,
    required this.actionText,
    required this.actionColor,
  });
}

class HighlightNumberText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle normalStyle;
  final TextStyle highlightStyle;

  const HighlightNumberText({
    super.key,
    required this.text,
    required this.highlight,
    required this.normalStyle,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (!text.contains(highlight)) {
      return TextWidget(text, style: normalStyle);
    }

    final parts = text.split(highlight);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: parts[0], style: normalStyle),
          TextSpan(text: highlight, style: highlightStyle),
          TextSpan(text: parts[1], style: normalStyle),
        ],
      ),
    );
  }
}

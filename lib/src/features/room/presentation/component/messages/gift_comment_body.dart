import 'package:general/src/core/index.dart';

/// Shared inline gift content used by both audio-live and video-live comments.
/// The surrounding message item owns the sender avatar/name and bubble skin.
class GiftCommentBody extends StatelessWidget {
  const GiftCommentBody({
    super.key,
    required this.text,
    required this.giftImage,
  });

  final Widget text;
  final String giftImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(child: text),
        6.wBox,
        SizedBox(
          width: 36.w,
          height: 36.h,
          child: ImageViewWidget(url: giftImage, boxFit: BoxFit.contain),
        ),
      ],
    );
  }
}

part of '../medals_page.dart';

class BadgesItem extends StatelessWidget {
  const BadgesItem({
    super.key,
    required this.isPicked,
    required this.image,
  });
  final bool? isPicked;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().screenHeight * 0.06,
      width: ScreenUtil().screenWidth * 0.15,
      padding: context.paddingAll(10),
      decoration: BoxDecoration(
        color: isPicked == true ? Colors.cyan : const Color(0xFF101430),
        border: Border.all(color: Colors.white),
        borderRadius: 20.radius,
      ),
      child: ImageViewWidget(
        url: image!,
        height: ScreenUtil().screenHeight * 0.06,
        width: ScreenUtil().screenWidth * 0.15,
      ),
    );
  }
}

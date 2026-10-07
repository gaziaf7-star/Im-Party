import 'package:general/src/core/index.dart';

class ChatUpperTab extends StatelessWidget {
  final String image, title;
  final int index;
  final void Function() onTap;

  const ChatUpperTab({
    super.key,
    required this.image,
    required this.onTap,
    required this.title,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: context.paddingAll(5),
          margin: context.paddingAll(5),
          decoration: BoxDecoration(
            color: ColorManager.grey.withValues(alpha: (0.10 )),
            borderRadius: 4.radius,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                image,
                fit: index == 1 ? BoxFit.contain : BoxFit.cover,
                height: 30.h,
                width: index == 1 ? 40.w : 30.w,
              ),
              10.hBox,
              TextWidget(
                title,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
                style: context.bodySmall.colorExt(
                  ColorManager.secondaryText.withValues(alpha: (0.8 )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

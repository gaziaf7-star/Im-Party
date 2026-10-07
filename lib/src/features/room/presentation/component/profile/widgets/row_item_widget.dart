import 'package:general/src/core/index.dart';

class RowItemWidget extends StatelessWidget {
  const RowItemWidget({super.key, this.widget, this.title});

  final Widget? widget;
  final String? title;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.h,
      padding: context.paddingSymmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: 10.radius,
      ),
      child: Row(
        children: [
          TextWidget(
            title ?? '',
            // This card is always white. Using the global theme text color can
            // become white on a dark app theme, which made labels such as
            // "Gift" almost invisible. Resolve ink against the actual card.
            style: context.bodyLarge.w600
                .size(15)
                .colorExt(ColorManager.inkOn(Colors.white)),
          ),
          const Spacer(),
          widget ?? const SizedBox(),
          10.wBox,
          Icon(
            Icons.arrow_forward_ios_outlined,
            size: 18.sp,
            color: const Color(0xFF5F6368),
          )
        ],
      ),
    );
  }
}

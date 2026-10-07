import '../index.dart';

class GenderWidget extends StatelessWidget {
  final int age;
  final int gender;
  final int? widthSize;
  const GenderWidget(
      {super.key, required this.age, required this.gender, this.widthSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widthSize != null ? 7.w : 0,
        vertical: 1.h,
      ),
      width: widthSize?.w,
      decoration: BoxDecoration(
        borderRadius: 12.radius,
        color: gender == 1 ? Colors.blue : Colors.pink,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            gender == 1 ? Icons.male : Icons.female,
            color: ColorManager.white,
            size: 12.r,
          ),
          1.wBox,
          TextWidget(
            age.toString(),
            style: context.bodyMedium.size(9).colorExt(ColorManager.onDark),
          ),
        ],
      ),
    );
  }
}

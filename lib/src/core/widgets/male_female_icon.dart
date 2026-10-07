import 'package:general/src/core/index.dart';

class MaleFemaleIcon extends StatelessWidget {
  final int? maleOrFeamle;
  final int? age;
  final double? height;
  final double? width;
  const MaleFemaleIcon(
      {this.maleOrFeamle, this.age, this.height, this.width, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: maleOrFeamle == 1 ? ColorManager.blue : ColorManager.pink,
        borderRadius: BorderRadius.circular(80.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: maleOrFeamle == 1
                ? Image.asset(
                    AssetsManager.man,
                    scale: 9.w,
                  )
                : Image.asset(
                    AssetsManager.femaleIcon,
                    scale: 5.w,
                  ),
          ),
          5.wBox,
          Text(
            age == 0 ? '' : age.toString(),
            style: context.bodyMedium.size(8).colorExt(ColorManager.textPrimary),
          )
        ],
      ),
    );
  }
}

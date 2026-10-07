import '../../../../../../core/index.dart';

class ProblemType extends StatefulWidget {
  static int seletedMomentProblem = 0;

  //  static const String pornAr = ;
  //   static const String otherAr = ;
  //   static const String bullyingAr = ;
  //   static const String violenceAr = ;
  static List<String> types = [
    StringManager.porn.tr(),
    StringManager.bullying.tr(),
    StringManager.violence.tr(),
    StringManager.other.tr(),
  ];
  static List<String> typesArabic = [
    "اباحية",
    "تنمر",
    "عنف",
    "اخري",
  ];

  const ProblemType({super.key});

  @override
  State<ProblemType> createState() => _ProblemTypeState();
}

class _ProblemTypeState extends State<ProblemType> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35.h,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: ProblemType.types.length,
          itemBuilder: (context, index) {
            final isSelected = ProblemType.seletedMomentProblem == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  ProblemType.seletedMomentProblem = index;
                });
              },
              child: Container(
                margin: context.paddingSymmetric(horizontal: 6),
                padding: context.paddingSymmetric(horizontal: 16, vertical: 0),
                decoration: BoxDecoration(
                  // Pill shape + brand gradient when selected (was a sharp
                  // 4px-radius box, flat primary fill, harsh black border) —
                  // matches the rest of the redesigned report page.
                  borderRadius: 20.radius,
                  gradient: isSelected ? ColorManager.brandGradient : null,
                  color: isSelected ? null : ColorManager.greyLight,
                ),
                child: Center(
                  child: Text(
                    ProblemType.types[index],
                    style: context.bodyMedium.w500.colorExt(isSelected
                        ? ColorManager.white
                        : ColorManager.momentPostTextColor),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
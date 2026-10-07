import 'package:general/src/core/index.dart';

class PartTwo extends StatelessWidget {
  const PartTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingAll(10),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: 8.radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: (0.2 )), // Shadow color
            offset: const Offset(2, 4), // Shadow offset (x, y)
            blurRadius: 6, // Spread of the shadow
            spreadRadius: 2, // Intensity around the edges
          ),
        ],
      ),
      child: Column(
        children: [
          TextWidget(StringManager.invit.tr()),

        ],
      ),
    );
  }




}

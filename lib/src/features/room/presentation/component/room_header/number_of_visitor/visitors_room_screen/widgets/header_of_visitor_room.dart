import 'package:general/src/core/index.dart';


class HeaderOfVisitorRoom extends StatelessWidget {
  const HeaderOfVisitorRoom({required this.numberOfVisitor, super.key});
  final int numberOfVisitor;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ColorManager.mainColorList,
            end: Alignment.centerRight,
            begin: Alignment.centerLeft,
          ),
        ),
        child: Row(
          children: [
            const Spacer(
              flex: 8,
            ),
            Text(
              '$numberOfVisitor',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(
              flex: 1,
            ),
            Text(StringManager.visitors.tr(),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const Spacer(
              flex: 8,
            ),
          ],
        ));
  }
}

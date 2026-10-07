part of 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';

class ProfileCard extends StatelessWidget {
  final Widget child;
//final double verticalPadding;
  const ProfileCard(
      {super.key, required this.child, });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: context.paddingZero(),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.r))),
      child: Container(
        // Fixed white (was cardDecoration()'s panel-driven card
        // gradient/surfaceCardColor — this is what made the Mall row and the
        // whole My Room/Task/Check-in/... menu list render as a solid black
        // card with barely-visible dark text on top of it).
        decoration: const BoxDecoration(color: ColorManager.white),
        //margin: context.paddingAll(10),
        width: ScreenUtil().screenWidth,
        //  padding: context.paddingSymmetric(horizontal: 5,),
        child: child,
      ),
    );
  }
}
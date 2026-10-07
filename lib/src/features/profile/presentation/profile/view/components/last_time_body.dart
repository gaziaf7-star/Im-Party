import '../../../../../../../reels_viewer/reels_viewer.dart';

class LastTimeBody extends StatelessWidget {
  const LastTimeBody({super.key, this.title});
  final String? title;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorManager.transparent,
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Center(
          child: Row(children: [
            Text(
              "$title ",
              style: TextStyle(
                  color: ColorManager.textPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      ),
    );
  }
}

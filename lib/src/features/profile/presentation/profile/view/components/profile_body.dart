part of 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.data});

  final MyDataEntity data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mine gets its own header: the shared UserInfoRow put the flag on a
        // line of its own and showed no level/charm badges. See MineHeader.
        MineHeader(
          user: MyDataModel.getInstance().convertMyDataEntityToUserEntity(data),
          level: data.level,
          frame: data.frame ?? '',
        ),
        20.hBox,
        // Was a white card (with a soft shadow) behind this row. On request
        // it now sits directly on the shared Home-matching gradient behind
        // it, like the reference image — no card, just the stats text.
        Padding(
          padding: context.paddingOnly(start: 15.0, end: 15, top: 5, bottom: 20),
          child: FFLFBody(
            isMyProfile: true,
            horizontalP: 0.w,
            // Smaller than the 14/14 default, matching the reference
            // image's more compact "1 / 0 / 0 / 0.0" stats row.
            countFontSize: 15.0,
            labelFontSize: 11.5,
            data: MyDataModel.getInstance()
                .convertMyDataEntityToUserEntity(data),
          ),
        ),
        10.hBox,
        // SVIP promo card restored. Existing SecondCard tap/design logic is
        // reused unchanged; only the previous hidden placeholder is removed.
        const SecondCard(),
        10.hBox,
        const ThirdCardBody(),
        10.hBox,
      ],
    );
  }
}

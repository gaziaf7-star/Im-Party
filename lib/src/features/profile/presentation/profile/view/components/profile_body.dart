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
        // Small gap so the follow card sits close under the header.
        6.hBox,
        // Follow / fans / friends / visitors in a white card; the fixed
        // admin header image ends at this card's middle (see _FollowCard).
        Padding(
          padding: context.paddingOnly(bottom: 16),
          child: _FollowCard(child: FFLFBody(
            isMyProfile: true,
            horizontalP: 0.w,
            // Smaller than the 14/14 default, matching the reference
            // image's more compact "1 / 0 / 0 / 0.0" stats row.
            countFontSize: 15.0,
            labelFontSize: 10.5,
            data: MyDataModel.getInstance()
                .convertMyDataEntityToUserEntity(data),
          )),
        ),
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

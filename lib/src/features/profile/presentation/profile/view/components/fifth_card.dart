part of 'package:general/src/features/profile/presentation/profile/view/profile_screen.dart';

class FifthCard extends StatelessWidget {
  const FifthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        children: [

            ListTileBody(
              image: "AssetsManager.language",
              title: StringManager.language.tr(),
              onTap: () {
                Navigator.pushNamed(context, Routes.languageScreen);
              },
            ),
            ListTileBody(
              image:" AssetsManager.privacySetting",
              title: StringManager.vipPrivilege.tr(),
              onTap: () {
                context.pushNamedRoute(Routes.privacyScreen);
              },
            ),
            ListTileBody(
              image: AssetsManager.report,
              title: StringManager.feedBack.tr(),
              onTap: () => Navigator.pushNamed(context, Routes.problemReportsScreen),
            ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/domain/entities/third_party_entity.dart';
// The offline country list the home "More" dialog already uses, so the
// registration picker and the feed filter can never disagree.
import 'package:general/src/features/home/presentation/home/view/components/local_countries.dart';

part 'components/form_add_info_body.dart';

part 'components/pick_image_body.dart';

// Fixed text colors for this page. The app's normal text colors
// (ColorManager.textTabBar / textPrimary) are theme-adaptive — they pick a
// light or dark shade based on the app's overall panel background, which is
// dark. Since this page's background is force-locked to white above, that
// adaptive logic was still picking a light shade here and making the text
// hard to read. These are fixed "light black" shades instead, independent of
// theme, so text always stays readable on this page's white background.
const Color _kTextDark = Color(0xFF1C1C1E);
const Color _kTextMuted = Color(0xFF55555A);

class AddInformationPage extends StatefulWidget {
  const AddInformationPage({super.key});

  @override
  State<AddInformationPage> createState() => _AddInformationPageState();
}

class _AddInformationPageState extends State<AddInformationPage> {

  ThirdPartyEntity? kThirdPartyEntity;

  Future<void> _google() async {
    if ('${kThirdPartyEntity?.type}' == "google") {
      if (kThirdPartyEntity?.data.googleID.displayName != null) {
        di<AddInformationBloc>().add(
          UsernameEvent(
            name: kThirdPartyEntity?.data.googleID.displayName,
          ),
        );
      }

      if (kThirdPartyEntity?.data.googleID.photoUrl != null) {
        final File image = await Methods()
            .getImageFileFromNetwork(kThirdPartyEntity?.data.googleID.photoUrl);
        di<AddInformationBloc>().add(
          UserImageEvent(image: image),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    kThirdPartyEntity = di<AddInformationBloc>().state.kThirdPartyEntity;
    if (kThirdPartyEntity != null) {
      _google();
      // if ('${kThirdPartyEntity?.type}' == "apple") {
      //   if (kThirdPartyEntity?.data.givenName != null) {}
      // }
      // if ('${kThirdPartyEntity?.type}' == "huawei") {
      //   if (kThirdPartyEntity?.data.givenName != null) {}
      // }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Forced white background for this screen (was ColorManager.scaffoldBg,
      // which is theme/panel driven). Requested explicitly: this page always
      // shows white regardless of the app's dark/light theme setting.
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          // This prevents going back
          return false;
        },
        child: SafeArea(
          child: SingleChildScrollView(
            // Smoother, less "digital" scroll feel (iOS-style overscroll bounce)
            // instead of the default clamped physics.
            physics: const BouncingScrollPhysics(),
            child: BlocBuilder<AddInformationBloc, AddInformationState>(
              buildWhen: (prev, curr) => prev != curr,
              builder: (__, state) {
                // Gentle fade + rise-in on first build so the page never just
                // "pops" into view after Google sign-in — purely visual, no
                // change to any text size or field behaviour below.
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 16),
                      child: child,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      30.hBox,
                      TextWidget(
                        StringManager.hiTemp.tr(),
                        padding: context.paddingSymmetric(horizontal: 10),
                        style: context.bodyMedium.bold.size(22).colorExt(_kTextDark),
                      ),
                      2.hBox,
                      TextWidget(
                        StringManager.improveTheInfo2.tr(),
                        padding: context.paddingSymmetric(horizontal: 10),
                        textAlign: TextAlign.center,
                        style: context.bodySmall.w500.colorExt(_kTextMuted).size(14),
                      ),
                      40.hBox,
                      _FormAddInfoBody(state: state),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
/* Row(
                    children: [
                      Expanded(
                        child: GenderPickerWidget(
                          controller: __.gender,
                          onChanged: (value) {
                            di<AddInformationBloc>().add(
                              SelectedGenderEvent(
                                gender: value == 0
                                    ? StringManager.male.tr()
                                    : StringManager.female.tr(),
                              ),
                            );
                          },
                        ),
                      ),
                      16.wBox,
                      Expanded(
                        child: DatePickerWidget(
                          controller: __.birthday,
                          dateTime: __.birthday.text.isNotEmpty
                              ? DateTime.parse(
                                  Methods().convertNumerals(__.birthday.text,
                                      toEnglish: true),
                                )
                              : null,
                          onDateTimeChanged: (value) => context
                              .read<AddInformationBloc>()
                              .add(SelectedBirthdayEvent(dateTime: value)),
                        ),
                      ),
                    ],
                  ),*/
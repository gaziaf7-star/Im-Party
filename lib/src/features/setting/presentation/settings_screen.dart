import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/realtime/realtime_client.dart';
import 'package:general/src/core/services/auth_service.dart';
import 'switch_account_view/bloc/log_out_bloc/log_out_bloc.dart';

part 'switch_account_view/view/widgets/main_card.dart';
part 'switch_account_view/view/widgets/setting_single_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> settingsTitles = [
      StringManager.accountSettings.tr(),
      StringManager.language.tr(),
      StringManager.deleteAccount.tr(),
      StringManager.appSettings.tr(),
    ];

    List<String> settingsTitles2 = [
      StringManager.aboutUs.tr(),
      StringManager.blockList.tr(),
      StringManager.privacyPolicy.tr(),
      StringManager.vipPrivilege.tr(),
      StringManager.clearCache.tr(),
      StringManager.logOut.tr(),
    ];
    final normalPage = BlocListener<LogOutBloc, BaseLogOutState>(
      bloc: di<LogOutBloc>(),
      listener: (context, state) {
        if (state is LogOutSuccess) {
          // Tear down the Centrifugo realtime socket on logout (replaces the old
          // legacy realtime disconnect). Guarded + best-effort.
          if (di.isRegistered<RealtimeClient>()) {
            unawaited(di<RealtimeClient>().stop());
          }
          Methods.showToast(context, message: state.message);
          // Route through AuthService.clearToken() (the single auth-teardown
          // path) instead of deleting the Hive key directly, so the persistent
          // HTTP cache is purged on logout (defense-in-depth alongside the
          // per-user cache key). Deleting TOKEN_KEY here directly used to bypass
          // DioFactory.clearHttpCache().
          AuthService().clearToken();
          navKey.currentContext?.pushNamedAndRemoveUntil(Routes.intro);
        } else if (state is LogOutError) {
          Methods.showToast(context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: ColorManager.white,
        appBar: AppBarWidget(
          backgroundColor: ColorManager.white,
          iconColor: ColorManager.black,
          titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
          title: StringManager.settings.tr(),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(
              settingsTitles.length,
                  (index) {
                return Container(
                  width: ScreenUtil().screenWidth,
                  color: ColorManager.white,
                  child: SettingSingleItem(
                    margin: 18.h,
                    title: settingsTitles[index],
                    onTap: ConstantsManager.settingsOnTaps[index],
                  ),
                );
              },
            ),
            3.hBox,
            ...List.generate(
              settingsTitles2.length,
                  (index) {
                return SettingSingleItem(
                  margin: 1.5,
                  isPaddingContainer: true,
                  isLogOut: index == 5,
                  title: settingsTitles2[index],
                  onTap:
                  ConstantsManager.settingsOnTaps2(context: context)[index],
                );
              },
            ),
          ],
        ),
      ),
    );

    return normalPage;
  }
}
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/presentation/global/send_code/send_code_bloc.dart';
import 'package:general/src/features/setting/presentation/account_setting/bind_number/bind_number_bloc.dart';

part 'widgets/account_setting_item.dart';

class AccountSettingPage extends StatelessWidget {
  AccountSettingPage({super.key});

  String action = "";

  @override
  Widget build(BuildContext context) {
    List<Function()> accountSettingsOnTaps = [
          () {
        if (MyDataModel.getInstance().isPhone ?? false) {
          Methods.showToast(context, message: StringManager.yourPhoneIsFound.tr());
        } else {
          context.pushNamedRoute(
            Routes.bindNumber,
          );
        }
      },
          () {},
          () {
        if (MyDataModel.getInstance().isGoogle != true) {
          di<AccountBloc>().add(BindGoogleEvent(context: context));
        }
      },
          () {},
    ];
    return BlocListener<AccountBloc, AccountState>(
      bloc: di<AccountBloc>(),
      listener: (context, state) {
        if (state.googleAuthState == RequestState.error) {
          Methods.showToast(
            context,
            message: state.googleAuthError!,
            isError: true,
          );
        }
      },
      child: BlocListener<SendCodeBloc, SendCodeState>(
        listener: (context, state) {
          if (state.requestState == RequestState.loaded) {
            if (action == "changePassword") {
              context.pushNamedRoute(Routes.otp,
                  arguments: SendCodeParameter(otpType: OtpType.passwordChange,
                    phone: MyDataModel.getInstance().phone ?? '', ));
            }else if(action == "changePhoneNumber"){
              context.pushNamedRoute(Routes.otp,
                  arguments: SendCodeParameter(otpType: OtpType.verifyOldPhone,
                    phone: MyDataModel.getInstance().phone ?? '', ));
            }
          }

          if (state.requestState == RequestState.loading) {
            Methods.showToast(context, isLoading: true);
          }

          else if (state.requestState == RequestState.error) {
            Methods.showToast(context, message: state.message, isError: true);
          }
        },
        child: Scaffold(
          backgroundColor: ColorManager.white,
          appBar:  AppBarWidget(
            backgroundColor: ColorManager.white,
            iconColor: ColorManager.black,
            titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
            title: StringManager.accountSettings.tr(),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              8.hBox,
              SecurityItem(
                title: StringManager.changePassword.tr(),
                onTap: () {
                  if ((MyDataModel.getInstance().isPhone ?? false) &&
                      MyDataModel.getInstance().phone != null) {
                    action = "changePassword";
                    context.read<SendCodeBloc>().add(
                      SendCodeEvent(
                        context: context,
                        parameter: SendCodeParameter(
                          isDifferent: false,
                          phone: MyDataModel.getInstance().phone ?? '',
                          otpType: OtpType.passwordChange,
                        ),
                      ),
                    );
                  } else {
                    Methods.showToast(context,
                        message: StringManager.pleaseBindYouPass.tr());
                  }
                },
                bind: '',
              ),
              SecurityItem(
                title: StringManager.changePhoneNumber.tr(),
                onTap: () {
                  if ((MyDataModel.getInstance().isPhone ?? false) &&
                      MyDataModel.getInstance().phone != null) {
                    action = "changePhoneNumber";
                    context.read<SendCodeBloc>().add(
                      SendCodeEvent(
                        context: context,
                        parameter: SendCodeParameter(
                          isDifferent: false,
                          phone: MyDataModel.getInstance().phone ?? '',
                          otpType: OtpType.verifyOldPhone,
                        ),
                      ),
                    );
                  } else {
                    Methods.showToast(context,
                        message: StringManager.pleaseBindYouPhone.tr());
                  }
                },
                bind: '',
              ),
              8.hBox,
              ...List.generate(ConstantsManager.accountSettingsTitles.length,
                      (i) {
                    return SecurityItem(
                      title: ConstantsManager.accountSettingsTitles[i],
                      onTap: accountSettingsOnTaps[i],
                      image: ConstantsManager.accountSettingIcon[i],
                      bind: i == 0
                          ? (MyDataModel.getInstance().isPhone == true)
                          ? StringManager.bound.tr()
                          : StringManager.bind.tr()
                          : i == 1
                          ? (MyDataModel.getInstance().isFacebook == true)
                          ? StringManager.bound.tr()
                          : StringManager.bind.tr()
                          : i == 2
                          ? (MyDataModel.getInstance().isGoogle == true)
                          ? StringManager.bound.tr()
                          : StringManager.bind.tr()
                          : i == 3
                          ? ''
                          : '',
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:country_picker/country_picker.dart';
import 'package:general/src/features/auth/presentation/change_phone/bloc/change_number_bloc.dart';
import 'package:general/src/features/auth/presentation/global/send_code/send_code_bloc.dart';
import 'package:general/src/features/auth/presentation/otp/bloc/otp_bloc.dart';

import '../../../../../core/index.dart';

class ChangeNewPhoneScreen extends StatelessWidget {
  final SendCodeParameter parameter;

  const ChangeNewPhoneScreen({super.key, required this.parameter});

  void _openCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showSearch: false,
      countryListTheme: const CountryListThemeData(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        padding: EdgeInsets.only(top: 10),
      ),
      showPhoneCode: true,
      onSelect: (Country country) {
        context.read<ChangePhoneBloc>().add(ChangeCountryChangePhone(country));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePhoneBloc, ChangePhoneState>(
      buildWhen: (prev, curr) => prev.selectedCountry != curr.selectedCountry || prev.formKeyCP != curr.formKeyCP,
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: ColorManager.scaffoldBg,
          appBar: AppBarWidget(
            backgroundColor: ColorManager.scaffoldBg,
          ),
          body: Form(
            key: state.formKeyCP,
            child: Padding(
              padding: context.paddingSymmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  15.hBox,
                  Image.asset(
                    scale: 7,
                    fit: BoxFit.contain,
                    AssetsManager.logo,
                  ),
                  10.hBox,
                  TextWidget(
                    StringManager.recoverPhone.tr(),
                    style: context.bodyLarge.bold
                        .colorExt(ColorManager.textPrimary),
                  ),
                  15.hBox,
                  TextWidget(
                    StringManager.recoverNewPasswordSubtitle.tr(),
                    textAlign: TextAlign.center,
                    style: context.bodyMedium.colorExt(ColorManager.textPrimary),
                  ),
                  15.hBox,
                  GestureDetector(
                    onTap: () => _openCountryPicker(context),
                    child: Container(
                      decoration: BoxDecoration(
                          color: ColorManager.grayLight,
                          borderRadius: 20.radius),
                      child: Row(
                        children: [
                          10.wBox,
                          TextWidget(
                            " ${state.selectedCountry?.name ?? 'UAE'}${state.selectedCountry?.phoneCode ?? "+971"}",
                            style: context.bodyMedium.size(16),
                          ),
                          10.wBox,
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: TextInputWidget(
                              border: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: ColorManager.transparent),
                              ),
                              StringManager.phoneNum.tr(),
                              contentPadding: EdgeInsets.zero,
                              keyboardType: TextInputType.phone,
                              controller: state.phoneControllerNew,

                              textColor: ColorManager.textPrimary,

                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: ColorManager.transparent),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: ColorManager.transparent),
                              ),
                              errorBorder: InputBorder.none,
                              // controller: state.phoneControllerNew,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return StringManager.requiredField.tr();
                                }
                                if (!Methods().isValidPhoneNumber(
                                    state.selectedCountry?.countryCode ?? "SA",
                                    value)) {
                                  return StringManager.phoneValidator.tr();
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  100.hBox,
                  BlocListener<SendCodeBloc, SendCodeState>(
                    listener: (context, __) {
                      if (__.requestState == RequestState.loaded) {
                        context.pushNamedRoute(
                          Routes.otp,
                          arguments: SendCodeParameter(
                            isDifferent: false,
                            newCode: di<OtpBloc>().state.code.text,
                            code: parameter.code,
                            phone:
                                '+${state.selectedCountry?.phoneCode ?? '971'}${state.phoneControllerNew.text}',
                            otpType: OtpType.verifyNewPhone,
                            newPhone: parameter.phone,
                          ),
                        );
                      }
                    },
                    child: BlocBuilder<SendCodeBloc, SendCodeState>(
                      buildWhen: (prev, curr) => prev.requestState != curr.requestState,
                      builder: (context, codeState) {
                        return ButtonWidget(
                          title: StringManager.next.tr(),
                          width: 355,
                          height: 55.h,
                          radius: 70.r,
                          backgroundColor: ColorManager.primary,
                          isLoading: codeState.requestState.isLoading,
                          onPressed: () {
                            if (state.formKeyCP.currentState?.validate() ==
                                false) {
                              return;
                            }
                            context.read<SendCodeBloc>().add(
                                  SendCodeEvent(
                                    context: context,
                                    parameter: SendCodeParameter(
                                      isDifferent: false,
                                      newCode: di<OtpBloc>().state.code.text,
                                      code: parameter.code,
                                      phone:
                                          '+${state.selectedCountry?.phoneCode ?? '971'}${state.phoneControllerNew.text}',
                                      otpType: OtpType.verifyNewPhone,
                                      newPhone: parameter.phone,
                                    ),
                                  ),
                                );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

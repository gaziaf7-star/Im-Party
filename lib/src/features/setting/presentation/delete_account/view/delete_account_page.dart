import 'package:general/src/core/services/auth_service.dart';
import 'package:general/src/features/setting/presentation/delete_account/bloc/delete_account_bloc.dart';
import '../../../../../core/index.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteAccountBloc, DeleteAccountState>(
      bloc: di<DeleteAccountBloc>(),
      listener: (context, state) {
        if (state.requestState.isLoaded) {
          Methods.showToast(context, message: state.message);
          AuthService().clearToken();
          navKey.currentContext?.pushNamedAndRemoveUntil(Routes.intro);
        } else if (state.requestState.isError) {
          Methods.showToast(context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: ColorManager.white,
        appBar: AppBarWidget(
          backgroundColor: ColorManager.white,
          iconColor: ColorManager.black,
          titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
          title: StringManager.deleteAccount.tr(),
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                40.hBox,
                Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorManager.redAccount.withValues(alpha: 0.1),
                  ),
                  child: Icon(Icons.error_outline,
                      color: ColorManager.redAccount, size: 56),
                ),
                16.hBox,
                TextWidget(
                  StringManager.deleteAccountWarning.tr(),
                  style: context.bodyMedium
                      .size(18)
                      .bold
                      .colorExt(ColorManager.redAccount),
                  textAlign: TextAlign.center,
                ),
                10.hBox,
                TextWidget(
                  StringManager.deleteAccountConfirmation.tr(),
                  textAlign: TextAlign.center,
                  style: context.bodyMedium
                      .size(14)
                      .colorExt(ColorManager.black.withValues(alpha: 0.7)),
                ),
                20.hBox,
                Container(
                  width: double.infinity,
                  padding:  EdgeInsets.all(15.h),
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: ColorManager.grey2.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextWidget(
                    textAlign: TextAlign.center,
                    StringManager.deleteAccountDetails.tr(),
                    style: context.bodyMedium
                        .size(15)
                        .copyWith(height: 1.5)
                        .colorExt(ColorManager.black),
                  ),
                ),
                20.hBox,
                BlocBuilder<DeleteAccountBloc, DeleteAccountState>(
                  bloc: di<DeleteAccountBloc>(),
                  buildWhen: (prev, curr) => prev.isActive != curr.isActive || prev.requestState != curr.requestState,
                  builder: (context, state) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: 5.radius,
                                side: BorderSide(
                                  color: ColorManager.primary,
                                ),
                              ),
                              activeColor: ColorManager.primary,
                              fillColor:
                              WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return ColorManager.primary;
                                }
                                if (states.contains(WidgetState.disabled)) {
                                  return Colors.grey;
                                }
                                return ColorManager.transparent;
                              }),
                              side: BorderSide(
                                color: ColorManager.primary,
                                width: 2,
                              ),
                              value: state.isActive,
                              onChanged: (value) {
                                di<DeleteAccountBloc>()
                                    .add(SelectToReadEvent(isActive: value!));
                              },
                            ),
                            Expanded(
                              child: TextWidget(
                                StringManager.readAndAcceptToDeleteAccount.tr(),
                                style: context.bodyMedium.w500
                                    .colorExt(ColorManager.black)
                                    .copyWith(overflow: TextOverflow.fade),
                              ),
                            ),
                          ],
                        ),
                        70.hBox,
                        ButtonWidget(
                          onPressed: () {
                            if (!state.isActive) {
                              Methods.showToast(context,
                                  message:
                                  StringManager.pleaseAcceptYoDeletion.tr(),
                                  isError: true);
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) => AnimatedDialog(
                                  title: StringManager.deleteAccount.tr(),
                                  description: StringManager.deleteDescribe.tr(),
                                  onTap: () {
                                    di<DeleteAccountBloc>()
                                        .add(const DeleteAccountEvent());
                                  },
                                ),
                              );
                            }
                          },
                          title: StringManager.delete.tr(),
                          isLoading: state.requestState.isLoading,
                          fontSize: 14,
                          titleColor: ColorManager.white,
                          elevation: 0,
                          borderColor: ColorManager.redAccount,
                          width: 200,
                          backgroundColor: ColorManager.redAccount,
                        ),
                      ],
                    );
                  },
                ),
                20.hBox,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
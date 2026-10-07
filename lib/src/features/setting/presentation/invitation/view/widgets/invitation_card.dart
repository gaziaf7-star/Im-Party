import 'package:share_plus/share_plus.dart';
import 'package:general/src/core/services/dynamic_link_handler.dart';
import 'package:general/src/features/setting/presentation/invitation/bloc/invite_bloc.dart';

import '../../../../../../core/index.dart';

class InvitationCard extends StatelessWidget {
  const InvitationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: context.paddingSymmetric(vertical: 20.h),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            ColorManager.mainColor,
            Colors.white.withValues(alpha: (0.8)),
            Colors.white.withValues(alpha: (0.9)),
            Colors.white,
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: ColorManager.white)),
      child: BlocConsumer<SendInviteBloc, SendInviteState>(
        bloc: di<SendInviteBloc>(),
        listener: (context, state) {
          if (state.sendInviteCodeRequest == RequestState.loading) {
            Methods.showToast(context, isLoading: true);
          } else if (state.sendInviteCodeRequest == RequestState.loaded) {
            Methods.showToast(context,
                message: state.successSendInviteCode.toString());
          } else if (state.sendInviteCodeRequest == RequestState.error) {
            Methods.showToast(context,
                message: state.errorSendInviteMessage.toString(),
                isError: true);
          }
        },
        builder: (context, state) {
          if (state.sendInviteCodeRequest == RequestState.loaded) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  margin: context.paddingSymmetric(horizontal: 50.w),
                  decoration: BoxDecoration(
                    color: ColorManager.grey.withValues(alpha: (0.2)),
                    border: Border.all(
                      color: Colors.green,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20.r)),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 150.h,
                  ),
                ),
                20.hBox,
                TextWidget(
                  StringManager.youHaveBeenInvited.tr(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            );
          } else {
            return Form(
              key: state.formKey,
              child: Column(
                children: [
                  15.hBox,
                  Padding(
                    padding: context.paddingSymmetric(horizontal: 20.w),
                    child: TextInputWidget(
                      StringManager.enterTheInviteCode.tr(),
                      keyboardType: TextInputType.multiline,
                      controller: state.codeController,
                    ),
                  ),
                  20.hBox,
                  ButtonWidget(
                    width: 200.w,
                    height: 50.h,
                    backgroundColor: ColorManager.primary,
                    onPressed: () async {
                      String link =
                          await DynamicLinkHandler.instance.createDynamicLink(
                        MyDataModel.getInstance().uuid.toString(),
                        'invitation_code',
                      );
                      await SharePlus.instance.share(
                        ShareParams(
                          uri: Uri.parse(link),
                        ),
                      );
                    },
                    title: StringManager.send.tr(),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

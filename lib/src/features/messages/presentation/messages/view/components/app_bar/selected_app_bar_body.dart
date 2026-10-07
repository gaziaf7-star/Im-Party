part of 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

class _SelectedAppBarBody extends StatelessWidget {
  const _SelectedAppBarBody({required this.bloc});

  final ToggleAppBarBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 18.5.h,
            color: ColorManager.onBrandGradient,
          ),
        ),
        20.wBox,
        TextWidget(
          '${bloc.state.counter}',
          // Fixed white — this sits on the brand-gradient app bar now.
          style: context.bodyLarge.w600
              .colorExt(ColorManager.onBrandGradient),
        ),
        const Spacer(),
        if (bloc.state.counter == 1) ...{
          IconButton(
            onPressed: () =>
                bloc.add(const ShowReplayBoxEvent(isReplying: true)),
            icon: Icon(
              CupertinoIcons.reply_all,
              color: ColorManager.onBrandGradient,
              size: 24.0.h,
            ),
          ),
          if ((bloc.state.messageSelectionMap.values.first.message ?? '')
              .trim()
              .isNotEmpty)
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                    text: bloc.state.messageSelectionMap.values.first.message ??
                        ''));
                Methods.showToast(
                  context,
                  message: StringManager.copied.tr(),
                );
                bloc.add(const ToggleAppBarEvent(isToggle: false));
              },
              icon: Icon(
                Icons.copy,
                color: ColorManager.onBrandGradient,
                size: 24.0.h,
              ),
            ),
        },
        IconButton(
          onPressed: () => showDeleteDialog(
            context,
            onDeleteForEveryone: () {
              di<FetchMessagesBloc>().add(
                LocalDeleteMessagesEvent(
                  params: FetchMessagesParamsUC(
                    messageIds: bloc.messagesId(),
                  ),
                  forEveryone: true,
                ),
              );
              context.popRoute();
            },
            onDeleteForMe: () {
              di<FetchMessagesBloc>().add(
                LocalDeleteMessagesEvent(
                  params: FetchMessagesParamsUC(
                    messageIds: bloc.messagesId(),
                  ),
                  forEveryone: false,
                ),
              );
              context.popRoute();
            },
          ),
          icon: Icon(
            CupertinoIcons.delete,
            color: ColorManager.redAccount,
            size: 24.0.h,
          ),
        ),
      ],
    );
  }
}
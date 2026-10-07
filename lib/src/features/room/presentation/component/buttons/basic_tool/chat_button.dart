import 'package:general/src/core/widgets/body_theme_background.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/chats/presentation/chats/bloc/manager_get_users_chat/get_users_chat_bloc.dart';
import 'package:general/src/features/chats/presentation/chats/view/chats_page.dart';

import '../../../../../../core/index.dart';

class ChatButton extends StatelessWidget {
  const ChatButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        bottomDailog(
          context: context,
          widget: SizedBox(
            height: MediaQuery.of(context).size.height * .8,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: 10.radiusCircular,
                topRight: 10.radiusCircular,
              ),
              child: const Stack(
                children: [
                  BodyThemeBackground(),
                  ChatsPage(fromRoom: true),
                ],
              ),
            ),
          ),
        );
      },
      child: BlocBuilder<FetchUsersChatBloc, GetUsersChatState>(
        bloc: di<FetchUsersChatBloc>(),
        // Rebuild only when the live drift-derived unread total changes (#31/#32).
        buildWhen: (prev, curr) =>
        prev.totalUnreadFromDrift != curr.totalUnreadFromDrift,
        builder: (context, state) {
          final unread = state.totalUnreadFromDrift;
          return ConstantsManager.isTheme1
              ? Stack(
            children: [
              Image.asset(
                AssetsManager.messageIconNew,
                width: 36.w,
                height: 36.h,
                fit: BoxFit.cover,
              ),
              if (unread > 0)
                Positioned(
                  right: 0.h,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Text(
                      unread.toString(),
                      style: context.bodySmall
                          .size(8)
                          .colorExt(ColorManager.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          )
              : CircleAvatar(
            radius: 19.5.r,
            backgroundColor: Colors.black.withValues(alpha: .1),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 19.5.r,
                        backgroundColor:
                        Colors.black.withValues(alpha: .1),
                        // Unified with Emoji/Mic/More's icon size (24.sp)
                        // so all bottom-bar tiles look the same size.
                        child: Image.asset(
                          AssetsManager.mailAudioIcon,
                          width: 24.sp,
                          height: 24.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    right: 0.h,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Text(
                        unread.toString(),
                        style: context.bodySmall
                            .size(8)
                            .colorExt(ColorManager.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
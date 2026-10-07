import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/chats/presentation/notification/view/widgets/notification_card.dart';

/// Bell icon for the chats top bar. Tapping it drops a compact notifications
/// panel down from the top (instead of pushing the full screen), populated from
/// the same [GetSystemChatBloc] the notifications screen uses.
class NotificationsBell extends StatelessWidget {
  const NotificationsBell({super.key});

  void _open(BuildContext context) {
    // Refresh in the background so the panel shows the latest.
    if (!di<GetSystemChatBloc>().state.systemReqState.isLoaded) {
      di<GetSystemChatBloc>().add(const GetSystemChatEvent());
    } else {
      di<GetSystemChatBloc>().add(const GetSystemChatEvent(isLoading: false));
    }

    final topInset = MediaQuery.of(context).viewPadding.top;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'notifications',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: topInset + 56.h, left: 10.w, right: 10.w),
          child: Material(
            color: Colors.transparent,
            child: _panel(context),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Widget _panel(BuildContext context) {
    return Container(
      constraints:
      BoxConstraints(maxHeight: ScreenUtil().screenHeight * 0.55),
      decoration: BoxDecoration(
        // White card + light-black text (was a dark lightBlack card with
        // white text) — matches the professional white look used across the
        // app now, and the panel-driven text couldn't reliably show black
        // on the old dark surface.
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: context.paddingSymmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: context.paddingSymmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  StringManager.notification.tr(),
                  style: context.bodyLarge.bold
                      .colorExt(ColorManager.momentPostTextColor),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      Routes.notificationScreen,
                      arguments: 2,
                    );
                  },
                  child: TextWidget(
                    StringManager.seeMore.tr(),
                    style: context.bodyMedium
                        .colorExt(ColorManager.brandGradientColors.last),
                  ),
                ),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: ColorManager.momentPostTextColor.withValues(alpha: 0.08)),
          Flexible(
            child: BlocBuilder<GetSystemChatBloc, GetSystemChatsStates>(
              bloc: di<GetSystemChatBloc>(),
              buildWhen: (p, c) =>
              p.systemReqState != c.systemReqState ||
                  p.systemEntity != c.systemEntity,
              builder: (context, state) {
                if (state.systemReqState.isLoading &&
                    state.systemEntity.isEmpty) {
                  return Padding(
                    padding: context.paddingAll(20),
                    child: const LoadingWidget(),
                  );
                }
                final items = state.systemEntity
                    .where((e) => e.title.isNotEmpty)
                    .toList();
                if (items.isEmpty) {
                  return Padding(
                    padding: context.paddingAll(24),
                    child: TextWidget(
                      StringManager.emptyNotifications.tr(),
                      style: context.bodyMedium.colorExt(
                          ColorManager.momentPostTextColor
                              .withValues(alpha: 0.7)),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  padding: context.paddingSymmetric(vertical: 4),
                  itemCount: items.length,
                  itemBuilder: (_, i) => NotificationCard(
                    userId: items[i].fromUserId,
                    index: i,
                    content: items[i].title,
                    created: items[i].created,
                    img: items[i].img,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _open(context),
      // Fixed white — sits on the Chats page's Home-style gradient band now.
      icon: Icon(Icons.notifications_none,
          color: ColorManager.homeHeaderTextColor),
      tooltip: StringManager.notification.tr(),
    );
  }
}
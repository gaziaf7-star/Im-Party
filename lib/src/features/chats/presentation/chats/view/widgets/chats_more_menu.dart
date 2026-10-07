import 'package:general/src/core/index.dart';
import 'package:general/src/features/chats/presentation/chats/view/media_settings_screen.dart';
import 'package:general/src/features/family/presentation/widgets/pop_up_item_widget.dart';

/// Top-bar overflow (3-dots) menu for the chats screen. Holds the entries that
/// used to live as fixed rows in the body: Friend Requests and System
/// Notifications. Reuses the family `popUpItemWidget` styling for consistency.
class ChatsMoreMenu extends StatelessWidget {
  const ChatsMoreMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      // Fixed white — this icon now always sits on the Chats page's
      // Home-style gradient band, not the panel's textPrimary.
      iconColor: ColorManager.homeHeaderTextColor,
      // Fixed white popup card (was the mutable, panel-overridable
      // surfaceCardColor) so the dropdown always matches the light theme.
      color: ColorManager.white,
      elevation: 0.0,
      style: TextButton.styleFrom(
        minimumSize: const Size(10, 10),
        padding: context.paddingZero(),
      ),
      padding: context.paddingOnly(end: 10),
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(borderRadius: 5.radius),
      itemBuilder: (_) => [
        popUpItemWidget(
          title: StringManager.friendRequest.tr(),
          icon: Icons.person_add_alt_1,
          context: context,
          onTap: () =>
              Navigator.pushNamed(context, Routes.chatRequestPage),
        ),
        popUpItemWidget(
          title: StringManager.mediaSettings.tr(),
          icon: Icons.image_outlined,
          context: context,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MediaSettingsScreen()),
          ),
        ),
        // Notifications moved to the dedicated bell icon next to this menu.
      ],
    );
  }
}
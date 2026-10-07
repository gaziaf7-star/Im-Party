import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/groups/presentation/public_groups/view/public_groups_screen.dart';
import '../chat_friend_picker_screen.dart';
import 'chat_strings.dart';

/// WhatsApp-style FAB for the chats screen.
///
/// Opens a clean professional bottom sheet with:
/// - New Chat
/// - New Group
/// - Discover Public Groups
class NewChatFab extends StatelessWidget {
  const NewChatFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: ColorManager.brandGradient,
      ),
      child: FloatingActionButton(
        heroTag: 'fab_new_chat',
        backgroundColor: ColorManager.transparent,
        elevation: 0,
        highlightElevation: 0,
        onPressed: () => _showSheet(context),
        child: Icon(
          Icons.chat_rounded,
          color: ColorManager.onBrandGradient,
          size: 24.h,
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    final double bottomLift =
        80.h + MediaQuery.of(context).viewPadding.bottom + 8.h;

    bottomDailog(
      context: context,
      widget: Container(
        margin: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          bottom: bottomLift,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24.r,
              spreadRadius: 1.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                8.w,
                12.h,
                8.w,
                12.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top drag indicator
                  Container(
                    width: 42.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8D8D8),
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                  ),

                  // New Chat
                  _SheetItem(
                    icon: Icons.person_add_alt_1_rounded,
                    label: ChatStrings.newChat,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatFriendPickerScreen(),
                        ),
                      );
                    },
                  ),

                  // New Group
                  _SheetItem(
                    icon: Icons.group_add_rounded,
                    label: ChatStrings.newGroup,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushNamed(
                        context,
                        Routes.createGroupScreen,
                      );
                    },
                  ),

                  // Public Groups
                  _SheetItem(
                    icon: Icons.public_rounded,
                    label: StringManager.discoverPublicGroups.tr(),
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PublicGroupsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 2.h,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          splashColor:
          ColorManager.brandGradientColors.first.withValues(alpha: 0.08),
          highlightColor:
          ColorManager.brandGradientColors.first.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            child: Row(
              children: [
                // Icon background
                Container(
                  width: 46.w,
                  height: 46.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ColorManager.brandGradientColors.first
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    icon,
                    color: ColorManager.brandGradientColors.last,
                    size: 23.h,
                  ),
                ),

                14.wBox,

                // Black professional text
                Expanded(
                  child: TextWidget(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyLarge
                        .colorExt(const Color(0xFF111111))
                        .w600,
                  ),
                ),

                8.wBox,

                // Right arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15.h,
                  color: const Color(0xFF9A9A9A),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
part of '../medals_page.dart';

/// Full "Manage my badges" page -- replaces the old bottom sheet reached from
/// "My Badge > More", on request. Same pick grid + save bar as before
/// (BottomDialogPickPersonal/Room, now rendered with asPage: true), just
/// with a profile header (avatar + name) on top and its own dark page
/// instead of a white bottom sheet.
class BadgeManagePage extends StatelessWidget {
  const BadgeManagePage({
    super.key,
    required this.index,
    required this.pickedAchievements,
    required this.pickedRoomIds,
  });

  /// 0 = personal (My Badge), 1 = room (My Room Badge).
  final int index;
  final List<String> pickedAchievements;
  final List<int> pickedRoomIds;

  @override
  Widget build(BuildContext context) {
    final me = MyDataModel.getInstance();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF241605), Color(0xFF0D0904)],
                ),
              ),
            ),
          ),
          // The diamond pattern texture was added here on an earlier
          // request, then asked to be removed again -- this page keeps a
          // clean gradient only, no pattern ("futa futa ata thakba nah").
          SafeArea(
            child: Column(
              children: [
                AppBarWidget(
                  backgroundColor: ColorManager.transparent,
                  iconColor: Colors.white,
                  // Name shown in the AppBar's own centered title, on
                  // request -- was a separate TextWidget below the avatar.
                  title: me.name ?? '',
                  titleStyle: context.bodyLarge.bold.colorExt(Colors.white),
                ),
                // A bit more breathing room above the avatar and before the
                // tab bar, on request ("aro akto nesa namba").
                12.hBox,
                ClipOval(
                  child: ImageViewWidget(
                    url: me.profile?.image ?? '',
                    displayName: me.name ?? '',
                    height: 80.h,
                    width: 80.h,
                    boxFit: BoxFit.cover,
                  ),
                ),
                24.hBox,
                Expanded(
                  child: index == 0
                      ? BottomDialogPickPersonal(
                          asPage: true,
                          pickedAchievements: pickedAchievements,
                          pickedRoomIds: pickedRoomIds,
                        )
                      : BottomDialogPickRoom(
                          asPage: true,
                          pickedAchievements: pickedAchievements,
                          pickedPersonalIds: pickedRoomIds,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

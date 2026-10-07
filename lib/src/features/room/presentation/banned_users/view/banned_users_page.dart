import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// Host/admin screen listing the users banned/kicked from the room — read
/// straight from the UTD-Stream kit (`controller.listBans()`), the single source
/// of truth for moderation. Unban hits `controller.unbanUser()`.
class BannedUsersPage extends StatefulWidget {
  const BannedUsersPage({super.key});

  @override
  State<BannedUsersPage> createState() => _BannedUsersPageState();
}

class _BannedUsersPageState extends State<BannedUsersPage> {
  final List<UTDBannedUser> _items = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final controller = RoomData.instance.utdController;
    if (controller == null) {
      if (mounted) setState(() {
        _loading = false;
        _error = true;
      });
      return;
    }
    if (mounted) setState(() {
      _loading = true;
      _error = false;
    });
    final result = await controller.listBans(page: 1, perPage: 100);
    if (!mounted) return;
    if (result == null) {
      setState(() {
        _loading = false;
        _error = true;
      });
      return;
    }
    // Only the bans that apply to THIS room (room-scoped) or globally.
    final roomName = RoomData.instance.room.id?.toString();
    setState(() {
      _items
        ..clear()
        ..addAll(result.data.where(
            (b) => b.isGlobal || b.roomName == roomName));
      _loading = false;
    });
  }

  Future<void> _unban(UTDBannedUser user) async {
    final controller = RoomData.instance.utdController;
    if (controller == null) return;
    Methods.showToast(context, isLoading: true);
    final ok = await controller.unbanUser(
      user.identity,
      global: user.isGlobal,
      roomName: user.roomName,
    );
    if (!mounted) return;
    if (ok) {
      setState(() => _items.removeWhere((b) => b.id == user.id));
      Methods.showToast(context, message: StringManager.userUnbanned.tr());
    } else {
      Methods.showToast(context,
          message: StringManager.somethingWrong.tr(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // A compact, opaque bottom dialog (NOT a full-screen Scaffold) — matches the
    // other room dialogs and stops the room showing through behind it.
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.55,
      ),
      decoration: BoxDecoration(
        // White sheet / black text on request, matching the rest of the
        // tools sheet.
        color: ColorManager.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      padding: context.paddingOnly(start: 15, end: 15, top: 12, bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle + title
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: ColorManager.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          10.hBox,
          TextWidget(
            StringManager.bannedUsers.tr(),
            style: context.bodyLarge.bold.colorExt(ColorManager.black),
          ),
          10.hBox,
          Flexible(
            child: RefreshIndicatorWidget(
              onRefresh: _load,
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 30.h),
        child: const Center(child: LoadingWidget()),
      );
    }
    if (_items.isEmpty) {
      return ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30.h),
            child: Center(
              child: TextWidget(
                (_error
                        ? StringManager.somethingWrong
                        : StringManager.noBannedUsers)
                    .tr(),
                style: context.bodyLarge.colorExt(ColorManager.greyTextColor),
              ),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final user = _items[index];
        return _BannedRow(user: user, onUnban: () => _unban(user));
      },
    );
  }
}

class _BannedRow extends StatelessWidget {
  final UTDBannedUser user;
  final VoidCallback onUnban;

  const _BannedRow({required this.user, required this.onUnban});

  String get _expiryLabel => user.isPermanent
      ? StringManager.permanent.tr()
      : _formatDateTime(user.expiresAt!.toLocal());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(vertical: 6.h),
      child: Row(
        children: [
          UserImage(
            image: user.attributes?.avatar ?? "",
            displayName: user.name ?? user.identity,
            imageSize: 45.sp,
          ),
          10.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientName(child: TextWidget(user.name ?? user.identity,
                    style: context.bodyLarge.w600
                        .colorExt(ColorManager.black))),
                3.hBox,
                TextWidget(_expiryLabel,
                    style:
                        context.bodySmall.colorExt(ColorManager.greyTextColor)),
              ],
            ),
          ),
          IconButton(
            onPressed: onUnban,
            icon: const Icon(CupertinoIcons.delete,
                color: ColorManager.redAccount),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
}

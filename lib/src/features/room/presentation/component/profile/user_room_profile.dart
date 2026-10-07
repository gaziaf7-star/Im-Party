import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/presentation/component/profile/new_profile_body.dart';
import 'package:general/src/features/room/presentation/component/profile/profile_body.dart';
import 'package:general/src/features/room/room.dart';

class UserRoomProfile extends StatefulWidget {
  final EnterRoomModel roomData;
  final String userId;

  const UserRoomProfile({
    super.key,
    required this.roomData,
    required this.userId,
  });

  @override
  State<UserRoomProfile> createState() => _UserRoomProfileState();
}

class _UserRoomProfileState extends State<UserRoomProfile> {
  UserInRoomModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final int id = int.tryParse(widget.userId) ?? 0;

    // Guard: a non-numeric/invalid identity collapses to 0. Never read the cache
    // or fetch with id 0 — the Hive cache key "0" gets poisoned by earlier failed
    // lookups, so id-0 reads return a DIFFERENT (previously tapped) user. Show the
    // graceful empty state instead of someone else's profile.
    if (id <= 0) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    UserInRoomModel? cachedUser;
    try {
      cachedUser = UsersCache().getUser(id);
    } catch (_) {}
    if (cachedUser != null && mounted) {
      setState(() {
        _user = cachedUser;
        _loading = false;
      });
    }

    // The Hive cache is a point-in-time snapshot taken when this user joined
    // the room (onUserJoined). Equipping a new item from the backpack — e.g.
    // an avatar frame — after that moment never touches it, so this sheet
    // kept showing the gear the user had at join time (or none at all),
    // while the live entry animation and the user's own profile page always
    // read fresh data and looked fine. Always refresh in the background and
    // swap the live data in once it lands, instead of trusting the cache.
    final fresh = await getUsersByIds([id]).then((map) => map[id]);
    if (fresh != null) {
      await UsersCache().setUser(fresh);
      if (mounted) {
        setState(() {
          _user = fresh;
          _loading = false;
        });
      }
    } else if (cachedUser == null && mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int id = int.tryParse(widget.userId) ?? 0;
    if (id <= 0) {
      return _emptyProfile(context);
    }

    if (_user == null) {
      if (_loading) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.4,
            minHeight: 300.h,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: ColorManager.whiteGrey,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }
      return _emptyProfile(context);
    }

    return _buildProfileBody(_user!);
  }

  Widget _emptyProfile(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.4,
        minHeight: 300.h,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.whiteGrey,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48.w, color: ColorManager.grey),
              10.hBox,
              TextWidget(
                StringManager.error.tr(),
                style: context.bodyMedium.colorExt(ColorManager.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBody(UserInRoomModel userData) {
    final myId = MyDataModel.getInstance().id;
    final isMyProfile = myId != null && myId.toString() == widget.userId;
    return ConstantsManager.isTheme1
        ? NewProfileBody(
            roomData: widget.roomData,
            userData: userData,
            userId: widget.userId,
            isMyProfile: isMyProfile,
          )
        : ProfileBody(
            roomData: widget.roomData,
            userData: userData,
            userId: widget.userId,
            isMyProfile: isMyProfile,
          );
  }
}

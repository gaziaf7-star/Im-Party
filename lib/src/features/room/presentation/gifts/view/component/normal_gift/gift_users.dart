import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/room.dart';

class GiftUser extends StatefulWidget {
  final List<UTDParticipant> users;
  final String ownerId;
  final double containerHeight;
  final bool useNewThemeLayout;
  final Color selectedBorderColor;
  final Color labelTextColor;
  final Color seatNumberBackgroundColor;
  final Color seatNumberTextColor;
  final Color allButtonBackgroundColor;
  final Color allButtonTextColor;
  final double allButtonBorderRadius;

  const GiftUser({
    required this.users,
    required this.ownerId,
    required this.containerHeight,
    required this.useNewThemeLayout,
    required this.selectedBorderColor,
    required this.labelTextColor,
    required this.seatNumberBackgroundColor,
    required this.seatNumberTextColor,
    required this.allButtonBackgroundColor,
    required this.allButtonTextColor,
    required this.allButtonBorderRadius,
    super.key,
  });

  static ValueNotifier<Map<int, SelectedObject>> userSelected =
      ValueNotifier<Map<int, SelectedObject>>({});
  static Map<int, UTDParticipant> userOnMicsForGifts = <int, UTDParticipant>{};
  static ValueNotifier<int> refreshGiftUsers = ValueNotifier<int>(0);

  static void clearAll() {
    userSelected.value = {};
    userOnMicsForGifts.clear();
    refreshGiftUsers.value = 0;
  }

  @override
  GiftUserState createState() => GiftUserState();
}

class GiftUserState extends State<GiftUser> {
  late Map<int, UserInRoomModel> users = {};

  @override
  void initState() {
    super.initState();
    GiftUser.userSelected.value.clear();
    if (di<RoomStateManager>().isInVideoRoom) {
      if (RoomData.instance.isError.value) {
        for (int i = 0; i < widget.users.length; i++) {
          GiftUser.userOnMicsForGifts.putIfAbsent(i, () => widget.users[i]);
        }
      }
      _loadUsersData();
    }
  }

  Future<void> _loadUsersData() async {
    final userIds = GiftUser.userOnMicsForGifts.values
        .map((user) => int.tryParse(user.id))
        .whereType<int>()
        .toList();

    final cachedUsers = <int, UserInRoomModel>{};
    final idsToFetch = <int>[];

    for (var id in userIds) {
      final cached = UsersCache().getUser(id);
      if (cached != null) {
        cachedUsers[id] = cached;
      } else {
        idsToFetch.add(id);
      }
    }

    final fetchedUsers =
        idsToFetch.isNotEmpty ? await getUsersByIds(idsToFetch) : {};

    setState(() {
      users = {...cachedUsers, ...fetchedUsers};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingAll(4.0),
      child: SizedBox(
        height: widget.containerHeight,
        child: di<RoomStateManager>().isInAudioRoom
            ? ValueListenableBuilder<List<SeatState>>(
                valueListenable:
                    RoomData.instance.utdController?.seatController.seats ??
                        ValueNotifier([]),
                builder: (context, seatValues, _) {
                  final occupied = seatValues
                      .where((s) => s.isOccupied)
                      .toList()
                    ..sort((a, b) => a.index.compareTo(b.index));
                  final sortedUsers = occupied
                      .map((s) => UTDParticipant(
                            id: s.occupantUserId!,
                            name: RoomData
                                    .instance
                                    .users[
                                        int.tryParse(s.occupantUserId!) ?? 0]
                                    ?.name ??
                                '',
                            attributes: s.attributes,
                          ))
                      .toList();
                  return _buildUserSelection(context, sortedUsers);
                },
              )
            : ValueListenableBuilder<int>(
                valueListenable: GiftUser.refreshGiftUsers,
                builder: (context, _, __) {
                  final sortedUsers =
                      GiftUser.userOnMicsForGifts.values.toList();
                  return _buildUserSelection(context, sortedUsers);
                },
              ),
      ),
    );
  }

  Widget _buildUserSelection(
      BuildContext context, List<UTDParticipant> sortedUsers) {
    return ValueListenableBuilder<Map<int, SelectedObject>>(
      valueListenable: GiftUser.userSelected,
      builder: (context, selectedMap, _) {
        if (widget.useNewThemeLayout) {
          return Row(
            children: [
              TextWidget(StringManager.send,
                  style:
                      context.bodySmall.colorExt(widget.labelTextColor)),
              5.wBox,
              Flexible(
                child: SizedBox(
                  height: 33.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: sortedUsers.length,
                    itemBuilder: (context, index) {
                      final user = sortedUsers[index];
                      final userId = int.tryParse(user.id) ?? index;
                      final userData =
                          users[userId] ?? const UserInRoomModel();

                      return Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: InkWell(
                          onTap: () {
                            final updatedMap = {...selectedMap};
                            if (updatedMap.containsKey(userId)) {
                              updatedMap.remove(userId);
                            } else {
                              updatedMap[userId] = SelectedObject(
                                userId: user.id,
                                name: user.name,
                                selected: true,
                              );
                            }
                            GiftUser.userSelected.value = updatedMap;
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 16.w,
                                backgroundColor:
                                    selectedMap.containsKey(userId)
                                        ? widget.selectedBorderColor
                                        : ColorManager.transparent,
                                child: ClipOval(
                                  child: Builder(builder: (_) {
                                    // Resolve the avatar from a single source and
                                    // fall back to the name initial (never the app
                                    // logo). Use isNotEmpty (not != null) so an
                                    // empty "" url doesn't render the logo, and
                                    // avoid name[0] which crashes on empty names.
                                    final img = di<RoomStateManager>().isInAudioRoom
                                        ? (user.attributes["avatar"]?.isNotEmpty ==
                                                true
                                            ? user.attributes["avatar"]!
                                            : (RoomData.instance.users[userId]
                                                    ?.image ??
                                                ""))
                                        : (userData.image ?? "");
                                    if (img.isNotEmpty) {
                                      return ImageViewWidget(
                                        width: 28.w,
                                        height: 28.h,
                                        url: img,
                                        boxFit: BoxFit.cover,
                                        displayName: user.name,
                                      );
                                    }
                                    return InitialsAvatar(
                                      name: user.name,
                                      size: 28.w,
                                    );
                                  }),
                                ),
                              ),
                              if (di<RoomStateManager>().isInAudioRoom)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 10.w,
                                    height: 10.w,
                                    decoration: const BoxDecoration(
                                      color: ColorManager.white,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${(RoomData.instance.utdController?.seatController.getSeatIndexByUserId(user.id) ?? -1) + 1}",
                                      style: context.bodySmall
                                          .size(8)
                                          .w600
                                          .colorExt(ColorManager.textPrimary),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // "All" button
              InkWell(
                onTap: () {
                  if (GiftUser.userSelected.value.isEmpty) {
                    final newMap = <int, SelectedObject>{};
                    for (final user in sortedUsers) {
                      final userId = int.tryParse(user.id) ?? 0;
                      newMap[userId] = SelectedObject(
                        userId: user.id,
                        name: user.name,
                        selected: true,
                      );
                    }
                    GiftUser.userSelected.value = newMap;
                  } else {
                    GiftUser.userSelected.value = {};
                  }
                },
                child: Container(
                  padding: context.paddingAll(3),
                  decoration: BoxDecoration(
                    color: widget.allButtonBackgroundColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: ColorManager.white,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 325.w,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: sortedUsers.length,
                  itemBuilder: (context, index) {
                    final user = sortedUsers[index];
                    final userId = int.tryParse(user.id) ?? index;
                    final userData =
                        users[userId] ?? const UserInRoomModel();

                    return InkWell(
                      onTap: () {
                        final updatedMap = {...selectedMap};
                        if (updatedMap.containsKey(userId)) {
                          updatedMap.remove(userId);
                        } else {
                          updatedMap[userId] = SelectedObject(
                            userId: user.id,
                            name: user.name,
                            selected: true,
                          );
                        }
                        GiftUser.userSelected.value = updatedMap;
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                selectedMap.containsKey(userId)
                                    ? widget.selectedBorderColor
                                    : ColorManager.transparent,
                            radius:20.w,
                            child: Builder(builder: (_) {
                              // Single avatar source → name-initial fallback
                              // (never app logo); isNotEmpty guards the empty url
                              // and name[0] crash.
                              final img = di<RoomStateManager>().isInAudioRoom
                                  ? (user.attributes["avatar"]?.isNotEmpty == true
                                      ? user.attributes["avatar"]!
                                      : (RoomData.instance.users[userId]?.image ??
                                          ""))
                                  : (userData.image ?? "");
                              return CircleAvatar(
                                radius: 18.w,
                                backgroundColor: ColorManager.transparent,
                                child: img.isNotEmpty
                                    ? ImageViewWidget(
                                        width: 42.w,
                                        height: 42.h,
                                        url: img,
                                        boxFit: BoxFit.cover,
                                        shape: BoxShape.circle,
                                        displayName: user.name,
                                      )
                                    : InitialsAvatar(
                                        name: user.name,
                                        size: 36.w,
                                      ),
                              );
                            }),
                          ),
                          Positioned(
                            bottom: 2.h,
                            right: 0.w,
                            child: Container(
                              width: 10.w,
                              height: 12.h,
                              decoration: BoxDecoration(
                                color: widget.seatNumberBackgroundColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  "${(RoomData.instance.utdController?.seatController.getSeatIndexByUserId(user.id) ?? -1) + 1}",
                                  style: context.bodyMedium
                                      .size(9)
                                      .w600
                                      .colorExt(
                                          widget.seatNumberTextColor),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              InkWell(
                onTap: () {
                  if (GiftUser.userSelected.value.isEmpty) {
                    final newMap = <int, SelectedObject>{};
                    for (final user in sortedUsers) {
                      final userId = int.tryParse(user.id) ?? 0;
                      newMap[userId] = SelectedObject(
                        userId: user.id,
                        name: user.name,
                        selected: true,
                      );
                    }
                    GiftUser.userSelected.value = newMap;
                  } else {
                    GiftUser.userSelected.value = {};
                  }
                },
                child: Container(
                  padding: context.paddingSymmetric(
                    horizontal: 15,
                    vertical: 7.0,
                  ),
                  decoration: BoxDecoration(
                    color: widget.allButtonBackgroundColor,
                    borderRadius: BorderRadius.circular(
                        widget.allButtonBorderRadius),
                  ),
                  child: Text(
                    "All",
                    style: context.bodyMedium
                        .colorExt(widget.allButtonTextColor),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class SelectedObject extends Equatable {
  final String userId;
  final String name;
  final bool selected;

  const SelectedObject({
    required this.userId,
    required this.name,
    required this.selected,
  });

  @override
  List<Object?> get props => [userId, name, selected];

  SelectedObject copyWith({
    String? userId,
    String? name,
    bool? selected,
  }) {
    return SelectedObject(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      selected: selected ?? this.selected,
    );
  }
}

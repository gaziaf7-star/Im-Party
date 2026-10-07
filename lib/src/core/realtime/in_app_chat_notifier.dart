import 'dart:async';
import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/app_lifecycle_signal.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';

/// In-app (foreground) notifier for incoming 1:1 / group chat messages.
///
/// External/system push (FCM via [NotificationService]) already covers the
/// BACKGROUND case. This is the FOREGROUND counterpart: when a new incoming
/// message lands on the realtime receive path while the app is on screen and the
/// user is NOT already looking at that conversation, it surfaces a tappable
/// heads-up banner (sender + preview + avatar) over the root navigator and plays
/// a short notification sound.
///
/// Singleton (no DI needed), mirroring [AppLifecycleSignal] /
/// `LuckyGiftSoundManager`. The realtime client funnels every persisted incoming
/// message through [notifyIncoming]; suppression logic lives here so the receive
/// path stays a thin trigger.
class InAppChatNotifier {
  InAppChatNotifier._internal();

  static final InAppChatNotifier _instance = InAppChatNotifier._internal();

  static InAppChatNotifier get instance => _instance;

  /// The peer user id of the conversation the user is currently viewing, if any.
  /// Set when a 1:1 chat opens and cleared when it closes, so we never banner a
  /// message for the chat that is already on screen.
  int? _activePeerUserId;

  /// The server room id of the group conversation currently on screen, if any.
  int? _activeGroupRoomId;

  /// Last-notified server identity per server room id, so re-applied messages
  /// (recovery / gap-fill re-upserts the same row) don't re-banner or re-beep.
  ///
  /// Bounded LRU (insertion-ordered [LinkedHashMap]): without a cap this grew
  /// one entry per distinct room for the whole process lifetime.
  final LinkedHashMap<int, int> _lastNotifiedByRoom = LinkedHashMap<int, int>();
  static const int _lastNotifiedCap = 256;

  OverlayEntry? _currentEntry;
  Timer? _dismissTimer;

  /// Dedicated player for the short notification chime (asset-backed so it is
  /// reliably audible on Android, unlike SystemSound.alert which is a no-op on
  /// many Android OEMs).
  AudioPlayer? _player;
  static const String _soundAsset = 'sounds/chat_notification.wav';

  // --- active conversation tracking -----------------------------------------

  /// Mark the 1:1 conversation with [peerUserId] as the one on screen.
  void setActivePeer(int? peerUserId) {
    _activePeerUserId = peerUserId;
  }

  /// Mark the group [serverRoomId] as the conversation on screen.
  void setActiveGroup(int? serverRoomId) {
    _activeGroupRoomId = serverRoomId;
  }

  /// Clear any active-conversation marker (e.g. leaving a chat for the list).
  void clearActive() {
    _activePeerUserId = null;
    _activeGroupRoomId = null;
  }

  /// Clear the 1:1 marker ONLY if it still points at [peerUserId]. Used by the
  /// closing chat (screen dispose / realtime closeChat) so that an A→B switch —
  /// where B's screen initState (setActivePeer B) runs BEFORE A's dispose — does
  /// not wipe B's freshly-set marker. An unconditional clear here races the
  /// active-room tracking and re-enables banners/sound for the chat on screen.
  void clearActivePeerIfMatches(int? peerUserId) {
    if (peerUserId != null && _activePeerUserId == peerUserId) {
      _activePeerUserId = null;
    }
  }

  /// Clear the group marker ONLY if it still points at [serverRoomId]. Same
  /// A→B-switch race protection as [clearActivePeerIfMatches], for groups.
  void clearActiveGroupIfMatches(int? serverRoomId) {
    if (serverRoomId != null && _activeGroupRoomId == serverRoomId) {
      _activeGroupRoomId = null;
    }
  }

  /// Record the last-notified identity for [serverRoomId] as the most-recently-
  /// used entry, evicting the oldest once the LRU cap is exceeded.
  void _recordNotified(int serverRoomId, int identity) {
    // Re-insert to move the key to the MRU end (insertion-ordered map).
    _lastNotifiedByRoom.remove(serverRoomId);
    _lastNotifiedByRoom[serverRoomId] = identity;
    while (_lastNotifiedByRoom.length > _lastNotifiedCap) {
      _lastNotifiedByRoom.remove(_lastNotifiedByRoom.keys.first);
    }
  }

  /// Clear all per-session state (active markers + dedup high-water marks).
  /// Invoked from the chat teardown on logout / account switch so a new
  /// identity never inherits the previous session's dedup state (which would
  /// silently suppress its first messages per reused room id).
  void reset() {
    clearActive();
    _lastNotifiedByRoom.clear();
    _removeBanner();
  }

  /// The group [serverRoomId] currently on screen, if any. Lets the realtime
  /// receive path decide whether a kick/self-leave for that room must pop the
  /// open chat (it only closes the screen when the affected group is the one the
  /// user is actually looking at).
  int? get activeGroupRoomId => _activeGroupRoomId;

  /// The peer user id of the 1:1 conversation currently on screen, if any. Lets
  /// the realtime receive path suppress the unread bump for the open chat at the
  /// source (instead of writing-then-reverting it via a follow-up markRead,
  /// which flickers the badge).
  int? get activePeerUserId => _activePeerUserId;

  /// Pop the open group chat when it is the conversation [serverRoomId] on
  /// screen — used when the current user is kicked from / leaves that group, so
  /// they can no longer post into a room they are no longer a member of. A no-op
  /// when a different (or no) group is open. Drops the active marker so a late
  /// duplicate event cannot pop a now-unrelated route.
  void closeActiveGroupIfMatches(int serverRoomId) {
    if (_activeGroupRoomId != serverRoomId) return;
    _activeGroupRoomId = null;
    _removeBanner();
    final navigator = navKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    }
  }

  // --- entry point -----------------------------------------------------------

  /// Decide whether to surface an in-app banner + sound for a freshly persisted
  /// message. Called from the realtime receive path with the raw server JSON and
  /// the resolved [serverRoomId].
  void notifyIncoming({
    required Map<String, dynamic> json,
    required int serverRoomId,
  }) {
    // Only foreground; backgrounded delivery is handled by system push.
    if (!AppLifecycleSignal.isForeground.value) return;

    final senderId = _asInt(json['user_id'] ?? json['sender_id']);
    final me = MyDataModel.getInstance().id;
    // Skip our own echo and anything we can't attribute to a remote sender.
    if (senderId == null || me == null || senderId == me) return;

    // System / non-user messages don't warrant a chat heads-up.
    if ((json['kind']?.toString()) == 'system') return;

    // Dedup: only the first time we see this server message for the room.
    final identity = _asInt(
          json['id'] ?? json['server_message_id'] ?? json['server_seq'],
        ) ??
        0;
    if (identity != 0) {
      final last = _lastNotifiedByRoom[serverRoomId];
      if (last != null && identity <= last) return;
      _recordNotified(serverRoomId, identity);
    }

    // Suppress when the user is already looking at this conversation.
    if (_activeGroupRoomId != null && _activeGroupRoomId == serverRoomId) return;
    if (_activePeerUserId != null && _activePeerUserId == senderId) return;

    final senderName = _senderName(json);
    final body = _previewFor(json);

    // Group vs DM identity:
    //  - GROUP: the banner title is the GROUP name and the avatar is the group
    //    image, with the line prefixed by the sender ("Sender: message"), so the
    //    user can tell which group + who wrote. Tapping opens the group chat.
    //  - DM: the title/avatar are the sender's, the line is the raw body, and
    //    tapping opens the 1:1 conversation. (Unchanged behaviour.)
    final isGroup = _isGroup(json);
    final String title;
    final String avatarUrl;
    final String preview;
    if (isGroup) {
      final groupName = _groupName(json);
      title = groupName.isNotEmpty ? groupName : senderName;
      avatarUrl = _groupImage(json);
      preview = (body.isNotEmpty && senderName.isNotEmpty)
          ? '$senderName: $body'
          : body;
    } else {
      title = senderName;
      avatarUrl = _senderImage(json);
      preview = body;
    }

    _playSound();
    _showBanner(
      title: title,
      preview: preview,
      avatarUrl: avatarUrl,
      peerUserId: senderId,
      hasColorName: _hasColorName(json),
      isGroup: isGroup,
      serverRoomId: serverRoomId,
      groupId: _groupId(json),
    );
  }

  // --- sound -----------------------------------------------------------------

  void _playSound() {
    try {
      final player = _player ??= AudioPlayer();
      player.setReleaseMode(ReleaseMode.stop);
      // Restart from the top so back-to-back messages each ping.
      unawaited(_replay(player));
    } catch (_) {
      // Fallback to the OS alert if the audio backend is unavailable. (On many
      // Android OEMs this is silent, hence the asset chime above is primary.)
      try {
        SystemSound.play(SystemSoundType.alert);
      } catch (_) {
        // Best-effort; never let a missing audio backend break message receipt.
      }
    }
  }

  Future<void> _replay(AudioPlayer player) async {
    try {
      await player.stop();
      await player.play(AssetSource(_soundAsset), volume: 1.0);
    } catch (_) {
      try {
        SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }

  // --- banner ----------------------------------------------------------------

  void _showBanner({
    required String title,
    required String preview,
    required String avatarUrl,
    required int peerUserId,
    required bool hasColorName,
    required bool isGroup,
    required int serverRoomId,
    required int? groupId,
  }) {
    final overlay = navKey.currentState?.overlay;
    if (overlay == null) return;

    // Only one heads-up at a time; replace the previous.
    _removeBanner();

    final entry = OverlayEntry(
      builder: (context) => _ChatHeadsUpBanner(
        title: title,
        preview: preview,
        avatarUrl: avatarUrl,
        onTap: () {
          _removeBanner();
          if (isGroup) {
            _openGroup(
              chatRoomId: serverRoomId,
              groupId: groupId,
              name: title,
              image: avatarUrl,
            );
          } else {
            _openChat(
              peerUserId: peerUserId,
              name: title,
              image: avatarUrl,
              hasColorName: hasColorName,
            );
          }
        },
        onDismiss: _removeBanner,
      ),
    );
    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 4), _removeBanner);
  }

  void _removeBanner() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }

  void _openChat({
    required int peerUserId,
    required String name,
    required String image,
    required bool hasColorName,
  }) {
    final navigator = navKey.currentState;
    if (navigator == null) return;
    navigator.pushNamed(
      Routes.messages,
      arguments: MessagesParameter(
        userId: peerUserId.toString(),
        name: name,
        image: image,
        hasColorName: hasColorName,
      ),
    );
  }

  /// Open the group conversation the banner was for. Mirrors the FCM group
  /// deep-link (notification_service.dart): a minimal [GroupEntity] keyed by the
  /// chat room id is enough — the group screen backfills the rest. The id falls
  /// back to the chat room id when the payload's chat_groups.id is absent.
  void _openGroup({
    required int chatRoomId,
    required int? groupId,
    required String name,
    required String image,
  }) {
    final navigator = navKey.currentState;
    if (navigator == null) return;
    navigator.pushNamed(
      Routes.groupChatDetailScreen,
      arguments: GroupEntity(
        id: groupId ?? chatRoomId,
        chatRoomId: chatRoomId,
        name: name,
        avatar: image,
      ),
    );
  }

  // --- payload extraction ----------------------------------------------------

  String _previewFor(Map<String, dynamic> json) {
    final body = (json['message'] ?? json['body'])?.toString();
    if (body != null && body.trim().isNotEmpty) return body.trim();
    switch (json['type']?.toString()) {
      case 'image':
        return StringManager.photo.tr();
      case 'audio':
        return StringManager.voice.tr();
      case 'video':
        return StringManager.video.tr();
      default:
        return '';
    }
  }

  String _senderName(Map<String, dynamic> json) {
    final user = json['user'];
    if (user is Map) {
      final name = (user['name'] ?? user['user_name'] ?? user['userName'])
          ?.toString();
      if (name != null && name.trim().isNotEmpty) return name.trim();
    }
    final flat =
        (json['user_name'] ?? json['userName'] ?? json['name'])?.toString();
    if (flat != null && flat.trim().isNotEmpty) return flat.trim();
    return StringManager.message.tr();
  }

  String _senderImage(Map<String, dynamic> json) {
    final user = json['user'];
    if (user is Map) {
      final image = (user['image'] ?? user['user_image'] ?? user['userImage'])
          ?.toString();
      if (image != null && image.isNotEmpty) return image;
    }
    final flat =
        (json['user_image'] ?? json['userImage'] ?? json['image'])?.toString();
    return flat ?? '';
  }

  bool _hasColorName(Map<String, dynamic> json) {
    final user = json['user'];
    final raw = (user is Map)
        ? (user['has_color_name'] ?? user['hasColorName'])
        : (json['has_color_name'] ?? json['hasColorName']);
    if (raw is bool) return raw;
    return raw?.toString() == 'true' || raw?.toString() == '1';
  }

  /// A group message carries either the backend-injected `group` object
  /// (BroadcastGroupMessage) or the `is_group` flag (ChatMessageResource).
  bool _isGroup(Map<String, dynamic> json) {
    if (json['group'] is Map) return true;
    final flag = json['is_group'];
    if (flag is bool) return flag;
    return flag?.toString() == 'true' || flag?.toString() == '1';
  }

  String _groupName(Map<String, dynamic> json) {
    final group = json['group'];
    if (group is Map) {
      final name = (group['name'] ?? group['title'])?.toString();
      if (name != null && name.trim().isNotEmpty) return name.trim();
    }
    return '';
  }

  String _groupImage(Map<String, dynamic> json) {
    final group = json['group'];
    if (group is Map) {
      final image = (group['image'] ?? group['avatar'])?.toString();
      if (image != null && image.isNotEmpty) return image;
    }
    return '';
  }

  int? _groupId(Map<String, dynamic> json) {
    final group = json['group'];
    if (group is Map) return _asInt(group['id']);
    return null;
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  void dispose() {
    _removeBanner();
    _lastNotifiedByRoom.clear();
    _player?.dispose();
    _player = null;
  }
}

/// Top heads-up card shown for an incoming foreground chat message. Styled to
/// match the app's overlay banners (see `Methods.showToast` / room banners):
/// avatar + sender name + one-line preview, tappable to open the chat.
class _ChatHeadsUpBanner extends StatelessWidget {
  const _ChatHeadsUpBanner({
    required this.title,
    required this.preview,
    required this.avatarUrl,
    required this.onTap,
    required this.onDismiss,
  });

  final String title;
  final String preview;
  final String avatarUrl;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 8.h,
      left: 12.w,
      right: 12.w,
      child: Material(
        color: ColorManager.transparent,
        child: Dismissible(
          key: const ValueKey('in_app_chat_banner'),
          direction: DismissDirection.up,
          onDismissed: (_) => onDismiss(),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: context.paddingSymmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: 16.radius,
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.black.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  UserImage(
                    image: avatarUrl,
                    displayName: title,
                    imageSize: 44,
                    borderRadius: 22.radius,
                  ),
                  10.wBox,
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          title,
                          isTranslate: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyMedium.w600
                              .colorExt(ColorManager.black),
                        ),
                        if (preview.isNotEmpty) ...[
                          2.hBox,
                          TextWidget(
                            preview,
                            isTranslate: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.bodyMedium
                                .colorExt(ColorManager.greyTextColor),
                          ),
                        ],
                      ],
                    ),
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

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

/// State of the two owner/admin room controls.
///
/// [version] is a logical counter: every change made by an owner/admin bumps
/// it, and a client only accepts a state with a higher version (ties broken by
/// [updatedAt]). Clocks on phones differ, so ordering by time alone would let a
/// slow-clock admin's change be ignored.
class RoomControlsState {
  final bool allMute;
  final Set<String> muteAllow;
  final bool commentLock;
  final Set<String> commentAllow;
  final int version;
  final int updatedAt;
  final String by;

  const RoomControlsState({
    this.allMute = false,
    this.muteAllow = const {},
    this.commentLock = false,
    this.commentAllow = const {},
    this.version = 0,
    this.updatedAt = 0,
    this.by = '',
  });

  RoomControlsState copyWith({
    bool? allMute,
    Set<String>? muteAllow,
    bool? commentLock,
    Set<String>? commentAllow,
    int? version,
    int? updatedAt,
    String? by,
  }) {
    return RoomControlsState(
      allMute: allMute ?? this.allMute,
      muteAllow: muteAllow ?? this.muteAllow,
      commentLock: commentLock ?? this.commentLock,
      commentAllow: commentAllow ?? this.commentAllow,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      by: by ?? this.by,
    );
  }

  bool isNewerThan(RoomControlsState other) =>
      version > other.version ||
      (version == other.version && updatedAt > other.updatedAt);

  Map<String, dynamic> toJson() => {
    'all_mute': allMute,
    'mute_allow_users': muteAllow.toList(),
    'comment_lock': commentLock,
    'comment_allow_users': commentAllow.toList(),
    'v': version,
    't': updatedAt,
    'by': by,
  };

  static Set<String> _ids(Object? raw) => {
    if (raw is List)
      for (final e in raw)
        if (e != null && e.toString().isNotEmpty) e.toString(),
  };

  factory RoomControlsState.fromJson(Map<String, dynamic> json) {
    return RoomControlsState(
      allMute: json['all_mute'] == true,
      muteAllow: _ids(json['mute_allow_users']),
      commentLock: json['comment_lock'] == true,
      commentAllow: _ids(json['comment_allow_users']),
      version: int.tryParse('${json['v'] ?? 0}') ?? 0,
      updatedAt: int.tryParse('${json['t'] ?? 0}') ?? 0,
      by: '${json['by'] ?? ''}',
    );
  }
}

/// All Mute and Comment Lock for audio rooms.
///
/// * All Mute: normal users on a seat cannot speak. The owner/admin can allow
///   chosen seated users; an allowance ends when that user leaves the seat.
/// * Comment Lock: normal users cannot send comments. The owner/admin can
///   allow chosen users (seated or audience).
///
/// Owner and admins are never affected. The state travels on the room data
/// channel (`roomControls`). A user who joins later asks for it
/// (`roomControlsQuery`) and whoever already holds it answers -- the answers
/// are spread over a random delay and stop as soon as one has been seen, so a
/// full room does not reply all at once.
///
/// Both controls are enforced on every phone: the mic cannot be turned on
/// ([UTDMediaController.speakGate]) and locked users' comments are neither
/// sent nor shown ([UTDChatController.appReceiveGate]).
class RoomControls {
  RoomControls._();
  static final RoomControls instance = RoomControls._();

  static const String messageKey = 'roomControls';
  static const String queryKey = 'roomControlsQuery';

  /// Marks a comment the user typed (text or picture) in its userData, so the
  /// receive gate drops only real comments and never system lines such as the
  /// "joined the room" message.
  static const String userCommentKey = 'uc';

  final ValueNotifier<RoomControlsState> state = ValueNotifier(
    const RoomControlsState(),
  );

  UTDRoomController? _controller;
  VoidCallback? _connListener;
  VoidCallback? _seatsListener;
  Set<String> _seated = {};
  Timer? _queryTimer;
  Timer? _replyTimer;
  Timer? _restoreTimer;
  StreamSubscription<String>? _metaSub;
  bool _installed = false;
  final Random _random = Random();

  String get _me => MyDataModel.getInstance().id?.toString() ?? '';

  /// Owner or admin of the current room.
  bool isPrivileged(String userId) {
    if (userId.isEmpty) return false;
    final ownerId = RoomData.instance.roomOrNull?.ownerId?.toString();
    return userId == ownerId ||
        RoomData.instance.adminsInRoom.containsKey(userId);
  }

  bool get amPrivileged => isPrivileged(_me);

  bool canSpeak(String userId) {
    final s = state.value;
    return !s.allMute || isPrivileged(userId) || s.muteAllow.contains(userId);
  }

  bool canChat(String userId) {
    final s = state.value;
    return !s.commentLock ||
        isPrivileged(userId) ||
        s.commentAllow.contains(userId);
  }

  bool get canISpeak => canSpeak(_me);
  bool get canIChat => canChat(_me);

  void _install() {
    if (_installed) return;
    _installed = true;
    UTDMediaController.speakGate = () => canISpeak;
    UTDChatController.appReceiveGate =
        (senderId, userData) =>
            '${userData[userCommentKey] ?? ''}' != '1' || canChat(senderId);
  }

  /// Hooks the controls to the room's controller. Safe to call again with the
  /// same controller (minimize / restore).
  void attach(UTDRoomController controller) {
    _install();
    if (identical(_controller, controller)) return;
    _detach();
    // A new controller means a new room: the last room's All Mute / Comment
    // Lock must not follow the user in (it muted them in rooms where nobody
    // had turned it on). This room's state comes from the query below.
    _seated = {};
    state.value = const RoomControlsState();
    _controller = controller;

    _connListener = () {
      if (controller.connectionState.value == UTDConnectionState.connected) {
        _applyServerState(controller.roomMetadata);
        _scheduleQuery();
        _scheduleRestore();
      }
    };
    _metaSub = controller.roomMetadataStream.listen(_applyServerState);
    controller.connectionState.addListener(_connListener!);
    _connListener!();

    _seated = _seatedIds(controller);
    _seatsListener = () => _onSeatsChanged(controller);
    controller.seatController.seats.addListener(_seatsListener!);
  }

  void _detach() {
    final c = _controller;
    if (c != null) {
      if (_connListener != null) {
        try {
          c.connectionState.removeListener(_connListener!);
        } catch (_) {}
      }
      if (_seatsListener != null) {
        try {
          c.seatController.seats.removeListener(_seatsListener!);
        } catch (_) {}
      }
    }
    _connListener = null;
    _seatsListener = null;
    _controller = null;
    _queryTimer?.cancel();
    _replyTimer?.cancel();
    _restoreTimer?.cancel();
    _metaSub?.cancel();
    _metaSub = null;
  }

  /// Room exit: forget everything.
  void reset() {
    _detach();
    _seated = {};
    state.value = const RoomControlsState();
  }

  Set<String> _seatedIds(UTDRoomController c) => {
    for (final s in c.seatController.seats.value)
      if (s.occupantUserId != null && s.occupantUserId!.isNotEmpty)
        s.occupantUserId!,
  };

  /// People on a seat right now, owner/admins left out.
  List<String> seatedNormalUsers() {
    final c = _controller ?? RoomData.instance.utdController;
    if (c == null) return const [];
    return [
      for (final s in c.seatController.seats.value)
        if (s.occupantUserId != null &&
            s.occupantUserId!.isNotEmpty &&
            !isPrivileged(s.occupantUserId!))
          s.occupantUserId!,
    ];
  }

  /// Everyone in the room, owner/admins left out.
  List<String> roomNormalUsers() {
    final c = _controller ?? RoomData.instance.utdController;
    if (c == null) return const [];
    final ids = <String>{
      for (final p in c.participants) p.id,
      ..._seatedIds(c),
    };
    return [
      for (final id in ids)
        if (id.isNotEmpty && !isPrivileged(id)) id,
    ];
  }

  // ---------------------------------------------------------------------------
  // Owner / admin actions
  // ---------------------------------------------------------------------------

  void setAllMute(bool on) {
    final s = state.value;
    _change(s.copyWith(allMute: on, muteAllow: const {}));
  }

  void setMuteAllowed(String userId, bool allowed) {
    final s = state.value;
    if (!s.allMute) return;
    final next = {...s.muteAllow};
    allowed ? next.add(userId) : next.remove(userId);
    _change(s.copyWith(muteAllow: next));
  }

  void setCommentLock(bool on) {
    final s = state.value;
    _change(s.copyWith(commentLock: on, commentAllow: const {}));
  }

  void setCommentAllowed(String userId, bool allowed) {
    final s = state.value;
    if (!s.commentLock) return;
    final next = {...s.commentAllow};
    allowed ? next.add(userId) : next.remove(userId);
    _change(s.copyWith(commentAllow: next));
  }

  void _change(RoomControlsState next) {
    if (!amPrivileged) return;
    final prev = state.value;
    final stamped = next.copyWith(
      version: prev.version + 1,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      by: _me,
    );
    state.value = stamped;
    _replyTimer?.cancel();
    _restoreTimer?.cancel();
    _save(stamped);
    _broadcast(announce: true);
    final me = MyDataModel.getInstance();
    _announce(prev, stamped, me.name ?? '', me.profile?.image ?? '');
    _enforce();
  }

  void _broadcast({required bool announce}) {
    final me = MyDataModel.getInstance();
    sendRoomData(
      data: {
        'message': messageKey,
        ...state.value.toJson(),
        'announce': announce,
        'byName': me.name ?? '',
        'img': me.profile?.image ?? '',
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Incoming
  // ---------------------------------------------------------------------------

  void handleMessage(Map<String, dynamic> content) {
    final type = content['message'];
    if (type == queryKey) {
      _onQuery();
      return;
    }
    if (type != messageKey) return;

    final next = RoomControlsState.fromJson(content);
    // Only an owner/admin may change the controls.
    if (!isPrivileged(next.by)) return;

    final current = state.value;
    if (!next.isNewerThan(current)) {
      // Someone already answered a query with what this phone holds.
      if (next.version == current.version) _replyTimer?.cancel();
      return;
    }
    _replyTimer?.cancel();
    _restoreTimer?.cancel();
    state.value = next;
    if (amPrivileged) _save(next);
    if (content['announce'] == true) {
      _announce(
        current,
        next,
        '${content['byName'] ?? ''}',
        '${content['img'] ?? ''}',
      );
    }
    _enforce();
  }

  void _scheduleQuery() {
    _queryTimer?.cancel();
    _queryTimer = Timer(const Duration(milliseconds: 1500), () {
      sendRoomData(data: {'message': queryKey, 'by': _me});
    });
  }

  void _onQuery() {
    if (state.value.version == 0) return;
    _replyTimer?.cancel();
    _replyTimer = Timer(
      Duration(milliseconds: 200 + _random.nextInt(1500)),
      () => _broadcast(announce: false),
    );
  }

  // ---------------------------------------------------------------------------
  // Keeping the state across visits
  // ---------------------------------------------------------------------------

  String? get _roomId => RoomData.instance.roomOrNull?.id?.toString();

  static String _prefKey(String roomId) => 'room_controls_$roomId';

  /// The backend's copy (`_seats` in the room metadata). It only counts when
  /// it turns something on: today the backend always sends false, and taking
  /// that would wipe the state the people in the room already share.
  void _applyServerState(String? metadata) {
    if (metadata == null || metadata.isEmpty) return;
    Map<String, dynamic>? seats;
    try {
      final decoded = jsonDecode(metadata);
      if (decoded is Map && decoded['_seats'] is Map) {
        seats = Map<String, dynamic>.from(decoded['_seats'] as Map);
      }
    } catch (_) {
      return;
    }
    if (seats == null) return;
    final server = RoomControlsState.fromJson(seats);
    if (!server.allMute && !server.commentLock) return;
    final current = state.value;
    if (current.version > 0) return;
    _restoreTimer?.cancel();
    state.value = server.copyWith(
      version: 1,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      by: RoomData.instance.roomOrNull?.ownerId?.toString() ?? '',
    );
    _enforce();
  }

  /// Saves the room's controls on this phone (owner/admin only), so the room
  /// is the way they left it when they come back.
  void _save(RoomControlsState s) {
    final roomId = _roomId;
    if (roomId == null || roomId.isEmpty) return;
    SharedPreferences.getInstance()
        .then((p) => p.setString(_prefKey(roomId), jsonEncode(s.toJson())))
        .catchError((Object e) {
          Methods.printLog('[RoomControls] save failed: $e');
          return false;
        });
  }

  /// When nobody in the room answered the query (the room was empty), the
  /// owner/admin puts back what they saved last time and shares it.
  void _scheduleRestore() {
    _restoreTimer?.cancel();
    if (!amPrivileged) return;
    final roomId = _roomId;
    if (roomId == null || roomId.isEmpty) return;
    _restoreTimer = Timer(const Duration(milliseconds: 3500), () async {
      if (state.value.version > 0 || !amPrivileged) return;
      final String? raw;
      try {
        raw = (await SharedPreferences.getInstance()).getString(
          _prefKey(roomId),
        );
      } catch (_) {
        return;
      }
      if (raw == null || _roomId != roomId || state.value.version > 0) return;
      final RoomControlsState saved;
      try {
        saved = RoomControlsState.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map),
        );
      } catch (_) {
        return;
      }
      if (!saved.allMute && !saved.commentLock) return;
      // Allowances belong to people who were seated then; start clean.
      state.value = saved.copyWith(
        muteAllow: const {},
        version: saved.version + 1,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        by: _me,
      );
      _broadcast(announce: false);
      _enforce();
    });
  }

  // ---------------------------------------------------------------------------
  // Local effects
  // ---------------------------------------------------------------------------

  /// An allowance to speak ends when the user leaves their seat. Every phone
  /// applies this same rule when it sees the seat change, so no message is
  /// needed for it.
  void _onSeatsChanged(UTDRoomController c) {
    final now = _seatedIds(c);
    final left = _seated.difference(now);
    _seated = now;
    // Taking a seat grants the publish permission; re-read it in case the
    // permissions event was missed, so the mic button does not stay dead.
    c.mediaController.refreshCanPublish();
    final s = state.value;
    if (left.isNotEmpty && s.muteAllow.any(left.contains)) {
      state.value = s.copyWith(muteAllow: s.muteAllow.difference(left));
    }
    _enforce();
  }

  /// Turns the local mic off when this user may no longer speak.
  void _enforce() {
    if (canISpeak) return;
    final media =
        (_controller ?? RoomData.instance.utdController)?.mediaController;
    if (media == null || !media.isMicEnabled.value) return;
    media.setMicrophoneEnabled(false).catchError((Object e) {
      Methods.printLog('[RoomControls] mic off failed: $e');
    });
  }

  /// One chat line per switch (on/off), shown on every phone.
  void _announce(
    RoomControlsState prev,
    RoomControlsState next,
    String byName,
    String img,
  ) {
    final lines = <String>[
      if (prev.allMute != next.allMute)
        next.allMute ? 'turned on All Mute' : 'turned off All Mute',
      if (prev.commentLock != next.commentLock)
        next.commentLock ? 'locked all comments' : 'unlocked all comments',
    ];
    final chat = RoomData.instance.chatController;
    if (chat == null) return;
    for (final line in lines) {
      chat.addDisplayMessage(
        UTDChatMessage(
          senderUserId: next.by,
          senderName: byName,
          text: line,
          timestamp: DateTime.now(),
          userData: {
            'img': img,
            'senderId': next.by,
            'senderName': byName,
            'type': 'message',
          },
        ),
      );
    }
  }
}

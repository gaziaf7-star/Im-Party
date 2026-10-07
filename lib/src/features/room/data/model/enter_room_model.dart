import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';
import 'package:general/src/features/room/presentation/charisma/bloc/charisma_bloc.dart';
import 'package:general/src/features/room/presentation/manager/room_mode/room_mode_cubit.dart';
import 'package:general/src/features/room/room.dart';
import '../../../auth/data/model/vip_model.dart';

class EnterRoomModel extends Equatable {
  int? id;
  int? ownerId;
  bool? roomPassStatus;
  String? roomName;
  String? roomCover;
  String? roomIntro;
  String? roomPass;
  String? roomBackground;
  String? roomWelcome;
  dynamic giftPrice;
  int? isPK;
  PKModel? pkModel;
  String? mode;
  List<String>? admins;

  /// Granular admin permissions: user id -> permission keys (null = ALL).
  /// Parsed from `admin_permissions` in the enter-room payload.
  Map<String, List<String>?>? adminPermissions;
  String? uuidOwnerRoom;
  int? showPk;
  String roomRule;
  bool? isCommentsClosed;
  String? ownerSpecialId;
  ImageColorEntity? ownerImageColor;
  bool? isCharisma;
  VipCenterModel? vip;
  List<List<int>>? cpIndexs;
  bool? isLive;

  /// When the broadcast went on air, from the server.
  ///
  /// Server-owned on purpose: a client-side stopwatch would start whenever THIS
  /// viewer joined, so everyone would see a different elapsed time for the same
  /// broadcast.
  DateTime? liveStartedAt;
  String? ownerName;
  String? ownerImage;

  /// The host's avatar frame (a ware) and its media type, so the room
  /// chrome can draw it the way profile screens do.
  String? ownerFrame;
  String? ownerFrameType;
  String? streamType;
  List<dynamic>? mics;
  int? myTaskId;
  int? currentTaskId;
  String? luckyGiftCoins;
  String? roomLevelImage;

  /// Cumulative UNIQUE viewers of the CURRENT broadcast (server-counted in
  /// enter_room, reset on end-live). Live rooms only; 0 for audio.
  int? liveViewersTotal;

  /// Whether the requesting user already follows the host (true for the host
  /// themself). Drives the live "متابعة" pill.
  bool? isFollowingOwner;

  static EnterRoomModel? _instance;

  EnterRoomModel({
    this.ownerId,
    this.admins,
    this.adminPermissions,
    this.pkModel,
    this.roomName,
    this.roomCover,
    this.roomIntro,
    this.roomPass,
    this.roomBackground,
    this.roomWelcome,
    this.giftPrice,
    this.isPK,
    this.id,
    this.roomPassStatus,
    this.mode,
    this.uuidOwnerRoom,
    this.showPk,
    this.roomRule = '',
    this.isCommentsClosed,
    this.isCharisma,
    this.vip,
    this.cpIndexs,
    this.mics,
    this.ownerSpecialId,
    this.ownerImageColor,
    this.isLive,
    this.liveStartedAt,
    this.ownerName,
    this.ownerImage,
    this.ownerFrame,
    this.ownerFrameType,
    this.streamType,
    this.myTaskId,
    this.currentTaskId,
    this.luckyGiftCoins,
    this.roomLevelImage,
    this.liveViewersTotal,
    this.isFollowingOwner,
  });

  void copyWith({
    int? id,
    int? ownerId,
    bool? roomPassStatus,
    String? roomName,
    String? roomCover,
    String? roomIntro,
    String? roomPass,
    String? roomBackground,
    String? roomWelcome,
    dynamic giftPrice,
    int? isPK,
    PKModel? pkModel,
    String? mode,
    List<String>? admins,
    Map<String, List<String>?>? adminPermissions,
    String? uuidOwnerRoom,
    int? showPk,
    String? roomRule,
    bool? isCommentsClosed,
    String? ownerSpecialId,
    ImageColorEntity? ownerImageColor,
    bool? isCharisma,
    VipCenterModel? vip,
    List<List<int>>? cpIndexs,
    bool? isLive,
    String? ownerFrame,
    String? ownerFrameType,
    DateTime? liveStartedAt,
    String? ownerName,
    String? ownerImage,
    String? streamType,
    List<dynamic>? mics,
    int? myTaskId,
    int? currentTaskId,
    String? luckyGiftCoins,
    String? roomLevelImage,
    int? liveViewersTotal,
    bool? isFollowingOwner,
  }) {
    this.ownerSpecialId = ownerSpecialId ?? this.ownerSpecialId;
    this.ownerImageColor = ownerImageColor ?? this.ownerImageColor;
    this.ownerId = ownerId ?? this.ownerId;
    this.admins = admins ?? this.admins;
    this.adminPermissions = adminPermissions ?? this.adminPermissions;
    this.pkModel = pkModel ?? this.pkModel;
    this.roomName = roomName ?? this.roomName;
    this.roomCover = roomCover ?? this.roomCover;
    this.roomIntro = roomIntro ?? this.roomIntro;
    this.roomPass = roomPass ?? this.roomPass;
    this.roomBackground = roomBackground ?? this.roomBackground;
    this.roomWelcome = roomWelcome ?? this.roomWelcome;
    this.giftPrice = giftPrice ?? this.giftPrice;
    this.isPK = isPK ?? this.isPK;
    this.id = id ?? this.id;
    this.roomPassStatus = roomPassStatus ?? this.roomPassStatus;
    this.mode = mode ?? this.mode;
    this.uuidOwnerRoom = uuidOwnerRoom ?? this.uuidOwnerRoom;
    this.showPk = showPk ?? this.showPk;
    this.roomRule = roomRule ?? this.roomRule;
    this.isCommentsClosed = isCommentsClosed ?? this.isCommentsClosed;
    this.isCharisma = isCharisma ?? this.isCharisma;
    this.vip = vip ?? this.vip;
    this.cpIndexs = cpIndexs ?? this.cpIndexs;
    this.mics = mics ?? this.mics;
    this.isLive = isLive ?? this.isLive;
    this.ownerFrame = ownerFrame ?? this.ownerFrame;
    this.ownerFrameType = ownerFrameType ?? this.ownerFrameType;
    this.liveStartedAt = liveStartedAt ?? this.liveStartedAt;
    this.ownerName = ownerName ?? this.ownerName;
    this.ownerImage = ownerImage ?? this.ownerImage;
    this.streamType = streamType ?? this.streamType;
    this.myTaskId = myTaskId ?? this.myTaskId;
    this.currentTaskId = currentTaskId ?? this.currentTaskId;
    this.luckyGiftCoins = luckyGiftCoins ?? this.luckyGiftCoins;
    this.roomLevelImage = roomLevelImage ?? this.roomLevelImage;
    this.liveViewersTotal = liveViewersTotal ?? this.liveViewersTotal;
    this.isFollowingOwner = isFollowingOwner ?? this.isFollowingOwner;
  }

  factory EnterRoomModel.fromJson(Map<String, dynamic> json) {
    final charismaVisible = json['charisma_status'] ?? false;
    RoomData.instance.isCharismaVisible.value = charismaVisible;
    di<RoomOverlayCubit>().setCharismaVisible(charismaVisible);

    // Server-authoritative charisma: seed the seat-state render from the
    // per-seat charisma_total + owner_charisma_total shipped in the enter-room
    // payload, so a (re)joiner shows correct badges immediately with zero resync.
    _seedCharismaFromEnterRoom(json, charismaVisible == true);

    EnterRoomModel createInstance() {
      return EnterRoomModel(
        id: parseValue<int>(json['id'], 0),
        ownerId: parseValue<int>(json['owner_id'], 0),
        roomPassStatus: parseValue<bool>(json['password_status'], false),
        roomName: parseValue<String>(json['room_name'], ''),
        roomCover: parseValue<String>(json['room_cover'], ''),
        roomIntro: parseValue<String>(json['room_intro'], ''),
        roomPass: parseValue<String>(json['room_pass'], ''),
        roomBackground: parseValue<String>(json['room_background'], ''),
        roomWelcome: parseValue<String>(json['room_welcome'], ''),
        giftPrice: json['giftPrice'] ?? "0.0",
        isPK: parseValue<int>(json['is_pk'], 0),
        pkModel: json['pk'] is Map<String, dynamic>
            ? PKModel.fromJson(json['pk'])
            : null,
        mode: parseValue<String>(json['mode'], ''),
        admins:
            json['admins'] is List ? List<String>.from(json['admins']) : null,
        adminPermissions: _parseAdminPermissions(json['admin_permissions']),
        uuidOwnerRoom: parseValue<String>(json['uuid'], ''),
        showPk: parseValue<int>(json['show_pk'], 0),
        roomRule: parseValue<String>(json['room_rule'], ''),
        isCommentsClosed: parseValue<bool>(json['is_comment_closed'], false),
        ownerSpecialId: parseValue<String>(json['owner_special_id'], ''),
        ownerName: parseValue<String>(json['owner_name'], ''),
        ownerImage: parseValue<String>(json['owner_image'], ''),
        isCharisma: parseValue<bool>(json['charisma_status'], false),
        isLive: parseValue<bool>(json['is_live'], false),
        ownerFrame: parseValue<String>(json['owner_frame'], ''),
        ownerFrameType: parseValue<String>(json['owner_frame_type'], ''),
        liveStartedAt: DateTime.tryParse('${json['live_started_at'] ?? ''}'),
        streamType: parseValue<String>(json['stream_type'], ""),
        vip: json['vip'] is Map<String, dynamic>
            ? VipCenterModel.fromJson(json['vip'])
            : null,
        ownerImageColor: json['owner_image_color'] is Map<String, dynamic>
            ? ImageColorModel.fromJson(json['owner_image_color'])
            : null,
        cpIndexs: json['cp_indexs'] is List
            ? (json['cp_indexs'] as List<dynamic>)
                .whereType<List>()
                .map((e) => e.whereType<int>().toList())
                .toList()
            : [],
        mics: (json['microphones'] is List ? json['microphones'] as List : [])
            .map((item) {
          final microphone = MicrophoneBox.fromJson(item);
          return microphone;
        }).toList(),
        myTaskId: parseValue<int>(json['owner_task_room_id'], 0),
        currentTaskId: parseValue<int>(json['current_task_room_id'], 0),
        luckyGiftCoins: parseValue<String>(json['lucky_gift_coins'], "0"),
        roomLevelImage: parseValue<String>(json['room_level_image'], ""),
        liveViewersTotal: parseValue<int>(json['live_viewers_total'], 0),
        isFollowingOwner: parseValue<bool>(json['is_following_owner'], false),
      );
    }

    if (_instance == null) {
      _instance = createInstance();
    } else if (json['id'] != null && json['id'] != _instance!.id) {
      // A DIFFERENT room: never merge — merging lets the previous room's
      // values leak through this room's null fields (e.g. a coverless
      // broadcast showing the PREVIOUS broadcast's cover/intro — owner
      // report 2026-06-12). Merge semantics are for partial updates of the
      // SAME room only.
      _instance = createInstance();
    } else {
      _instance!.copyWith(
        id: json['id'] ?? _instance!.id,
        ownerId: json['owner_id'] ?? _instance!.ownerId,
        roomPassStatus: json['password_status'] ?? _instance!.roomPassStatus,
        roomName: json['room_name'] ?? _instance!.roomName,
        roomCover: json['room_cover'] ?? _instance!.roomCover,
        roomIntro: json['room_intro'] ?? _instance!.roomIntro,
        roomPass: json['room_pass'] ?? _instance!.roomPass,
        roomBackground: json['room_background'] ?? _instance!.roomBackground,
        roomWelcome: json['room_welcome'] ?? _instance!.roomWelcome,
        giftPrice: json['giftPrice'] ?? _instance!.giftPrice,
        isPK: json['is_pk'] ?? _instance!.isPK,
        pkModel: json['pk'] is Map<String, dynamic>
            ? PKModel.fromJson(json['pk'])
            : _instance!.pkModel,
        mode: json['mode']?.toString() ?? _instance!.mode,
        admins: json['admins'] is List
            ? List<String>.from(json['admins'])
            : _instance!.admins,
        adminPermissions: _parseAdminPermissions(json['admin_permissions']) ??
            _instance!.adminPermissions,
        uuidOwnerRoom: json['uuid'] ?? _instance!.uuidOwnerRoom,
        showPk: json['show_pk'] ?? _instance!.showPk,
        roomRule: json['room_rule'] ?? _instance!.roomRule,
        isCommentsClosed:
            json['is_comment_closed'] ?? _instance!.isCommentsClosed,
        isCharisma: json['charisma_status'] ?? _instance!.isCharisma,
        ownerSpecialId: json['owner_special_id'] ?? _instance!.ownerSpecialId,
        isLive: json['is_live'] ?? _instance!.isLive,
        ownerFrame: parseValue<String>(json['owner_frame'], _instance!.ownerFrame ?? ''),
        ownerFrameType: parseValue<String>(json['owner_frame_type'], _instance!.ownerFrameType ?? ''),
        liveStartedAt: DateTime.tryParse('${json['live_started_at'] ?? ''}') ?? _instance!.liveStartedAt,
        ownerName: json['owner_name'] ?? _instance!.ownerName,
        ownerImage: json['owner_image'] ?? _instance!.ownerImage,
        streamType: json['stream_type'] ?? _instance!.streamType,
        ownerImageColor: json['owner_image_color'] is Map<String, dynamic>
            ? ImageColorModel.fromJson(json['owner_image_color'])
            : _instance!.ownerImageColor,
        vip: json['vip'] is Map<String, dynamic>
            ? VipCenterModel.fromJson(json['vip'])
            : _instance!.vip,
        cpIndexs: json['cp_indexs'] is List
            ? (json['cp_indexs'] as List<dynamic>)
                .whereType<List>()
                .map((e) => e.whereType<int>().toList())
                .toList()
            : _instance!.cpIndexs,
        mics: json['microphones'] is List
            ? (json['microphones'] as List)
                .map((item) => MicrophoneBox.fromJson(item))
                .toList()
            : _instance!.mics,
        myTaskId: parseValue<int>(json['owner_task_room_id'], 0),
        currentTaskId: parseValue<int>(json['current_task_room_id'], 0),
        luckyGiftCoins: parseValue<String>(json['lucky_gift_coins'], "0"),
        roomLevelImage: parseValue<String>(json['room_level_image'], ""),
        liveViewersTotal:
            json['live_viewers_total'] ?? _instance!.liveViewersTotal,
        isFollowingOwner:
            json['is_following_owner'] ?? _instance!.isFollowingOwner,
      );
    }

    return _instance!;
  }

  @override
  List<Object?> get props => [
        ownerId,
        admins,
        pkModel,
        roomName,
        roomCover,
        roomIntro,
        roomPass,
        roomBackground,
        roomWelcome,
        giftPrice,
        isPK,
        id,
        roomPassStatus,
        mode,
        uuidOwnerRoom,
        showPk,
        roomRule,
        isCommentsClosed,
        isCharisma,
        ownerSpecialId,
        ownerImageColor,
        vip,
        cpIndexs,
        mics,
        isLive,
        ownerImage,
        ownerName,
        streamType,
        myTaskId,
        currentTaskId,
        luckyGiftCoins,
        roomLevelImage,
        liveViewersTotal,
        isFollowingOwner,
      ];
}

class MicrophoneBox extends Equatable {
  final int? id;
  final String? name;
  final String? img;
  final String? seatCondition;

  const MicrophoneBox({
    this.id,
    this.name,
    this.img,
    this.seatCondition,
  });

  factory MicrophoneBox.fromJson(dynamic json) {
    if (json is String) {
      return MicrophoneBox(seatCondition: json);
    }

    if (json is Map) {
      return MicrophoneBox(
        id: parseValue<int>(json['id'], 0),
        name: parseValue<String>(json['name'], ''),
        img: parseValue<String>(json['img'], ''),
        seatCondition: parseValue<String>(json['seat_condition'], ''),
      );
    }

    return const MicrophoneBox(seatCondition: 'empty');
  }

  @override
  List<Object?> get props => [id, name, img, seatCondition];
}

Map<String, List<String>?>? _parseAdminPermissions(dynamic raw) {
  if (raw is! Map) return null;
  final out = <String, List<String>?>{};
  raw.forEach((key, value) {
    out['$key'] = value is List
        ? value.map((e) => e.toString()).toList()
        : null; // null = all permissions
  });
  return out;
}

/// Seeds the charisma seat-state render from the server-authoritative
/// enter-room payload: each seated user's `charisma_total` plus the room owner's
/// `owner_charisma_total`. When charisma is off, clears any stale render. The
/// dispatch is deferred so it never re-enters CharismaBloc while it (or the room)
/// is still being built during entry.
void _seedCharismaFromEnterRoom(Map<String, dynamic> json, bool charismaVisible) {
  scheduleMicrotask(() {
    final bloc = di<CharismaBloc>();
    if (bloc.isClosed) return;

    if (!charismaVisible) {
      bloc.add(const InitCharismaEvent());
      return;
    }

    final updates = <CharismaModel>[];

    final mics = json['microphones'];
    if (mics is List) {
      for (final m in mics) {
        if (m is! Map) continue;
        final userId = int.tryParse('${m['id']}') ?? 0;
        if (userId <= 0) continue;
        final total = (m['charisma_total'] is num)
            ? (m['charisma_total'] as num).toInt()
            : int.tryParse('${m['charisma_total'] ?? ''}') ?? 0;
        if (total <= 0) continue;
        updates.add(CharismaModel(
          userId: userId,
          total: Methods().convertToAbbreviatedString(total),
          position: 0,
          totalValue: total,
        ));
      }
    }

    final ownerId = int.tryParse('${json['owner_id']}') ?? 0;
    final ownerTotal = (json['owner_charisma_total'] is num)
        ? (json['owner_charisma_total'] as num).toInt()
        : int.tryParse('${json['owner_charisma_total'] ?? ''}') ?? 0;
    if (ownerId > 0 &&
        ownerTotal > 0 &&
        !updates.any((e) => e.userId == ownerId)) {
      updates.add(CharismaModel(
        userId: ownerId,
        total: Methods().convertToAbbreviatedString(ownerTotal),
        position: 0,
        totalValue: ownerTotal,
      ));
    }

    if (updates.isNotEmpty) {
      bloc.add(UpdateCharismaEvent(data: updates));
    }
  });
}

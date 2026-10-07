// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
      'local_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverRoomIdMeta =
      const VerificationMeta('serverRoomId');
  @override
  late final GeneratedColumn<int> serverRoomId = GeneratedColumn<int>(
      'server_room_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<RoomType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<RoomType>($RoomsTable.$convertertype);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _peerUserIdMeta =
      const VerificationMeta('peerUserId');
  @override
  late final GeneratedColumn<int> peerUserId = GeneratedColumn<int>(
      'peer_user_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _memberCountMeta =
      const VerificationMeta('memberCount');
  @override
  late final GeneratedColumn<int> memberCount = GeneratedColumn<int>(
      'member_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastMessageLocalIdMeta =
      const VerificationMeta('lastMessageLocalId');
  @override
  late final GeneratedColumn<int> lastMessageLocalId = GeneratedColumn<int>(
      'last_message_local_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastPreviewTextMeta =
      const VerificationMeta('lastPreviewText');
  @override
  late final GeneratedColumn<String> lastPreviewText = GeneratedColumn<String>(
      'last_preview_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastPreviewTypeMeta =
      const VerificationMeta('lastPreviewType');
  @override
  late final GeneratedColumn<int> lastPreviewType = GeneratedColumn<int>(
      'last_preview_type', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastPreviewSenderIdMeta =
      const VerificationMeta('lastPreviewSenderId');
  @override
  late final GeneratedColumn<int> lastPreviewSenderId = GeneratedColumn<int>(
      'last_preview_sender_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastPreviewServerMessageIdMeta =
      const VerificationMeta('lastPreviewServerMessageId');
  @override
  late final GeneratedColumn<int> lastPreviewServerMessageId =
      GeneratedColumn<int>('last_preview_server_message_id', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastPreviewStatusMeta =
      const VerificationMeta('lastPreviewStatus');
  @override
  late final GeneratedColumn<String> lastPreviewStatus =
      GeneratedColumn<String>('last_preview_status', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastPreviewStateMeta =
      const VerificationMeta('lastPreviewState');
  @override
  late final GeneratedColumn<int> lastPreviewState = GeneratedColumn<int>(
      'last_preview_state', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastPreviewDeleteStateMeta =
      const VerificationMeta('lastPreviewDeleteState');
  @override
  late final GeneratedColumn<int> lastPreviewDeleteState = GeneratedColumn<int>(
      'last_preview_delete_state', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastServerSeqMeta =
      const VerificationMeta('lastServerSeq');
  @override
  late final GeneratedColumn<int> lastServerSeq = GeneratedColumn<int>(
      'last_server_seq', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _myLastReadSeqMeta =
      const VerificationMeta('myLastReadSeq');
  @override
  late final GeneratedColumn<int> myLastReadSeq = GeneratedColumn<int>(
      'my_last_read_seq', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
      'unread_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _mutedUntilMeta =
      const VerificationMeta('mutedUntil');
  @override
  late final GeneratedColumn<int> mutedUntil = GeneratedColumn<int>(
      'muted_until', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _draftTextMeta =
      const VerificationMeta('draftText');
  @override
  late final GeneratedColumn<String> draftText = GeneratedColumn<String>(
      'draft_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _myRoleMeta = const VerificationMeta('myRole');
  @override
  late final GeneratedColumn<String> myRole = GeneratedColumn<String>(
      'my_role', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        serverRoomId,
        type,
        title,
        avatarUrl,
        peerUserId,
        groupId,
        memberCount,
        lastMessageLocalId,
        lastPreviewText,
        lastPreviewType,
        lastPreviewSenderId,
        lastPreviewServerMessageId,
        lastPreviewStatus,
        lastPreviewState,
        lastPreviewDeleteState,
        lastServerSeq,
        myLastReadSeq,
        unreadCount,
        mutedUntil,
        draftText,
        isArchived,
        myRole,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(Insertable<Room> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    }
    if (data.containsKey('server_room_id')) {
      context.handle(
          _serverRoomIdMeta,
          serverRoomId.isAcceptableOrUnknown(
              data['server_room_id']!, _serverRoomIdMeta));
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('peer_user_id')) {
      context.handle(
          _peerUserIdMeta,
          peerUserId.isAcceptableOrUnknown(
              data['peer_user_id']!, _peerUserIdMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('member_count')) {
      context.handle(
          _memberCountMeta,
          memberCount.isAcceptableOrUnknown(
              data['member_count']!, _memberCountMeta));
    }
    if (data.containsKey('last_message_local_id')) {
      context.handle(
          _lastMessageLocalIdMeta,
          lastMessageLocalId.isAcceptableOrUnknown(
              data['last_message_local_id']!, _lastMessageLocalIdMeta));
    }
    if (data.containsKey('last_preview_text')) {
      context.handle(
          _lastPreviewTextMeta,
          lastPreviewText.isAcceptableOrUnknown(
              data['last_preview_text']!, _lastPreviewTextMeta));
    }
    if (data.containsKey('last_preview_type')) {
      context.handle(
          _lastPreviewTypeMeta,
          lastPreviewType.isAcceptableOrUnknown(
              data['last_preview_type']!, _lastPreviewTypeMeta));
    }
    if (data.containsKey('last_preview_sender_id')) {
      context.handle(
          _lastPreviewSenderIdMeta,
          lastPreviewSenderId.isAcceptableOrUnknown(
              data['last_preview_sender_id']!, _lastPreviewSenderIdMeta));
    }
    if (data.containsKey('last_preview_server_message_id')) {
      context.handle(
          _lastPreviewServerMessageIdMeta,
          lastPreviewServerMessageId.isAcceptableOrUnknown(
              data['last_preview_server_message_id']!,
              _lastPreviewServerMessageIdMeta));
    }
    if (data.containsKey('last_preview_status')) {
      context.handle(
          _lastPreviewStatusMeta,
          lastPreviewStatus.isAcceptableOrUnknown(
              data['last_preview_status']!, _lastPreviewStatusMeta));
    }
    if (data.containsKey('last_preview_state')) {
      context.handle(
          _lastPreviewStateMeta,
          lastPreviewState.isAcceptableOrUnknown(
              data['last_preview_state']!, _lastPreviewStateMeta));
    }
    if (data.containsKey('last_preview_delete_state')) {
      context.handle(
          _lastPreviewDeleteStateMeta,
          lastPreviewDeleteState.isAcceptableOrUnknown(
              data['last_preview_delete_state']!, _lastPreviewDeleteStateMeta));
    }
    if (data.containsKey('last_server_seq')) {
      context.handle(
          _lastServerSeqMeta,
          lastServerSeq.isAcceptableOrUnknown(
              data['last_server_seq']!, _lastServerSeqMeta));
    }
    if (data.containsKey('my_last_read_seq')) {
      context.handle(
          _myLastReadSeqMeta,
          myLastReadSeq.isAcceptableOrUnknown(
              data['my_last_read_seq']!, _myLastReadSeqMeta));
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    }
    if (data.containsKey('muted_until')) {
      context.handle(
          _mutedUntilMeta,
          mutedUntil.isAcceptableOrUnknown(
              data['muted_until']!, _mutedUntilMeta));
    }
    if (data.containsKey('draft_text')) {
      context.handle(_draftTextMeta,
          draftText.isAcceptableOrUnknown(data['draft_text']!, _draftTextMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('my_role')) {
      context.handle(_myRoleMeta,
          myRole.isAcceptableOrUnknown(data['my_role']!, _myRoleMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_id'])!,
      serverRoomId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_room_id']),
      type: $RoomsTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      peerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}peer_user_id']),
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id']),
      memberCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}member_count'])!,
      lastMessageLocalId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_message_local_id']),
      lastPreviewText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_preview_text']),
      lastPreviewType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_preview_type']),
      lastPreviewSenderId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}last_preview_sender_id']),
      lastPreviewServerMessageId: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_preview_server_message_id']),
      lastPreviewStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_preview_status']),
      lastPreviewState: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_preview_state']),
      lastPreviewDeleteState: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_preview_delete_state']),
      lastServerSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_server_seq'])!,
      myLastReadSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}my_last_read_seq'])!,
      unreadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unread_count'])!,
      mutedUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}muted_until']),
      draftText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}draft_text']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      myRole: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}my_role']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RoomType, int, int> $convertertype =
      const EnumIndexConverter<RoomType>(RoomType.values);
}

class Room extends DataClass implements Insertable<Room> {
  final int localId;

  /// Server-side conversation id. Null until the room is reconciled with the
  /// backend. UNIQUE so a server room maps to exactly one local row.
  final int? serverRoomId;
  final RoomType type;
  final String? title;
  final String? avatarUrl;

  /// For 1:1 (dm) rooms: the OTHER participant's user id. Needed to open the
  /// conversation (peer id drives the `chat:dm.{min}_{max}` realtime channel and
  /// the messages route). Null for group rooms. (schema v3)
  final int? peerUserId;

  /// For group rooms: the `chat_groups.id` (distinct from serverRoomId which is
  /// the chat_room id). Needed to open/send in a group from the list. Null for
  /// 1:1 rooms. (schema v3)
  final int? groupId;

  /// For group rooms: active members count (denormalized for the list row). 0 for
  /// 1:1 rooms. (schema v4)
  final int memberCount;

  /// Denormalized pointer to the last message row (for list previews).
  final int? lastMessageLocalId;

  /// Last message body (null for media-only bodies). Drives the preview text.
  final String? lastPreviewText;

  /// Last message [MessageContentType] index — so the list renders the same
  /// glyph/icon ('img'/'voice'/'video'/text) the join-based path produced.
  final int? lastPreviewType;

  /// Last message sender id (for the "You:" prefix + per-row isMe styling).
  final int? lastPreviewSenderId;

  /// Last message server id (for LastMessageEntity.id / jump-to-message).
  final int? lastPreviewServerMessageId;

  /// Last message raw server delivery status ('seen'/'sent'/...) — for the tick.
  final String? lastPreviewStatus;

  /// Last message [MessageState] index — for the tick when no raw status.
  final int? lastPreviewState;

  /// Last message [MessageDeleteState] index — for the deleted-preview placeholder.
  final int? lastPreviewDeleteState;

  /// Highest server_seq seen for this room (drives ordering + unread math).
  final int lastServerSeq;

  /// High-water-mark of what the current user has read in this room.
  final int myLastReadSeq;
  final int unreadCount;
  final int? mutedUntil;
  final String? draftText;
  final bool isArchived;

  /// Current user's role in this room (member/admin/owner) — null for 1:1.
  final String? myRole;
  final int? updatedAt;
  const Room(
      {required this.localId,
      this.serverRoomId,
      required this.type,
      this.title,
      this.avatarUrl,
      this.peerUserId,
      this.groupId,
      required this.memberCount,
      this.lastMessageLocalId,
      this.lastPreviewText,
      this.lastPreviewType,
      this.lastPreviewSenderId,
      this.lastPreviewServerMessageId,
      this.lastPreviewStatus,
      this.lastPreviewState,
      this.lastPreviewDeleteState,
      required this.lastServerSeq,
      required this.myLastReadSeq,
      required this.unreadCount,
      this.mutedUntil,
      this.draftText,
      required this.isArchived,
      this.myRole,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverRoomId != null) {
      map['server_room_id'] = Variable<int>(serverRoomId);
    }
    {
      map['type'] = Variable<int>($RoomsTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || peerUserId != null) {
      map['peer_user_id'] = Variable<int>(peerUserId);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<int>(groupId);
    }
    map['member_count'] = Variable<int>(memberCount);
    if (!nullToAbsent || lastMessageLocalId != null) {
      map['last_message_local_id'] = Variable<int>(lastMessageLocalId);
    }
    if (!nullToAbsent || lastPreviewText != null) {
      map['last_preview_text'] = Variable<String>(lastPreviewText);
    }
    if (!nullToAbsent || lastPreviewType != null) {
      map['last_preview_type'] = Variable<int>(lastPreviewType);
    }
    if (!nullToAbsent || lastPreviewSenderId != null) {
      map['last_preview_sender_id'] = Variable<int>(lastPreviewSenderId);
    }
    if (!nullToAbsent || lastPreviewServerMessageId != null) {
      map['last_preview_server_message_id'] =
          Variable<int>(lastPreviewServerMessageId);
    }
    if (!nullToAbsent || lastPreviewStatus != null) {
      map['last_preview_status'] = Variable<String>(lastPreviewStatus);
    }
    if (!nullToAbsent || lastPreviewState != null) {
      map['last_preview_state'] = Variable<int>(lastPreviewState);
    }
    if (!nullToAbsent || lastPreviewDeleteState != null) {
      map['last_preview_delete_state'] = Variable<int>(lastPreviewDeleteState);
    }
    map['last_server_seq'] = Variable<int>(lastServerSeq);
    map['my_last_read_seq'] = Variable<int>(myLastReadSeq);
    map['unread_count'] = Variable<int>(unreadCount);
    if (!nullToAbsent || mutedUntil != null) {
      map['muted_until'] = Variable<int>(mutedUntil);
    }
    if (!nullToAbsent || draftText != null) {
      map['draft_text'] = Variable<String>(draftText);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || myRole != null) {
      map['my_role'] = Variable<String>(myRole);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      localId: Value(localId),
      serverRoomId: serverRoomId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRoomId),
      type: Value(type),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      peerUserId: peerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(peerUserId),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      memberCount: Value(memberCount),
      lastMessageLocalId: lastMessageLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageLocalId),
      lastPreviewText: lastPreviewText == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPreviewText),
      lastPreviewType: lastPreviewType == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPreviewType),
      lastPreviewSenderId: lastPreviewSenderId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPreviewSenderId),
      lastPreviewServerMessageId:
          lastPreviewServerMessageId == null && nullToAbsent
              ? const Value.absent()
              : Value(lastPreviewServerMessageId),
      lastPreviewStatus: lastPreviewStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPreviewStatus),
      lastPreviewState: lastPreviewState == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPreviewState),
      lastPreviewDeleteState: lastPreviewDeleteState == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPreviewDeleteState),
      lastServerSeq: Value(lastServerSeq),
      myLastReadSeq: Value(myLastReadSeq),
      unreadCount: Value(unreadCount),
      mutedUntil: mutedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(mutedUntil),
      draftText: draftText == null && nullToAbsent
          ? const Value.absent()
          : Value(draftText),
      isArchived: Value(isArchived),
      myRole:
          myRole == null && nullToAbsent ? const Value.absent() : Value(myRole),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Room.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      localId: serializer.fromJson<int>(json['localId']),
      serverRoomId: serializer.fromJson<int?>(json['serverRoomId']),
      type: $RoomsTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      title: serializer.fromJson<String?>(json['title']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      peerUserId: serializer.fromJson<int?>(json['peerUserId']),
      groupId: serializer.fromJson<int?>(json['groupId']),
      memberCount: serializer.fromJson<int>(json['memberCount']),
      lastMessageLocalId: serializer.fromJson<int?>(json['lastMessageLocalId']),
      lastPreviewText: serializer.fromJson<String?>(json['lastPreviewText']),
      lastPreviewType: serializer.fromJson<int?>(json['lastPreviewType']),
      lastPreviewSenderId:
          serializer.fromJson<int?>(json['lastPreviewSenderId']),
      lastPreviewServerMessageId:
          serializer.fromJson<int?>(json['lastPreviewServerMessageId']),
      lastPreviewStatus:
          serializer.fromJson<String?>(json['lastPreviewStatus']),
      lastPreviewState: serializer.fromJson<int?>(json['lastPreviewState']),
      lastPreviewDeleteState:
          serializer.fromJson<int?>(json['lastPreviewDeleteState']),
      lastServerSeq: serializer.fromJson<int>(json['lastServerSeq']),
      myLastReadSeq: serializer.fromJson<int>(json['myLastReadSeq']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      mutedUntil: serializer.fromJson<int?>(json['mutedUntil']),
      draftText: serializer.fromJson<String?>(json['draftText']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      myRole: serializer.fromJson<String?>(json['myRole']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverRoomId': serializer.toJson<int?>(serverRoomId),
      'type': serializer.toJson<int>($RoomsTable.$convertertype.toJson(type)),
      'title': serializer.toJson<String?>(title),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'peerUserId': serializer.toJson<int?>(peerUserId),
      'groupId': serializer.toJson<int?>(groupId),
      'memberCount': serializer.toJson<int>(memberCount),
      'lastMessageLocalId': serializer.toJson<int?>(lastMessageLocalId),
      'lastPreviewText': serializer.toJson<String?>(lastPreviewText),
      'lastPreviewType': serializer.toJson<int?>(lastPreviewType),
      'lastPreviewSenderId': serializer.toJson<int?>(lastPreviewSenderId),
      'lastPreviewServerMessageId':
          serializer.toJson<int?>(lastPreviewServerMessageId),
      'lastPreviewStatus': serializer.toJson<String?>(lastPreviewStatus),
      'lastPreviewState': serializer.toJson<int?>(lastPreviewState),
      'lastPreviewDeleteState': serializer.toJson<int?>(lastPreviewDeleteState),
      'lastServerSeq': serializer.toJson<int>(lastServerSeq),
      'myLastReadSeq': serializer.toJson<int>(myLastReadSeq),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'mutedUntil': serializer.toJson<int?>(mutedUntil),
      'draftText': serializer.toJson<String?>(draftText),
      'isArchived': serializer.toJson<bool>(isArchived),
      'myRole': serializer.toJson<String?>(myRole),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  Room copyWith(
          {int? localId,
          Value<int?> serverRoomId = const Value.absent(),
          RoomType? type,
          Value<String?> title = const Value.absent(),
          Value<String?> avatarUrl = const Value.absent(),
          Value<int?> peerUserId = const Value.absent(),
          Value<int?> groupId = const Value.absent(),
          int? memberCount,
          Value<int?> lastMessageLocalId = const Value.absent(),
          Value<String?> lastPreviewText = const Value.absent(),
          Value<int?> lastPreviewType = const Value.absent(),
          Value<int?> lastPreviewSenderId = const Value.absent(),
          Value<int?> lastPreviewServerMessageId = const Value.absent(),
          Value<String?> lastPreviewStatus = const Value.absent(),
          Value<int?> lastPreviewState = const Value.absent(),
          Value<int?> lastPreviewDeleteState = const Value.absent(),
          int? lastServerSeq,
          int? myLastReadSeq,
          int? unreadCount,
          Value<int?> mutedUntil = const Value.absent(),
          Value<String?> draftText = const Value.absent(),
          bool? isArchived,
          Value<String?> myRole = const Value.absent(),
          Value<int?> updatedAt = const Value.absent()}) =>
      Room(
        localId: localId ?? this.localId,
        serverRoomId:
            serverRoomId.present ? serverRoomId.value : this.serverRoomId,
        type: type ?? this.type,
        title: title.present ? title.value : this.title,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        peerUserId: peerUserId.present ? peerUserId.value : this.peerUserId,
        groupId: groupId.present ? groupId.value : this.groupId,
        memberCount: memberCount ?? this.memberCount,
        lastMessageLocalId: lastMessageLocalId.present
            ? lastMessageLocalId.value
            : this.lastMessageLocalId,
        lastPreviewText: lastPreviewText.present
            ? lastPreviewText.value
            : this.lastPreviewText,
        lastPreviewType: lastPreviewType.present
            ? lastPreviewType.value
            : this.lastPreviewType,
        lastPreviewSenderId: lastPreviewSenderId.present
            ? lastPreviewSenderId.value
            : this.lastPreviewSenderId,
        lastPreviewServerMessageId: lastPreviewServerMessageId.present
            ? lastPreviewServerMessageId.value
            : this.lastPreviewServerMessageId,
        lastPreviewStatus: lastPreviewStatus.present
            ? lastPreviewStatus.value
            : this.lastPreviewStatus,
        lastPreviewState: lastPreviewState.present
            ? lastPreviewState.value
            : this.lastPreviewState,
        lastPreviewDeleteState: lastPreviewDeleteState.present
            ? lastPreviewDeleteState.value
            : this.lastPreviewDeleteState,
        lastServerSeq: lastServerSeq ?? this.lastServerSeq,
        myLastReadSeq: myLastReadSeq ?? this.myLastReadSeq,
        unreadCount: unreadCount ?? this.unreadCount,
        mutedUntil: mutedUntil.present ? mutedUntil.value : this.mutedUntil,
        draftText: draftText.present ? draftText.value : this.draftText,
        isArchived: isArchived ?? this.isArchived,
        myRole: myRole.present ? myRole.value : this.myRole,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Room copyWithCompanion(RoomsCompanion data) {
    return Room(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverRoomId: data.serverRoomId.present
          ? data.serverRoomId.value
          : this.serverRoomId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      peerUserId:
          data.peerUserId.present ? data.peerUserId.value : this.peerUserId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      memberCount:
          data.memberCount.present ? data.memberCount.value : this.memberCount,
      lastMessageLocalId: data.lastMessageLocalId.present
          ? data.lastMessageLocalId.value
          : this.lastMessageLocalId,
      lastPreviewText: data.lastPreviewText.present
          ? data.lastPreviewText.value
          : this.lastPreviewText,
      lastPreviewType: data.lastPreviewType.present
          ? data.lastPreviewType.value
          : this.lastPreviewType,
      lastPreviewSenderId: data.lastPreviewSenderId.present
          ? data.lastPreviewSenderId.value
          : this.lastPreviewSenderId,
      lastPreviewServerMessageId: data.lastPreviewServerMessageId.present
          ? data.lastPreviewServerMessageId.value
          : this.lastPreviewServerMessageId,
      lastPreviewStatus: data.lastPreviewStatus.present
          ? data.lastPreviewStatus.value
          : this.lastPreviewStatus,
      lastPreviewState: data.lastPreviewState.present
          ? data.lastPreviewState.value
          : this.lastPreviewState,
      lastPreviewDeleteState: data.lastPreviewDeleteState.present
          ? data.lastPreviewDeleteState.value
          : this.lastPreviewDeleteState,
      lastServerSeq: data.lastServerSeq.present
          ? data.lastServerSeq.value
          : this.lastServerSeq,
      myLastReadSeq: data.myLastReadSeq.present
          ? data.myLastReadSeq.value
          : this.myLastReadSeq,
      unreadCount:
          data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
      mutedUntil:
          data.mutedUntil.present ? data.mutedUntil.value : this.mutedUntil,
      draftText: data.draftText.present ? data.draftText.value : this.draftText,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      myRole: data.myRole.present ? data.myRole.value : this.myRole,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('localId: $localId, ')
          ..write('serverRoomId: $serverRoomId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('peerUserId: $peerUserId, ')
          ..write('groupId: $groupId, ')
          ..write('memberCount: $memberCount, ')
          ..write('lastMessageLocalId: $lastMessageLocalId, ')
          ..write('lastPreviewText: $lastPreviewText, ')
          ..write('lastPreviewType: $lastPreviewType, ')
          ..write('lastPreviewSenderId: $lastPreviewSenderId, ')
          ..write('lastPreviewServerMessageId: $lastPreviewServerMessageId, ')
          ..write('lastPreviewStatus: $lastPreviewStatus, ')
          ..write('lastPreviewState: $lastPreviewState, ')
          ..write('lastPreviewDeleteState: $lastPreviewDeleteState, ')
          ..write('lastServerSeq: $lastServerSeq, ')
          ..write('myLastReadSeq: $myLastReadSeq, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('mutedUntil: $mutedUntil, ')
          ..write('draftText: $draftText, ')
          ..write('isArchived: $isArchived, ')
          ..write('myRole: $myRole, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        localId,
        serverRoomId,
        type,
        title,
        avatarUrl,
        peerUserId,
        groupId,
        memberCount,
        lastMessageLocalId,
        lastPreviewText,
        lastPreviewType,
        lastPreviewSenderId,
        lastPreviewServerMessageId,
        lastPreviewStatus,
        lastPreviewState,
        lastPreviewDeleteState,
        lastServerSeq,
        myLastReadSeq,
        unreadCount,
        mutedUntil,
        draftText,
        isArchived,
        myRole,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.localId == this.localId &&
          other.serverRoomId == this.serverRoomId &&
          other.type == this.type &&
          other.title == this.title &&
          other.avatarUrl == this.avatarUrl &&
          other.peerUserId == this.peerUserId &&
          other.groupId == this.groupId &&
          other.memberCount == this.memberCount &&
          other.lastMessageLocalId == this.lastMessageLocalId &&
          other.lastPreviewText == this.lastPreviewText &&
          other.lastPreviewType == this.lastPreviewType &&
          other.lastPreviewSenderId == this.lastPreviewSenderId &&
          other.lastPreviewServerMessageId == this.lastPreviewServerMessageId &&
          other.lastPreviewStatus == this.lastPreviewStatus &&
          other.lastPreviewState == this.lastPreviewState &&
          other.lastPreviewDeleteState == this.lastPreviewDeleteState &&
          other.lastServerSeq == this.lastServerSeq &&
          other.myLastReadSeq == this.myLastReadSeq &&
          other.unreadCount == this.unreadCount &&
          other.mutedUntil == this.mutedUntil &&
          other.draftText == this.draftText &&
          other.isArchived == this.isArchived &&
          other.myRole == this.myRole &&
          other.updatedAt == this.updatedAt);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<int> localId;
  final Value<int?> serverRoomId;
  final Value<RoomType> type;
  final Value<String?> title;
  final Value<String?> avatarUrl;
  final Value<int?> peerUserId;
  final Value<int?> groupId;
  final Value<int> memberCount;
  final Value<int?> lastMessageLocalId;
  final Value<String?> lastPreviewText;
  final Value<int?> lastPreviewType;
  final Value<int?> lastPreviewSenderId;
  final Value<int?> lastPreviewServerMessageId;
  final Value<String?> lastPreviewStatus;
  final Value<int?> lastPreviewState;
  final Value<int?> lastPreviewDeleteState;
  final Value<int> lastServerSeq;
  final Value<int> myLastReadSeq;
  final Value<int> unreadCount;
  final Value<int?> mutedUntil;
  final Value<String?> draftText;
  final Value<bool> isArchived;
  final Value<String?> myRole;
  final Value<int?> updatedAt;
  const RoomsCompanion({
    this.localId = const Value.absent(),
    this.serverRoomId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.peerUserId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.lastMessageLocalId = const Value.absent(),
    this.lastPreviewText = const Value.absent(),
    this.lastPreviewType = const Value.absent(),
    this.lastPreviewSenderId = const Value.absent(),
    this.lastPreviewServerMessageId = const Value.absent(),
    this.lastPreviewStatus = const Value.absent(),
    this.lastPreviewState = const Value.absent(),
    this.lastPreviewDeleteState = const Value.absent(),
    this.lastServerSeq = const Value.absent(),
    this.myLastReadSeq = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.mutedUntil = const Value.absent(),
    this.draftText = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.myRole = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RoomsCompanion.insert({
    this.localId = const Value.absent(),
    this.serverRoomId = const Value.absent(),
    required RoomType type,
    this.title = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.peerUserId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.lastMessageLocalId = const Value.absent(),
    this.lastPreviewText = const Value.absent(),
    this.lastPreviewType = const Value.absent(),
    this.lastPreviewSenderId = const Value.absent(),
    this.lastPreviewServerMessageId = const Value.absent(),
    this.lastPreviewStatus = const Value.absent(),
    this.lastPreviewState = const Value.absent(),
    this.lastPreviewDeleteState = const Value.absent(),
    this.lastServerSeq = const Value.absent(),
    this.myLastReadSeq = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.mutedUntil = const Value.absent(),
    this.draftText = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.myRole = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : type = Value(type);
  static Insertable<Room> custom({
    Expression<int>? localId,
    Expression<int>? serverRoomId,
    Expression<int>? type,
    Expression<String>? title,
    Expression<String>? avatarUrl,
    Expression<int>? peerUserId,
    Expression<int>? groupId,
    Expression<int>? memberCount,
    Expression<int>? lastMessageLocalId,
    Expression<String>? lastPreviewText,
    Expression<int>? lastPreviewType,
    Expression<int>? lastPreviewSenderId,
    Expression<int>? lastPreviewServerMessageId,
    Expression<String>? lastPreviewStatus,
    Expression<int>? lastPreviewState,
    Expression<int>? lastPreviewDeleteState,
    Expression<int>? lastServerSeq,
    Expression<int>? myLastReadSeq,
    Expression<int>? unreadCount,
    Expression<int>? mutedUntil,
    Expression<String>? draftText,
    Expression<bool>? isArchived,
    Expression<String>? myRole,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverRoomId != null) 'server_room_id': serverRoomId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (peerUserId != null) 'peer_user_id': peerUserId,
      if (groupId != null) 'group_id': groupId,
      if (memberCount != null) 'member_count': memberCount,
      if (lastMessageLocalId != null)
        'last_message_local_id': lastMessageLocalId,
      if (lastPreviewText != null) 'last_preview_text': lastPreviewText,
      if (lastPreviewType != null) 'last_preview_type': lastPreviewType,
      if (lastPreviewSenderId != null)
        'last_preview_sender_id': lastPreviewSenderId,
      if (lastPreviewServerMessageId != null)
        'last_preview_server_message_id': lastPreviewServerMessageId,
      if (lastPreviewStatus != null) 'last_preview_status': lastPreviewStatus,
      if (lastPreviewState != null) 'last_preview_state': lastPreviewState,
      if (lastPreviewDeleteState != null)
        'last_preview_delete_state': lastPreviewDeleteState,
      if (lastServerSeq != null) 'last_server_seq': lastServerSeq,
      if (myLastReadSeq != null) 'my_last_read_seq': myLastReadSeq,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (mutedUntil != null) 'muted_until': mutedUntil,
      if (draftText != null) 'draft_text': draftText,
      if (isArchived != null) 'is_archived': isArchived,
      if (myRole != null) 'my_role': myRole,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RoomsCompanion copyWith(
      {Value<int>? localId,
      Value<int?>? serverRoomId,
      Value<RoomType>? type,
      Value<String?>? title,
      Value<String?>? avatarUrl,
      Value<int?>? peerUserId,
      Value<int?>? groupId,
      Value<int>? memberCount,
      Value<int?>? lastMessageLocalId,
      Value<String?>? lastPreviewText,
      Value<int?>? lastPreviewType,
      Value<int?>? lastPreviewSenderId,
      Value<int?>? lastPreviewServerMessageId,
      Value<String?>? lastPreviewStatus,
      Value<int?>? lastPreviewState,
      Value<int?>? lastPreviewDeleteState,
      Value<int>? lastServerSeq,
      Value<int>? myLastReadSeq,
      Value<int>? unreadCount,
      Value<int?>? mutedUntil,
      Value<String?>? draftText,
      Value<bool>? isArchived,
      Value<String?>? myRole,
      Value<int?>? updatedAt}) {
    return RoomsCompanion(
      localId: localId ?? this.localId,
      serverRoomId: serverRoomId ?? this.serverRoomId,
      type: type ?? this.type,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      peerUserId: peerUserId ?? this.peerUserId,
      groupId: groupId ?? this.groupId,
      memberCount: memberCount ?? this.memberCount,
      lastMessageLocalId: lastMessageLocalId ?? this.lastMessageLocalId,
      lastPreviewText: lastPreviewText ?? this.lastPreviewText,
      lastPreviewType: lastPreviewType ?? this.lastPreviewType,
      lastPreviewSenderId: lastPreviewSenderId ?? this.lastPreviewSenderId,
      lastPreviewServerMessageId:
          lastPreviewServerMessageId ?? this.lastPreviewServerMessageId,
      lastPreviewStatus: lastPreviewStatus ?? this.lastPreviewStatus,
      lastPreviewState: lastPreviewState ?? this.lastPreviewState,
      lastPreviewDeleteState:
          lastPreviewDeleteState ?? this.lastPreviewDeleteState,
      lastServerSeq: lastServerSeq ?? this.lastServerSeq,
      myLastReadSeq: myLastReadSeq ?? this.myLastReadSeq,
      unreadCount: unreadCount ?? this.unreadCount,
      mutedUntil: mutedUntil ?? this.mutedUntil,
      draftText: draftText ?? this.draftText,
      isArchived: isArchived ?? this.isArchived,
      myRole: myRole ?? this.myRole,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverRoomId.present) {
      map['server_room_id'] = Variable<int>(serverRoomId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>($RoomsTable.$convertertype.toSql(type.value));
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (peerUserId.present) {
      map['peer_user_id'] = Variable<int>(peerUserId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (memberCount.present) {
      map['member_count'] = Variable<int>(memberCount.value);
    }
    if (lastMessageLocalId.present) {
      map['last_message_local_id'] = Variable<int>(lastMessageLocalId.value);
    }
    if (lastPreviewText.present) {
      map['last_preview_text'] = Variable<String>(lastPreviewText.value);
    }
    if (lastPreviewType.present) {
      map['last_preview_type'] = Variable<int>(lastPreviewType.value);
    }
    if (lastPreviewSenderId.present) {
      map['last_preview_sender_id'] = Variable<int>(lastPreviewSenderId.value);
    }
    if (lastPreviewServerMessageId.present) {
      map['last_preview_server_message_id'] =
          Variable<int>(lastPreviewServerMessageId.value);
    }
    if (lastPreviewStatus.present) {
      map['last_preview_status'] = Variable<String>(lastPreviewStatus.value);
    }
    if (lastPreviewState.present) {
      map['last_preview_state'] = Variable<int>(lastPreviewState.value);
    }
    if (lastPreviewDeleteState.present) {
      map['last_preview_delete_state'] =
          Variable<int>(lastPreviewDeleteState.value);
    }
    if (lastServerSeq.present) {
      map['last_server_seq'] = Variable<int>(lastServerSeq.value);
    }
    if (myLastReadSeq.present) {
      map['my_last_read_seq'] = Variable<int>(myLastReadSeq.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (mutedUntil.present) {
      map['muted_until'] = Variable<int>(mutedUntil.value);
    }
    if (draftText.present) {
      map['draft_text'] = Variable<String>(draftText.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (myRole.present) {
      map['my_role'] = Variable<String>(myRole.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('localId: $localId, ')
          ..write('serverRoomId: $serverRoomId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('peerUserId: $peerUserId, ')
          ..write('groupId: $groupId, ')
          ..write('memberCount: $memberCount, ')
          ..write('lastMessageLocalId: $lastMessageLocalId, ')
          ..write('lastPreviewText: $lastPreviewText, ')
          ..write('lastPreviewType: $lastPreviewType, ')
          ..write('lastPreviewSenderId: $lastPreviewSenderId, ')
          ..write('lastPreviewServerMessageId: $lastPreviewServerMessageId, ')
          ..write('lastPreviewStatus: $lastPreviewStatus, ')
          ..write('lastPreviewState: $lastPreviewState, ')
          ..write('lastPreviewDeleteState: $lastPreviewDeleteState, ')
          ..write('lastServerSeq: $lastServerSeq, ')
          ..write('myLastReadSeq: $myLastReadSeq, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('mutedUntil: $mutedUntil, ')
          ..write('draftText: $draftText, ')
          ..write('isArchived: $isArchived, ')
          ..write('myRole: $myRole, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
      'local_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _clientUuidMeta =
      const VerificationMeta('clientUuid');
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
      'client_uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _serverMessageIdMeta =
      const VerificationMeta('serverMessageId');
  @override
  late final GeneratedColumn<int> serverMessageId = GeneratedColumn<int>(
      'server_message_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
      'room_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES rooms (local_id) ON DELETE CASCADE'));
  static const VerificationMeta _serverSeqMeta =
      const VerificationMeta('serverSeq');
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
      'server_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<int> senderId = GeneratedColumn<int>(
      'sender_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumnWithTypeConverter<MessageKind, int> kind =
      GeneratedColumn<int>('kind', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<MessageKind>($MessagesTable.$converterkind);
  static const VerificationMeta _systemEventMeta =
      const VerificationMeta('systemEvent');
  @override
  late final GeneratedColumn<String> systemEvent = GeneratedColumn<String>(
      'system_event', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<MessageContentType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<MessageContentType>($MessagesTable.$convertertype);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _replyToClientUuidMeta =
      const VerificationMeta('replyToClientUuid');
  @override
  late final GeneratedColumn<String> replyToClientUuid =
      GeneratedColumn<String>('reply_to_client_uuid', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtClientMeta =
      const VerificationMeta('createdAtClient');
  @override
  late final GeneratedColumn<int> createdAtClient = GeneratedColumn<int>(
      'created_at_client', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _serverCreatedAtMeta =
      const VerificationMeta('serverCreatedAt');
  @override
  late final GeneratedColumn<int> serverCreatedAt = GeneratedColumn<int>(
      'server_created_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumnWithTypeConverter<MessageState, int> state =
      GeneratedColumn<int>('state', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<MessageState>($MessagesTable.$converterstate);
  static const VerificationMeta _deleteStateMeta =
      const VerificationMeta('deleteState');
  @override
  late final GeneratedColumnWithTypeConverter<MessageDeleteState, int>
      deleteState = GeneratedColumn<int>('delete_state', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: Constant(MessageDeleteState.none.index))
          .withConverter<MessageDeleteState>(
              $MessagesTable.$converterdeleteState);
  static const VerificationMeta _serverStatusMeta =
      const VerificationMeta('serverStatus');
  @override
  late final GeneratedColumn<String> serverStatus = GeneratedColumn<String>(
      'server_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reactsJsonMeta =
      const VerificationMeta('reactsJson');
  @override
  late final GeneratedColumn<String> reactsJson = GeneratedColumn<String>(
      'reacts_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _attachmentJsonMeta =
      const VerificationMeta('attachmentJson');
  @override
  late final GeneratedColumn<String> attachmentJson = GeneratedColumn<String>(
      'attachment_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _replyPreviewJsonMeta =
      const VerificationMeta('replyPreviewJson');
  @override
  late final GeneratedColumn<String> replyPreviewJson = GeneratedColumn<String>(
      'reply_preview_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        clientUuid,
        serverMessageId,
        roomId,
        serverSeq,
        senderId,
        kind,
        systemEvent,
        type,
        body,
        replyToClientUuid,
        createdAtClient,
        serverCreatedAt,
        state,
        deleteState,
        serverStatus,
        reactsJson,
        attachmentJson,
        replyPreviewJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    }
    if (data.containsKey('client_uuid')) {
      context.handle(
          _clientUuidMeta,
          clientUuid.isAcceptableOrUnknown(
              data['client_uuid']!, _clientUuidMeta));
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('server_message_id')) {
      context.handle(
          _serverMessageIdMeta,
          serverMessageId.isAcceptableOrUnknown(
              data['server_message_id']!, _serverMessageIdMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(_serverSeqMeta,
          serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta));
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    }
    context.handle(_kindMeta, const VerificationResult.success());
    if (data.containsKey('system_event')) {
      context.handle(
          _systemEventMeta,
          systemEvent.isAcceptableOrUnknown(
              data['system_event']!, _systemEventMeta));
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('reply_to_client_uuid')) {
      context.handle(
          _replyToClientUuidMeta,
          replyToClientUuid.isAcceptableOrUnknown(
              data['reply_to_client_uuid']!, _replyToClientUuidMeta));
    }
    if (data.containsKey('created_at_client')) {
      context.handle(
          _createdAtClientMeta,
          createdAtClient.isAcceptableOrUnknown(
              data['created_at_client']!, _createdAtClientMeta));
    } else if (isInserting) {
      context.missing(_createdAtClientMeta);
    }
    if (data.containsKey('server_created_at')) {
      context.handle(
          _serverCreatedAtMeta,
          serverCreatedAt.isAcceptableOrUnknown(
              data['server_created_at']!, _serverCreatedAtMeta));
    }
    context.handle(_stateMeta, const VerificationResult.success());
    context.handle(_deleteStateMeta, const VerificationResult.success());
    if (data.containsKey('server_status')) {
      context.handle(
          _serverStatusMeta,
          serverStatus.isAcceptableOrUnknown(
              data['server_status']!, _serverStatusMeta));
    }
    if (data.containsKey('reacts_json')) {
      context.handle(
          _reactsJsonMeta,
          reactsJson.isAcceptableOrUnknown(
              data['reacts_json']!, _reactsJsonMeta));
    }
    if (data.containsKey('attachment_json')) {
      context.handle(
          _attachmentJsonMeta,
          attachmentJson.isAcceptableOrUnknown(
              data['attachment_json']!, _attachmentJsonMeta));
    }
    if (data.containsKey('reply_preview_json')) {
      context.handle(
          _replyPreviewJsonMeta,
          replyPreviewJson.isAcceptableOrUnknown(
              data['reply_preview_json']!, _replyPreviewJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {clientUuid},
      ];
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_id'])!,
      clientUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_uuid'])!,
      serverMessageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_message_id']),
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}room_id'])!,
      serverSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_seq']),
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sender_id']),
      kind: $MessagesTable.$converterkind.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kind'])!),
      systemEvent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}system_event']),
      type: $MessagesTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body']),
      replyToClientUuid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reply_to_client_uuid']),
      createdAtClient: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at_client'])!,
      serverCreatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_created_at']),
      state: $MessagesTable.$converterstate.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}state'])!),
      deleteState: $MessagesTable.$converterdeleteState.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}delete_state'])!),
      serverStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_status']),
      reactsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reacts_json']),
      attachmentJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attachment_json']),
      replyPreviewJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reply_preview_json']),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MessageKind, int, int> $converterkind =
      const EnumIndexConverter<MessageKind>(MessageKind.values);
  static JsonTypeConverter2<MessageContentType, int, int> $convertertype =
      const EnumIndexConverter<MessageContentType>(MessageContentType.values);
  static JsonTypeConverter2<MessageState, int, int> $converterstate =
      const EnumIndexConverter<MessageState>(MessageState.values);
  static JsonTypeConverter2<MessageDeleteState, int, int>
      $converterdeleteState =
      const EnumIndexConverter<MessageDeleteState>(MessageDeleteState.values);
}

class Message extends DataClass implements Insertable<Message> {
  final int localId;

  /// Client-generated UUID. The dedup + idempotency key across the whole stack.
  final String clientUuid;

  /// Server message id. Null while pending. UNIQUE once assigned.
  final int? serverMessageId;

  /// FK -> rooms.local_id.
  final int roomId;

  /// Atomic per-room sequence from the server. Null while pending; drives order.
  final int? serverSeq;
  final int? senderId;
  final MessageKind kind;

  /// For [MessageKind.system] rows: the system event name (member_joined, ...).
  final String? systemEvent;
  final MessageContentType type;
  final String? body;

  /// Reply target referenced by client_uuid (stable across pending->sent).
  final String? replyToClientUuid;

  /// Client clock at creation time (ms epoch) — fallback ordering for pending.
  final int createdAtClient;

  /// Server-assigned creation timestamp (ms epoch). Null while pending.
  final int? serverCreatedAt;
  final MessageState state;
  final MessageDeleteState deleteState;

  /// Raw server-side delivery status string for 1:1 receipts (e.g. 'seen',
  /// 'sent'). Mirrors the legacy `MessagesEntity.status`; null for groups.
  final String? serverStatus;

  /// Reactions cached as a JSON array (id, react, userReact{...}). Kept on the
  /// row so the UI renders without a join; toggled optimistically then synced.
  final String? reactsJson;

  /// Attachment payload as JSON (file url, type, first_frame/thumb, duration).
  /// Covers image/audio/video bodies for both sent and received messages.
  final String? attachmentJson;

  /// Cached preview of the replied-to message (id, user_id, text, type, album)
  /// so the reply bubble renders without resolving [replyToClientUuid].
  final String? replyPreviewJson;
  const Message(
      {required this.localId,
      required this.clientUuid,
      this.serverMessageId,
      required this.roomId,
      this.serverSeq,
      this.senderId,
      required this.kind,
      this.systemEvent,
      required this.type,
      this.body,
      this.replyToClientUuid,
      required this.createdAtClient,
      this.serverCreatedAt,
      required this.state,
      required this.deleteState,
      this.serverStatus,
      this.reactsJson,
      this.attachmentJson,
      this.replyPreviewJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['client_uuid'] = Variable<String>(clientUuid);
    if (!nullToAbsent || serverMessageId != null) {
      map['server_message_id'] = Variable<int>(serverMessageId);
    }
    map['room_id'] = Variable<int>(roomId);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || senderId != null) {
      map['sender_id'] = Variable<int>(senderId);
    }
    {
      map['kind'] = Variable<int>($MessagesTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || systemEvent != null) {
      map['system_event'] = Variable<String>(systemEvent);
    }
    {
      map['type'] = Variable<int>($MessagesTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || replyToClientUuid != null) {
      map['reply_to_client_uuid'] = Variable<String>(replyToClientUuid);
    }
    map['created_at_client'] = Variable<int>(createdAtClient);
    if (!nullToAbsent || serverCreatedAt != null) {
      map['server_created_at'] = Variable<int>(serverCreatedAt);
    }
    {
      map['state'] = Variable<int>($MessagesTable.$converterstate.toSql(state));
    }
    {
      map['delete_state'] = Variable<int>(
          $MessagesTable.$converterdeleteState.toSql(deleteState));
    }
    if (!nullToAbsent || serverStatus != null) {
      map['server_status'] = Variable<String>(serverStatus);
    }
    if (!nullToAbsent || reactsJson != null) {
      map['reacts_json'] = Variable<String>(reactsJson);
    }
    if (!nullToAbsent || attachmentJson != null) {
      map['attachment_json'] = Variable<String>(attachmentJson);
    }
    if (!nullToAbsent || replyPreviewJson != null) {
      map['reply_preview_json'] = Variable<String>(replyPreviewJson);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      localId: Value(localId),
      clientUuid: Value(clientUuid),
      serverMessageId: serverMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverMessageId),
      roomId: Value(roomId),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      senderId: senderId == null && nullToAbsent
          ? const Value.absent()
          : Value(senderId),
      kind: Value(kind),
      systemEvent: systemEvent == null && nullToAbsent
          ? const Value.absent()
          : Value(systemEvent),
      type: Value(type),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      replyToClientUuid: replyToClientUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToClientUuid),
      createdAtClient: Value(createdAtClient),
      serverCreatedAt: serverCreatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverCreatedAt),
      state: Value(state),
      deleteState: Value(deleteState),
      serverStatus: serverStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(serverStatus),
      reactsJson: reactsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(reactsJson),
      attachmentJson: attachmentJson == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentJson),
      replyPreviewJson: replyPreviewJson == null && nullToAbsent
          ? const Value.absent()
          : Value(replyPreviewJson),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      localId: serializer.fromJson<int>(json['localId']),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      serverMessageId: serializer.fromJson<int?>(json['serverMessageId']),
      roomId: serializer.fromJson<int>(json['roomId']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      senderId: serializer.fromJson<int?>(json['senderId']),
      kind: $MessagesTable.$converterkind
          .fromJson(serializer.fromJson<int>(json['kind'])),
      systemEvent: serializer.fromJson<String?>(json['systemEvent']),
      type: $MessagesTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      body: serializer.fromJson<String?>(json['body']),
      replyToClientUuid:
          serializer.fromJson<String?>(json['replyToClientUuid']),
      createdAtClient: serializer.fromJson<int>(json['createdAtClient']),
      serverCreatedAt: serializer.fromJson<int?>(json['serverCreatedAt']),
      state: $MessagesTable.$converterstate
          .fromJson(serializer.fromJson<int>(json['state'])),
      deleteState: $MessagesTable.$converterdeleteState
          .fromJson(serializer.fromJson<int>(json['deleteState'])),
      serverStatus: serializer.fromJson<String?>(json['serverStatus']),
      reactsJson: serializer.fromJson<String?>(json['reactsJson']),
      attachmentJson: serializer.fromJson<String?>(json['attachmentJson']),
      replyPreviewJson: serializer.fromJson<String?>(json['replyPreviewJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'serverMessageId': serializer.toJson<int?>(serverMessageId),
      'roomId': serializer.toJson<int>(roomId),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'senderId': serializer.toJson<int?>(senderId),
      'kind':
          serializer.toJson<int>($MessagesTable.$converterkind.toJson(kind)),
      'systemEvent': serializer.toJson<String?>(systemEvent),
      'type':
          serializer.toJson<int>($MessagesTable.$convertertype.toJson(type)),
      'body': serializer.toJson<String?>(body),
      'replyToClientUuid': serializer.toJson<String?>(replyToClientUuid),
      'createdAtClient': serializer.toJson<int>(createdAtClient),
      'serverCreatedAt': serializer.toJson<int?>(serverCreatedAt),
      'state':
          serializer.toJson<int>($MessagesTable.$converterstate.toJson(state)),
      'deleteState': serializer.toJson<int>(
          $MessagesTable.$converterdeleteState.toJson(deleteState)),
      'serverStatus': serializer.toJson<String?>(serverStatus),
      'reactsJson': serializer.toJson<String?>(reactsJson),
      'attachmentJson': serializer.toJson<String?>(attachmentJson),
      'replyPreviewJson': serializer.toJson<String?>(replyPreviewJson),
    };
  }

  Message copyWith(
          {int? localId,
          String? clientUuid,
          Value<int?> serverMessageId = const Value.absent(),
          int? roomId,
          Value<int?> serverSeq = const Value.absent(),
          Value<int?> senderId = const Value.absent(),
          MessageKind? kind,
          Value<String?> systemEvent = const Value.absent(),
          MessageContentType? type,
          Value<String?> body = const Value.absent(),
          Value<String?> replyToClientUuid = const Value.absent(),
          int? createdAtClient,
          Value<int?> serverCreatedAt = const Value.absent(),
          MessageState? state,
          MessageDeleteState? deleteState,
          Value<String?> serverStatus = const Value.absent(),
          Value<String?> reactsJson = const Value.absent(),
          Value<String?> attachmentJson = const Value.absent(),
          Value<String?> replyPreviewJson = const Value.absent()}) =>
      Message(
        localId: localId ?? this.localId,
        clientUuid: clientUuid ?? this.clientUuid,
        serverMessageId: serverMessageId.present
            ? serverMessageId.value
            : this.serverMessageId,
        roomId: roomId ?? this.roomId,
        serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
        senderId: senderId.present ? senderId.value : this.senderId,
        kind: kind ?? this.kind,
        systemEvent: systemEvent.present ? systemEvent.value : this.systemEvent,
        type: type ?? this.type,
        body: body.present ? body.value : this.body,
        replyToClientUuid: replyToClientUuid.present
            ? replyToClientUuid.value
            : this.replyToClientUuid,
        createdAtClient: createdAtClient ?? this.createdAtClient,
        serverCreatedAt: serverCreatedAt.present
            ? serverCreatedAt.value
            : this.serverCreatedAt,
        state: state ?? this.state,
        deleteState: deleteState ?? this.deleteState,
        serverStatus:
            serverStatus.present ? serverStatus.value : this.serverStatus,
        reactsJson: reactsJson.present ? reactsJson.value : this.reactsJson,
        attachmentJson:
            attachmentJson.present ? attachmentJson.value : this.attachmentJson,
        replyPreviewJson: replyPreviewJson.present
            ? replyPreviewJson.value
            : this.replyPreviewJson,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      localId: data.localId.present ? data.localId.value : this.localId,
      clientUuid:
          data.clientUuid.present ? data.clientUuid.value : this.clientUuid,
      serverMessageId: data.serverMessageId.present
          ? data.serverMessageId.value
          : this.serverMessageId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      kind: data.kind.present ? data.kind.value : this.kind,
      systemEvent:
          data.systemEvent.present ? data.systemEvent.value : this.systemEvent,
      type: data.type.present ? data.type.value : this.type,
      body: data.body.present ? data.body.value : this.body,
      replyToClientUuid: data.replyToClientUuid.present
          ? data.replyToClientUuid.value
          : this.replyToClientUuid,
      createdAtClient: data.createdAtClient.present
          ? data.createdAtClient.value
          : this.createdAtClient,
      serverCreatedAt: data.serverCreatedAt.present
          ? data.serverCreatedAt.value
          : this.serverCreatedAt,
      state: data.state.present ? data.state.value : this.state,
      deleteState:
          data.deleteState.present ? data.deleteState.value : this.deleteState,
      serverStatus: data.serverStatus.present
          ? data.serverStatus.value
          : this.serverStatus,
      reactsJson:
          data.reactsJson.present ? data.reactsJson.value : this.reactsJson,
      attachmentJson: data.attachmentJson.present
          ? data.attachmentJson.value
          : this.attachmentJson,
      replyPreviewJson: data.replyPreviewJson.present
          ? data.replyPreviewJson.value
          : this.replyPreviewJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('localId: $localId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('serverMessageId: $serverMessageId, ')
          ..write('roomId: $roomId, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('senderId: $senderId, ')
          ..write('kind: $kind, ')
          ..write('systemEvent: $systemEvent, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('replyToClientUuid: $replyToClientUuid, ')
          ..write('createdAtClient: $createdAtClient, ')
          ..write('serverCreatedAt: $serverCreatedAt, ')
          ..write('state: $state, ')
          ..write('deleteState: $deleteState, ')
          ..write('serverStatus: $serverStatus, ')
          ..write('reactsJson: $reactsJson, ')
          ..write('attachmentJson: $attachmentJson, ')
          ..write('replyPreviewJson: $replyPreviewJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      localId,
      clientUuid,
      serverMessageId,
      roomId,
      serverSeq,
      senderId,
      kind,
      systemEvent,
      type,
      body,
      replyToClientUuid,
      createdAtClient,
      serverCreatedAt,
      state,
      deleteState,
      serverStatus,
      reactsJson,
      attachmentJson,
      replyPreviewJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.localId == this.localId &&
          other.clientUuid == this.clientUuid &&
          other.serverMessageId == this.serverMessageId &&
          other.roomId == this.roomId &&
          other.serverSeq == this.serverSeq &&
          other.senderId == this.senderId &&
          other.kind == this.kind &&
          other.systemEvent == this.systemEvent &&
          other.type == this.type &&
          other.body == this.body &&
          other.replyToClientUuid == this.replyToClientUuid &&
          other.createdAtClient == this.createdAtClient &&
          other.serverCreatedAt == this.serverCreatedAt &&
          other.state == this.state &&
          other.deleteState == this.deleteState &&
          other.serverStatus == this.serverStatus &&
          other.reactsJson == this.reactsJson &&
          other.attachmentJson == this.attachmentJson &&
          other.replyPreviewJson == this.replyPreviewJson);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> localId;
  final Value<String> clientUuid;
  final Value<int?> serverMessageId;
  final Value<int> roomId;
  final Value<int?> serverSeq;
  final Value<int?> senderId;
  final Value<MessageKind> kind;
  final Value<String?> systemEvent;
  final Value<MessageContentType> type;
  final Value<String?> body;
  final Value<String?> replyToClientUuid;
  final Value<int> createdAtClient;
  final Value<int?> serverCreatedAt;
  final Value<MessageState> state;
  final Value<MessageDeleteState> deleteState;
  final Value<String?> serverStatus;
  final Value<String?> reactsJson;
  final Value<String?> attachmentJson;
  final Value<String?> replyPreviewJson;
  const MessagesCompanion({
    this.localId = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.serverMessageId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.senderId = const Value.absent(),
    this.kind = const Value.absent(),
    this.systemEvent = const Value.absent(),
    this.type = const Value.absent(),
    this.body = const Value.absent(),
    this.replyToClientUuid = const Value.absent(),
    this.createdAtClient = const Value.absent(),
    this.serverCreatedAt = const Value.absent(),
    this.state = const Value.absent(),
    this.deleteState = const Value.absent(),
    this.serverStatus = const Value.absent(),
    this.reactsJson = const Value.absent(),
    this.attachmentJson = const Value.absent(),
    this.replyPreviewJson = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.localId = const Value.absent(),
    required String clientUuid,
    this.serverMessageId = const Value.absent(),
    required int roomId,
    this.serverSeq = const Value.absent(),
    this.senderId = const Value.absent(),
    required MessageKind kind,
    this.systemEvent = const Value.absent(),
    required MessageContentType type,
    this.body = const Value.absent(),
    this.replyToClientUuid = const Value.absent(),
    required int createdAtClient,
    this.serverCreatedAt = const Value.absent(),
    required MessageState state,
    this.deleteState = const Value.absent(),
    this.serverStatus = const Value.absent(),
    this.reactsJson = const Value.absent(),
    this.attachmentJson = const Value.absent(),
    this.replyPreviewJson = const Value.absent(),
  })  : clientUuid = Value(clientUuid),
        roomId = Value(roomId),
        kind = Value(kind),
        type = Value(type),
        createdAtClient = Value(createdAtClient),
        state = Value(state);
  static Insertable<Message> custom({
    Expression<int>? localId,
    Expression<String>? clientUuid,
    Expression<int>? serverMessageId,
    Expression<int>? roomId,
    Expression<int>? serverSeq,
    Expression<int>? senderId,
    Expression<int>? kind,
    Expression<String>? systemEvent,
    Expression<int>? type,
    Expression<String>? body,
    Expression<String>? replyToClientUuid,
    Expression<int>? createdAtClient,
    Expression<int>? serverCreatedAt,
    Expression<int>? state,
    Expression<int>? deleteState,
    Expression<String>? serverStatus,
    Expression<String>? reactsJson,
    Expression<String>? attachmentJson,
    Expression<String>? replyPreviewJson,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (serverMessageId != null) 'server_message_id': serverMessageId,
      if (roomId != null) 'room_id': roomId,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (senderId != null) 'sender_id': senderId,
      if (kind != null) 'kind': kind,
      if (systemEvent != null) 'system_event': systemEvent,
      if (type != null) 'type': type,
      if (body != null) 'body': body,
      if (replyToClientUuid != null) 'reply_to_client_uuid': replyToClientUuid,
      if (createdAtClient != null) 'created_at_client': createdAtClient,
      if (serverCreatedAt != null) 'server_created_at': serverCreatedAt,
      if (state != null) 'state': state,
      if (deleteState != null) 'delete_state': deleteState,
      if (serverStatus != null) 'server_status': serverStatus,
      if (reactsJson != null) 'reacts_json': reactsJson,
      if (attachmentJson != null) 'attachment_json': attachmentJson,
      if (replyPreviewJson != null) 'reply_preview_json': replyPreviewJson,
    });
  }

  MessagesCompanion copyWith(
      {Value<int>? localId,
      Value<String>? clientUuid,
      Value<int?>? serverMessageId,
      Value<int>? roomId,
      Value<int?>? serverSeq,
      Value<int?>? senderId,
      Value<MessageKind>? kind,
      Value<String?>? systemEvent,
      Value<MessageContentType>? type,
      Value<String?>? body,
      Value<String?>? replyToClientUuid,
      Value<int>? createdAtClient,
      Value<int?>? serverCreatedAt,
      Value<MessageState>? state,
      Value<MessageDeleteState>? deleteState,
      Value<String?>? serverStatus,
      Value<String?>? reactsJson,
      Value<String?>? attachmentJson,
      Value<String?>? replyPreviewJson}) {
    return MessagesCompanion(
      localId: localId ?? this.localId,
      clientUuid: clientUuid ?? this.clientUuid,
      serverMessageId: serverMessageId ?? this.serverMessageId,
      roomId: roomId ?? this.roomId,
      serverSeq: serverSeq ?? this.serverSeq,
      senderId: senderId ?? this.senderId,
      kind: kind ?? this.kind,
      systemEvent: systemEvent ?? this.systemEvent,
      type: type ?? this.type,
      body: body ?? this.body,
      replyToClientUuid: replyToClientUuid ?? this.replyToClientUuid,
      createdAtClient: createdAtClient ?? this.createdAtClient,
      serverCreatedAt: serverCreatedAt ?? this.serverCreatedAt,
      state: state ?? this.state,
      deleteState: deleteState ?? this.deleteState,
      serverStatus: serverStatus ?? this.serverStatus,
      reactsJson: reactsJson ?? this.reactsJson,
      attachmentJson: attachmentJson ?? this.attachmentJson,
      replyPreviewJson: replyPreviewJson ?? this.replyPreviewJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (serverMessageId.present) {
      map['server_message_id'] = Variable<int>(serverMessageId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<int>(senderId.value);
    }
    if (kind.present) {
      map['kind'] =
          Variable<int>($MessagesTable.$converterkind.toSql(kind.value));
    }
    if (systemEvent.present) {
      map['system_event'] = Variable<String>(systemEvent.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($MessagesTable.$convertertype.toSql(type.value));
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (replyToClientUuid.present) {
      map['reply_to_client_uuid'] = Variable<String>(replyToClientUuid.value);
    }
    if (createdAtClient.present) {
      map['created_at_client'] = Variable<int>(createdAtClient.value);
    }
    if (serverCreatedAt.present) {
      map['server_created_at'] = Variable<int>(serverCreatedAt.value);
    }
    if (state.present) {
      map['state'] =
          Variable<int>($MessagesTable.$converterstate.toSql(state.value));
    }
    if (deleteState.present) {
      map['delete_state'] = Variable<int>(
          $MessagesTable.$converterdeleteState.toSql(deleteState.value));
    }
    if (serverStatus.present) {
      map['server_status'] = Variable<String>(serverStatus.value);
    }
    if (reactsJson.present) {
      map['reacts_json'] = Variable<String>(reactsJson.value);
    }
    if (attachmentJson.present) {
      map['attachment_json'] = Variable<String>(attachmentJson.value);
    }
    if (replyPreviewJson.present) {
      map['reply_preview_json'] = Variable<String>(replyPreviewJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('localId: $localId, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('serverMessageId: $serverMessageId, ')
          ..write('roomId: $roomId, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('senderId: $senderId, ')
          ..write('kind: $kind, ')
          ..write('systemEvent: $systemEvent, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('replyToClientUuid: $replyToClientUuid, ')
          ..write('createdAtClient: $createdAtClient, ')
          ..write('serverCreatedAt: $serverCreatedAt, ')
          ..write('state: $state, ')
          ..write('deleteState: $deleteState, ')
          ..write('serverStatus: $serverStatus, ')
          ..write('reactsJson: $reactsJson, ')
          ..write('attachmentJson: $attachmentJson, ')
          ..write('replyPreviewJson: $replyPreviewJson')
          ..write(')'))
        .toString();
  }
}

class $ConversationMembersTable extends ConversationMembers
    with TableInfo<$ConversationMembersTable, ConversationMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
      'room_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES rooms (local_id) ON DELETE CASCADE'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _joinedSeqMeta =
      const VerificationMeta('joinedSeq');
  @override
  late final GeneratedColumn<int> joinedSeq = GeneratedColumn<int>(
      'joined_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _removedSeqMeta =
      const VerificationMeta('removedSeq');
  @override
  late final GeneratedColumn<int> removedSeq = GeneratedColumn<int>(
      'removed_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameCacheMeta =
      const VerificationMeta('nameCache');
  @override
  late final GeneratedColumn<String> nameCache = GeneratedColumn<String>(
      'name_cache', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarCacheMeta =
      const VerificationMeta('avatarCache');
  @override
  late final GeneratedColumn<String> avatarCache = GeneratedColumn<String>(
      'avatar_cache', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastReadSeqMeta =
      const VerificationMeta('lastReadSeq');
  @override
  late final GeneratedColumn<int> lastReadSeq = GeneratedColumn<int>(
      'last_read_seq', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        roomId,
        userId,
        role,
        status,
        joinedSeq,
        removedSeq,
        nameCache,
        avatarCache,
        lastReadSeq
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation_members';
  @override
  VerificationContext validateIntegrity(Insertable<ConversationMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('joined_seq')) {
      context.handle(_joinedSeqMeta,
          joinedSeq.isAcceptableOrUnknown(data['joined_seq']!, _joinedSeqMeta));
    }
    if (data.containsKey('removed_seq')) {
      context.handle(
          _removedSeqMeta,
          removedSeq.isAcceptableOrUnknown(
              data['removed_seq']!, _removedSeqMeta));
    }
    if (data.containsKey('name_cache')) {
      context.handle(_nameCacheMeta,
          nameCache.isAcceptableOrUnknown(data['name_cache']!, _nameCacheMeta));
    }
    if (data.containsKey('avatar_cache')) {
      context.handle(
          _avatarCacheMeta,
          avatarCache.isAcceptableOrUnknown(
              data['avatar_cache']!, _avatarCacheMeta));
    }
    if (data.containsKey('last_read_seq')) {
      context.handle(
          _lastReadSeqMeta,
          lastReadSeq.isAcceptableOrUnknown(
              data['last_read_seq']!, _lastReadSeqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roomId, userId};
  @override
  ConversationMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationMember(
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}room_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status']),
      joinedSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}joined_seq']),
      removedSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}removed_seq']),
      nameCache: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_cache']),
      avatarCache: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_cache']),
      lastReadSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_read_seq'])!,
    );
  }

  @override
  $ConversationMembersTable createAlias(String alias) {
    return $ConversationMembersTable(attachedDatabase, alias);
  }
}

class ConversationMember extends DataClass
    implements Insertable<ConversationMember> {
  /// FK -> rooms.local_id.
  final int roomId;
  final int userId;
  final String? role;
  final String? status;
  final int? joinedSeq;
  final int? removedSeq;
  final String? nameCache;
  final String? avatarCache;
  final int lastReadSeq;
  const ConversationMember(
      {required this.roomId,
      required this.userId,
      this.role,
      this.status,
      this.joinedSeq,
      this.removedSeq,
      this.nameCache,
      this.avatarCache,
      required this.lastReadSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['room_id'] = Variable<int>(roomId);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || joinedSeq != null) {
      map['joined_seq'] = Variable<int>(joinedSeq);
    }
    if (!nullToAbsent || removedSeq != null) {
      map['removed_seq'] = Variable<int>(removedSeq);
    }
    if (!nullToAbsent || nameCache != null) {
      map['name_cache'] = Variable<String>(nameCache);
    }
    if (!nullToAbsent || avatarCache != null) {
      map['avatar_cache'] = Variable<String>(avatarCache);
    }
    map['last_read_seq'] = Variable<int>(lastReadSeq);
    return map;
  }

  ConversationMembersCompanion toCompanion(bool nullToAbsent) {
    return ConversationMembersCompanion(
      roomId: Value(roomId),
      userId: Value(userId),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      joinedSeq: joinedSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedSeq),
      removedSeq: removedSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(removedSeq),
      nameCache: nameCache == null && nullToAbsent
          ? const Value.absent()
          : Value(nameCache),
      avatarCache: avatarCache == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarCache),
      lastReadSeq: Value(lastReadSeq),
    );
  }

  factory ConversationMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationMember(
      roomId: serializer.fromJson<int>(json['roomId']),
      userId: serializer.fromJson<int>(json['userId']),
      role: serializer.fromJson<String?>(json['role']),
      status: serializer.fromJson<String?>(json['status']),
      joinedSeq: serializer.fromJson<int?>(json['joinedSeq']),
      removedSeq: serializer.fromJson<int?>(json['removedSeq']),
      nameCache: serializer.fromJson<String?>(json['nameCache']),
      avatarCache: serializer.fromJson<String?>(json['avatarCache']),
      lastReadSeq: serializer.fromJson<int>(json['lastReadSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<int>(roomId),
      'userId': serializer.toJson<int>(userId),
      'role': serializer.toJson<String?>(role),
      'status': serializer.toJson<String?>(status),
      'joinedSeq': serializer.toJson<int?>(joinedSeq),
      'removedSeq': serializer.toJson<int?>(removedSeq),
      'nameCache': serializer.toJson<String?>(nameCache),
      'avatarCache': serializer.toJson<String?>(avatarCache),
      'lastReadSeq': serializer.toJson<int>(lastReadSeq),
    };
  }

  ConversationMember copyWith(
          {int? roomId,
          int? userId,
          Value<String?> role = const Value.absent(),
          Value<String?> status = const Value.absent(),
          Value<int?> joinedSeq = const Value.absent(),
          Value<int?> removedSeq = const Value.absent(),
          Value<String?> nameCache = const Value.absent(),
          Value<String?> avatarCache = const Value.absent(),
          int? lastReadSeq}) =>
      ConversationMember(
        roomId: roomId ?? this.roomId,
        userId: userId ?? this.userId,
        role: role.present ? role.value : this.role,
        status: status.present ? status.value : this.status,
        joinedSeq: joinedSeq.present ? joinedSeq.value : this.joinedSeq,
        removedSeq: removedSeq.present ? removedSeq.value : this.removedSeq,
        nameCache: nameCache.present ? nameCache.value : this.nameCache,
        avatarCache: avatarCache.present ? avatarCache.value : this.avatarCache,
        lastReadSeq: lastReadSeq ?? this.lastReadSeq,
      );
  ConversationMember copyWithCompanion(ConversationMembersCompanion data) {
    return ConversationMember(
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      status: data.status.present ? data.status.value : this.status,
      joinedSeq: data.joinedSeq.present ? data.joinedSeq.value : this.joinedSeq,
      removedSeq:
          data.removedSeq.present ? data.removedSeq.value : this.removedSeq,
      nameCache: data.nameCache.present ? data.nameCache.value : this.nameCache,
      avatarCache:
          data.avatarCache.present ? data.avatarCache.value : this.avatarCache,
      lastReadSeq:
          data.lastReadSeq.present ? data.lastReadSeq.value : this.lastReadSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationMember(')
          ..write('roomId: $roomId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('joinedSeq: $joinedSeq, ')
          ..write('removedSeq: $removedSeq, ')
          ..write('nameCache: $nameCache, ')
          ..write('avatarCache: $avatarCache, ')
          ..write('lastReadSeq: $lastReadSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(roomId, userId, role, status, joinedSeq,
      removedSeq, nameCache, avatarCache, lastReadSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationMember &&
          other.roomId == this.roomId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.status == this.status &&
          other.joinedSeq == this.joinedSeq &&
          other.removedSeq == this.removedSeq &&
          other.nameCache == this.nameCache &&
          other.avatarCache == this.avatarCache &&
          other.lastReadSeq == this.lastReadSeq);
}

class ConversationMembersCompanion extends UpdateCompanion<ConversationMember> {
  final Value<int> roomId;
  final Value<int> userId;
  final Value<String?> role;
  final Value<String?> status;
  final Value<int?> joinedSeq;
  final Value<int?> removedSeq;
  final Value<String?> nameCache;
  final Value<String?> avatarCache;
  final Value<int> lastReadSeq;
  final Value<int> rowid;
  const ConversationMembersCompanion({
    this.roomId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.joinedSeq = const Value.absent(),
    this.removedSeq = const Value.absent(),
    this.nameCache = const Value.absent(),
    this.avatarCache = const Value.absent(),
    this.lastReadSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationMembersCompanion.insert({
    required int roomId,
    required int userId,
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.joinedSeq = const Value.absent(),
    this.removedSeq = const Value.absent(),
    this.nameCache = const Value.absent(),
    this.avatarCache = const Value.absent(),
    this.lastReadSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : roomId = Value(roomId),
        userId = Value(userId);
  static Insertable<ConversationMember> custom({
    Expression<int>? roomId,
    Expression<int>? userId,
    Expression<String>? role,
    Expression<String>? status,
    Expression<int>? joinedSeq,
    Expression<int>? removedSeq,
    Expression<String>? nameCache,
    Expression<String>? avatarCache,
    Expression<int>? lastReadSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (joinedSeq != null) 'joined_seq': joinedSeq,
      if (removedSeq != null) 'removed_seq': removedSeq,
      if (nameCache != null) 'name_cache': nameCache,
      if (avatarCache != null) 'avatar_cache': avatarCache,
      if (lastReadSeq != null) 'last_read_seq': lastReadSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationMembersCompanion copyWith(
      {Value<int>? roomId,
      Value<int>? userId,
      Value<String?>? role,
      Value<String?>? status,
      Value<int?>? joinedSeq,
      Value<int?>? removedSeq,
      Value<String?>? nameCache,
      Value<String?>? avatarCache,
      Value<int>? lastReadSeq,
      Value<int>? rowid}) {
    return ConversationMembersCompanion(
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedSeq: joinedSeq ?? this.joinedSeq,
      removedSeq: removedSeq ?? this.removedSeq,
      nameCache: nameCache ?? this.nameCache,
      avatarCache: avatarCache ?? this.avatarCache,
      lastReadSeq: lastReadSeq ?? this.lastReadSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (joinedSeq.present) {
      map['joined_seq'] = Variable<int>(joinedSeq.value);
    }
    if (removedSeq.present) {
      map['removed_seq'] = Variable<int>(removedSeq.value);
    }
    if (nameCache.present) {
      map['name_cache'] = Variable<String>(nameCache.value);
    }
    if (avatarCache.present) {
      map['avatar_cache'] = Variable<String>(avatarCache.value);
    }
    if (lastReadSeq.present) {
      map['last_read_seq'] = Variable<int>(lastReadSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationMembersCompanion(')
          ..write('roomId: $roomId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('joinedSeq: $joinedSeq, ')
          ..write('removedSeq: $removedSeq, ')
          ..write('nameCache: $nameCache, ')
          ..write('avatarCache: $avatarCache, ')
          ..write('lastReadSeq: $lastReadSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
      'local_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumnWithTypeConverter<OutboxOpType, int> opType =
      GeneratedColumn<int>('op_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<OutboxOpType>($OutboxTable.$converteropType);
  static const VerificationMeta _clientUuidMeta =
      const VerificationMeta('clientUuid');
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
      'client_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
      'room_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mediaLocalRefMeta =
      const VerificationMeta('mediaLocalRef');
  @override
  late final GeneratedColumn<String> mediaLocalRef = GeneratedColumn<String>(
      'media_local_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextRetryAtMeta =
      const VerificationMeta('nextRetryAt');
  @override
  late final GeneratedColumn<int> nextRetryAt = GeneratedColumn<int>(
      'next_retry_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        opType,
        clientUuid,
        roomId,
        payloadJson,
        mediaLocalRef,
        attempts,
        nextRetryAt,
        lastError,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    }
    context.handle(_opTypeMeta, const VerificationResult.success());
    if (data.containsKey('client_uuid')) {
      context.handle(
          _clientUuidMeta,
          clientUuid.isAcceptableOrUnknown(
              data['client_uuid']!, _clientUuidMeta));
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('media_local_ref')) {
      context.handle(
          _mediaLocalRefMeta,
          mediaLocalRef.isAcceptableOrUnknown(
              data['media_local_ref']!, _mediaLocalRefMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
          _nextRetryAtMeta,
          nextRetryAt.isAcceptableOrUnknown(
              data['next_retry_at']!, _nextRetryAtMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_id'])!,
      opType: $OutboxTable.$converteropType.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}op_type'])!),
      clientUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_uuid'])!,
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}room_id'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      mediaLocalRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_local_ref']),
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      nextRetryAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}next_retry_at']),
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OutboxOpType, int, int> $converteropType =
      const EnumIndexConverter<OutboxOpType>(OutboxOpType.values);
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final int localId;
  final OutboxOpType opType;

  /// Idempotency-Key sent to the backend; ties this op to its message row.
  final String clientUuid;
  final int roomId;
  final String payloadJson;

  /// Optional reference into media_uploads for attachment-bearing ops.
  final String? mediaLocalRef;
  final int attempts;

  /// ms epoch — worker skips rows whose retry time is in the future.
  final int? nextRetryAt;
  final String? lastError;
  final int createdAt;
  const OutboxData(
      {required this.localId,
      required this.opType,
      required this.clientUuid,
      required this.roomId,
      required this.payloadJson,
      this.mediaLocalRef,
      required this.attempts,
      this.nextRetryAt,
      this.lastError,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    {
      map['op_type'] =
          Variable<int>($OutboxTable.$converteropType.toSql(opType));
    }
    map['client_uuid'] = Variable<String>(clientUuid);
    map['room_id'] = Variable<int>(roomId);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || mediaLocalRef != null) {
      map['media_local_ref'] = Variable<String>(mediaLocalRef);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<int>(nextRetryAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      localId: Value(localId),
      opType: Value(opType),
      clientUuid: Value(clientUuid),
      roomId: Value(roomId),
      payloadJson: Value(payloadJson),
      mediaLocalRef: mediaLocalRef == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaLocalRef),
      attempts: Value(attempts),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      localId: serializer.fromJson<int>(json['localId']),
      opType: $OutboxTable.$converteropType
          .fromJson(serializer.fromJson<int>(json['opType'])),
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      roomId: serializer.fromJson<int>(json['roomId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      mediaLocalRef: serializer.fromJson<String?>(json['mediaLocalRef']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextRetryAt: serializer.fromJson<int?>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'opType':
          serializer.toJson<int>($OutboxTable.$converteropType.toJson(opType)),
      'clientUuid': serializer.toJson<String>(clientUuid),
      'roomId': serializer.toJson<int>(roomId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'mediaLocalRef': serializer.toJson<String?>(mediaLocalRef),
      'attempts': serializer.toJson<int>(attempts),
      'nextRetryAt': serializer.toJson<int?>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  OutboxData copyWith(
          {int? localId,
          OutboxOpType? opType,
          String? clientUuid,
          int? roomId,
          String? payloadJson,
          Value<String?> mediaLocalRef = const Value.absent(),
          int? attempts,
          Value<int?> nextRetryAt = const Value.absent(),
          Value<String?> lastError = const Value.absent(),
          int? createdAt}) =>
      OutboxData(
        localId: localId ?? this.localId,
        opType: opType ?? this.opType,
        clientUuid: clientUuid ?? this.clientUuid,
        roomId: roomId ?? this.roomId,
        payloadJson: payloadJson ?? this.payloadJson,
        mediaLocalRef:
            mediaLocalRef.present ? mediaLocalRef.value : this.mediaLocalRef,
        attempts: attempts ?? this.attempts,
        nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
        lastError: lastError.present ? lastError.value : this.lastError,
        createdAt: createdAt ?? this.createdAt,
      );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      localId: data.localId.present ? data.localId.value : this.localId,
      opType: data.opType.present ? data.opType.value : this.opType,
      clientUuid:
          data.clientUuid.present ? data.clientUuid.value : this.clientUuid,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      mediaLocalRef: data.mediaLocalRef.present
          ? data.mediaLocalRef.value
          : this.mediaLocalRef,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextRetryAt:
          data.nextRetryAt.present ? data.nextRetryAt.value : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('localId: $localId, ')
          ..write('opType: $opType, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('roomId: $roomId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('mediaLocalRef: $mediaLocalRef, ')
          ..write('attempts: $attempts, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localId, opType, clientUuid, roomId,
      payloadJson, mediaLocalRef, attempts, nextRetryAt, lastError, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.localId == this.localId &&
          other.opType == this.opType &&
          other.clientUuid == this.clientUuid &&
          other.roomId == this.roomId &&
          other.payloadJson == this.payloadJson &&
          other.mediaLocalRef == this.mediaLocalRef &&
          other.attempts == this.attempts &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<int> localId;
  final Value<OutboxOpType> opType;
  final Value<String> clientUuid;
  final Value<int> roomId;
  final Value<String> payloadJson;
  final Value<String?> mediaLocalRef;
  final Value<int> attempts;
  final Value<int?> nextRetryAt;
  final Value<String?> lastError;
  final Value<int> createdAt;
  const OutboxCompanion({
    this.localId = const Value.absent(),
    this.opType = const Value.absent(),
    this.clientUuid = const Value.absent(),
    this.roomId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.mediaLocalRef = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.localId = const Value.absent(),
    required OutboxOpType opType,
    required String clientUuid,
    required int roomId,
    required String payloadJson,
    this.mediaLocalRef = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    required int createdAt,
  })  : opType = Value(opType),
        clientUuid = Value(clientUuid),
        roomId = Value(roomId),
        payloadJson = Value(payloadJson),
        createdAt = Value(createdAt);
  static Insertable<OutboxData> custom({
    Expression<int>? localId,
    Expression<int>? opType,
    Expression<String>? clientUuid,
    Expression<int>? roomId,
    Expression<String>? payloadJson,
    Expression<String>? mediaLocalRef,
    Expression<int>? attempts,
    Expression<int>? nextRetryAt,
    Expression<String>? lastError,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (opType != null) 'op_type': opType,
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (roomId != null) 'room_id': roomId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (mediaLocalRef != null) 'media_local_ref': mediaLocalRef,
      if (attempts != null) 'attempts': attempts,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxCompanion copyWith(
      {Value<int>? localId,
      Value<OutboxOpType>? opType,
      Value<String>? clientUuid,
      Value<int>? roomId,
      Value<String>? payloadJson,
      Value<String?>? mediaLocalRef,
      Value<int>? attempts,
      Value<int?>? nextRetryAt,
      Value<String?>? lastError,
      Value<int>? createdAt}) {
    return OutboxCompanion(
      localId: localId ?? this.localId,
      opType: opType ?? this.opType,
      clientUuid: clientUuid ?? this.clientUuid,
      roomId: roomId ?? this.roomId,
      payloadJson: payloadJson ?? this.payloadJson,
      mediaLocalRef: mediaLocalRef ?? this.mediaLocalRef,
      attempts: attempts ?? this.attempts,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (opType.present) {
      map['op_type'] =
          Variable<int>($OutboxTable.$converteropType.toSql(opType.value));
    }
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (mediaLocalRef.present) {
      map['media_local_ref'] = Variable<String>(mediaLocalRef.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<int>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('localId: $localId, ')
          ..write('opType: $opType, ')
          ..write('clientUuid: $clientUuid, ')
          ..write('roomId: $roomId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('mediaLocalRef: $mediaLocalRef, ')
          ..write('attempts: $attempts, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MediaUploadsTable extends MediaUploads
    with TableInfo<$MediaUploadsTable, MediaUpload> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaUploadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientUuidMeta =
      const VerificationMeta('clientUuid');
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
      'client_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteUrlMeta =
      const VerificationMeta('remoteUrl');
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
      'remote_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbLocalPathMeta =
      const VerificationMeta('thumbLocalPath');
  @override
  late final GeneratedColumn<String> thumbLocalPath = GeneratedColumn<String>(
      'thumb_local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbRemoteUrlMeta =
      const VerificationMeta('thumbRemoteUrl');
  @override
  late final GeneratedColumn<String> thumbRemoteUrl = GeneratedColumn<String>(
      'thumb_remote_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
      'mime', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
      'width', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _uploadStateMeta =
      const VerificationMeta('uploadState');
  @override
  late final GeneratedColumnWithTypeConverter<MediaUploadState, int>
      uploadState = GeneratedColumn<int>('upload_state', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<MediaUploadState>(
              $MediaUploadsTable.$converteruploadState);
  static const VerificationMeta _bytesSentMeta =
      const VerificationMeta('bytesSent');
  @override
  late final GeneratedColumn<int> bytesSent = GeneratedColumn<int>(
      'bytes_sent', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        clientUuid,
        localPath,
        remoteUrl,
        thumbLocalPath,
        thumbRemoteUrl,
        mime,
        width,
        height,
        durationMs,
        sizeBytes,
        uploadState,
        bytesSent
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_uploads';
  @override
  VerificationContext validateIntegrity(Insertable<MediaUpload> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_uuid')) {
      context.handle(
          _clientUuidMeta,
          clientUuid.isAcceptableOrUnknown(
              data['client_uuid']!, _clientUuidMeta));
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(_remoteUrlMeta,
          remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta));
    }
    if (data.containsKey('thumb_local_path')) {
      context.handle(
          _thumbLocalPathMeta,
          thumbLocalPath.isAcceptableOrUnknown(
              data['thumb_local_path']!, _thumbLocalPathMeta));
    }
    if (data.containsKey('thumb_remote_url')) {
      context.handle(
          _thumbRemoteUrlMeta,
          thumbRemoteUrl.isAcceptableOrUnknown(
              data['thumb_remote_url']!, _thumbRemoteUrlMeta));
    }
    if (data.containsKey('mime')) {
      context.handle(
          _mimeMeta, mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta));
    }
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    }
    context.handle(_uploadStateMeta, const VerificationResult.success());
    if (data.containsKey('bytes_sent')) {
      context.handle(_bytesSentMeta,
          bytesSent.isAcceptableOrUnknown(data['bytes_sent']!, _bytesSentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientUuid};
  @override
  MediaUpload map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaUpload(
      clientUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_uuid'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      remoteUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_url']),
      thumbLocalPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}thumb_local_path']),
      thumbRemoteUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}thumb_remote_url']),
      mime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime']),
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width']),
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height']),
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms']),
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes']),
      uploadState: $MediaUploadsTable.$converteruploadState.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}upload_state'])!),
      bytesSent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bytes_sent'])!,
    );
  }

  @override
  $MediaUploadsTable createAlias(String alias) {
    return $MediaUploadsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MediaUploadState, int, int> $converteruploadState =
      const EnumIndexConverter<MediaUploadState>(MediaUploadState.values);
}

class MediaUpload extends DataClass implements Insertable<MediaUpload> {
  final String clientUuid;
  final String localPath;
  final String? remoteUrl;
  final String? thumbLocalPath;
  final String? thumbRemoteUrl;
  final String? mime;
  final int? width;
  final int? height;
  final int? durationMs;
  final int? sizeBytes;
  final MediaUploadState uploadState;
  final int bytesSent;
  const MediaUpload(
      {required this.clientUuid,
      required this.localPath,
      this.remoteUrl,
      this.thumbLocalPath,
      this.thumbRemoteUrl,
      this.mime,
      this.width,
      this.height,
      this.durationMs,
      this.sizeBytes,
      required this.uploadState,
      required this.bytesSent});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_uuid'] = Variable<String>(clientUuid);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    if (!nullToAbsent || thumbLocalPath != null) {
      map['thumb_local_path'] = Variable<String>(thumbLocalPath);
    }
    if (!nullToAbsent || thumbRemoteUrl != null) {
      map['thumb_remote_url'] = Variable<String>(thumbRemoteUrl);
    }
    if (!nullToAbsent || mime != null) {
      map['mime'] = Variable<String>(mime);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    {
      map['upload_state'] = Variable<int>(
          $MediaUploadsTable.$converteruploadState.toSql(uploadState));
    }
    map['bytes_sent'] = Variable<int>(bytesSent);
    return map;
  }

  MediaUploadsCompanion toCompanion(bool nullToAbsent) {
    return MediaUploadsCompanion(
      clientUuid: Value(clientUuid),
      localPath: Value(localPath),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      thumbLocalPath: thumbLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbLocalPath),
      thumbRemoteUrl: thumbRemoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbRemoteUrl),
      mime: mime == null && nullToAbsent ? const Value.absent() : Value(mime),
      width:
          width == null && nullToAbsent ? const Value.absent() : Value(width),
      height:
          height == null && nullToAbsent ? const Value.absent() : Value(height),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      uploadState: Value(uploadState),
      bytesSent: Value(bytesSent),
    );
  }

  factory MediaUpload.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaUpload(
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      localPath: serializer.fromJson<String>(json['localPath']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      thumbLocalPath: serializer.fromJson<String?>(json['thumbLocalPath']),
      thumbRemoteUrl: serializer.fromJson<String?>(json['thumbRemoteUrl']),
      mime: serializer.fromJson<String?>(json['mime']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      uploadState: $MediaUploadsTable.$converteruploadState
          .fromJson(serializer.fromJson<int>(json['uploadState'])),
      bytesSent: serializer.fromJson<int>(json['bytesSent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientUuid': serializer.toJson<String>(clientUuid),
      'localPath': serializer.toJson<String>(localPath),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'thumbLocalPath': serializer.toJson<String?>(thumbLocalPath),
      'thumbRemoteUrl': serializer.toJson<String?>(thumbRemoteUrl),
      'mime': serializer.toJson<String?>(mime),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'durationMs': serializer.toJson<int?>(durationMs),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'uploadState': serializer.toJson<int>(
          $MediaUploadsTable.$converteruploadState.toJson(uploadState)),
      'bytesSent': serializer.toJson<int>(bytesSent),
    };
  }

  MediaUpload copyWith(
          {String? clientUuid,
          String? localPath,
          Value<String?> remoteUrl = const Value.absent(),
          Value<String?> thumbLocalPath = const Value.absent(),
          Value<String?> thumbRemoteUrl = const Value.absent(),
          Value<String?> mime = const Value.absent(),
          Value<int?> width = const Value.absent(),
          Value<int?> height = const Value.absent(),
          Value<int?> durationMs = const Value.absent(),
          Value<int?> sizeBytes = const Value.absent(),
          MediaUploadState? uploadState,
          int? bytesSent}) =>
      MediaUpload(
        clientUuid: clientUuid ?? this.clientUuid,
        localPath: localPath ?? this.localPath,
        remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
        thumbLocalPath:
            thumbLocalPath.present ? thumbLocalPath.value : this.thumbLocalPath,
        thumbRemoteUrl:
            thumbRemoteUrl.present ? thumbRemoteUrl.value : this.thumbRemoteUrl,
        mime: mime.present ? mime.value : this.mime,
        width: width.present ? width.value : this.width,
        height: height.present ? height.value : this.height,
        durationMs: durationMs.present ? durationMs.value : this.durationMs,
        sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
        uploadState: uploadState ?? this.uploadState,
        bytesSent: bytesSent ?? this.bytesSent,
      );
  MediaUpload copyWithCompanion(MediaUploadsCompanion data) {
    return MediaUpload(
      clientUuid:
          data.clientUuid.present ? data.clientUuid.value : this.clientUuid,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      thumbLocalPath: data.thumbLocalPath.present
          ? data.thumbLocalPath.value
          : this.thumbLocalPath,
      thumbRemoteUrl: data.thumbRemoteUrl.present
          ? data.thumbRemoteUrl.value
          : this.thumbRemoteUrl,
      mime: data.mime.present ? data.mime.value : this.mime,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      uploadState:
          data.uploadState.present ? data.uploadState.value : this.uploadState,
      bytesSent: data.bytesSent.present ? data.bytesSent.value : this.bytesSent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaUpload(')
          ..write('clientUuid: $clientUuid, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('thumbLocalPath: $thumbLocalPath, ')
          ..write('thumbRemoteUrl: $thumbRemoteUrl, ')
          ..write('mime: $mime, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationMs: $durationMs, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('uploadState: $uploadState, ')
          ..write('bytesSent: $bytesSent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      clientUuid,
      localPath,
      remoteUrl,
      thumbLocalPath,
      thumbRemoteUrl,
      mime,
      width,
      height,
      durationMs,
      sizeBytes,
      uploadState,
      bytesSent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaUpload &&
          other.clientUuid == this.clientUuid &&
          other.localPath == this.localPath &&
          other.remoteUrl == this.remoteUrl &&
          other.thumbLocalPath == this.thumbLocalPath &&
          other.thumbRemoteUrl == this.thumbRemoteUrl &&
          other.mime == this.mime &&
          other.width == this.width &&
          other.height == this.height &&
          other.durationMs == this.durationMs &&
          other.sizeBytes == this.sizeBytes &&
          other.uploadState == this.uploadState &&
          other.bytesSent == this.bytesSent);
}

class MediaUploadsCompanion extends UpdateCompanion<MediaUpload> {
  final Value<String> clientUuid;
  final Value<String> localPath;
  final Value<String?> remoteUrl;
  final Value<String?> thumbLocalPath;
  final Value<String?> thumbRemoteUrl;
  final Value<String?> mime;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> durationMs;
  final Value<int?> sizeBytes;
  final Value<MediaUploadState> uploadState;
  final Value<int> bytesSent;
  final Value<int> rowid;
  const MediaUploadsCompanion({
    this.clientUuid = const Value.absent(),
    this.localPath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.thumbLocalPath = const Value.absent(),
    this.thumbRemoteUrl = const Value.absent(),
    this.mime = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.uploadState = const Value.absent(),
    this.bytesSent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaUploadsCompanion.insert({
    required String clientUuid,
    required String localPath,
    this.remoteUrl = const Value.absent(),
    this.thumbLocalPath = const Value.absent(),
    this.thumbRemoteUrl = const Value.absent(),
    this.mime = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    required MediaUploadState uploadState,
    this.bytesSent = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : clientUuid = Value(clientUuid),
        localPath = Value(localPath),
        uploadState = Value(uploadState);
  static Insertable<MediaUpload> custom({
    Expression<String>? clientUuid,
    Expression<String>? localPath,
    Expression<String>? remoteUrl,
    Expression<String>? thumbLocalPath,
    Expression<String>? thumbRemoteUrl,
    Expression<String>? mime,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? durationMs,
    Expression<int>? sizeBytes,
    Expression<int>? uploadState,
    Expression<int>? bytesSent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (localPath != null) 'local_path': localPath,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (thumbLocalPath != null) 'thumb_local_path': thumbLocalPath,
      if (thumbRemoteUrl != null) 'thumb_remote_url': thumbRemoteUrl,
      if (mime != null) 'mime': mime,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (durationMs != null) 'duration_ms': durationMs,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (uploadState != null) 'upload_state': uploadState,
      if (bytesSent != null) 'bytes_sent': bytesSent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaUploadsCompanion copyWith(
      {Value<String>? clientUuid,
      Value<String>? localPath,
      Value<String?>? remoteUrl,
      Value<String?>? thumbLocalPath,
      Value<String?>? thumbRemoteUrl,
      Value<String?>? mime,
      Value<int?>? width,
      Value<int?>? height,
      Value<int?>? durationMs,
      Value<int?>? sizeBytes,
      Value<MediaUploadState>? uploadState,
      Value<int>? bytesSent,
      Value<int>? rowid}) {
    return MediaUploadsCompanion(
      clientUuid: clientUuid ?? this.clientUuid,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      thumbLocalPath: thumbLocalPath ?? this.thumbLocalPath,
      thumbRemoteUrl: thumbRemoteUrl ?? this.thumbRemoteUrl,
      mime: mime ?? this.mime,
      width: width ?? this.width,
      height: height ?? this.height,
      durationMs: durationMs ?? this.durationMs,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      uploadState: uploadState ?? this.uploadState,
      bytesSent: bytesSent ?? this.bytesSent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (thumbLocalPath.present) {
      map['thumb_local_path'] = Variable<String>(thumbLocalPath.value);
    }
    if (thumbRemoteUrl.present) {
      map['thumb_remote_url'] = Variable<String>(thumbRemoteUrl.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (uploadState.present) {
      map['upload_state'] = Variable<int>(
          $MediaUploadsTable.$converteruploadState.toSql(uploadState.value));
    }
    if (bytesSent.present) {
      map['bytes_sent'] = Variable<int>(bytesSent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaUploadsCompanion(')
          ..write('clientUuid: $clientUuid, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('thumbLocalPath: $thumbLocalPath, ')
          ..write('thumbRemoteUrl: $thumbRemoteUrl, ')
          ..write('mime: $mime, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationMs: $durationMs, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('uploadState: $uploadState, ')
          ..write('bytesSent: $bytesSent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
      'room_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastKnownSeqMeta =
      const VerificationMeta('lastKnownSeq');
  @override
  late final GeneratedColumn<int> lastKnownSeq = GeneratedColumn<int>(
      'last_known_seq', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _epochMeta = const VerificationMeta('epoch');
  @override
  late final GeneratedColumn<String> epoch = GeneratedColumn<String>(
      'epoch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [roomId, lastKnownSeq, epoch, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    }
    if (data.containsKey('last_known_seq')) {
      context.handle(
          _lastKnownSeqMeta,
          lastKnownSeq.isAcceptableOrUnknown(
              data['last_known_seq']!, _lastKnownSeqMeta));
    }
    if (data.containsKey('epoch')) {
      context.handle(
          _epochMeta, epoch.isAcceptableOrUnknown(data['epoch']!, _epochMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roomId};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}room_id'])!,
      lastKnownSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_known_seq'])!,
      epoch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}epoch']),
      lastSyncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final int roomId;
  final int lastKnownSeq;

  /// Centrifugo channel epoch. A mismatch on reconnect forces a full resync.
  final String? epoch;
  final int? lastSyncedAt;
  const SyncStateData(
      {required this.roomId,
      required this.lastKnownSeq,
      this.epoch,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['room_id'] = Variable<int>(roomId);
    map['last_known_seq'] = Variable<int>(lastKnownSeq);
    if (!nullToAbsent || epoch != null) {
      map['epoch'] = Variable<String>(epoch);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      roomId: Value(roomId),
      lastKnownSeq: Value(lastKnownSeq),
      epoch:
          epoch == null && nullToAbsent ? const Value.absent() : Value(epoch),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SyncStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      roomId: serializer.fromJson<int>(json['roomId']),
      lastKnownSeq: serializer.fromJson<int>(json['lastKnownSeq']),
      epoch: serializer.fromJson<String?>(json['epoch']),
      lastSyncedAt: serializer.fromJson<int?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<int>(roomId),
      'lastKnownSeq': serializer.toJson<int>(lastKnownSeq),
      'epoch': serializer.toJson<String?>(epoch),
      'lastSyncedAt': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  SyncStateData copyWith(
          {int? roomId,
          int? lastKnownSeq,
          Value<String?> epoch = const Value.absent(),
          Value<int?> lastSyncedAt = const Value.absent()}) =>
      SyncStateData(
        roomId: roomId ?? this.roomId,
        lastKnownSeq: lastKnownSeq ?? this.lastKnownSeq,
        epoch: epoch.present ? epoch.value : this.epoch,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      lastKnownSeq: data.lastKnownSeq.present
          ? data.lastKnownSeq.value
          : this.lastKnownSeq,
      epoch: data.epoch.present ? data.epoch.value : this.epoch,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('roomId: $roomId, ')
          ..write('lastKnownSeq: $lastKnownSeq, ')
          ..write('epoch: $epoch, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(roomId, lastKnownSeq, epoch, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.roomId == this.roomId &&
          other.lastKnownSeq == this.lastKnownSeq &&
          other.epoch == this.epoch &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<int> roomId;
  final Value<int> lastKnownSeq;
  final Value<String?> epoch;
  final Value<int?> lastSyncedAt;
  const SyncStateCompanion({
    this.roomId = const Value.absent(),
    this.lastKnownSeq = const Value.absent(),
    this.epoch = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  SyncStateCompanion.insert({
    this.roomId = const Value.absent(),
    this.lastKnownSeq = const Value.absent(),
    this.epoch = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  static Insertable<SyncStateData> custom({
    Expression<int>? roomId,
    Expression<int>? lastKnownSeq,
    Expression<String>? epoch,
    Expression<int>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (lastKnownSeq != null) 'last_known_seq': lastKnownSeq,
      if (epoch != null) 'epoch': epoch,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  SyncStateCompanion copyWith(
      {Value<int>? roomId,
      Value<int>? lastKnownSeq,
      Value<String?>? epoch,
      Value<int?>? lastSyncedAt}) {
    return SyncStateCompanion(
      roomId: roomId ?? this.roomId,
      lastKnownSeq: lastKnownSeq ?? this.lastKnownSeq,
      epoch: epoch ?? this.epoch,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (lastKnownSeq.present) {
      map['last_known_seq'] = Variable<int>(lastKnownSeq.value);
    }
    if (epoch.present) {
      map['epoch'] = Variable<String>(epoch.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('roomId: $roomId, ')
          ..write('lastKnownSeq: $lastKnownSeq, ')
          ..write('epoch: $epoch, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ConversationMembersTable conversationMembers =
      $ConversationMembersTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $MediaUploadsTable mediaUploads = $MediaUploadsTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final RoomsDao roomsDao = RoomsDao(this as AppDatabase);
  late final MessagesDao messagesDao = MessagesDao(this as AppDatabase);
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  late final MediaUploadsDao mediaUploadsDao =
      MediaUploadsDao(this as AppDatabase);
  late final SyncStateDao syncStateDao = SyncStateDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [rooms, messages, conversationMembers, outbox, mediaUploads, syncState];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('rooms',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('messages', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('rooms',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('conversation_members', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$RoomsTableCreateCompanionBuilder = RoomsCompanion Function({
  Value<int> localId,
  Value<int?> serverRoomId,
  required RoomType type,
  Value<String?> title,
  Value<String?> avatarUrl,
  Value<int?> peerUserId,
  Value<int?> groupId,
  Value<int> memberCount,
  Value<int?> lastMessageLocalId,
  Value<String?> lastPreviewText,
  Value<int?> lastPreviewType,
  Value<int?> lastPreviewSenderId,
  Value<int?> lastPreviewServerMessageId,
  Value<String?> lastPreviewStatus,
  Value<int?> lastPreviewState,
  Value<int?> lastPreviewDeleteState,
  Value<int> lastServerSeq,
  Value<int> myLastReadSeq,
  Value<int> unreadCount,
  Value<int?> mutedUntil,
  Value<String?> draftText,
  Value<bool> isArchived,
  Value<String?> myRole,
  Value<int?> updatedAt,
});
typedef $$RoomsTableUpdateCompanionBuilder = RoomsCompanion Function({
  Value<int> localId,
  Value<int?> serverRoomId,
  Value<RoomType> type,
  Value<String?> title,
  Value<String?> avatarUrl,
  Value<int?> peerUserId,
  Value<int?> groupId,
  Value<int> memberCount,
  Value<int?> lastMessageLocalId,
  Value<String?> lastPreviewText,
  Value<int?> lastPreviewType,
  Value<int?> lastPreviewSenderId,
  Value<int?> lastPreviewServerMessageId,
  Value<String?> lastPreviewStatus,
  Value<int?> lastPreviewState,
  Value<int?> lastPreviewDeleteState,
  Value<int> lastServerSeq,
  Value<int> myLastReadSeq,
  Value<int> unreadCount,
  Value<int?> mutedUntil,
  Value<String?> draftText,
  Value<bool> isArchived,
  Value<String?> myRole,
  Value<int?> updatedAt,
});

final class $$RoomsTableReferences
    extends BaseReferences<_$AppDatabase, $RoomsTable, Room> {
  $$RoomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.messages,
          aliasName:
              $_aliasNameGenerator(db.rooms.localId, db.messages.roomId));

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager($_db, $_db.messages)
        .filter((f) => f.roomId.localId($_item.localId));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ConversationMembersTable,
      List<ConversationMember>> _conversationMembersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.conversationMembers,
          aliasName: $_aliasNameGenerator(
              db.rooms.localId, db.conversationMembers.roomId));

  $$ConversationMembersTableProcessedTableManager get conversationMembersRefs {
    final manager =
        $$ConversationMembersTableTableManager($_db, $_db.conversationMembers)
            .filter((f) => f.roomId.localId($_item.localId));

    final cache =
        $_typedResult.readTableOrNull(_conversationMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverRoomId => $composableBuilder(
      column: $table.serverRoomId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<RoomType, RoomType, int> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get peerUserId => $composableBuilder(
      column: $table.peerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get memberCount => $composableBuilder(
      column: $table.memberCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastMessageLocalId => $composableBuilder(
      column: $table.lastMessageLocalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastPreviewText => $composableBuilder(
      column: $table.lastPreviewText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPreviewType => $composableBuilder(
      column: $table.lastPreviewType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPreviewSenderId => $composableBuilder(
      column: $table.lastPreviewSenderId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPreviewServerMessageId => $composableBuilder(
      column: $table.lastPreviewServerMessageId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastPreviewStatus => $composableBuilder(
      column: $table.lastPreviewStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPreviewState => $composableBuilder(
      column: $table.lastPreviewState,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPreviewDeleteState => $composableBuilder(
      column: $table.lastPreviewDeleteState,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastServerSeq => $composableBuilder(
      column: $table.lastServerSeq, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get myLastReadSeq => $composableBuilder(
      column: $table.myLastReadSeq, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mutedUntil => $composableBuilder(
      column: $table.mutedUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get draftText => $composableBuilder(
      column: $table.draftText, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get myRole => $composableBuilder(
      column: $table.myRole, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> messagesRefs(
      Expression<bool> Function($$MessagesTableFilterComposer f) f) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.localId,
        referencedTable: $db.messages,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MessagesTableFilterComposer(
              $db: $db,
              $table: $db.messages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> conversationMembersRefs(
      Expression<bool> Function($$ConversationMembersTableFilterComposer f) f) {
    final $$ConversationMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.localId,
        referencedTable: $db.conversationMembers,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationMembersTableFilterComposer(
              $db: $db,
              $table: $db.conversationMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverRoomId => $composableBuilder(
      column: $table.serverRoomId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get peerUserId => $composableBuilder(
      column: $table.peerUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get memberCount => $composableBuilder(
      column: $table.memberCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastMessageLocalId => $composableBuilder(
      column: $table.lastMessageLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastPreviewText => $composableBuilder(
      column: $table.lastPreviewText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPreviewType => $composableBuilder(
      column: $table.lastPreviewType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPreviewSenderId => $composableBuilder(
      column: $table.lastPreviewSenderId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPreviewServerMessageId => $composableBuilder(
      column: $table.lastPreviewServerMessageId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastPreviewStatus => $composableBuilder(
      column: $table.lastPreviewStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPreviewState => $composableBuilder(
      column: $table.lastPreviewState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPreviewDeleteState => $composableBuilder(
      column: $table.lastPreviewDeleteState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastServerSeq => $composableBuilder(
      column: $table.lastServerSeq,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get myLastReadSeq => $composableBuilder(
      column: $table.myLastReadSeq,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mutedUntil => $composableBuilder(
      column: $table.mutedUntil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get draftText => $composableBuilder(
      column: $table.draftText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get myRole => $composableBuilder(
      column: $table.myRole, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverRoomId => $composableBuilder(
      column: $table.serverRoomId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RoomType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<int> get peerUserId => $composableBuilder(
      column: $table.peerUserId, builder: (column) => column);

  GeneratedColumn<int> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get memberCount => $composableBuilder(
      column: $table.memberCount, builder: (column) => column);

  GeneratedColumn<int> get lastMessageLocalId => $composableBuilder(
      column: $table.lastMessageLocalId, builder: (column) => column);

  GeneratedColumn<String> get lastPreviewText => $composableBuilder(
      column: $table.lastPreviewText, builder: (column) => column);

  GeneratedColumn<int> get lastPreviewType => $composableBuilder(
      column: $table.lastPreviewType, builder: (column) => column);

  GeneratedColumn<int> get lastPreviewSenderId => $composableBuilder(
      column: $table.lastPreviewSenderId, builder: (column) => column);

  GeneratedColumn<int> get lastPreviewServerMessageId => $composableBuilder(
      column: $table.lastPreviewServerMessageId, builder: (column) => column);

  GeneratedColumn<String> get lastPreviewStatus => $composableBuilder(
      column: $table.lastPreviewStatus, builder: (column) => column);

  GeneratedColumn<int> get lastPreviewState => $composableBuilder(
      column: $table.lastPreviewState, builder: (column) => column);

  GeneratedColumn<int> get lastPreviewDeleteState => $composableBuilder(
      column: $table.lastPreviewDeleteState, builder: (column) => column);

  GeneratedColumn<int> get lastServerSeq => $composableBuilder(
      column: $table.lastServerSeq, builder: (column) => column);

  GeneratedColumn<int> get myLastReadSeq => $composableBuilder(
      column: $table.myLastReadSeq, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => column);

  GeneratedColumn<int> get mutedUntil => $composableBuilder(
      column: $table.mutedUntil, builder: (column) => column);

  GeneratedColumn<String> get draftText =>
      $composableBuilder(column: $table.draftText, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<String> get myRole =>
      $composableBuilder(column: $table.myRole, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> messagesRefs<T extends Object>(
      Expression<T> Function($$MessagesTableAnnotationComposer a) f) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.localId,
        referencedTable: $db.messages,
        getReferencedColumn: (t) => t.roomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MessagesTableAnnotationComposer(
              $db: $db,
              $table: $db.messages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> conversationMembersRefs<T extends Object>(
      Expression<T> Function($$ConversationMembersTableAnnotationComposer a)
          f) {
    final $$ConversationMembersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.localId,
            referencedTable: $db.conversationMembers,
            getReferencedColumn: (t) => t.roomId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ConversationMembersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.conversationMembers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$RoomsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoomsTable,
    Room,
    $$RoomsTableFilterComposer,
    $$RoomsTableOrderingComposer,
    $$RoomsTableAnnotationComposer,
    $$RoomsTableCreateCompanionBuilder,
    $$RoomsTableUpdateCompanionBuilder,
    (Room, $$RoomsTableReferences),
    Room,
    PrefetchHooks Function({bool messagesRefs, bool conversationMembersRefs})> {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<int?> serverRoomId = const Value.absent(),
            Value<RoomType> type = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<int?> peerUserId = const Value.absent(),
            Value<int?> groupId = const Value.absent(),
            Value<int> memberCount = const Value.absent(),
            Value<int?> lastMessageLocalId = const Value.absent(),
            Value<String?> lastPreviewText = const Value.absent(),
            Value<int?> lastPreviewType = const Value.absent(),
            Value<int?> lastPreviewSenderId = const Value.absent(),
            Value<int?> lastPreviewServerMessageId = const Value.absent(),
            Value<String?> lastPreviewStatus = const Value.absent(),
            Value<int?> lastPreviewState = const Value.absent(),
            Value<int?> lastPreviewDeleteState = const Value.absent(),
            Value<int> lastServerSeq = const Value.absent(),
            Value<int> myLastReadSeq = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<int?> mutedUntil = const Value.absent(),
            Value<String?> draftText = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<String?> myRole = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
          }) =>
              RoomsCompanion(
            localId: localId,
            serverRoomId: serverRoomId,
            type: type,
            title: title,
            avatarUrl: avatarUrl,
            peerUserId: peerUserId,
            groupId: groupId,
            memberCount: memberCount,
            lastMessageLocalId: lastMessageLocalId,
            lastPreviewText: lastPreviewText,
            lastPreviewType: lastPreviewType,
            lastPreviewSenderId: lastPreviewSenderId,
            lastPreviewServerMessageId: lastPreviewServerMessageId,
            lastPreviewStatus: lastPreviewStatus,
            lastPreviewState: lastPreviewState,
            lastPreviewDeleteState: lastPreviewDeleteState,
            lastServerSeq: lastServerSeq,
            myLastReadSeq: myLastReadSeq,
            unreadCount: unreadCount,
            mutedUntil: mutedUntil,
            draftText: draftText,
            isArchived: isArchived,
            myRole: myRole,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<int?> serverRoomId = const Value.absent(),
            required RoomType type,
            Value<String?> title = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<int?> peerUserId = const Value.absent(),
            Value<int?> groupId = const Value.absent(),
            Value<int> memberCount = const Value.absent(),
            Value<int?> lastMessageLocalId = const Value.absent(),
            Value<String?> lastPreviewText = const Value.absent(),
            Value<int?> lastPreviewType = const Value.absent(),
            Value<int?> lastPreviewSenderId = const Value.absent(),
            Value<int?> lastPreviewServerMessageId = const Value.absent(),
            Value<String?> lastPreviewStatus = const Value.absent(),
            Value<int?> lastPreviewState = const Value.absent(),
            Value<int?> lastPreviewDeleteState = const Value.absent(),
            Value<int> lastServerSeq = const Value.absent(),
            Value<int> myLastReadSeq = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<int?> mutedUntil = const Value.absent(),
            Value<String?> draftText = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<String?> myRole = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
          }) =>
              RoomsCompanion.insert(
            localId: localId,
            serverRoomId: serverRoomId,
            type: type,
            title: title,
            avatarUrl: avatarUrl,
            peerUserId: peerUserId,
            groupId: groupId,
            memberCount: memberCount,
            lastMessageLocalId: lastMessageLocalId,
            lastPreviewText: lastPreviewText,
            lastPreviewType: lastPreviewType,
            lastPreviewSenderId: lastPreviewSenderId,
            lastPreviewServerMessageId: lastPreviewServerMessageId,
            lastPreviewStatus: lastPreviewStatus,
            lastPreviewState: lastPreviewState,
            lastPreviewDeleteState: lastPreviewDeleteState,
            lastServerSeq: lastServerSeq,
            myLastReadSeq: myLastReadSeq,
            unreadCount: unreadCount,
            mutedUntil: mutedUntil,
            draftText: draftText,
            isArchived: isArchived,
            myRole: myRole,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$RoomsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {messagesRefs = false, conversationMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (messagesRefs) db.messages,
                if (conversationMembersRefs) db.conversationMembers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messagesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$RoomsTableReferences._messagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoomsTableReferences(db, table, p0).messagesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.roomId == item.localId),
                        typedResults: items),
                  if (conversationMembersRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$RoomsTableReferences
                            ._conversationMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoomsTableReferences(db, table, p0)
                                .conversationMembersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.roomId == item.localId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RoomsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoomsTable,
    Room,
    $$RoomsTableFilterComposer,
    $$RoomsTableOrderingComposer,
    $$RoomsTableAnnotationComposer,
    $$RoomsTableCreateCompanionBuilder,
    $$RoomsTableUpdateCompanionBuilder,
    (Room, $$RoomsTableReferences),
    Room,
    PrefetchHooks Function({bool messagesRefs, bool conversationMembersRefs})>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  Value<int> localId,
  required String clientUuid,
  Value<int?> serverMessageId,
  required int roomId,
  Value<int?> serverSeq,
  Value<int?> senderId,
  required MessageKind kind,
  Value<String?> systemEvent,
  required MessageContentType type,
  Value<String?> body,
  Value<String?> replyToClientUuid,
  required int createdAtClient,
  Value<int?> serverCreatedAt,
  required MessageState state,
  Value<MessageDeleteState> deleteState,
  Value<String?> serverStatus,
  Value<String?> reactsJson,
  Value<String?> attachmentJson,
  Value<String?> replyPreviewJson,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<int> localId,
  Value<String> clientUuid,
  Value<int?> serverMessageId,
  Value<int> roomId,
  Value<int?> serverSeq,
  Value<int?> senderId,
  Value<MessageKind> kind,
  Value<String?> systemEvent,
  Value<MessageContentType> type,
  Value<String?> body,
  Value<String?> replyToClientUuid,
  Value<int> createdAtClient,
  Value<int?> serverCreatedAt,
  Value<MessageState> state,
  Value<MessageDeleteState> deleteState,
  Value<String?> serverStatus,
  Value<String?> reactsJson,
  Value<String?> attachmentJson,
  Value<String?> replyPreviewJson,
});

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoomsTable _roomIdTable(_$AppDatabase db) => db.rooms
      .createAlias($_aliasNameGenerator(db.messages.roomId, db.rooms.localId));

  $$RoomsTableProcessedTableManager? get roomId {
    if ($_item.roomId == null) return null;
    final manager = $$RoomsTableTableManager($_db, $_db.rooms)
        .filter((f) => f.localId($_item.roomId!));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverMessageId => $composableBuilder(
      column: $table.serverMessageId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MessageKind, MessageKind, int> get kind =>
      $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get systemEvent => $composableBuilder(
      column: $table.systemEvent, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MessageContentType, MessageContentType, int>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyToClientUuid => $composableBuilder(
      column: $table.replyToClientUuid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAtClient => $composableBuilder(
      column: $table.createdAtClient,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverCreatedAt => $composableBuilder(
      column: $table.serverCreatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MessageState, MessageState, int> get state =>
      $composableBuilder(
          column: $table.state,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<MessageDeleteState, MessageDeleteState, int>
      get deleteState => $composableBuilder(
          column: $table.deleteState,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get serverStatus => $composableBuilder(
      column: $table.serverStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reactsJson => $composableBuilder(
      column: $table.reactsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attachmentJson => $composableBuilder(
      column: $table.attachmentJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyPreviewJson => $composableBuilder(
      column: $table.replyPreviewJson,
      builder: (column) => ColumnFilters(column));

  $$RoomsTableFilterComposer get roomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.localId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableFilterComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverMessageId => $composableBuilder(
      column: $table.serverMessageId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get systemEvent => $composableBuilder(
      column: $table.systemEvent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyToClientUuid => $composableBuilder(
      column: $table.replyToClientUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAtClient => $composableBuilder(
      column: $table.createdAtClient,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverCreatedAt => $composableBuilder(
      column: $table.serverCreatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deleteState => $composableBuilder(
      column: $table.deleteState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverStatus => $composableBuilder(
      column: $table.serverStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reactsJson => $composableBuilder(
      column: $table.reactsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attachmentJson => $composableBuilder(
      column: $table.attachmentJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyPreviewJson => $composableBuilder(
      column: $table.replyPreviewJson,
      builder: (column) => ColumnOrderings(column));

  $$RoomsTableOrderingComposer get roomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.localId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableOrderingComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => column);

  GeneratedColumn<int> get serverMessageId => $composableBuilder(
      column: $table.serverMessageId, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<int> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get systemEvent => $composableBuilder(
      column: $table.systemEvent, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageContentType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get replyToClientUuid => $composableBuilder(
      column: $table.replyToClientUuid, builder: (column) => column);

  GeneratedColumn<int> get createdAtClient => $composableBuilder(
      column: $table.createdAtClient, builder: (column) => column);

  GeneratedColumn<int> get serverCreatedAt => $composableBuilder(
      column: $table.serverCreatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageState, int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageDeleteState, int> get deleteState =>
      $composableBuilder(
          column: $table.deleteState, builder: (column) => column);

  GeneratedColumn<String> get serverStatus => $composableBuilder(
      column: $table.serverStatus, builder: (column) => column);

  GeneratedColumn<String> get reactsJson => $composableBuilder(
      column: $table.reactsJson, builder: (column) => column);

  GeneratedColumn<String> get attachmentJson => $composableBuilder(
      column: $table.attachmentJson, builder: (column) => column);

  GeneratedColumn<String> get replyPreviewJson => $composableBuilder(
      column: $table.replyPreviewJson, builder: (column) => column);

  $$RoomsTableAnnotationComposer get roomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.localId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableAnnotationComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, $$MessagesTableReferences),
    Message,
    PrefetchHooks Function({bool roomId})> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<String> clientUuid = const Value.absent(),
            Value<int?> serverMessageId = const Value.absent(),
            Value<int> roomId = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int?> senderId = const Value.absent(),
            Value<MessageKind> kind = const Value.absent(),
            Value<String?> systemEvent = const Value.absent(),
            Value<MessageContentType> type = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<String?> replyToClientUuid = const Value.absent(),
            Value<int> createdAtClient = const Value.absent(),
            Value<int?> serverCreatedAt = const Value.absent(),
            Value<MessageState> state = const Value.absent(),
            Value<MessageDeleteState> deleteState = const Value.absent(),
            Value<String?> serverStatus = const Value.absent(),
            Value<String?> reactsJson = const Value.absent(),
            Value<String?> attachmentJson = const Value.absent(),
            Value<String?> replyPreviewJson = const Value.absent(),
          }) =>
              MessagesCompanion(
            localId: localId,
            clientUuid: clientUuid,
            serverMessageId: serverMessageId,
            roomId: roomId,
            serverSeq: serverSeq,
            senderId: senderId,
            kind: kind,
            systemEvent: systemEvent,
            type: type,
            body: body,
            replyToClientUuid: replyToClientUuid,
            createdAtClient: createdAtClient,
            serverCreatedAt: serverCreatedAt,
            state: state,
            deleteState: deleteState,
            serverStatus: serverStatus,
            reactsJson: reactsJson,
            attachmentJson: attachmentJson,
            replyPreviewJson: replyPreviewJson,
          ),
          createCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            required String clientUuid,
            Value<int?> serverMessageId = const Value.absent(),
            required int roomId,
            Value<int?> serverSeq = const Value.absent(),
            Value<int?> senderId = const Value.absent(),
            required MessageKind kind,
            Value<String?> systemEvent = const Value.absent(),
            required MessageContentType type,
            Value<String?> body = const Value.absent(),
            Value<String?> replyToClientUuid = const Value.absent(),
            required int createdAtClient,
            Value<int?> serverCreatedAt = const Value.absent(),
            required MessageState state,
            Value<MessageDeleteState> deleteState = const Value.absent(),
            Value<String?> serverStatus = const Value.absent(),
            Value<String?> reactsJson = const Value.absent(),
            Value<String?> attachmentJson = const Value.absent(),
            Value<String?> replyPreviewJson = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            localId: localId,
            clientUuid: clientUuid,
            serverMessageId: serverMessageId,
            roomId: roomId,
            serverSeq: serverSeq,
            senderId: senderId,
            kind: kind,
            systemEvent: systemEvent,
            type: type,
            body: body,
            replyToClientUuid: replyToClientUuid,
            createdAtClient: createdAtClient,
            serverCreatedAt: serverCreatedAt,
            state: state,
            deleteState: deleteState,
            serverStatus: serverStatus,
            reactsJson: reactsJson,
            attachmentJson: attachmentJson,
            replyPreviewJson: replyPreviewJson,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MessagesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({roomId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (roomId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.roomId,
                    referencedTable: $$MessagesTableReferences._roomIdTable(db),
                    referencedColumn:
                        $$MessagesTableReferences._roomIdTable(db).localId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, $$MessagesTableReferences),
    Message,
    PrefetchHooks Function({bool roomId})>;
typedef $$ConversationMembersTableCreateCompanionBuilder
    = ConversationMembersCompanion Function({
  required int roomId,
  required int userId,
  Value<String?> role,
  Value<String?> status,
  Value<int?> joinedSeq,
  Value<int?> removedSeq,
  Value<String?> nameCache,
  Value<String?> avatarCache,
  Value<int> lastReadSeq,
  Value<int> rowid,
});
typedef $$ConversationMembersTableUpdateCompanionBuilder
    = ConversationMembersCompanion Function({
  Value<int> roomId,
  Value<int> userId,
  Value<String?> role,
  Value<String?> status,
  Value<int?> joinedSeq,
  Value<int?> removedSeq,
  Value<String?> nameCache,
  Value<String?> avatarCache,
  Value<int> lastReadSeq,
  Value<int> rowid,
});

final class $$ConversationMembersTableReferences extends BaseReferences<
    _$AppDatabase, $ConversationMembersTable, ConversationMember> {
  $$ConversationMembersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RoomsTable _roomIdTable(_$AppDatabase db) => db.rooms.createAlias(
      $_aliasNameGenerator(db.conversationMembers.roomId, db.rooms.localId));

  $$RoomsTableProcessedTableManager? get roomId {
    if ($_item.roomId == null) return null;
    final manager = $$RoomsTableTableManager($_db, $_db.rooms)
        .filter((f) => f.localId($_item.roomId!));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ConversationMembersTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationMembersTable> {
  $$ConversationMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get joinedSeq => $composableBuilder(
      column: $table.joinedSeq, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get removedSeq => $composableBuilder(
      column: $table.removedSeq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameCache => $composableBuilder(
      column: $table.nameCache, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarCache => $composableBuilder(
      column: $table.avatarCache, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastReadSeq => $composableBuilder(
      column: $table.lastReadSeq, builder: (column) => ColumnFilters(column));

  $$RoomsTableFilterComposer get roomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.localId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableFilterComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ConversationMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationMembersTable> {
  $$ConversationMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get joinedSeq => $composableBuilder(
      column: $table.joinedSeq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get removedSeq => $composableBuilder(
      column: $table.removedSeq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameCache => $composableBuilder(
      column: $table.nameCache, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarCache => $composableBuilder(
      column: $table.avatarCache, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastReadSeq => $composableBuilder(
      column: $table.lastReadSeq, builder: (column) => ColumnOrderings(column));

  $$RoomsTableOrderingComposer get roomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.localId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableOrderingComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ConversationMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationMembersTable> {
  $$ConversationMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get joinedSeq =>
      $composableBuilder(column: $table.joinedSeq, builder: (column) => column);

  GeneratedColumn<int> get removedSeq => $composableBuilder(
      column: $table.removedSeq, builder: (column) => column);

  GeneratedColumn<String> get nameCache =>
      $composableBuilder(column: $table.nameCache, builder: (column) => column);

  GeneratedColumn<String> get avatarCache => $composableBuilder(
      column: $table.avatarCache, builder: (column) => column);

  GeneratedColumn<int> get lastReadSeq => $composableBuilder(
      column: $table.lastReadSeq, builder: (column) => column);

  $$RoomsTableAnnotationComposer get roomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roomId,
        referencedTable: $db.rooms,
        getReferencedColumn: (t) => t.localId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomsTableAnnotationComposer(
              $db: $db,
              $table: $db.rooms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ConversationMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationMembersTable,
    ConversationMember,
    $$ConversationMembersTableFilterComposer,
    $$ConversationMembersTableOrderingComposer,
    $$ConversationMembersTableAnnotationComposer,
    $$ConversationMembersTableCreateCompanionBuilder,
    $$ConversationMembersTableUpdateCompanionBuilder,
    (ConversationMember, $$ConversationMembersTableReferences),
    ConversationMember,
    PrefetchHooks Function({bool roomId})> {
  $$ConversationMembersTableTableManager(
      _$AppDatabase db, $ConversationMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationMembersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationMembersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> roomId = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<int?> joinedSeq = const Value.absent(),
            Value<int?> removedSeq = const Value.absent(),
            Value<String?> nameCache = const Value.absent(),
            Value<String?> avatarCache = const Value.absent(),
            Value<int> lastReadSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationMembersCompanion(
            roomId: roomId,
            userId: userId,
            role: role,
            status: status,
            joinedSeq: joinedSeq,
            removedSeq: removedSeq,
            nameCache: nameCache,
            avatarCache: avatarCache,
            lastReadSeq: lastReadSeq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int roomId,
            required int userId,
            Value<String?> role = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<int?> joinedSeq = const Value.absent(),
            Value<int?> removedSeq = const Value.absent(),
            Value<String?> nameCache = const Value.absent(),
            Value<String?> avatarCache = const Value.absent(),
            Value<int> lastReadSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationMembersCompanion.insert(
            roomId: roomId,
            userId: userId,
            role: role,
            status: status,
            joinedSeq: joinedSeq,
            removedSeq: removedSeq,
            nameCache: nameCache,
            avatarCache: avatarCache,
            lastReadSeq: lastReadSeq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ConversationMembersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({roomId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (roomId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.roomId,
                    referencedTable:
                        $$ConversationMembersTableReferences._roomIdTable(db),
                    referencedColumn: $$ConversationMembersTableReferences
                        ._roomIdTable(db)
                        .localId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ConversationMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConversationMembersTable,
    ConversationMember,
    $$ConversationMembersTableFilterComposer,
    $$ConversationMembersTableOrderingComposer,
    $$ConversationMembersTableAnnotationComposer,
    $$ConversationMembersTableCreateCompanionBuilder,
    $$ConversationMembersTableUpdateCompanionBuilder,
    (ConversationMember, $$ConversationMembersTableReferences),
    ConversationMember,
    PrefetchHooks Function({bool roomId})>;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> localId,
  required OutboxOpType opType,
  required String clientUuid,
  required int roomId,
  required String payloadJson,
  Value<String?> mediaLocalRef,
  Value<int> attempts,
  Value<int?> nextRetryAt,
  Value<String?> lastError,
  required int createdAt,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> localId,
  Value<OutboxOpType> opType,
  Value<String> clientUuid,
  Value<int> roomId,
  Value<String> payloadJson,
  Value<String?> mediaLocalRef,
  Value<int> attempts,
  Value<int?> nextRetryAt,
  Value<String?> lastError,
  Value<int> createdAt,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<OutboxOpType, OutboxOpType, int> get opType =>
      $composableBuilder(
          column: $table.opType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaLocalRef => $composableBuilder(
      column: $table.mediaLocalRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get opType => $composableBuilder(
      column: $table.opType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaLocalRef => $composableBuilder(
      column: $table.mediaLocalRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OutboxOpType, int> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => column);

  GeneratedColumn<int> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get mediaLocalRef => $composableBuilder(
      column: $table.mediaLocalRef, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()> {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<OutboxOpType> opType = const Value.absent(),
            Value<String> clientUuid = const Value.absent(),
            Value<int> roomId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String?> mediaLocalRef = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int?> nextRetryAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              OutboxCompanion(
            localId: localId,
            opType: opType,
            clientUuid: clientUuid,
            roomId: roomId,
            payloadJson: payloadJson,
            mediaLocalRef: mediaLocalRef,
            attempts: attempts,
            nextRetryAt: nextRetryAt,
            lastError: lastError,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            required OutboxOpType opType,
            required String clientUuid,
            required int roomId,
            required String payloadJson,
            Value<String?> mediaLocalRef = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int?> nextRetryAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            required int createdAt,
          }) =>
              OutboxCompanion.insert(
            localId: localId,
            opType: opType,
            clientUuid: clientUuid,
            roomId: roomId,
            payloadJson: payloadJson,
            mediaLocalRef: mediaLocalRef,
            attempts: attempts,
            nextRetryAt: nextRetryAt,
            lastError: lastError,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()>;
typedef $$MediaUploadsTableCreateCompanionBuilder = MediaUploadsCompanion
    Function({
  required String clientUuid,
  required String localPath,
  Value<String?> remoteUrl,
  Value<String?> thumbLocalPath,
  Value<String?> thumbRemoteUrl,
  Value<String?> mime,
  Value<int?> width,
  Value<int?> height,
  Value<int?> durationMs,
  Value<int?> sizeBytes,
  required MediaUploadState uploadState,
  Value<int> bytesSent,
  Value<int> rowid,
});
typedef $$MediaUploadsTableUpdateCompanionBuilder = MediaUploadsCompanion
    Function({
  Value<String> clientUuid,
  Value<String> localPath,
  Value<String?> remoteUrl,
  Value<String?> thumbLocalPath,
  Value<String?> thumbRemoteUrl,
  Value<String?> mime,
  Value<int?> width,
  Value<int?> height,
  Value<int?> durationMs,
  Value<int?> sizeBytes,
  Value<MediaUploadState> uploadState,
  Value<int> bytesSent,
  Value<int> rowid,
});

class $$MediaUploadsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaUploadsTable> {
  $$MediaUploadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbLocalPath => $composableBuilder(
      column: $table.thumbLocalPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbRemoteUrl => $composableBuilder(
      column: $table.thumbRemoteUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mime => $composableBuilder(
      column: $table.mime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MediaUploadState, MediaUploadState, int>
      get uploadState => $composableBuilder(
          column: $table.uploadState,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get bytesSent => $composableBuilder(
      column: $table.bytesSent, builder: (column) => ColumnFilters(column));
}

class $$MediaUploadsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaUploadsTable> {
  $$MediaUploadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbLocalPath => $composableBuilder(
      column: $table.thumbLocalPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbRemoteUrl => $composableBuilder(
      column: $table.thumbRemoteUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mime => $composableBuilder(
      column: $table.mime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get uploadState => $composableBuilder(
      column: $table.uploadState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bytesSent => $composableBuilder(
      column: $table.bytesSent, builder: (column) => ColumnOrderings(column));
}

class $$MediaUploadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaUploadsTable> {
  $$MediaUploadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbLocalPath => $composableBuilder(
      column: $table.thumbLocalPath, builder: (column) => column);

  GeneratedColumn<String> get thumbRemoteUrl => $composableBuilder(
      column: $table.thumbRemoteUrl, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediaUploadState, int> get uploadState =>
      $composableBuilder(
          column: $table.uploadState, builder: (column) => column);

  GeneratedColumn<int> get bytesSent =>
      $composableBuilder(column: $table.bytesSent, builder: (column) => column);
}

class $$MediaUploadsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MediaUploadsTable,
    MediaUpload,
    $$MediaUploadsTableFilterComposer,
    $$MediaUploadsTableOrderingComposer,
    $$MediaUploadsTableAnnotationComposer,
    $$MediaUploadsTableCreateCompanionBuilder,
    $$MediaUploadsTableUpdateCompanionBuilder,
    (
      MediaUpload,
      BaseReferences<_$AppDatabase, $MediaUploadsTable, MediaUpload>
    ),
    MediaUpload,
    PrefetchHooks Function()> {
  $$MediaUploadsTableTableManager(_$AppDatabase db, $MediaUploadsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaUploadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaUploadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaUploadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> clientUuid = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String?> remoteUrl = const Value.absent(),
            Value<String?> thumbLocalPath = const Value.absent(),
            Value<String?> thumbRemoteUrl = const Value.absent(),
            Value<String?> mime = const Value.absent(),
            Value<int?> width = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<int?> durationMs = const Value.absent(),
            Value<int?> sizeBytes = const Value.absent(),
            Value<MediaUploadState> uploadState = const Value.absent(),
            Value<int> bytesSent = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaUploadsCompanion(
            clientUuid: clientUuid,
            localPath: localPath,
            remoteUrl: remoteUrl,
            thumbLocalPath: thumbLocalPath,
            thumbRemoteUrl: thumbRemoteUrl,
            mime: mime,
            width: width,
            height: height,
            durationMs: durationMs,
            sizeBytes: sizeBytes,
            uploadState: uploadState,
            bytesSent: bytesSent,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String clientUuid,
            required String localPath,
            Value<String?> remoteUrl = const Value.absent(),
            Value<String?> thumbLocalPath = const Value.absent(),
            Value<String?> thumbRemoteUrl = const Value.absent(),
            Value<String?> mime = const Value.absent(),
            Value<int?> width = const Value.absent(),
            Value<int?> height = const Value.absent(),
            Value<int?> durationMs = const Value.absent(),
            Value<int?> sizeBytes = const Value.absent(),
            required MediaUploadState uploadState,
            Value<int> bytesSent = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaUploadsCompanion.insert(
            clientUuid: clientUuid,
            localPath: localPath,
            remoteUrl: remoteUrl,
            thumbLocalPath: thumbLocalPath,
            thumbRemoteUrl: thumbRemoteUrl,
            mime: mime,
            width: width,
            height: height,
            durationMs: durationMs,
            sizeBytes: sizeBytes,
            uploadState: uploadState,
            bytesSent: bytesSent,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MediaUploadsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MediaUploadsTable,
    MediaUpload,
    $$MediaUploadsTableFilterComposer,
    $$MediaUploadsTableOrderingComposer,
    $$MediaUploadsTableAnnotationComposer,
    $$MediaUploadsTableCreateCompanionBuilder,
    $$MediaUploadsTableUpdateCompanionBuilder,
    (
      MediaUpload,
      BaseReferences<_$AppDatabase, $MediaUploadsTable, MediaUpload>
    ),
    MediaUpload,
    PrefetchHooks Function()>;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  Value<int> roomId,
  Value<int> lastKnownSeq,
  Value<String?> epoch,
  Value<int?> lastSyncedAt,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<int> roomId,
  Value<int> lastKnownSeq,
  Value<String?> epoch,
  Value<int?> lastSyncedAt,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastKnownSeq => $composableBuilder(
      column: $table.lastKnownSeq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get epoch => $composableBuilder(
      column: $table.epoch, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastKnownSeq => $composableBuilder(
      column: $table.lastKnownSeq,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get epoch => $composableBuilder(
      column: $table.epoch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<int> get lastKnownSeq => $composableBuilder(
      column: $table.lastKnownSeq, builder: (column) => column);

  GeneratedColumn<String> get epoch =>
      $composableBuilder(column: $table.epoch, builder: (column) => column);

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$SyncStateTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncStateTable,
    SyncStateData,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableAnnotationComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (
      SyncStateData,
      BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>
    ),
    SyncStateData,
    PrefetchHooks Function()> {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> roomId = const Value.absent(),
            Value<int> lastKnownSeq = const Value.absent(),
            Value<String?> epoch = const Value.absent(),
            Value<int?> lastSyncedAt = const Value.absent(),
          }) =>
              SyncStateCompanion(
            roomId: roomId,
            lastKnownSeq: lastKnownSeq,
            epoch: epoch,
            lastSyncedAt: lastSyncedAt,
          ),
          createCompanionCallback: ({
            Value<int> roomId = const Value.absent(),
            Value<int> lastKnownSeq = const Value.absent(),
            Value<String?> epoch = const Value.absent(),
            Value<int?> lastSyncedAt = const Value.absent(),
          }) =>
              SyncStateCompanion.insert(
            roomId: roomId,
            lastKnownSeq: lastKnownSeq,
            epoch: epoch,
            lastSyncedAt: lastSyncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStateTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncStateTable,
    SyncStateData,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableAnnotationComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (
      SyncStateData,
      BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>
    ),
    SyncStateData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ConversationMembersTableTableManager get conversationMembers =>
      $$ConversationMembersTableTableManager(_db, _db.conversationMembers);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$MediaUploadsTableTableManager get mediaUploads =>
      $$MediaUploadsTableTableManager(_db, _db.mediaUploads);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
}

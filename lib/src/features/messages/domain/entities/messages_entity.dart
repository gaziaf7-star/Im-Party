import 'dart:io';

import 'package:general/src/core/index.dart';

class MessagesEntity extends Equatable {
  final int? id;
  final String? clientUuid;
  final int? userId;
  final int? chatId;
  final String? status;
  final String? type;
  final String? message;
  final String? createdAt;
  final bool? senderDeleted;
  final bool? receiverDeleted;
  final AlbumsEntity? albums;
  final List<ReactEntity>? reacts;
  final ReplayEntity? replay;
  final MessageState messageState;

  const MessagesEntity({
    this.id,
    this.clientUuid,
    this.userId,
    this.chatId,
    this.status,
    this.type,
    this.message,
    this.createdAt,
    this.senderDeleted,
    this.receiverDeleted,
    this.albums,
    this.reacts,
    this.replay,
    this.messageState = MessageState.loading,
  });

  @override
  List<Object?> get props => [
        id,
        clientUuid,
        userId,
        chatId,
        status,
        type,
        message,
        createdAt,
        senderDeleted,
        receiverDeleted,
        albums,
        reacts,
        replay,
        messageState,
      ];

  /*  MessagesEntity copyWithMessageEntity(MessagesEntity other) {
    return MessagesEntity(
      messageState: other.messageState,
      id: other.id ?? id,
      userId: other.userId ?? userId,
      status: other.status ?? status,
      type: other.type ?? type,
      message: other.message ?? message,
      createdAt: other.createdAt ?? createdAt,
      senderDeleted: other.senderDeleted ?? senderDeleted,
      receiverDeleted: other.receiverDeleted ?? receiverDeleted,
      albums: other.albums != null
          ? other.albums!.copyWith(
              id: albums!.id ?? id,
              userId: albums!.userId ?? userId,
              file: albums!.file ?? albums!.file,
              type: albums!.type ?? type,
            )
          : albums,
      reacts: other.reacts ?? reacts,
      replay: other.replay ??
          replay?.copyWith(
            messageId: replay!.messageId ?? replay!.messageId,
            messageUserId: replay!.messageUserId ?? replay!.messageUserId,
            message: replay!.message ?? replay!.message,
            messageType: replay!.messageType ?? replay!.messageType,
            page: replay!.page ?? replay!.page,
            albums: replay!.albums,
          ),
    );
  }
 */
  MessagesEntity copyWith({
    int? id,
    String? clientUuid,
    int? userId,
    String? status,
    String? type,
    String? message,
    String? createdAt,
    bool? senderDeleted,
    bool? receiverDeleted,
    AlbumsEntity? albums,
    List<ReactEntity>? reacts,
    ReplayEntity? replay,
    MessageState? messageState,
  }) {
    return MessagesEntity(
      messageState: messageState ?? this.messageState,
      id: id ?? this.id,
      clientUuid: clientUuid ?? this.clientUuid,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      type: type ?? this.type,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      senderDeleted: senderDeleted ?? this.senderDeleted,
      receiverDeleted: receiverDeleted ?? this.receiverDeleted,
      albums: albums ??
          this.albums?.copyWith(
                id: albums?.id ?? this.albums?.id,
                userId: albums?.userId ?? this.albums?.userId,
                file: albums?.file ?? this.albums?.file,
                type: albums?.type ?? this.albums?.type,
                isLocal: albums?.isLocal ?? this.albums?.isLocal,
              ),
      reacts: reacts ?? this.reacts,
      replay: replay ??
          this.replay?.copyWith(
                messageId: replay?.messageId ?? this.replay?.messageId,
                messageUserId:
                    replay?.messageUserId ?? this.replay?.messageUserId,
                message: replay?.message ?? this.replay?.message,
                messageType: replay?.messageType ?? this.replay?.messageType,
                page: replay?.page ?? this.replay?.page,
                albums: this.replay?.albums,
              ),
    );
  }
}

// AlbumsEntity
class AlbumsEntity extends Equatable {
  final int? id;
  final int? userId;
  final String? file;
  final String? type;
  final String? firstFrame;
  final bool isLocal;
  final File? firstFrameFile;
  final String? duration;
  final File? videoFile;

  const AlbumsEntity({
    this.id,
    this.userId,
    this.file,
    this.type,
    this.firstFrame,
    this.isLocal = false,
    this.firstFrameFile,
    this.duration = '',
    this.videoFile,
  });

  AlbumsEntity copyWith({
    int? id,
    int? userId,
    String? file,
    String? type,
    String? firstFrame,
    bool? isLocal,
    String? duration,
    File? firstFrameFile,
    File? videoFile,
  }) {
    return AlbumsEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      file: file ?? this.file,
      type: type ?? this.type,
      firstFrame: firstFrame ?? this.firstFrame,
      isLocal: isLocal ?? this.isLocal,
      duration: duration ?? this.duration,
      firstFrameFile: firstFrameFile ?? this.firstFrameFile,
      videoFile: videoFile ?? this.videoFile,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        file,
        type,
        firstFrame,
        isLocal,
        firstFrameFile,
        duration,
        videoFile
      ];
}

// ReactEntity
class ReactEntity extends Equatable {
  final int? id;
  final UserReactEntity? userReact;
  final String react;

  const ReactEntity({
    this.id,
    this.userReact,
    required this.react,
  });

  ReactEntity copyWith({
    int? id,
    String? react,
  }) {
    return ReactEntity(
      id: id ?? this.id,
      userReact: userReact,
      react: react ?? this.react,
    );
  }

  @override
  List<Object?> get props => [id, userReact, react];
}

// UserReactEntity
class UserReactEntity extends Equatable {
  final int userId;
  final String userName;
  final String userImage;
  final bool? hasColorName;

  const UserReactEntity({
    required this.userId,
    required this.userName,
    required this.userImage,
    this.hasColorName,
  });

  @override
  List<Object?> get props => [userId, userName, userImage, hasColorName];
}

// ReplayEntity
class ReplayEntity extends Equatable {
  final int? messageId;
  final int? messageUserId;
  final String? message;
  final String? messageType;
  final AlbumsEntity? albums;
  final int? page;

  const ReplayEntity({
    this.messageId,
    this.messageUserId,
    this.message,
    this.messageType,
    this.albums,
    this.page,
  });

  @override
  List<Object?> get props => [
        messageId,
        messageUserId,
        message,
        messageType,
        albums,
        page,
      ];

  ReplayEntity copyWith({
    int? messageId,
    int? messageUserId,
    String? message,
    String? messageType,
    int? page,
    AlbumsEntity? albums,
  }) {
    return ReplayEntity(
      messageId: messageId ?? this.messageId,
      messageUserId: messageUserId ?? this.messageUserId,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      page: page ?? this.page,
      albums: albums ?? this.albums,
    );
  }
}

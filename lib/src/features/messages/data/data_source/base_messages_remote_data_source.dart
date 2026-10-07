import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';
import 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';
import 'package:mime/mime.dart';

abstract class BaseMessagesRemoteDataSource {
  Future<BaseResponse<bool>> blockUnblockUser({required String userId});

  Future<BaseResponse<String>> sendChatNotification({
    required NotificationParameterUC param,
  });

  Future<BaseResponse<String>> sendMessageAll(SendMessageAllPram pram);

  Future<BaseResponse<MessagesModel>> updateMessage({
    required UpdateMessageUC param,
  });

  Future<BaseResponse<String>> deleteMessage({
    required DeleteMessageParamsUC param,
  });

  Future<BaseResponse<String>> pinChatToTop({
    required PinChatToTopParamsUC param,
  });

  Future<BaseResponse<String>> removePinChatToTop({required String userId});

  Future<BaseResponse<ConversationModel>> fetchMessages({
    required FetchMessagesParamsUC param,
  });

  Future<MessagesModel> makeReact({required MakeReactParamsUC param});

  Future<void> closeChat({required int chatId});

  Future<UserStatusEntity> onlineUser({required String userId});

  Future<Map<String, String>> getPreSignedUrl(SendVideoParam param);

  Future<int> uploadFileToStorage(
    SendVideoParam param,
  );
}

class MessagesRemoteDataSourceImp extends BaseMessagesRemoteDataSource {
  static String massagePrice = "";

  final DioFactory _dio;

  MessagesRemoteDataSourceImp(this._dio);

  @override
  Future<BaseResponse<bool>> blockUnblockUser({required userId}) async {
    final response = await _dio.get(
      EndPoints.blockUnblock(userId),
    );
    bool jsonData = response.data['data']['is_blocked'];

    return BaseResponse<bool>.fromJson(
      response.data,
      fromJsonT: (json) => jsonData,
    );
  }

  @override
  Future<BaseResponse<String>> sendChatNotification({required param}) async {
    final response = await _dio.post(
      EndPoints.sendNotificationChat,
      data: {
        "reciver_id": param.userId,
        "content": param.body,
        "media": param.image
      },
    );

    return BaseResponse<String>.fromJson(response.data,
        fromJsonT: (json) => json['message']);
  }

  @override
  Future<BaseResponse<ConversationModel>> fetchMessages(
      {required param}) async {
    Map<String, dynamic> body = {'user_id': param.userId, "page": param.page};
    final timeZone = await Methods().getCurrentTimeZone();

    final response = await _dio.post(
      EndPoints.oneUserChat,
      headers: {'tz': timeZone},
      data: body,
    );

    return BaseResponse<ConversationModel>.fromJson(response.data,
        fromJsonT: (json) => ConversationModel.fromJson(json));
  }

  @override
  Future<MessagesModel> makeReact({required param}) async {
    Map<String, dynamic> body = {
      'message_id': param.messageId,
      'react': param.react,
    };

    final response = await _dio.post(EndPoints.makeReact, data: body);
    Methods.printLog(response.data['message'].toString());

    return MessagesModel.fromJson(response.data['message']);
  }

  @override
  Future<BaseResponse<String>> sendMessageAll(SendMessageAllPram pram) async {
    FormData data_;
    data_ = FormData.fromMap({
      "message": pram.message,
      "type": pram.type,
      "image_url": pram.url,
      "except_ids": pram.exceptUsers,
      "users": pram.users,
    });

    final timeZone = await Methods().getCurrentTimeZone();
    final response = await _dio.post(
      EndPoints.sendMessageAll,
      headers: {'tz': timeZone},
      data: data_,
    );
    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<String>.fromJson(
      response.data,
      fromJsonT: (json) => jsonData["data"],
    );
  }

  @override
  Future<BaseResponse<MessagesModel>> updateMessage({required param}) async {
    Map body = {
      "message_id": param.messageId,
      "message": param.message,
      "_method": 'PATCH'
    };
    final response =
        await _dio.post(EndPoints.updateMessage(param.messageId), data: body);
    Map<String, dynamic> jsonData = response.data;
    Methods.printLog(response.data.toString());
    return BaseResponse<MessagesModel>.fromJson(
      response.data,
      fromJsonT: (json) => MessagesModel.fromJson(jsonData["data"]),
    );
  }

  @override
  Future<BaseResponse<String>> deleteMessage({required param}) async {
    final formData = FormData();
    for (var i = 0; i < param.messageIds.length; i++) {
      formData.fields.add(MapEntry('id[]', param.messageIds[i].toString()));
    }
    final response = await _dio.post(EndPoints.deleteMessage(param.deleteType),
        data: formData);

    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<String>.fromJson(
      response.data,
      fromJsonT: (json) => jsonData["data"],
    );
  }

  @override
  Future<BaseResponse<String>> pinChatToTop({required param}) async {
    Map body = {
      "user_id": param.userId,
      "chat_id": param.chatId,
    };
    final response = await _dio.post(EndPoints.pinToTop, data: body);

    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<String>.fromJson(
      response.data,
      fromJsonT: (json) => jsonData["data"],
    );
  }

  @override
  Future<BaseResponse<String>> removePinChatToTop({required userId}) async {
    final response = await _dio.delete(
      EndPoints.removePinToTop(userId),
    );

    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<String>.fromJson(
      response.data,
      fromJsonT: (json) => jsonData["data"],
    );
  }

  @override
  Future<void> closeChat({required chatId}) async {
    await _dio.get(
      EndPoints.closeChat,
    );
  }

  // user-status is cached for 10 s (the server sends max-age=10) and
  // simultaneous calls for the same user share one request.
  static final Map<String, ({UserStatusEntity status, DateTime at})>
      _statusCache = {};
  static final Map<String, Future<UserStatusEntity>> _statusInFlight = {};

  @override
  Future<UserStatusEntity> onlineUser({required userId}) {
    final key = userId.toString();
    final cached = _statusCache[key];
    if (cached != null &&
        DateTime.now().difference(cached.at).inSeconds < 10) {
      return Future.value(cached.status);
    }
    return _statusInFlight[key] ??= _fetchUserStatus(userId).whenComplete(
      () => _statusInFlight.remove(key),
    );
  }

  Future<UserStatusEntity> _fetchUserStatus(dynamic userId) async {
    final response = await _dio.get(
      EndPoints.userOnline(userId),
    );

    Map<String, dynamic> jsonData = response.data;
    // Newer server shape: {status, data:{user_id, online, last_seen_at}};
    // older shape had the fields at the top level. Accept both.
    final inner = jsonData['data'];
    if (inner is Map) {
      jsonData = Map<String, dynamic>.from(inner);
    }

    final raw = jsonData['online'];
    final status = UserStatusEntity(
      online: raw is int
          ? raw
          : (raw == true ? 1 : (int.tryParse('$raw') ?? 0)),
      lastSeen: jsonData['last_seen_at']?.toString(),
    );
    _statusCache['$userId'] = (status: status, at: DateTime.now());
    return status;
  }

  @override
  Future<Map<String, String>> getPreSignedUrl(SendVideoParam param) async {
    final fileName = param.video!.path
        .split('/')
        .last
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final int fileSize = param.video!.lengthSync();

    final String fileType =
        lookupMimeType(param.video!.path) ?? 'application/octet-stream';

    final response = await _dio.post(
      EndPoints.generateUploadChatVideoLink,
      data: {
        "name": fileName,
        "type": fileType,
        "size": fileSize,
        "folder": "chat",
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to generate pre-signed URL');
    }

    return {
      'upload_url': response.data['upload_url'],
      'name': response.data['name'],
    };
  }

  @override
  Future<int> uploadFileToStorage(
    SendVideoParam param,
  ) async {
    final File reel = param.video!;
    final String fileType =
        lookupMimeType(reel.path) ?? 'application/octet-stream';
    final int fileSize = reel.lengthSync();
    final fileStream = reel.openRead();

    // The pre-signed URL carries its own signature: use a clean client so the
    // app's interceptors never add `Authorization` / device headers, and give
    // large videos a long timeout (the link is valid for 30 minutes).
    final putDio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(minutes: 10),
      receiveTimeout: const Duration(minutes: 10),
      responseType: ResponseType.plain,
    ));

    final response = await putDio.put(
      param.preSignedUrl!,
      data: fileStream,
      options: Options(headers: {
        'Content-Type': fileType,
        'Content-Length': fileSize.toString(),
      }, method: 'PUT'),
      onSendProgress: (int sent, int total) =>
          _notifyVideoProgress(sent, total, param.videoProgressId),
    );
    return response.statusCode ?? 500;
  }

  // ── shared upload-progress helper (#83) ────────────────────────────────────

  static void _notifyVideoProgress(
      int sent, int total, String? videoProgressId) {
    if (total <= 0) return;
    final pct = sent / total * 100;
    if (pct > 50) {
      final key =
          MessageVideoWidgetState.currentTime[videoProgressId] ?? 0;
      MessageVideoWidgetState.videoProgressNotifier.value[key] = pct / 100;
      MessageVideoWidgetState.videoProgressNotifier.notifyListeners();
    }
  }
}

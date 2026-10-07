import 'dart:developer';
import 'dart:io';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/room/data/model/gift_category_model.dart';
import 'package:general/src/features/room/data/model/reaction_model.dart';
import 'package:general/src/features/room/data/model/send_gift_model.dart';
import 'package:general/src/features/room/room.dart';
import 'package:mime/mime.dart';
import '../../../../core/services/notification/notification_service.dart';
import '../model/extra_profile_data_model.dart';
import '../model/get_games_images_model.dart';

abstract class BaseRoomRemoteDataSource {
  Future<BaseResponse<EnterRoomModel>> enterRoom({
    required String roomId,
    String? roomPassword,
    bool? ignorePassword,
    bool? sendToZego,
  });

  Future<BaseResponse<SendGiftModel>> sendGifts(GiftParameter params);

  Future<BaseResponse<List<GiftsModel>>> fetchGifts(int type);

  Future<BaseResponse<SvgaDataModel>> fetchGamesImages(int type);

  Future<BaseResponse<List<GiftsModel>>> getUserGift();

  Future<BaseResponse<List<String>>> getGiftImages();

  Future<BaseResponse<GetConfigKeyModel>> fetchConfigKey(
      GetConfigKeyPram? params);

  Future<List<RoomVisitorModel>> fetchRoomUser(GetAllUserPram params);

  Future<BaseResponse<String>> startPK(StartPKParameter parameter);

  Future<BaseResponse<String>> showPK(String roomId);

  Future<BaseResponse<String>> hidePK(String roomId);

  Future<BaseResponse<String>> blockComments(BlockCommentsParameter param);

  Future<BaseResponse<String>> closePK(ClosePKParameter params);

  Future<BaseResponse<List<EmojiModel>>> fetchEmoji(String categoryId);

  Future<List<BackgroundModel>> fetchBackGround();

  Future<BaseResponse<LuckyGiftModel>> sendLuckyGift(GiftParameter params);

  Future<BaseResponse<EnterRoomModel>> updateRoom({
    required ParameterUpdate parameterUpdate,
  });

  Future<BaseResponse<UserModel>> fetchUserData({
    required String userId,
    bool? isVisit,
  });

  Future<BaseResponse<RankingModel>> fetchTopInRoom(
      TopParameterInRoom params,
      );

  Future<BaseResponse<CloseEffectModel>> clearMode(String key);

  Future<String> changeRoomMode({required String roomId, required int mode});

  Future<String> lockComments(LockCommentsParameter params);

  Future<String> unLockComments(LockCommentsParameter params);

  Future<String> removePasswordRoom(String roomId);

  /// Host explicitly ends their live broadcast (immediate delisting).
  Future<RoomSessionSummaryModel?> endLive({String? roomId});

  Future<String> addAdminRoom(AddAdminParameter param);

  Future<String> removeAdmin(RemoveAdminParameter params);

  /// The room's PERSISTED admin list from the app backend (`rooms/admins`,
  /// backed by the dual-written room_administrators) — survives broadcast
  /// restarts, unlike the engine's session-scoped `list-by-role`.
  /// Upload one picture for a party-room chat message and return its URL.
  Future<String> uploadRoomChatImage(File image);

  /// Persist the party room's view mode.
  ///
  /// `free_mic = 1` means only the owner or a room admin may seat someone --
  /// the server-side half of view mode, enforced in up_microphone. The kit's
  /// seat mode is the client-side half and is set separately.
  Future<void> updateRoomViewMode({
    required String roomId,
    required int freeMic,
  });

  Future<List<UserModel>> adminsRoom(
      {required String ownerId, required String roomId});

  Future<String> openGame(int id);

  Future<String> addRoomBackGround(File roomBackGround);

  Future<List<BackgroundModel>> getMyBackGround();

  Future<BaseResponse<BackgroundSettingModel>> getMyBackGroundSetting();

  Future<BaseResponse<Map<String, dynamic>>> startCharisma(String roomId);

  Future<BaseResponse<Map<String, dynamic>>> resetCharisma(
      {required String roomId, required String ownerId});

  Future<BaseResponse<List<CharismaModel>>> getCharismaExtraData(String roomId);

  Future<List<CharismaLevelModel>> getCharismaLevels();

  Future<BaseResponse<String>> deleteSong(int songId);

  Future<BaseResponse<String>> sendYallowBanner(String roomId, String message);

  Future<BaseResponse<bool>> checkAdminOwner(CheckAdminOwnerParam param);

  Future<BaseResponse<ExtraProfileDataModel>> fetchExtraProfileData(
      String userId);

  Future<BaseResponse<List<BubblePadding>>> fetchBubblePadding();

  Future<BaseResponse<LuckyBoxModel>> getLuckyBoxes();

  Future<BaseResponse<SendLuckyBoxModel>> sendLuckyBox(LuckyBoxParam params);

  Future<BaseResponse<PickUpLuckyBoxModel>> pickUpLuckyBox(String boxId);

  Future<BaseResponse<CreatePaidRoomModel>> getCreatePaidRoom();

  Future<BaseResponse<FreeGamesModel>> getFreeGamesImages();

  Future<BaseResponse<SuperBombModel>> getSuperBomb({required String roomId});

  Future<BaseResponse<SuberBoomVideoseModel>> getSuperBombVideos();

  Future<BaseResponse<BombRulesResponse>> getSuperBombRules();

  Future<BaseResponse<RoomBoomThemeModel>> getRoomBoomThemes();

  Future<Map<String, String>> getPreSignedUrl(File reel);

  Future<int> uploadFileToStorage(UploadSongParam param);

  Future<BaseResponse<String>> notifyBackend(UploadSongParam param);

  Future<BaseResponse<List<MusicModel>>> getMusic();

  Future<BaseResponse<List<MusicModel>>> getMyMusic();

  Future<BaseResponse<String>> getRoomActivityWebViewLink();

  Future<BaseResponse<RoomRewardModel>> getRoomActivity(int roomId);

  Future<BaseResponse<List<GiftCategoryModel>>> fetchGiftCategory();
  Future<BaseResponse<List<ReactionModel>>> fetchEmojisCategory();

  Future<BaseResponse<List<UserModel>>> fetchUsersData({
    required List<String> userIds,
  });

  Future<BaseResponse<List<String>>> fetchBadWords();
}

class RoomRemoteDataSourceImp implements BaseRoomRemoteDataSource {
  final DioFactory _dio;

  RoomRemoteDataSourceImp(this._dio);

  @override
  Future<String> changeRoomMode({
    required String roomId,
    required int mode,
  }) async {
    // `room_id` is always sent: without it the endpoint resolves the caller's
    // AUDIO room by owner, which would silently re-layout the wrong room.
    final body = {'room_id': roomId, 'mode': mode};

    try {
      final response = await _dio.post(EndPoints.changeRoomMode, data: body);

      return (response.data['message'] ?? '').toString();
    } on DioException catch (e) {
      // Fired from inside the live room, this call routinely lands on a pooled
      // socket the network has already dropped: nothing reaches the server, and
      // Android only reports it ~21s later as "connection reset by peer". A
      // second attempt opens a fresh connection and succeeds.
      //
      // Safe to repeat — setting a room's mode is idempotent — and ONLY for
      // transport failures. A refusal the server actually sent (403, 404, 422)
      // is rethrown untouched, because retrying it would just fail twice.
      if (!_isTransportFailure(e)) rethrow;

      final response = await _dio.post(EndPoints.changeRoomMode, data: body);

      return (response.data['message'] ?? '').toString();
    }
  }

  /// Whether this failure happened below HTTP — no response was ever received,
  /// so the request may never have reached the server at all.
  bool _isTransportFailure(DioException e) {
    if (e.response != null) return false;

    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.unknown;
  }

  @override
  Future<BaseResponse<CloseEffectModel>> clearMode(String key) async {
    final response = await _dio.post(
      EndPoints.clearMode,
      data: {"key": key},
    );

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => CloseEffectModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<EnterRoomModel>> enterRoom({
    required String roomId,
    String? roomPassword,
    bool? ignorePassword,
    bool? sendToZego,
  }) async {
    final Map<String, dynamic> body = {
      "room_pass": roomPassword,
      "room_id": roomId,
    };
    final response = await _dio.post(
      EndPoints.enterRoom,
      data: body,
    );
    return BaseResponse.fromJson(response.data,
        fromJsonT: (json) => EnterRoomModel.fromJson(json));
  }

  @override
  Future<BaseResponse<SendGiftModel>> sendGifts(GiftParameter params) async {
    String toUid = params.toUid;
    List<String> uniqueList = toUid.split(',').toSet().toList();
    String uniqueToUid = uniqueList.join(',');
    final body = {
      'room_id': params.roomId,
      'id': params.id,
      'toUid': uniqueToUid,
      'num': params.num,
      'to_zego': params.toZego,
      'type': params.giftType,
    };
    final response = await _dio.post(
      EndPoints.sendGift,
      data: body,
    );

    final result = SendGiftModel.fromJson(response.data);

    return BaseResponse.fromJson(response.data, fromJsonT: (json) => result);
  }

  @override
  Future<BaseResponse<List<GiftsModel>>> fetchGifts(int type) async {
    // Cache ONLY the static gift catalog (positive category type). Types -1 and
    // 11 are the per-user bag/backpack: owned gifts with MUTABLE quantity that
    // changes on send/receive, so they must never be cached (pass no
    // cacheDuration -> falls to the global noCache default).
    final response = await _dio.get(
      EndPoints.getGifts(type),
      cacheDuration:
      (type > 0 && type != 11) ? const Duration(minutes: 30) : null,
    );

    final giftsModelList = BaseResponse<List<GiftsModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>).map((element) {
        return GiftsModel.fromJson(element);
      }).toList(),
    );

    return Future.value(giftsModelList);
  }

  @override
  Future<BaseResponse<List<GiftsModel>>> getUserGift() async {
    // Per-user owned inventory (mutable quantity) — never cached.
    final response = await _dio.get(
      EndPoints.getUserGift,
    );

    final giftsModelList = BaseResponse<List<GiftsModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => GiftsModel.fromJson(element))
          .toList(),
    );

    return Future.value(giftsModelList);
  }

  @override
  Future<BaseResponse<List<String>>> getGiftImages() async {
    final response = await _dio.get(
      EndPoints.getGiftImages,
      cacheDuration: const Duration(hours: 1),
    );

    final giftsModelList = BaseResponse<List<String>>.fromJson(
      response.data,
      fromJsonT: (json) =>
          (json as List<dynamic>).map((element) => element.toString()).toList(),
    );

    return Future.value(giftsModelList);
  }

  @override
  Future<BaseResponse<GetConfigKeyModel>> fetchConfigKey(
      GetConfigKeyPram? getConfigKeyPram) async {
    try {
      final Map<String, dynamic> body;

      if (getConfigKeyPram == null) {
        body = {'keys': [], "enable-special": 1};
      } else {
        body = {
          'keys': [getConfigKeyPram.specialBar],
          "enable-special": 1
        };
      }

      final response = await _dio.post(
        EndPoints.getConfigKey,
        data: body,
      );

      final result = GetConfigKeyModel.fromJson(response.data['data']);

      return BaseResponse.fromJson(response.data, fromJsonT: (json) => result);
    } catch (error) {
      throw NetworkExceptions.getDioException(error);
    }
  }

  @override
  Future<List<RoomVisitorModel>> fetchRoomUser(GetAllUserPram pram) async {
    final response = await _dio.post(
      EndPoints.getRoomUsers,
      data: {"owner_id": pram.ownerId, "users": pram.usersId![0]},
    );

    Map<String, dynamic> resultData = response.data;

    return List<RoomVisitorModel>.from(
        resultData['data'].map((x) => RoomVisitorModel.fromJson(x)));
  }

  @override
  Future<BaseResponse<String>> showPK(String roomId) async {
    final body = {
      'room_id': roomId,
    };

    final response = await _dio.post(
      EndPoints.showPk,
      data: body,
    );

    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<String>.fromJson(
      response.data,
      fromJsonT: (json) => jsonData["message"] ?? "",
    );
  }

  @override
  Future<BaseResponse<String>> startPK(StartPKParameter parameter) async {
    final body = {'room_id': parameter.roomId, 'minutes': parameter.time};

    final response = await _dio.post(
      EndPoints.startPk,
      data: body,
    );

    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<String>.fromJson(
      response.data,
      fromJsonT: (json) => jsonData['data']['pk_id'].toString(),
    );
  }

  @override
  Future<BaseResponse<String>> closePK(ClosePKParameter parameter) async {
    final body = {'room_id': parameter.roomId, 'pk_id': parameter.pkId};

    final response = await _dio.post(
      EndPoints.closePk,
      data: body,
    );

    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<String>.fromJson(
      response.data,
      fromJsonT: (json) => jsonData["message"] ?? "",
    );
  }

///////

  @override
  Future<BaseResponse<String>> blockComments(
      BlockCommentsParameter param) async {
    final response = await _dio.post(
      EndPoints.blockComments(param.roomId, param.value),
    );

    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<String>.fromJson(
      response.data,
      fromJsonT: (json) => jsonData["message"] ?? "",
    );
  }

/////

  @override
  Future<BaseResponse<String>> hidePK(String roomId) async {
    final body = {
      'room_id': roomId,
    };

    final response = await _dio.post(
      EndPoints.hidePK,
      data: body,
    );

    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<String>.fromJson(
      response.data,
      fromJsonT: (json) => jsonData["message"] ?? "",
    );
  }

  @override
  Future<BaseResponse<List<EmojiModel>>> fetchEmoji(categoryId) async {
    final response = await _dio.get(
      EndPoints.getEmojie(categoryId),
    );

    final usersList = BaseResponse<List<EmojiModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => EmojiModel.fromJson(element))
          .toList(),
    );

    return Future.value(usersList);
  }

  @override
  Future<List<BackgroundModel>> fetchBackGround() async {
    final response = await _dio.get(
      EndPoints.getBcakground,
    );

    return List<BackgroundModel>.from((response.data["data"] as List)
        .map((e) => BackgroundModel.fromJson(e)));
  }

  @override
  Future<BaseResponse<LuckyGiftModel>> sendLuckyGift(
      GiftParameter giftParameter) async {
    final body = {
      'room_id': giftParameter.roomId,
      'id': giftParameter.id,
      'toUid': giftParameter.toUid,
      'num': giftParameter.num,
      "count": giftParameter.count,
      // Per-request idempotency nonce (backend dedups retries on it).
      if (giftParameter.nonce != null) 'nonce': giftParameter.nonce,
    };

    final response = await _dio.post(
      EndPoints.sendLuckyGift,
      data: body,
    );

    final LuckyGiftModel roomData =
    LuckyGiftModel.fromJson(response.data['data']);

    return BaseResponse.fromJson(response.data, fromJsonT: (json) => roomData);
  }

  @override
  Future<BaseResponse<EnterRoomModel>> updateRoom(
      {required ParameterUpdate parameterUpdate}) async {
    FormData formData;
    if (parameterUpdate.roomCover == null) {
      formData = FormData.fromMap({
        'room_name': parameterUpdate.roomName,
        'free_mic': parameterUpdate.freeMic,
        'room_background': parameterUpdate.roomBackgroundId,
        'room_intro': parameterUpdate.roomIntro,
        'room_pass': parameterUpdate.roomPass,
        'room_type': parameterUpdate.roomType,
        'room_class': parameterUpdate.roomClass,
        'change': parameterUpdate.change,
        'type': parameterUpdate.roomVideoType,
      });
    } else {
      File file = parameterUpdate.roomCover!;
      String fileName = file.path.split('/').last;
      formData = FormData.fromMap({
        "room_cover":
        await MultipartFile.fromFile(file.path, filename: fileName),
        'room_name': parameterUpdate.roomName,
        'free_mic': parameterUpdate.freeMic,
        'room_background': parameterUpdate.roomBackgroundId,
        'room_intro': parameterUpdate.roomIntro,
        'room_pass': parameterUpdate.roomPass,
        'room_type': parameterUpdate.roomType,
        'room_class': parameterUpdate.roomClass,
        'change': parameterUpdate.change,
        'type': parameterUpdate.roomVideoType,
      });
    }
    final response = await _dio.post(
      EndPoints.getRoomUpdate(roomId: parameterUpdate.ownerId),
      data: formData,
    );

    final EnterRoomModel roomData =
    EnterRoomModel.fromJson(response.data['data']);

    return BaseResponse.fromJson(response.data, fromJsonT: (json) => roomData);
  }

  @override
  Future<BaseResponse<UserModel>> fetchUserData(
      {required String userId, bool? isVisit}) async {
    final response = await _dio.get(
      EndPoints.getUserData(
        userId: userId,
        isVisit: isVisit,
      ),
    );
    final UserModel roomData = UserModel.fromJson(response.data['data']);
    return BaseResponse.fromJson(response.data, fromJsonT: (json) => roomData);
  }

  @override
  Future<BaseResponse<RankingModel>> fetchTopInRoom(
      TopParameterInRoom params) async {
    final body = {
      'type': params.innerType,
      'class': params.date,
      'roomId': params.roomId,
    };

    final response = await _dio.post(
      EndPoints.topUrlInRoom,
      data: body,
    );

    return BaseResponse<RankingModel>.fromJson(
      response.data,
      fromJsonT: (json) => RankingModel.fromJson(json),
    );
  }

  @override
  Future<RoomSessionSummaryModel?> endLive({String? roomId}) async {
    // `room_id` is what makes this work for a PARTY room. Without it the
    // backend falls back to the caller's non-audio room, which is why an audio
    // room's session could never be ended and it stayed listed as live.
    final response = await _dio.post(
      EndPoints.endLive,
      data: roomId == null ? null : {'room_id': roomId},
    );

    final data = response.data is Map ? response.data['data'] : null;

    return data is Map<String, dynamic>
        ? RoomSessionSummaryModel.fromJson(data)
        : null;
  }

  @override
  Future<String> removePasswordRoom(String roomId) async {
    final body = {
      'room_id': roomId,
    };
    final response = await _dio.post(
      EndPoints.removePassRoom,
      data: body,
    );
    Map<String, dynamic> jsonData = response.data;
    return jsonData['message'];
  }

  @override
  Future<String> addAdminRoom(AddAdminParameter param) async {
    try {
      final body = {
        'room_id': param.roomId,
        'user_id': param.userId,
        if (param.permissions != null) 'permissions': param.permissions,
      };

      final response = await _dio.post(EndPoints.addAdmin, data: body);

      Map<String, dynamic> jsonData = response.data;

      return jsonData['message'];
    } catch (error) {
      throw NetworkExceptions.getDioException(error);
    }
  }

  @override
  Future<List<UserModel>> adminsRoom(
      {required String ownerId, required String roomId}) async {
    try {
      final body = {
        'owner_id': ownerId,
        'id': roomId,
      };

      final response = await _dio.post(EndPoints.roomAdmins, data: body);

      Map<String, dynamic> jsonData = response.data;

      return List<UserModel>.from(
          jsonData["data"].map((x) => UserModel.fromJson(x)));
    } catch (error) {
      throw NetworkExceptions.getDioException(error);
    }
  }

  @override
  Future<String> uploadRoomChatImage(File image) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });

      final response =
      await _dio.post(EndPoints.roomChatImage, data: formData);

      // Bare shape, as everywhere else here: `url` sits at the top level of
      // the data object, not wrapped.
      final url = response.data?['data']?['url'] ?? response.data?['url'];
      if (url is! String || url.isEmpty) {
        throw Exception('upload returned no url');
      }
      return url;
    } catch (error) {
      throw NetworkExceptions.getDioException(error);
    }
  }

  @override
  Future<void> updateRoomViewMode({
    required String roomId,
    required int freeMic,
  }) async {
    try {
      await _dio.post(
        EndPoints.getRoomUpdate(roomId: roomId),
        // Sent as an int, not a bool: the backend casts with (int) and a
        // JSON `false` would arrive as the string "false" through form data.
        data: {'free_mic': freeMic},
      );
    } catch (error) {
      throw NetworkExceptions.getDioException(error);
    }
  }

  @override
  Future<String> removeAdmin(RemoveAdminParameter parameter) async {
    try {
      final body = {'room_id': parameter.roomId, 'user_id': parameter.userId};

      final response = await _dio.post(
        EndPoints.removeAdmin,
        data: body,
      );

      Map<String, dynamic> jsonData = response.data;

      return jsonData['message'];
    } catch (error) {
      throw NetworkExceptions.getDioException(error);
    }
  }

  @override
  Future<String> openGame(int id) async {
    final body = {'game_id': id};

    final response = await _dio.post(
      EndPoints.openGame,
      data: body,
    );

    Map<String, dynamic> resultData = response.data;

    return resultData["success"].toString();
  }

  @override
  Future<String> addRoomBackGround(File roomBackGround) async {
    FormData formData;
    File file = roomBackGround;
    String fileName = file.path.split('/').last;
    formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _dio.post(
      EndPoints.uploadBackGround,
      data: formData,
    );
    final result = response.data;
    return result['message'];
  }

  @override
  Future<List<BackgroundModel>> getMyBackGround() async {
    final response = await _dio.get(
      EndPoints.getMyBackGround,
    );
    return List<BackgroundModel>.from((response.data["data"] as List)
        .map((e) => BackgroundModel.fromJson(e)));
  }

  @override
  Future<BaseResponse<BackgroundSettingModel>> getMyBackGroundSetting() async {
    final response = await _dio.get(
      EndPoints.getMyBackGroundSetting,
    );

    return BaseResponse<BackgroundSettingModel>.fromJson(response.data,
        fromJsonT: (json) => BackgroundSettingModel.fromJson(json));
  }

  @override
  Future<BaseResponse<Map<String, dynamic>>> startCharisma(
      String roomId) async {
    final body = {'room_id': roomId};
    final response = await _dio.post(EndPoints.charisma, data: body);

    return BaseResponse.fromJson(response.data, fromJsonT: (json) => json);
  }

  @override
  Future<BaseResponse<Map<String, dynamic>>> resetCharisma(
      {required String roomId, required String ownerId}) async {
    final body = {'room_id': roomId, 'owner_id': ownerId};
    final response = await _dio.post(EndPoints.charismaReset, data: body);

    return BaseResponse.fromJson(response.data, fromJsonT: (json) => json);
  }

  @override
  Future<BaseResponse<List<CharismaModel>>> getCharismaExtraData(
      String roomId) async {
    final response = await _dio.get(
      EndPoints.getCharismaExtraData(roomId: roomId),
    );

    if (response.statusCode == 200 && response.data != null) {
      final boxesRaw = response.data?['data']?['boxes'];
      if (response.data?["data"]?["open_boom"] != null) {
        SuperBoomController.roomBoomLevel.value = int.parse(
            response.data?["data"]?["open_boom"]?["level"].toString() ?? "0");
        SuperBoomController.isSuperBoomVisible.value = true;
      }
      final List<dynamic> boxes = boxesRaw is List ? boxesRaw : [];
      LuckyBoxVariables.luckyBoxMap['luckyBoxes'].clear();
      LuckyBoxVariables.notifierLuckyBox.notifyListeners();
      if (boxes.isNotEmpty) {
        for (final box in boxes) {
          final boxMap = {
            messageContent: {
              boxIDKey: box['id'],
              boxCoinsKey: box['coins'],
              ownerBoxIdKey: box['user']['id'],
              ownerBoxNameKey: box['user']['name'],
              boxTypeKey: box['type'],
              'ownerBoxUId': box['user']['uuid'],
              'ownerBoxImage': box['user']['image'],
              'end_time': box['end_time'],
              'numOfBoxes': box['users_num'],
            }
          };

          showLuckyBox(boxMap);
        }
      }

      // The backend no longer returns a `charisma` block (charisma is now
      // computed client-side and lives in seat state). This call is kept for
      // its lucky-box + super-boom side effects above; the charisma list is
      // always empty and ignored by CharismaBloc.
      return BaseResponse.fromJson(
        response.data,
        fromJsonT: (json) => (json['charisma'] is List)
            ? (json['charisma'] as List)
            .map((element) => CharismaModel.fromJson(element))
            .toList()
            : <CharismaModel>[],
      );
    } else {
      throw Exception("Unexpected response status: ${response.statusCode}");
    }
  }

  @override
  Future<BaseResponse<String>> sendYallowBanner(
      String roomId, String message) async {
    final response = await _dio.post(
      EndPoints.yallowBanner,
      data: {
        'room_id': roomId,
        'message': message,
      },
    );

    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<String>.fromJson(
      response.data,
      fromJsonT: (json) => jsonData['message'].toString(),
    );
  }

  @override
  Future<BaseResponse<ExtraProfileDataModel>> fetchExtraProfileData(
      String userId) async {
    final response = await _dio.get(
      EndPoints.extraProfileData,
      queryParameters: {
        'id': userId,
      },
    );

    return BaseResponse<ExtraProfileDataModel>.fromJson(
      response.data,
      fromJsonT: (json) => ExtraProfileDataModel.fromJson(json),
    );
  }

  @override
  Future<String> lockComments(
      LockCommentsParameter lockCommentsParameter) async {
    final body = {
      'status': lockCommentsParameter.status,
    };

    final response = await _dio
        .post(EndPoints.lockComments(lockCommentsParameter.roomId), data: body);

    Map<String, dynamic> jsonData = response.data;

    return jsonData['message'];
  }

  @override
  Future<String> unLockComments(
      LockCommentsParameter lockCommentsParameter) async {
    final body = {
      'status': lockCommentsParameter.status,
    };

    final response = await _dio
        .post(EndPoints.lockComments(lockCommentsParameter.roomId), data: body);

    Map<String, dynamic> jsonData = response.data;

    return jsonData['message'];
  }

  @override
  Future<BaseResponse<bool>> checkAdminOwner(CheckAdminOwnerParam param) async {
    final response = await _dio.post(
      EndPoints.checkAdminOwner,
      data: {
        'room_id': param.roomId,
        'type': param.type,
      },
    );

    return BaseResponse<bool>.fromJson(
      response.data,
      fromJsonT: (json) => json,
    );
  }

  @override
  Future<BaseResponse<List<BubblePadding>>> fetchBubblePadding() async {
    final response = await _dio.get(EndPoints.bubblePadding);

    return BaseResponse<List<BubblePadding>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => BubblePadding.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<SvgaDataModel>> fetchGamesImages(int type) async {
    final response = await _dio.get(EndPoints.gamesImages(type));

    return BaseResponse<SvgaDataModel>.fromJson(
      response.data,
      fromJsonT: (json) => SvgaDataModel.fromJason(json),
    );
  }

  @override
  Future<BaseResponse<LuckyBoxModel>> getLuckyBoxes() async {
    final response = await _dio.get(
      EndPoints.getBoxes,
    );
    return BaseResponse<LuckyBoxModel>.fromJson(
      response.data,
      fromJsonT: (json) => LuckyBoxModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<SendLuckyBoxModel>> sendLuckyBox(
      LuckyBoxParam params) async {
    final body = {
      'box_id': params.boxId,
      'room_id': params.roomId,
      'users_num': params.quantity
    };

    final response = await _dio.post(
      EndPoints.sendBox,
      data: body,
    );

    return BaseResponse<SendLuckyBoxModel>.fromJson(
      response.data,
      fromJsonT: (json) => SendLuckyBoxModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<PickUpLuckyBoxModel>> pickUpLuckyBox(String boxId) async {
    final body = {'bid': boxId};

    log(body.toString());

    final response = await _dio.post(
      EndPoints.pickUpBoxes,
      data: body,
    );

    log(response.toString());

    return BaseResponse<PickUpLuckyBoxModel>.fromJson(
      response.data,
      fromJsonT: (json) => PickUpLuckyBoxModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<CreatePaidRoomModel>> getCreatePaidRoom() async {
    final response = await _dio.get(
      EndPoints.roomSettings,
    );

    return BaseResponse<CreatePaidRoomModel>.fromJson(
      response.data,
      fromJsonT: (json) => CreatePaidRoomModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<FreeGamesModel>> getFreeGamesImages() async {
    final response = await _dio.get(
      EndPoints.freeGamesImages,
    );

    return BaseResponse<FreeGamesModel>.fromJson(
      response.data,
      fromJsonT: (json) => FreeGamesModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<SuperBombModel>> getSuperBomb(
      {required String roomId}) async {
    final response = await _dio.get(
      EndPoints.getSuperBoom(roomId),
    );

    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<SuperBombModel>.fromJson(
      response.data,
      fromJsonT: (json) => SuperBombModel.fromJson(jsonData),
    );
  }

  @override
  Future<BaseResponse<SuberBoomVideoseModel>> getSuperBombVideos() async {
    final response = await _dio.get(
      EndPoints.getSuperBombVideos,
    );

    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<SuberBoomVideoseModel>.fromJson(
      response.data,
      fromJsonT: (json) => SuberBoomVideoseModel.fromJson(jsonData),
    );
  }

  @override
  Future<BaseResponse<BombRulesResponse>> getSuperBombRules() async {
    final response = await _dio.get(
      EndPoints.getSuperBombRules,
    );

    Map<String, dynamic> jsonData = response.data;

    return BaseResponse<BombRulesResponse>.fromJson(
      response.data,
      fromJsonT: (json) => BombRulesResponse.fromJson(jsonData),
    );
  }

  @override
  Future<BaseResponse<RoomBoomThemeModel>> getRoomBoomThemes() async {
    final response = await _dio.get(
      EndPoints.getRoomBoomThemes,
    );

    return BaseResponse<RoomBoomThemeModel>.fromJson(
      response.data,
      fromJsonT: (json) => RoomBoomThemeModel.fromJson(json),
    );
  }

  @override
  Future<Map<String, String>> getPreSignedUrl(File reel) async {
    final String extension = reel.path.split('.').last;
    final fileName = Methods().generateRandomFileName(extension: '.$extension');
    final int fileSize = reel.lengthSync();
    final String fileType = lookupMimeType(reel.path) ?? 'unknown';

    final response = await _dio.post(
      EndPoints.generateUploadLink,
      data: {
        "name": fileName,
        "type": fileType,
        "size": fileSize,
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
      UploadSongParam param,
      ) async {
    final File reel = param.song!;
    final String fileType = lookupMimeType(reel.path) ?? 'unknown';
    final int fileSize = reel.lengthSync();
    final fileStream = reel.openRead();

    // Proof-of-source logging: prints exactly which local file/size/type is
    // about to be PUT to which presigned URL, right before it goes over the
    // wire. Reproduce the "song became an image" failure once with this in
    // place and the log line settles the swap question either way -- if
    // `fileSize` here is already ~13KB, the wrong local file was picked up
    // (client-side); if it's the real multi-MB song size, the bytes got lost
    // or altered somewhere between here and the storage disk (transport/
    // server-side), not in a Flutter-side file/variable swap.
    Methods.printLog(
      '🎵 [UPLOAD_SONG_TO_STORAGE] path=${reel.path} '
      'sizeBytes=$fileSize contentType=$fileType '
      'url=${param.preSignedUrl}',
    );

    final response = await _dio.put(
      param.preSignedUrl!,
      data: fileStream,
      options: Options(headers: {
        'Content-Type': fileType,
        'Content-Length': fileSize.toString(),
      }, method: 'PUT'),
      onSendProgress: (int sent, int total) {
        if (total > 0) {
          final progress = (sent / total * 100).toInt();
          showProgressNotification(progress);

          if (progress == 100) {
            cancelProgressNotification();
          }
        }
      },
    );

    Methods.printLog(
      '🎵 [UPLOAD_SONG_TO_STORAGE] PUT finished '
      'status=${response.statusCode} for path=${reel.path}',
    );

    return response.statusCode ?? 500;
  }

  @override
  Future<BaseResponse<String>> notifyBackend(
      UploadSongParam param,
      ) async {
    final response = await _dio.post(EndPoints.createMusic,
        data: {
          "url": param.backendName,
          "user_id": MyDataModel.getInstance().id,
          if ((param.songName ?? '').isNotEmpty) "name": param.songName,
        },
        options: Options(method: 'POST'));

    if (response.statusCode != 200) {
      throw Exception('Failed to notify the backend');
    }

    return BaseResponse.fromJson(response.data);
  }

  @override
  Future<BaseResponse<String>> deleteSong(int songId) async {
    final response = await _dio.delete(
      EndPoints.deleteSong(songId),
    );

    return BaseResponse.fromJson(
      response.data,
    );
  }

  @override
  Future<BaseResponse<List<MusicModel>>> getMusic() async {
    final response = await _dio.get(
      EndPoints.getMusic,
    );
    return BaseResponse<List<MusicModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => MusicModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<MusicModel>>> getMyMusic() async {
    final response = await _dio.get(
      EndPoints.getMyMusic,
    );
    return BaseResponse<List<MusicModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => MusicModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<RoomRewardModel>> getRoomActivity(int roomId) async {
    final response = await _dio.get(
      EndPoints.roomActivityData(roomId),
    );
    return BaseResponse<RoomRewardModel>.fromJson(
      response.data,
      fromJsonT: (json) => RoomRewardModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<String>> getRoomActivityWebViewLink() async {
    final response = await _dio.get(
      EndPoints.roomActivityWebViewLink,
    );
    return BaseResponse<String>.fromJson(
      response.data,
    );
  }

  @override
  Future<BaseResponse<List<GiftCategoryModel>>> fetchGiftCategory() async {
    // This is static catalog data (same as fetchGifts above), but it was
    // never opting into the cache -- so opening the gift sheet for the
    // first time in a session always paid for a full, uncached network
    // round trip (on top of the per-category gift fetch that follows it)
    // before anything could show, which is what made the very first open
    // slow while every reopen after it (served from the bloc's in-memory
    // state) felt instant. Caching it the same way fetchGifts already is
    // removes that extra round trip on repeat app sessions too.
    final response = await _dio.get(
      EndPoints.giftCategory,
      cacheDuration: const Duration(minutes: 30),
    );
    return BaseResponse<List<GiftCategoryModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => GiftCategoryModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<ReactionModel>>> fetchEmojisCategory() async {
    final response = await _dio.get(EndPoints.emojisCategory);
    return BaseResponse<List<ReactionModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => ReactionModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<UserModel>>> fetchUsersData({
    required List<String> userIds,
  }) async {
    final response = await _dio.get(
      EndPoints.getUsers(userIds),
    );
    return BaseResponse<List<UserModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => UserModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<String>>> fetchBadWords() async {
    final response = await _dio.get(EndPoints.badWords);
    return BaseResponse<List<String>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => element.toString())
          .toList(),
    );
  }

  @override
  Future<List<CharismaLevelModel>> getCharismaLevels() async {
    final response = await _dio.get(EndPoints.charismaLevels);

    final List<dynamic> data = response.data['data'] ?? [];
    return data
        .map((e) => CharismaLevelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/data/model/create_room_model.dart';
import 'package:general/src/features/home/data/model/host_level_model.dart';
import 'package:general/src/features/home/data/model/my_rooms_model.dart';
import 'package:general/src/features/home/data/model/top_rank_images_models.dart';
import 'package:general/src/features/home/home.dart';
import '../model/banner_model.dart';
import '../model/carousel_model.dart';

abstract class BaseHomeRemoteDataSource {
  Future<BaseResponse<List<RoomModel>>> fetchRooms({
    required RoomsParameterUC params,
  });

  Future<BaseResponse<List<RoomModel>>> fetchLiveRooms({
    required RoomsParameterUC params,
  });

  Future<BaseResponse<SearchModel>> search(
      String keyWord, bool? isFriend, String? page);

  Future<BaseResponse<CreateRoomModel>> createRoom(
      {required CreateRoomParameter creatRoomParameter});

  Future<BaseResponse<List<RoomTypesModel>>> fetchAllTypesRoom();

  Future<BaseResponse<List<CarouselModel>>> getCarousel(CountryParams param);

  Future<BaseResponse<TopRankImagesModel>> getTopUserImageRank();

  Future<BaseResponse<MyRoomsModel>> getMyRoomData();

  Future<BaseResponse<DailyPrizesModel>> fetchDailyPrizes();

  Future<String> openDailyPrize();

  Future<BaseResponse<BannerModel>> getBanner();
  Future<BaseResponse<HostLevelsModel>> fetchHostLevels();
  Future<BaseResponse<String>> pickBox({required String stageId});
}

class HomeRemoteDataSourceImp extends BaseHomeRemoteDataSource {
  final DioFactory _dio;

  HomeRemoteDataSourceImp(this._dio);

  @override
  Future<BaseResponse<List<RoomModel>>> fetchRooms({required params}) async {
    String? type_;

    switch (params.type ?? '') {
      case TypeGetRooms.popular:
        type_ = TypeGetRooms.popular.name; // hot
        break;
      case TypeGetRooms.global:
        type_ = TypeGetRooms.global.name;
        break;
      case TypeGetRooms.following:
        type_ = TypeGetRooms.following.name;
        break;
      case TypeGetRooms.interests:
        type_ = TypeGetRooms.interests.name;
        break;
      case TypeGetRooms.friends:
        type_ = TypeGetRooms.friends.name;
        break;
      case TypeGetRooms.follow:
        type_ = TypeGetRooms.follow.name;
      case TypeGetRooms.lastCreate:
        type_ = 'last_create';
        break;
    }

    final response = await _dio.get(
      EndPoints.fetchRooms(
        page: params.currentPage,
        countryId: params.countryId,
        filter: type_,
      ),
    );
    return BaseResponse<List<RoomModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => RoomModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<RoomModel>>> fetchLiveRooms(
      {required params}) async {
    final response = await _dio.get(
      EndPoints.fetchLiveRooms(
        page: params.currentPage,
      ),
    );
    return BaseResponse<List<RoomModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => RoomModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<SearchModel>> search(
      String keyWord, bool? isFriend, String? page) async {
    final response = await _dio.get(EndPoints.search(
        keyword: keyWord, isFriend: isFriend, page: page ?? ''));

    return BaseResponse<SearchModel>.fromJson(
      response.data,
      fromJsonT: (json) => SearchModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<CreateRoomModel>> createRoom(
      {required CreateRoomParameter creatRoomParameter}) async {
    FormData formData;
    if (creatRoomParameter.roomCover == null) {
      formData = FormData.fromMap({
        'room_name': creatRoomParameter.roomName,
        'room_intro': creatRoomParameter.roomIntero,
        'room_type': creatRoomParameter.roomType,
        'room_pass': creatRoomParameter.roomPassword,
        'type': creatRoomParameter.type,
      });
    } else {
      File file = creatRoomParameter.roomCover!;
      String fileName = file.path.split('/').last;
      formData = FormData.fromMap({
        "room_cover":
            await MultipartFile.fromFile(file.path, filename: fileName),
        'room_intro': creatRoomParameter.roomIntero,
        'room_type': creatRoomParameter.roomType,
        'room_pass': creatRoomParameter.roomPassword,
        'room_name': creatRoomParameter.roomName,
        'type': creatRoomParameter.type,
      });
    }

    final response = await _dio.post(
      EndPoints.createRoom,
      data: formData,
    );
    return BaseResponse<CreateRoomModel>.fromJson(
      response.data,
      fromJsonT: (json) => CreateRoomModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<List<RoomTypesModel>>> fetchAllTypesRoom() async {
    final response = await _dio.get(
      EndPoints.fetchAllTypesRoom,
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => RoomTypesModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<CarouselModel>>> getCarousel(
      CountryParams param) async {
    String? notificationId;

    try {
      notificationId = await FirebaseMessaging.instance.getToken();
    } catch (error) {
      Methods.printLog("❌ Error getting FCM token: $error");
    }
    if (notificationId == null) {
      Methods.printLog(
          "⚠️ FCM token is null — sending 'no-fcm-token' in header");
    } else {
      Methods.printLog("✅ FCM token = $notificationId");
    }

    // No client cache: carousels/ads are admin-controlled and MUST reflect a
    // delete/disable/edit from the control panel on the very next load. Caching
    // the list (even briefly) let deleted banners linger on-device, so this GET
    // always hits the network. The payload is small and renders behind a shimmer.
    final response = await _dio.get(
      EndPoints.getCarousel(param.type, param.countryId),
      headers: {'X-Notification-Id': notificationId ?? ''},
    );

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => CarouselModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<TopRankImagesModel>> getTopUserImageRank() async {
    final response = await _dio.get(
      EndPoints.getTopUserImage,
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => TopRankImagesModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<MyRoomsModel>> getMyRoomData() async {
    final response = await _dio.get(
      EndPoints.getMyRooms,
    );

    MyRoomsModel data = MyRoomsModel.fromJson(response.data['data']);
    return BaseResponse.fromJson(response.data, fromJsonT: (json) => data);
  }

  @override
  Future<BaseResponse<DailyPrizesModel>> fetchDailyPrizes() async {
    final response = await _dio.get(
      EndPoints.currentDayPrize,
    );

    DailyPrizesModel dailyPrizes =
        DailyPrizesModel.fromJson(response.data['data']);
    return BaseResponse.fromJson(response.data,
        fromJsonT: (json) => dailyPrizes);
  }

  @override
  Future<String> openDailyPrize() async {
    final response = await _dio.post(EndPoints.receiveDailyPrize);

    return response.data['message'];
  }

  @override
  Future<BaseResponse<BannerModel>> getBanner() async {
    // No client cache: the splash banner is admin-controlled and must reflect a
    // delete/disable from the control panel immediately (see getCarousel above).
    final response = await _dio.get(
      EndPoints.getBanner,
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => BannerModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<HostLevelsModel>> fetchHostLevels() async {
    final response = await _dio.get(EndPoints.hostLevels);
    return BaseResponse<HostLevelsModel>.fromJson(
      response.data,
      fromJsonT: (json) => HostLevelsModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<String>> pickBox({required String stageId}) async {
    final response = await _dio.post(
      EndPoints.pickBox,
      data: {
        "host_level_id": stageId,
      },
    );
    return BaseResponse<String>.fromJson(response.data);
  }
}

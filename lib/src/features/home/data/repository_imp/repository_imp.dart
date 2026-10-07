import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/data/model/banner_model.dart';
import 'package:general/src/features/home/data/model/carousel_model.dart';
import 'package:general/src/features/home/data/model/create_room_model.dart';
import 'package:general/src/features/home/data/model/host_level_model.dart';
import 'package:general/src/features/home/data/model/my_rooms_model.dart';
import 'package:general/src/features/home/data/model/top_rank_images_models.dart';
import 'package:general/src/features/home/home.dart';

class HomeRepositoryImp extends BaseHomeRepository {
  final BaseHomeRemoteDataSource _remote;

  HomeRepositoryImp(this._remote);

  @override
  ResultFuture<BaseResponse<List<RoomModel>>> fetchRooms(
      {required RoomsParameterUC params}) {
    return execute<BaseResponse<List<RoomModel>>>(
        () => _remote.fetchRooms(params: params));
  }

  @override
  ResultFuture<BaseResponse<List<RoomModel>>> fetchLiveRooms(
      {required RoomsParameterUC params}) {
    return execute<BaseResponse<List<RoomModel>>>(
        () => _remote.fetchLiveRooms(params: params));
  }

  @override
  ResultFuture<BaseResponse<SearchModel>> search(
      String keyWord, bool? isFriend, String? page) {
    return execute<BaseResponse<SearchModel>>(
        () => _remote.search(keyWord, isFriend, page));
  }

  @override
  ResultFuture<BaseResponse<CreateRoomModel>> createRoom(
      {required CreateRoomParameter creatRoomParameter}) async {
    return await execute(
        () => _remote.createRoom(creatRoomParameter: creatRoomParameter));
  }

  @override
  ResultFuture<BaseResponse<List<RoomTypesModel>>> fetchAllTypesRoom() async {
    return await execute(() => _remote.fetchAllTypesRoom());
  }

  @override
  ResultFuture<BaseResponse<List<CarouselModel>>> getCarousel(
      CountryParams param) async {
    return await execute(() => _remote.getCarousel(param));
  }

  @override
  ResultFuture<BaseResponse<TopRankImagesModel>> getTopUserImageRank() async {
    return await execute(() => _remote.getTopUserImageRank());
  }

  @override
  ResultFuture<BaseResponse<MyRoomsModel>> getMyRoomData() async {
    return await execute(() => _remote.getMyRoomData());
  }

  @override
  ResultFuture<BaseResponse<DailyPrizesModel>> fetchDailyPrizes() async {
    return await execute<BaseResponse<DailyPrizesModel>>(
        () => _remote.fetchDailyPrizes());
  }

  @override
  ResultFuture<String> openDailyPrize() async {
    return await execute<String>(() => _remote.openDailyPrize());
  }

  @override
  ResultFuture<BaseResponse<BannerModel>> getBanner() async {
    return await execute<BaseResponse<BannerModel>>(() => _remote.getBanner());
  }

  @override
  ResultFuture<BaseResponse<HostLevelsModel>> fetchHostLevels() async {
    return await execute<BaseResponse<HostLevelsModel>>(
        () => _remote.fetchHostLevels());
  }

  @override
  ResultFuture<BaseResponse<String>> pickBox({required String stageId}) async {
    return await execute<BaseResponse<String>>(
      () => _remote.pickBox(stageId: stageId),
    );
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/data/model/create_room_model.dart';
import 'package:general/src/features/home/data/model/host_level_model.dart';
import 'package:general/src/features/home/data/model/my_rooms_model.dart';
import 'package:general/src/features/home/home.dart';
import '../../data/model/banner_model.dart';
import '../../data/model/carousel_model.dart';
import '../../data/model/top_rank_images_models.dart';

abstract class BaseHomeRepository {
  ResultFuture<BaseResponse<List<RoomModel>>> fetchRooms({
    required RoomsParameterUC params,
  });
  ResultFuture<BaseResponse<List<RoomModel>>> fetchLiveRooms({
    required RoomsParameterUC params,
  });
  ResultFuture<BaseResponse<SearchModel>> search(
    String keyWord,
    bool? isFriend,
    String? page,
  );
  ResultFuture<BaseResponse<CreateRoomModel>> createRoom({
    required CreateRoomParameter creatRoomParameter,
  });
  ResultFuture<BaseResponse<List<RoomTypesModel>>> fetchAllTypesRoom();
  ResultFuture<BaseResponse<List<CarouselModel>>> getCarousel(
    CountryParams param,
  );
  ResultFuture<BaseResponse<TopRankImagesModel>> getTopUserImageRank();
  ResultFuture<BaseResponse<MyRoomsModel>> getMyRoomData();
  ResultFuture<BaseResponse<DailyPrizesModel>> fetchDailyPrizes();
  ResultFuture<String> openDailyPrize();
  ResultFuture<BaseResponse<BannerModel>> getBanner();
  ResultFuture<BaseResponse<HostLevelsModel>> fetchHostLevels();
  ResultFuture<BaseResponse<String>> pickBox({required String stageId});
}

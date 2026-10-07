import 'dart:io';
import 'package:general/src/features/auth/data/model/close_effect_model.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/get_games_images_model.dart';
import 'package:general/src/features/room/data/model/gift_category_model.dart';
import 'package:general/src/features/room/data/model/reaction_model.dart';
import 'package:general/src/features/room/room.dart';
import '../../data/model/extra_profile_data_model.dart';
import 'package:general/src/features/room/data/model/send_gift_model.dart';

abstract class RoomBaseRepository {
  ResultFuture<BaseResponse<EnterRoomModel>> enterRoom(
    EnterRoomParameter parameter,
  );

  ResultFuture<BaseResponse<CloseEffectModel>> clearMode(String key);

  ResultFuture<String> changeRoomMode({required String roomId, required int mode});

  ResultFuture<BaseResponse<String>> deleteSong(int songId);

  ResultFuture<BaseResponse<SendGiftModel>> sendGifts(GiftParameter giftParameter);

  ResultFuture<BaseResponse<List<GiftsModel>>> fetchGifts(int type);

  ResultFuture<BaseResponse<List<GiftsModel>>> getUserGift();

  ResultFuture<BaseResponse<List<String>>> getGiftImages();

  ResultFuture<BaseResponse<GetConfigKeyModel>> fetchConfigKey(
    GetConfigKeyPram getConfigKeyPram,
  );

  ResultFuture<BaseResponse<String>> showPK(String roomId);
  ResultFuture<BaseResponse<String>> startPK(StartPKParameter parameter);
  ResultFuture<BaseResponse<String>> hidePK(String roomId);
  ResultFuture<BaseResponse<String>> blockComments(
    BlockCommentsParameter param,
  );
  ResultFuture<BaseResponse<String>> closePK(ClosePKParameter parameter);
  ResultFuture<BaseResponse<List<EmojiModel>>> fetchEmoji(String categoryId);

  ResultFuture<List<BackgroundModel>> fetchBackGround();
  ResultFuture<BaseResponse<LuckyGiftModel>> sendLuckyGift(
    GiftParameter giftParameter,
  );
  ResultFuture<BaseResponse<EnterRoomModel>> updateRoom({
    required ParameterUpdate parameterUpdate,
  });
  ResultFuture<BaseResponse<UserModel>> fetchUserData({
    required String userId,
    bool? isVisit,
  });
  ResultFuture<BaseResponse<RankingModel>> fetchTopInRoom(
    TopParameterInRoom topParameter,
  );

  ResultFuture<String> lockComments(
    LockCommentsParameter lockCommentsParameter,
  );
  ResultFuture<String> unLockComments(
      LockCommentsParameter lockCommentsParameter);
  ResultFuture<String> removePassRoom(String roomId);
  ResultFuture<String> openGame(int id);
  ResultFuture<String> addRoomBackGround(File roomBackGround);
  ResultFuture<List<BackgroundModel>> getMyAllBackGround();
  ResultFuture<BaseResponse<BackgroundSettingModel>> getMyBackGroundSetting();
  ResultFuture<BaseResponse<Map<String, dynamic>>> startCharisma(
    String roomId,
  );
  ResultFuture<BaseResponse<Map<String, dynamic>>> resetCharisma(
    ResetCharismaParam param,
  );
  ResultFuture<BaseResponse<List<CharismaModel>>> getCharismaExtraData(
    String roomId,
  );

  Future<List<CharismaLevelModel>> getCharismaLevels(
  );
  ResultFuture<BaseResponse<String>> sendYallowBanner(
    SendPobUpPram sendPobUpPram,
  );

  ResultFuture<BaseResponse<ExtraProfileDataModel>> fetchExtraProfileData(
    String userId,
  );

  ResultFuture<BaseResponse<bool>> checkAdminOwner(CheckAdminOwnerParam param);

  ResultFuture<BaseResponse<List<BubblePadding>>> fetchBubblePadding();
  ResultFuture<BaseResponse<SvgaDataModel>> fetchGamesImages(int type);

  ResultFuture<BaseResponse<LuckyBoxModel>> getLuckyBoxes();

  ResultFuture<BaseResponse<SendLuckyBoxModel>> sendLuckyBox(
    LuckyBoxParam params,
  );

  ResultFuture<BaseResponse<PickUpLuckyBoxModel>> pickUpLuckyBox(String boxId);

  ResultFuture<BaseResponse<CreatePaidRoomModel>> getCreatePaidRoom();
  ResultFuture<BaseResponse<FreeGamesModel>> getFreeGamesImages();
  ResultFuture<BaseResponse<SuperBombModel>> getSuperBomb({
    required String roomId,
  });
  ResultFuture<BaseResponse<SuberBoomVideoseModel>> getSuperBombVideos();
  ResultFuture<BaseResponse<BombRulesResponse>> getSuperBombRules();

  ResultFuture<BaseResponse<RoomBoomThemeModel>> getRoomBoomThemes();

  ResultFuture<Map<String, String>> getPreSignedUrl(File reel);

  ResultFuture<int> uploadFileToStorage(
    UploadSongParam param,
  );

  ResultFuture<BaseResponse<String>> notifyBackend(
    UploadSongParam param,
  );

  ResultFuture<BaseResponse<List<MusicModel>>> getMusic();

  ResultFuture<BaseResponse<List<MusicModel>>> getMyMusic();
  ResultFuture<BaseResponse<RoomRewardModel>> getRoomActivity(int roomId);
  ResultFuture<BaseResponse<String>> getRoomActivityWebViewLink();

  ResultFuture<BaseResponse<List<GiftCategoryModel>>> fetchGiftCategory();
  ResultFuture<BaseResponse<List<ReactionModel>>> fetchEmojisCategory();

  ResultFuture<BaseResponse<List<UserModel>>> fetchUsersData({
    required List<String> userIds,
  });

  ResultFuture<BaseResponse<List<String>>> fetchBadWords();
}

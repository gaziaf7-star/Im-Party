import 'dart:io';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/room/data/model/gift_category_model.dart';
import 'package:general/src/features/room/data/model/reaction_model.dart';
import 'package:general/src/features/room/room.dart';

import 'package:general/src/features/room/data/model/send_gift_model.dart';
import '../model/extra_profile_data_model.dart';
import '../model/get_games_images_model.dart';

class RoomRepositoryImp implements RoomBaseRepository {
  final BaseRoomRemoteDataSource _remote;

  RoomRepositoryImp(this._remote);

  @override
  ResultFuture<BaseResponse<CloseEffectModel>> clearMode(String key) {
    return execute<BaseResponse<CloseEffectModel>>(
        () => _remote.clearMode(key));
  }

  @override
  ResultFuture<String> changeRoomMode({
    required String roomId,
    required int mode,
  }) {
    return execute<String>(
        () => _remote.changeRoomMode(roomId: roomId, mode: mode));
  }

  @override
  ResultFuture<BaseResponse<EnterRoomModel>> enterRoom(
      EnterRoomParameter parameter) {
    return execute<BaseResponse<EnterRoomModel>>(
      () => _remote.enterRoom(
        roomId: parameter.roomId,
        roomPassword: parameter.roomPassword,
        ignorePassword: parameter.ignoreRoomPassword,
        sendToZego: parameter.sendToZego,
      ),
    );
  }

 @override
  ResultFuture<BaseResponse<SendGiftModel>> sendGifts(GiftParameter giftParameter) {
    return execute<BaseResponse<SendGiftModel>>(() => _remote.sendGifts(giftParameter));
  }

  @override
  ResultFuture<BaseResponse<List<GiftsModel>>> fetchGifts(int type) {
    return execute<BaseResponse<List<GiftsModel>>>(
        () => _remote.fetchGifts(type));
  }

  @override
  ResultFuture<BaseResponse<List<GiftsModel>>> getUserGift() {
    return execute<BaseResponse<List<GiftsModel>>>(() => _remote.getUserGift());
  }

  @override
  ResultFuture<BaseResponse<List<String>>> getGiftImages() {
    return execute<BaseResponse<List<String>>>(() => _remote.getGiftImages());
  }

  @override
  ResultFuture<BaseResponse<GetConfigKeyModel>> fetchConfigKey(
      GetConfigKeyPram getConfigKeyPram) {
    return execute<BaseResponse<GetConfigKeyModel>>(
        () => _remote.fetchConfigKey(getConfigKeyPram));
  }

  @override
  ResultFuture<BaseResponse<String>> showPK(String roomId) {
    return execute<BaseResponse<String>>(() => _remote.showPK(roomId));
  }

  @override
  ResultFuture<BaseResponse<String>> startPK(StartPKParameter parameter) {
    return execute<BaseResponse<String>>(() => _remote.startPK(parameter));
  }

  @override
  ResultFuture<BaseResponse<String>> hidePK(String roomId) {
    return execute<BaseResponse<String>>(() => _remote.hidePK(roomId));
  }

  @override
  ResultFuture<BaseResponse<String>> blockComments(
      BlockCommentsParameter param) {
    return execute<BaseResponse<String>>(() => _remote.blockComments(param));
  }

  @override
  ResultFuture<BaseResponse<String>> closePK(ClosePKParameter parameter) {
    return execute<BaseResponse<String>>(() => _remote.closePK(parameter));
  }

  @override
  ResultFuture<BaseResponse<List<EmojiModel>>> fetchEmoji(categoryId) {
    return execute<BaseResponse<List<EmojiModel>>>(
        () => _remote.fetchEmoji(categoryId));
  }



  @override
  ResultFuture<List<BackgroundModel>> fetchBackGround() {
    return execute<List<BackgroundModel>>(() => _remote.fetchBackGround());
  }

  @override
  ResultFuture<BaseResponse<LuckyGiftModel>> sendLuckyGift(
      GiftParameter parameter) {
    return execute<BaseResponse<LuckyGiftModel>>(
        () => _remote.sendLuckyGift(parameter));
  }

  @override
  ResultFuture<BaseResponse<EnterRoomModel>> updateRoom(
      {required ParameterUpdate parameterUpdate}) {
    return execute<BaseResponse<EnterRoomModel>>(
        () => _remote.updateRoom(parameterUpdate: parameterUpdate));
  }

  @override
  ResultFuture<BaseResponse<UserModel>> fetchUserData(
      {required String userId, bool? isVisit}) {
    return execute<BaseResponse<UserModel>>(
        () => _remote.fetchUserData(userId: userId, isVisit: isVisit));
  }

  @override
  ResultFuture<BaseResponse<RankingModel>> fetchTopInRoom(
      TopParameterInRoom topParameter) {
    return execute<BaseResponse<RankingModel>>(
        () => _remote.fetchTopInRoom(topParameter));
  }

  @override
  ResultFuture<String> removePassRoom(String roomId) async {
    return execute<String>(() => _remote.removePasswordRoom(roomId));
  }

  @override
  ResultFuture<String> openGame(int id) async {
    return execute<String>(() => _remote.openGame(id));
  }

  @override
  ResultFuture<String> addRoomBackGround(File roomBackGround) async {
    return execute<String>(() => _remote.addRoomBackGround(roomBackGround));
  }

  @override
  ResultFuture<List<BackgroundModel>> getMyAllBackGround() async {
    return execute<List<BackgroundModel>>(() => _remote.getMyBackGround());
  }

  @override
  ResultFuture<BaseResponse<BackgroundSettingModel>>
      getMyBackGroundSetting() async {
    return execute<BaseResponse<BackgroundSettingModel>>(
        () => _remote.getMyBackGroundSetting());
  }

  @override
  ResultFuture<BaseResponse<Map<String, dynamic>>> startCharisma(
      String roomId) async {
    return execute<BaseResponse<Map<String, dynamic>>>(
        () => _remote.startCharisma(roomId));
  }

  @override
  ResultFuture<BaseResponse<Map<String, dynamic>>> resetCharisma(
      ResetCharismaParam param) async {
    return execute<BaseResponse<Map<String, dynamic>>>(() =>
        _remote.resetCharisma(roomId: param.roomId, ownerId: param.ownerId));
  }

  @override
  ResultFuture<BaseResponse<List<CharismaModel>>> getCharismaExtraData(
      String roomId) async {
    return execute<BaseResponse<List<CharismaModel>>>(
        () => _remote.getCharismaExtraData(roomId));
  }

  @override
  Future<List<CharismaLevelModel>> getCharismaLevels() async {
    return _remote.getCharismaLevels();
  }

  @override
  ResultFuture<BaseResponse<String>> sendYallowBanner(
      SendPobUpPram sendPobUpPram) async {
    return execute<BaseResponse<String>>(() =>
        _remote.sendYallowBanner(sendPobUpPram.roomId, sendPobUpPram.message));
  }

  @override
  ResultFuture<BaseResponse<ExtraProfileDataModel>> fetchExtraProfileData(
      String userId) async {
    return execute<BaseResponse<ExtraProfileDataModel>>(
        () => _remote.fetchExtraProfileData(userId));
  }

  @override
  ResultFuture<BaseResponse<bool>> checkAdminOwner(
      CheckAdminOwnerParam param) async {
    return execute<BaseResponse<bool>>(() => _remote.checkAdminOwner(param));
  }

  @override
  ResultFuture<String> lockComments(
      LockCommentsParameter lockCommentsParameter) {
    return execute<String>(() => _remote.lockComments(lockCommentsParameter));
  }

  @override
  ResultFuture<String> unLockComments(
      LockCommentsParameter lockCommentsParameter) {
    return execute<String>(() => _remote.unLockComments(lockCommentsParameter));
  }

  @override
  ResultFuture<BaseResponse<List<BubblePadding>>> fetchBubblePadding() {
    return execute<BaseResponse<List<BubblePadding>>>(
        () => _remote.fetchBubblePadding());
  }

  @override
  ResultFuture<BaseResponse<SvgaDataModel>> fetchGamesImages(int type) {
    return execute<BaseResponse<SvgaDataModel>>(
        () => _remote.fetchGamesImages(type));
  }

  @override
  ResultFuture<BaseResponse<LuckyBoxModel>> getLuckyBoxes() {
    return execute<BaseResponse<LuckyBoxModel>>(() => _remote.getLuckyBoxes());
  }

  @override
  ResultFuture<BaseResponse<SendLuckyBoxModel>> sendLuckyBox(
      LuckyBoxParam params) {
    return execute<BaseResponse<SendLuckyBoxModel>>(
        () => _remote.sendLuckyBox(params));
  }

  @override
  ResultFuture<BaseResponse<PickUpLuckyBoxModel>> pickUpLuckyBox(String boxId) {
    return execute<BaseResponse<PickUpLuckyBoxModel>>(
        () => _remote.pickUpLuckyBox(boxId));
  }

  @override
  ResultFuture<BaseResponse<CreatePaidRoomModel>> getCreatePaidRoom() {
    return execute<BaseResponse<CreatePaidRoomModel>>(
        () => _remote.getCreatePaidRoom());
  }

  @override
  ResultFuture<BaseResponse<FreeGamesModel>> getFreeGamesImages() {
    return execute<BaseResponse<FreeGamesModel>>(
        () => _remote.getFreeGamesImages());
  }

  @override
  ResultFuture<BaseResponse<SuperBombModel>> getSuperBomb(
      {required String roomId}) {
    return execute<BaseResponse<SuperBombModel>>(
      () => _remote.getSuperBomb(roomId: roomId),
    );
  }

  @override
  ResultFuture<BaseResponse<SuberBoomVideoseModel>> getSuperBombVideos() {
    return execute<BaseResponse<SuberBoomVideoseModel>>(
      () => _remote.getSuperBombVideos(),
    );
  }

  @override
  ResultFuture<BaseResponse<BombRulesResponse>> getSuperBombRules() {
    return execute<BaseResponse<BombRulesResponse>>(
      () => _remote.getSuperBombRules(),
    );
  }

  @override
  ResultFuture<BaseResponse<RoomBoomThemeModel>> getRoomBoomThemes() {
    return execute<BaseResponse<RoomBoomThemeModel>>(
      () => _remote.getRoomBoomThemes(),
    );
  }

  @override
  ResultFuture<Map<String, String>> getPreSignedUrl(File reel) {
    return execute<Map<String, String>>(
      () => _remote.getPreSignedUrl(reel),
    );
  }

  @override
  ResultFuture<BaseResponse<String>> notifyBackend(UploadSongParam param) {
    return execute<BaseResponse<String>>(
      () => _remote.notifyBackend(param),
    );
  }

  @override
  ResultFuture<int> uploadFileToStorage(UploadSongParam param) {
    return execute<int>(
      () => _remote.uploadFileToStorage(param),
    );
  }

  @override
  ResultFuture<BaseResponse<String>> deleteSong(int songId) {
    return execute<BaseResponse<String>>(() => _remote.deleteSong(songId));
  }

  @override
  ResultFuture<BaseResponse<List<MusicModel>>> getMusic() {
    return execute<BaseResponse<List<MusicModel>>>(() => _remote.getMusic());
  }

  @override
  ResultFuture<BaseResponse<List<MusicModel>>> getMyMusic() {
    return execute<BaseResponse<List<MusicModel>>>(() => _remote.getMyMusic());
  }

  @override
  ResultFuture<BaseResponse<RoomRewardModel>> getRoomActivity(int roomId) {
    return execute<BaseResponse<RoomRewardModel>>(
        () => _remote.getRoomActivity(roomId));
  }

  @override
  ResultFuture<BaseResponse<String>> getRoomActivityWebViewLink() {
    return execute<BaseResponse<String>>(
        () => _remote.getRoomActivityWebViewLink());
  }

  @override
  ResultFuture<BaseResponse<List<GiftCategoryModel>>> fetchGiftCategory() {
    return execute<BaseResponse<List<GiftCategoryModel>>>(
        () => _remote.fetchGiftCategory());
  }

  @override
  ResultFuture<BaseResponse<List<ReactionModel>>> fetchEmojisCategory() {
    return execute<BaseResponse<List<ReactionModel>>>(
        () => _remote.fetchEmojisCategory());
  }

  @override
  ResultFuture<BaseResponse<List<UserModel>>> fetchUsersData(
      {required List<String> userIds}) {
    return execute<BaseResponse<List<UserModel>>>(
        () => _remote.fetchUsersData(userIds: userIds));
  }

  @override
  ResultFuture<BaseResponse<List<String>>> fetchBadWords() {
    return execute<BaseResponse<List<String>>>(() => _remote.fetchBadWords());
  }
}

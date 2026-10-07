import 'dart:async';
import 'dart:developer';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/charisma/bloc/charisma_bloc.dart';
import 'package:general/src/features/room/presentation/component/messages/lucky_gift_sound_manager.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/lucky_gift_win_bloc/lucky_gift_win_event.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/manager/clear_mode_manager/clear_mode_bloc.dart';
import 'package:general/src/features/room/presentation/manager/emojie_manager/emojie_bloc.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_bloc.dart';
import 'package:general/src/features/room/presentation/manager/room_mode/room_mode_cubit.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_bloc.dart';
import 'package:general/src/features/room/presentation/room_comments/block_comments_bloc/block_comments_bloc.dart';
import 'package:general/src/features/room/presentation/super_bomb/bloc/get_super_bombs_bloc/get_super_bombs_bloc.dart';
import 'package:general/src/features/room/presentation/super_bomb/bloc/get_super_bombs_theme_bloc/get_super_bombs_theme_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_bloc.dart';
import 'package:general/src/features/room/presentation/youtube/bloc/youtube/youtube_event.dart';
import 'package:general/src/features/room/presentation/youtube/view/youtube_controller.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_badge/user_badges_bloc.dart';

class RoomCleanupHelper {
  static final RoomCleanupHelper _instance = RoomCleanupHelper._internal();
  factory RoomCleanupHelper() => _instance;
  RoomCleanupHelper._internal();

  /// [deferLuckyGiftEnd] — room-switch path only: the lucky-gift end call is
  /// network-bound and must not delay entering the next room. All synchronous
  /// state resets above it always run before this returns.
  Future<void> preCleanup({bool deferLuckyGiftEnd = false}) async {
    RoomData.instance.startExitRoom();
    RoomData.instance.disposeRtm();
    LuckyGiftSoundManager.instance.dispose();
    GiftController().normalGiftsToShow.clear();
    di<LuckyGiftWinBloc>().add(const ClearLuckyWinEvent());
    if (deferLuckyGiftEnd) {
      unawaited(() async {
        try {
          await LuckyGiftService.instance.endAllLuckyGift();
        } catch (e) {
          log('[RoomCleanupHelper] deferred endAllLuckyGift error: $e',
              name: 'room_nav');
        }
      }());
    } else {
      await LuckyGiftService.instance.endAllLuckyGift();
    }
  }

  Future<void> cleanupAudio() async {
    final musicBloc = di<MusicRoomBloc>();
    musicBloc.add(const DestroyMusicRoomListEvent());
    // The event above is async and may not run before the bloc is reset in
    // runDeferredCleanup, which would orphan a still-playing AudioPlayer that
    // keeps the previous room's music going after entering a new room. Silence
    // it synchronously as a guarantee.
    try {
      musicBloc.stopUpdatingPosition();
      await musicBloc.state.audioPlayer.stop();
    } catch (_) {}

    if (RoomData.instance.room.mode == '5') {
      di<YoutubeBloc>().add(const DisposeViewYoutubeVideoEvent());
      if (RoomData.instance.room.ownerId == MyDataModel.getInstance().id) {
        sendRoomData(data: {"message": 'endVideo'});
      }
    }

    YouTubeController.isCinemaMode.value = false;
    YouTubeController.firstVideo = true;

    final controller = RoomData.instance.utdController;
    if (controller != null) {
      await controller.leave();
    }
  }

  /// Critical cleanup that must complete before entering a new room.
  Future<void> runCriticalCleanup(int roomId) async {
    // Charisma is server-authoritative now (the backend owns the per-room
    // totals); there is no client-side snapshot to clear on room switch.
    // (Firestore room_users presence removed — occupancy is engine-driven.)

    RoomData.instance.roomDataUpdates = {
      'room_intro': '',
      'room_name': '',
      'room_img': '',
      'room_type': ''
    };
    di<RoomOverlayCubit>().resetToDefault();
    RoomData.instance.adminsInRoom.clear();
    RoomData.instance.users.clear();

    RoomData.instance.reset();
    RoomBackground.imgBackground.value = "";
    RoomData.instance.room = EnterRoomModel();
  }

  /// Non-critical cleanup that can run asynchronously (fire-and-forget).
  void runDeferredCleanup() {
    try {
      di<UserBadgesBloc>().add(const InitialUserBadges());
      di<GiftBloc>().add(const ShowBannerEvent(show: false));
      di<LuckyGiftAnaimationManagerBloc>()
          .add(const InitLuckyGiftAnaimationManagerEvent());
      di<LuckyGiftBannerForReciverBloc>()
          .add(const EndLuckyGiftBannerForReciverEvent());
      di<AlphaGiftManagerBloc>().add(const EndAlphaGift());
      di<GiftBloc>().add(const ShowGiftsEvent(
        pathGift: "",
        isShowGift: false,
        giftType: ShowGiftType.svga,
      ));

      GiftUser.userOnMicsForGifts.clear();
      LuckyGiftController.instance.tempLuckyGiftData = [];
      SuperBoomController.reset();
      EmojieController.reset();
      clearPendingUserFetches();

      GiftController().userIntroData = {
        'user_name_intro': '',
        'user_image_intro': '',
        'user_vip_intro': '',
        'wappelImage': '',
        'wappelType': '',
        'wappelKeyName': {},
      };
      GiftController().resetBannerQueue();
      ShowEntroWidget.showEntro.value = null;

      PkController.timeMinutePK = 0;
      PkController.timeSecondPK = 0;
      PkController.isPK.value = false;
      PkController.showPK.value = false;
      PKWidget.isStartPK.value = false;
      PkController.scoreTeam2 = 0;
      PkController.precantgeTeam1 = 0.5;
      PkController.precantgeTeam2 = 0.5;
      PkController.scoreTeam1 = 0;
      PkController.updatePKNotifier.value = 0;

      di<RoomHandlerBloc>().add(ResetRoomHandlerEvent());

      di.resetLazySingleton<CharismaBloc>();
      di.resetLazySingleton<SendGiftBloc>();
      di.resetLazySingleton<FetchGiftBloc>();
      di.resetLazySingleton<EmojieBloc>();
      di.resetLazySingleton<ThemeBloc>();
      di.resetLazySingleton<PKBloc>();
      di.resetLazySingleton<BlockCommentsBloc>();
      di.resetLazySingleton<ClearModeBloc>();
      di.resetLazySingleton<MusicRoomBloc>();
      di.resetLazySingleton<LuckyBoxBloc>();
      di.resetLazySingleton<YoutubeBloc>();
      di.resetLazySingleton<LuckyGiftBannerBloc>();
      di.resetLazySingleton<LuckyGiftBannerForReciverBloc>();
      di.resetLazySingleton<LuckyGiftWinBloc>();
      di.resetLazySingleton<LuckyGiftAnaimationManagerBloc>();
      di.resetLazySingleton<AlphaGiftManagerBloc>();
      di.resetLazySingleton<GetSuperBombsBloc>();
      di.resetLazySingleton<GetSuperBombsThemeBloc>();
    } catch (e) {
      log('[RoomCleanupHelper] Error in deferred cleanup: $e',
          name: 'room_nav');
    }
  }
}

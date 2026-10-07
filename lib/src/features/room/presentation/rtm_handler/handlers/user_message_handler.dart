import 'package:general/src/core/index.dart';
import 'package:general/src/core/services/auth_service.dart';
import 'package:general/src/features/room/room.dart';

import '../room_message_processor.dart';

/// Handles user-related RTM messages: entries, kicks, bans, invitations,
/// emoji display, and CP animations.
class UserMessageHandler {
  final String userModelId;
  final String roomId;

  /// Shared gift controller reference for user entry animations.
  GiftController get _giftController => GiftController();

  const UserMessageHandler({
    required this.userModelId,
    required this.roomId,
  });

  void handle(CategorizedMessage msg, BuildContext? context) {
    final result = msg.payload;

    switch (msg.messageType) {
      case userEntro:
        // Skip own entry — the entering user already triggers the animation
        // locally in onEnterRoomSuccess, so processing the broadcast would
        // duplicate the entry comment/animation.
        final entroSenderId =
            result[messageContent]?["userId"]?.toString() ?? '';
        if (entroSenderId.isEmpty || entroSenderId == userModelId) break;
        if (MyDataModel.getInstance().roomEffects?.showEntring ?? true) {
          _giftController.userEntro(result, _giftController.userIntroData);
        }
        break;

      case "unableToUPMicrophone":
        if (result[messageContent]["user_id"].toString() ==
            MyDataModel.getInstance().id.toString()) {
          // Fire-and-forget: leaveSeat returns false on a backend reject; guard
          // any unexpected throw so it doesn't escape to the zone guard.
          RoomData.instance.utdController?.seatController
              .leaveSeat(MyDataModel.getInstance().id.toString())
              .catchError((_) => false);
        }
        break;

      case "unableToEnterRoom":
        _handleUnableToEnterRoom(result);
        break;

      case "kickUserfromMic":
        if (result[messageContent]["user_id"].toString() ==
            MyDataModel.getInstance().id.toString()) {
          RoomData.instance.utdController?.seatController
              .leaveSeat(MyDataModel.getInstance().id.toString())
              .catchError((_) => false);
        }
        break;

      case kicKout:
        // CRITICAL self-check: only the kicked user must act on this. The engine
        // can deliver a targeted send-data frame to more than the target (e.g.
        // when the destination identity doesn't match the connected participant
        // identity it may fan out), so without this guard the OWNER (and everyone
        // else in the room) would run the kick on themselves when they kick one
        // person. The backend now stamps the target id into the payload.
        final kickTargetId = result[messageContent]['user_id']?.toString();
        if (kickTargetId == null ||
            kickTargetId != MyDataModel.getInstance().id.toString()) {
          break;
        }
        final kickContext = SafeNavigator.context;
        if (kickContext == null) break;
        kicKoutMember(
          result,
          userModelId,
          RoomData.instance.room.id!,
          RoomData.instance.room.ownerId.toString(),
          kickContext,
        );
        break;

      case "banDevice":
        _handleBanDevice(result);
        break;

      case "kickVisitorOut":
        _handleKickVisitorOut(result, context);
        break;

      case "banAdmin":
        _handleBanAdmin(result, context);
        break;

      case "cpLovelyZego":
        showCp(result[messageContent]);
        break;

      case EmojieController.showEmojie:
        EmojieController().showingEmojie(
          userId: result[messageContent]["id_user"].toString(),
          emojieData: EmojieData(
            emojie: result[messageContent]['emoji'].toString(),
            emojieId: result[messageContent]['id'],
            length: result[messageContent]['t_length'],
            type: result[messageContent]['type'],
          ),
          timeEmojie: result[messageContent]['t_length'],
        );
        break;
    }
  }

  Future<void> _handleUnableToEnterRoom(Map<String, dynamic> result) async {
    if (result[messageContent]["user_id"].toString() ==
        MyDataModel.getInstance().id.toString()) {
      final navContext = SafeNavigator.context;
      if (navContext == null) return;
      await di<RoomStateManager>().exitRoom(
        navContext,
        callback: () {
          SafeNavigator.pop();
        },
      );
    }
  }

  Future<void> _handleBanDevice(Map<String, dynamic> result) async {
    if (result[messageContent]["userId"].toString() ==
        MyDataModel.getInstance().id.toString()) {
      final navContext = SafeNavigator.context;
      if (navContext == null) return;
      await di<RoomStateManager>().exitRoom(navContext);
      // Route through AuthService.clearToken() (single auth-teardown path) so the
      // persistent HTTP cache is purged on this forced logout, instead of
      // deleting TOKEN_KEY directly (which bypassed DioFactory.clearHttpCache()).
      AuthService().clearToken();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navKey.currentContext?.pushNamedAndRemoveUntil(
          Routes.intro,
          arguments: Methods.getLang() == "en"
              ? "${result[messageContent]["reason_en"]} \n For ${result[messageContent]["duration"]} Hours"
              : "${result[messageContent]["reason_ar"]} \n لمدة ${result[messageContent]["duration"]} ساعة",
        );
      });
    }
  }

  Future<void> _handleKickVisitorOut(
    Map<String, dynamic> result,
    BuildContext? context,
  ) async {
    if (context == null) return;
    if (MyDataModel.getInstance().id.toString() ==
        result[messageContent]['visitorId'].toString()) {
      await di<RoomStateManager>().exitRoom(
        context,
        callback: () {
          Navigator.popUntil(
              context, (route) => route.settings.name == Routes.layout);
          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: ColorManager.transparent,
                contentPadding: EdgeInsets.zero,
                content: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    height: 50.h,
                    width: 200.w,
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: ColorManager.redIcons,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        StringManager.bloc(
                                durationKickout: result[messageContent]
                                        ['duration']
                                    .toString())
                            .tr(),
                        style:  TextStyle(color: ColorManager.textPrimary),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }

  Future<void> _handleBanAdmin(
    Map<String, dynamic> result,
    BuildContext? context,
  ) async {
    if (context == null) return;
    if (MyDataModel.getInstance().id.toString() ==
        result[messageContent]['adminId'].toString()) {
      await di<RoomStateManager>().exitRoom(
        context,
        callback: () {
          Navigator.popUntil(
              context, (route) => route.settings.name == Routes.layout);
          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: ColorManager.transparent,
                contentPadding: EdgeInsets.zero,
                content: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    height: 50.h,
                    width: 200.w,
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: ColorManager.redIcons,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        StringManager.youAreRemovedFromRoomAdmins.tr(),
                        style:  TextStyle(color: ColorManager.textPrimary),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }
}

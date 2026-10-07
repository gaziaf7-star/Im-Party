import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/moment.dart';
import 'package:general/src/features/moment/presentation/view/component/moment_content/moment_content_screen.dart';
import 'package:general/src/features/theme2_app/user_profile/presentation/screens/theme2_visitor_profile_page.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/view/main_reels_screen.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/features/setting/presentation/invitation/bloc/invite_bloc.dart';

final class DynamicLinkHandler {
  DynamicLinkHandler._();

  static final instance = DynamicLinkHandler._();

  final _appLinks = AppLinks();
  Uri? _lastProcessedUri;
  StreamSubscription<Uri?>? _linkSubscription;

  Future<void> initialize() async {
    _linkSubscription?.cancel();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? initialLink) {
        if (initialLink != null) {
          _handleLinkData(initialLink);
        }
      },
      onError: (error) {},
    );
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  void _handleLinkData(Uri data) async {
    _lastProcessedUri = data;
    final String? encodedData = data.queryParameters['data'];

    if (encodedData != null) {
      try {
        // Check if this is a room link (created by createRoomLink)
        if (encodedData.startsWith('room_')) {
          final String roomEncodedData =
              encodedData.substring(5); // Remove 'room_' prefix
          final String decodedRoomId =
              utf8.decode(base64Url.decode(roomEncodedData));
          final String roomId =
              jsonDecode(decodedRoomId); // roomId is encoded as JSON string

          final context = SafeNavigator.context;
          if (context == null) return;

          if (di<RoomStateManager>().isInRoom) {
            if (RoomData.instance.room.id.toString() == roomId) {
              final utdCtrl = RoomData.instance.utdController;
              if (utdCtrl != null && utdCtrl.minimize.isMinimizing) {
                utdCtrl.minimize.restoreWithNavigator();
                return;
              }
              // Check if live room is minimized - navigate to it
              if (di<RoomStateManager>().currentState ==
                  RoomStateType.videoMinimized) {
                Navigator.pushNamed(
                  context,
                  Routes.roomScreen,
                  arguments: RoomParameter(
                    myDataModel: MyDataModel.getInstance(),
                    isLocked: true,
                    isHost: MyDataModel.getInstance().id.toString() ==
                        RoomData.instance.room.ownerId.toString(),
                    roomId: RoomData.instance.room.id.toString(),
                    ownerId: RoomData.instance.room.ownerId.toString(),
                  ),
                );
              } else {
                return;
              }
            } else {
              await di<RoomStateManager>().exitRoom(
                context,
                callback: () {
                  final cbContext = SafeNavigator.context;
                  if (cbContext == null) return;
                  if (NavObserver.currentRoute.value == Routes.roomScreen ||
                      NavObserver.currentRoute.value ==
                          Routes.liveRoomScreen) {
                    Navigator.popUntil(
                      cbContext,
                      (route) {
                        return route.settings.name == Routes.layout;
                      },
                    );
                  }
                  Navigator.pushNamed(
                    cbContext,
                    Routes.roomHandlerScreen,
                    arguments: roomId,
                  );
                },
              );
            }
          } else {
            Navigator.pushNamed(
              context,
              Routes.roomHandlerScreen,
              arguments: roomId,
            );
          }

          return;
        } else if (encodedData.startsWith('reel_')) {
          final String roomEncodedData =
              encodedData.substring(5); // Remove 'reel_' prefix
          final String decodedRoomId =
              utf8.decode(base64Url.decode(roomEncodedData));
          final String reelId =
              jsonDecode(decodedRoomId); // id is encoded as JSON string

          if (ReelsScreen.currentReelId == reelId) {
            return;
          }

          final context = SafeNavigator.context;
          if (context == null) return;

          if (ReelsScreen.currentReelId != "" &&
              ReelsScreen.currentReelId != reelId) {
            Navigator.popUntil(
              context,
              (route) {
                return route.settings.name == Routes.layout;
              },
            );
            Navigator.pushNamed(
              context,
              Routes.reelsScreen,
              arguments: reelId,
            );
          } else {
            Navigator.pushNamed(
              context,
              Routes.reelsScreen,
              arguments: reelId,
            );
          }

          return;
        } else if (encodedData.startsWith('profile_')) {
          final String userId =
              encodedData.substring(8); // Remove 'profile_' prefix

          if (Theme2VisitorProfilePage.currentUserId == userId) {
            return;
          }

          final context = SafeNavigator.context;
          if (context == null) return;

          if (Theme2VisitorProfilePage.currentUserId != "" &&
              Theme2VisitorProfilePage.currentUserId != userId) {
            Navigator.popUntil(
              context,
              (route) {
                return route.settings.name == Routes.layout;
              },
            );
            Methods().userProfileNavigator(
              context: context,
              userId: userId,
            );
          } else {
            Methods().userProfileNavigator(
              context: context,
              userId: userId,
            );
          }

          return;
        } else if (encodedData.startsWith('invitation_code_')) {
          if (_lastProcessedUri == data) return;
          final String roomEncodedData =
              encodedData.substring(16); // Remove 'invitation_code_' prefix
          final String decodedRoomId =
              utf8.decode(base64Url.decode(roomEncodedData));
          final String code =
              jsonDecode(decodedRoomId); // code is encoded as JSON string
          di<SendInviteBloc>().add(SendCodeEvent(code: code));
          return;
        } else {
          final String decodedData = utf8.decode(base64Url.decode(encodedData));
          final Map<String, dynamic> parsedData = jsonDecode(decodedData);

          if (parsedData['path'] == "moment") {
            MomentModel momentModel = MomentModel.fromJson(parsedData['data']);

            if (MomentContentScreen.currentMomentId ==
                momentModel.momentId.toString()) {
              return;
            }

            final context = SafeNavigator.context;
            if (context == null) return;

            if (MomentContentScreen.currentMomentId != "" &&
                MomentContentScreen.currentMomentId !=
                    momentModel.momentId.toString()) {
              Navigator.popUntil(
                context,
                (route) {
                  return route.settings.name == Routes.layout;
                },
              );
              di<MomentBloc>()
                  .add(MomentShareEvent(currentMoment: momentModel));
              Navigator.pushNamed(
                context,
                Routes.momentContent,
                arguments: MomentContentParameter(
                  type: MomentType.recommend,
                  currentMomentIndex: 0,
                  momentBloc: di<MomentBloc>(),
                  momentId: momentModel.momentId,
                  currentMoment: momentModel,
                ),
              );
            } else {
              di<MomentBloc>()
                  .add(MomentShareEvent(currentMoment: momentModel));
              Navigator.pushNamed(
                context,
                Routes.momentContent,
                arguments: MomentContentParameter(
                  type: MomentType.recommend,
                  currentMomentIndex: 0,
                  momentBloc: di<MomentBloc>(),
                  momentId: momentModel.momentId,
                  currentMoment: momentModel,
                ),
              );
            }
          }
        }
      } catch (error, stackTrace) {
        log('Error processing dynamic link: $error',
            name: 'Dynamic Link Handler', stackTrace: stackTrace);
      }
    }
  }

  Future<String> createProductLink(
      Map<String, dynamic> data, String type) async {
    final String encodedData = base64UrlEncode(utf8.encode(jsonEncode(data)));
    return '${EndPoints.domainURL}/deeplink?data=$encodedData';
  }

  Future<String> createDynamicLink(String id, String type) async {
    if (type == "profile") {
      return '${EndPoints.domainURL}/deeplink?data=${type}_$id';
    } else {
      final String encodedData = base64UrlEncode(utf8.encode(jsonEncode(id)));
      return '${EndPoints.domainURL}/deeplink?data=${type}_$encodedData';
    }
  }
}

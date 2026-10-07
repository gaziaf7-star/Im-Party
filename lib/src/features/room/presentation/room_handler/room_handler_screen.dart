import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RoomHandlerScreen extends StatefulWidget {
  final String roomId;
  const RoomHandlerScreen({super.key, required this.roomId});

  @override
  State<RoomHandlerScreen> createState() => _RoomHandlerScreenState();
}

class _RoomHandlerScreenState extends State<RoomHandlerScreen> {
  @override
  void initState() {
    super.initState();

    final roomStateManager = di<RoomStateManager>();
    final targetRoomId = int.tryParse(widget.roomId);

    // Check if user is already in the same room (using RoomStateManager)
    if (roomStateManager.isInRoom &&
        roomStateManager.currentRoomId == targetRoomId) {
      // Audio room minimized — restore via UTD package
      final utdCtrl = RoomData.instance.utdController;
      if (utdCtrl != null && utdCtrl.minimize.isMinimizing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
          utdCtrl.minimize.restoreWithNavigator();
        });
        return;
      }
      // Video room minimized — restore via state manager
      if (roomStateManager.isMinimized) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
        });
        return;
      }
      // Already in room full screen - just pop
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return;
    }

    // If in a different room, need to exit first (handled by RoomStateManager)
    if (roomStateManager.isInRoom &&
        roomStateManager.currentRoomId != targetRoomId) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Exit the current room, then enter the target through the fetch-based
        // EnterRoomEvent flow below. That flow loads the room record (incl.
        // streamType), so the BlocListener routes live vs audio correctly —
        // building an empty RoomEntity here always resolved isLive=false and
        // sent live rooms to the audio screen.
        final navContext = SafeNavigator.context;
        if (navContext == null) return;
        await di<RoomStateManager>().exitRoom(navContext);
        if (!mounted) return;
        di<RoomHandlerBloc>().add(
          EnterRoomEvent(
            context,
            isVip: 0,
            roomId: widget.roomId,
            roomPassword: "",
          ),
        );
      });
      return;
    }

    // Not in any room - proceed with entering
    di<RoomHandlerBloc>().add(
      EnterRoomEvent(
        context,
        isVip: 0,
        roomId: widget.roomId,
        roomPassword: "",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomHandlerBloc, RoomHandlerStates>(
      bloc: di<RoomHandlerBloc>(),
      listener: (context, state) {
        if (state is EnterRoomSuccesMessageState) {
          Navigator.pop(context);
          RoomData.instance.room = state.room;

          final navContext = SafeNavigator.context;
          if (navContext == null) return;
          Navigator.pushNamed(
            navContext,
            state.room.streamType == "live"
                ? Routes.liveRoomScreen
                : Routes.roomScreen,
            arguments: RoomParameter(
              roomId: state.room.id.toString(),
              ownerId: state.room.ownerId.toString(),
              myDataModel: MyDataModel.getInstance(),
              isLocked: true,
              fromDynamicLink: true,
              isHost: MyDataModel.getInstance().id == state.room.ownerId,
              isGame: false,
              specialIdImage: MyDataModel.getInstance().id == state.room.ownerId
                  ? MyDataModel.getInstance().specialIdImage
                  : state.room.ownerSpecialId,
              imageColorEntity:
                  MyDataModel.getInstance().id == state.room.ownerId
                      ? MyDataModel.getInstance().imageColorEntity
                      : state.room.ownerImageColor,
            ),
          );
        } else if (state is EnterRoomErrorMessageState) {
          Navigator.pop(context);
          Methods.showToast(
            context,
            message: state.errorMessage,
            isError: true,
          );
        }
      },
      child: Scaffold(
        backgroundColor: ColorManager.scaffoldBg,
        body: Center(
          child: SizedBox(
            height: 320.h,
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: ColorManager.primary,
              size: 35.h,
            ),
          ),
        ),
      ),
    );
  }
}

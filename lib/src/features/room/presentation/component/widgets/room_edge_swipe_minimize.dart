import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/gift_bloc/gift_bloc.dart';
import 'package:general/src/features/room/presentation/gifts/controller/lucky_gift_service.dart';
import 'package:general/src/features/room/presentation/manager/alpha_gift_manager/alpha_gift_manager_bloc.dart';
import 'package:general/src/features/room/presentation/manager/alpha_gift_manager/alpha_gift_manager_event.dart';
import 'package:general/src/features/room/room.dart';

/// Swipe in from the LEFT edge to minimize the audio room.
///
/// The room page follows the finger to the right (the page underneath shows
/// through, like a back swipe); release past the halfway point, or with a
/// flick, and the room minimizes into the floating bubble. Release early and
/// it springs back. The room route's own slide transition does the motion, so
/// the drag, the release and the exit button's minimize all look the same.
class RoomEdgeSwipeMinimize extends StatefulWidget {
  const RoomEdgeSwipeMinimize({super.key, required this.child});

  final Widget child;

  @override
  State<RoomEdgeSwipeMinimize> createState() => _RoomEdgeSwipeMinimizeState();
}

class _RoomEdgeSwipeMinimizeState extends State<RoomEdgeSwipeMinimize> {
  NavigatorState? _navigator;
  AnimationController? _controller;
  bool _active = false;

  /// Width of the touch strip along the left edge.
  static const double _edgeWidth = 22;

  void _onStart(DragStartDetails details) {
    final route = ModalRoute.of(context);
    if (route == null) return;
    // ModalRoute is a TransitionRoute: its animation controller drives the
    // slide, and is null until the route has been installed.
    final AnimationController? controller = route.controller;
    if (controller == null) return;
    final navigator = Navigator.of(context);
    // Only while the room is fully shown and there is a page to reveal.
    if (!navigator.canPop() || !controller.isCompleted) return;
    if (navigator.userGestureInProgress) return;
    _navigator = navigator;
    _controller = controller;
    _active = true;
    navigator.didStartUserGesture();
  }

  void _onUpdate(DragUpdateDetails details) {
    if (!_active) return;
    final width = MediaQuery.sizeOf(context).width;
    _controller!.value -= (details.primaryDelta ?? 0) / width;
  }

  void _onEnd(DragEndDetails details) {
    if (!_active) return;
    _active = false;
    final navigator = _navigator!;
    final controller = _controller!;
    final width = MediaQuery.sizeOf(context).width;
    final velocity = details.velocity.pixelsPerSecond.dx / width;

    final bool minimize =
        velocity.abs() >= 1.0 ? velocity > 0 : controller.value < 0.62;

    if (minimize && _minimizeNow()) {
      // The room route is popping; let go of the gesture once it has settled.
      _finishGesture(navigator, controller);
      return;
    }
    // Not far enough (or minimizing isn't allowed right now): spring back.
    controller.animateTo(
      1.0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
    _finishGesture(navigator, controller);
  }

  void _onCancel() {
    if (!_active) return;
    _active = false;
    final navigator = _navigator!;
    final controller = _controller!;
    controller.animateTo(
      1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    _finishGesture(navigator, controller);
  }

  void _finishGesture(NavigatorState navigator, AnimationController c) {
    if (!c.isAnimating) {
      navigator.didStopUserGesture();
      return;
    }
    void listener(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        c.removeStatusListener(listener);
        navigator.didStopUserGesture();
      }
    }

    c.addStatusListener(listener);
  }

  /// Same checks and teardown as the exit panel's "Minimize" button, then the
  /// kit's startMinimize (which pops the room route).
  bool _minimizeNow() {
    if (PkController.isPK.value == true) {
      Methods.showToast(context,
          message: StringManager.cantSave.tr(), isError: true);
      return false;
    }
    if (RoomData.instance.room.mode == '5') {
      Methods.showToast(
        context,
        message: StringManager.youCantSaveRoomBecauseCinemaMode.tr(),
        isError: true,
      );
      return false;
    }
    final controller = RoomData.instance.utdController;
    if (controller == null || controller.minimize.isMinimizing) return false;

    ShowEntroWidget.showEntro.value = null;
    di<GiftBloc>().add(
      const ShowGiftsEvent(
        isShowGift: false,
        pathGift: '',
        giftType: ShowGiftType.svga,
      ),
    );
    di<AlphaGiftManagerBloc>().add(const EndAlphaGift());
    GiftController().normalGiftsToShow.clear();
    di<LuckyGiftAnaimationManagerBloc>()
        .add(const InitLuckyGiftAnaimationManagerEvent());
    LuckyGiftService.instance.endAllLuckyGift();
    SuperBoomController.superBoomVideo.value = "";
    SuperBoomController.superBoomVideoType.value = "";

    final room = RoomData.instance.room;
    final myData = MyDataModel.getInstance();
    final isHost = myData.id == room.ownerId;
    return controller.minimize.startMinimize(
      context,
      routeNameOverride: Routes.roomScreen,
      routeArgumentsOverride: RoomParameter(
        myDataModel: myData,
        isHost: isHost,
        isLocked: RoomData.instance.isRoomLocked.value,
        roomId: room.id.toString(),
        ownerId: room.ownerId.toString(),
        specialIdImage: isHost ? myData.specialIdImage : room.ownerSpecialId,
        imageColorEntity:
            isHost ? myData.imageColorEntity : room.ownerImageColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: _edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _onStart,
            onHorizontalDragUpdate: _onUpdate,
            onHorizontalDragEnd: _onEnd,
            onHorizontalDragCancel: _onCancel,
          ),
        ),
      ],
    );
  }
}

/// Route for the audio room: slides in from the right and slides back out to
/// the right. While a finger is dragging (see [RoomEdgeSwipeMinimize]) the
/// motion follows it 1:1; otherwise it eases.
Route<T> roomSlideRoute<T>({
  required RouteSettings settings,
  required WidgetBuilder builder,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, _, __) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final navigator = Navigator.of(context);
      return AnimatedBuilder(
        animation: animation,
        // Own layer: the (heavy) room is painted once and only translated while
        // it slides, so the drag and the transitions stay smooth.
        child: RepaintBoundary(child: child),
        builder: (context, child) {
          final double t;
          if (navigator.userGestureInProgress) {
            t = animation.value;
          } else if (animation.status == AnimationStatus.reverse) {
            t = Curves.easeInCubic.transform(animation.value);
          } else {
            t = Curves.easeOutCubic.transform(animation.value);
          }
          return FractionalTranslation(
            translation: Offset(1.0 - t, 0),
            child: child,
          );
        },
      );
    },
  );
}

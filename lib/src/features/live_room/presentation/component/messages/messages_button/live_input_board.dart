// Flutter imports:
import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/component/messages/messages_button/live_message_input.dart';

/// Live-room in-room message input board — a fork of the audio room's
/// `AudioRoomInRoomMessageInputBoard`. Hosts [LiveInRoomMessageInput] in a
/// dismissible, transparent modal route so messages are sent through the LIVE
/// chat channel.
/// @nodoc
class LiveInRoomMessageInputBoard extends ModalRoute<String> {
  LiveInRoomMessageInputBoard({
    this.mention,
    this.rootNavigator = false,
  }) : super();

  final String? mention;
  final bool rootNavigator;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => const Color(0xff171821).withValues(alpha: 0.4);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(
                context,
                rootNavigator: rootNavigator,
              ).pop(),
              child: Container(color: Colors.transparent),
            ),
          ),
          LiveInRoomMessageInput(
            mention: mention,
            backgroundColor: Colors.white,
            inputBackgroundColor: ColorManager.white,
            textColor: Colors.black,
            textHintColor: Colors.black.withValues(alpha: 0.5),
            buttonColor: ColorManager.primary,
            onSubmit: () {
              Navigator.of(
                context,
                rootNavigator: rootNavigator,
              ).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }
}

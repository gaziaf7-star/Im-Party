import 'package:reaction_askany/models/emotions.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

class ReactController {
  ReactController._privateConstructor();

  static final ReactController _instance =
  ReactController._privateConstructor();

  static ReactController get instance => _instance;

  /// Reactions for [entity] as a pure function — no shared mutable list. The
  /// previous singleton `_emojis` was populated in build() and read by every
  /// `_EmojisWidget`, so an isolated rebuild could paint another message's
  /// reactions on the wrong bubble.
  static List<Emotions> emojisFor(MessagesEntity entity) =>
      [for (final r in entity.reacts ?? const <ReactEntity>[]) emotionFor(r.react)];

  static Emotions emotionFor(String reactType) {
    switch (reactType) {
      case "like":
        return Emotions.like;
      case "wow":
        return Emotions.wow;
      case "love":
        return Emotions.love;
      case "care":
        return Emotions.care;
      case "angry":
        return Emotions.angry;
      case "haha":
        return Emotions.haha;
      default:
        return Emotions.like;
    }
  }

  String _convertReactFromEnumToStringKey(Emotions emotion) {
    switch (emotion) {
      case Emotions.like:
        return 'like';
      case Emotions.wow:
        return 'wow';
      case Emotions.haha:
        return 'haha';
      case Emotions.angry:
        return 'angry';
      case Emotions.care:
        return 'care';
      case Emotions.love:
        return 'love';
      }
  }

  Emotions? emotionPicked(MessagesEntity entity) {
    if (entity.reacts != null) {
      for (final element in entity.reacts!) {
        if (element.userReact?.userId == MyDataModel.getInstance().id) {
          return emotionFor(element.react);
        }
      }
    }
    return null;
  }

  void handlePressed(MessagesEntity entity, Emotions emotion) {
    final reactType = _convertReactFromEnumToStringKey(emotion);
    final messageId = int.tryParse('${entity.id}');

    // The reaction is persisted via the drift repo + outbox inside the bloc
    // handler (LocalUpdateReactMessagesEvent). The legacy HTTP react bloc is no
    // longer fired here — it was a pure double-send on the realtime transport.
    // Carry the messageId on the event so the handler doesn't read the app-bar
    // selection (cleared by InitAppBarEvent below before the async handler runs).
    di<FetchMessagesBloc>().add(
      LocalUpdateReactMessagesEvent(reactType: reactType, messageId: messageId),
    );
    di<ToggleAppBarBloc>().add(const InitAppBarEvent());
  }
}
import 'package:general/src/core/index.dart';

class ChatSettingsEntity extends Equatable {
  final bool? chatWithFriends;
  final bool? chatWithFollowers;
  final bool? chatWithAll;

  const ChatSettingsEntity({
     this.chatWithFriends,
     this.chatWithFollowers,
     this.chatWithAll,
  });

  @override
  List<Object?> get props => [
        chatWithFriends,
        chatWithFollowers,
        chatWithAll,
      ];
}

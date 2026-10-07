import 'package:equatable/equatable.dart';

class EmojiEntity extends Equatable {
  final int id;
  final int pid;
  final String name;
  final String emoji;

  /// Static picker thumbnail (backend's `show_img`). Used only for the
  /// non-animating grid preview -- sending/playing on a seat always uses
  /// [emoji].
  final String showImg;
  final int tLength;
  final int sort;
  final String userId;
  final String type;

  const EmojiEntity({
    required this.id,
    required this.pid,
    required this.name,
    required this.emoji,
    required this.showImg,
    required this.tLength,
    required this.sort,
    required this.userId,
    required this.type,
  });

  @override
  List<Object?> get props => [
        id,
        pid,
        name,
        emoji,
        showImg,
        tLength,
        sort,
        userId,
        type,
      ];
}

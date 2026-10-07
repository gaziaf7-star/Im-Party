import '../../../../core/index.dart';

/// What a broadcast was worth, shown to the host once it ends.
///
/// The backend computes this while tearing the session down, because every
/// figure is derived from state the teardown then clears.
class RoomSessionSummaryModel extends Equatable {
  const RoomSessionSummaryModel({
    required this.roomId,
    required this.durationSeconds,
    required this.viewers,
    required this.coinsReceived,
    required this.giftsReceived,
    required this.newFollowers,
    required this.topGifters,
  });

  final int roomId;

  /// Zero when the server had no start time for the session — an unknown
  /// duration, not a zero-length one.
  final int durationSeconds;

  /// Distinct people who came in, so one person rejoining is not five viewers.
  final int viewers;
  final int coinsReceived;
  final int giftsReceived;
  final int newFollowers;
  final List<SessionGifterModel> topGifters;

  factory RoomSessionSummaryModel.fromJson(Map<String, dynamic> json) {
    return RoomSessionSummaryModel(
      roomId: parseValue<int>(json['room_id'], 0),
      durationSeconds: parseValue<int>(json['duration_seconds'], 0),
      viewers: parseValue<int>(json['viewers'], 0),
      coinsReceived: parseValue<int>(json['coins_received'], 0),
      giftsReceived: parseValue<int>(json['gifts_received'], 0),
      newFollowers: parseValue<int>(json['new_followers'], 0),
      topGifters: (json['top_gifters'] is List)
          ? (json['top_gifters'] as List)
              .whereType<Map<String, dynamic>>()
              .map(SessionGifterModel.fromJson)
              .toList()
          : const [],
    );
  }

  /// `1:05:20` for anything over an hour, `05:20` below it — a leading `00:`
  /// on a five-minute session reads like a bug.
  String get formattedDuration {
    final duration = Duration(seconds: durationSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return duration.inHours > 0
        ? '${duration.inHours}:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  List<Object?> get props => [
        roomId,
        durationSeconds,
        viewers,
        coinsReceived,
        giftsReceived,
        newFollowers,
        topGifters,
      ];
}

class SessionGifterModel extends Equatable {
  const SessionGifterModel({
    required this.userId,
    required this.name,
    required this.image,
    required this.coins,
  });

  final int userId;
  final String name;
  final String image;
  final int coins;

  factory SessionGifterModel.fromJson(Map<String, dynamic> json) {
    return SessionGifterModel(
      userId: parseValue<int>(json['user_id'], 0),
      name: parseValue<String>(json['name'], ''),
      image: parseValue<String>(json['image'], ''),
      coins: parseValue<int>(json['coins'], 0),
    );
  }

  @override
  List<Object?> get props => [userId, name, image, coins];
}

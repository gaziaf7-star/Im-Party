import 'package:equatable/equatable.dart';

/// Represents a participant in the audio room.
/// Replaces `UTDParticipant`.
class UTDParticipant extends Equatable {
  /// Unique user ID.
  final String id;

  /// Display name.
  final String name;

  /// Whether the participant's mic is enabled.
  final bool isMicEnabled;

  /// Whether the participant is currently speaking.
  final bool isSpeaking;

  /// Custom attributes (e.g., 'fr' = frame, 'frt' = frame type, 'cn' = color name).
  final Map<String, String> attributes;

  const UTDParticipant({
    required this.id,
    required this.name,
    this.isMicEnabled = false,
    this.isSpeaking = false,
    this.attributes = const {},
  });

  UTDParticipant copyWith({
    String? id,
    String? name,
    bool? isMicEnabled,
    bool? isSpeaking,
    Map<String, String>? attributes,
  }) {
    return UTDParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      isMicEnabled: isMicEnabled ?? this.isMicEnabled,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  List<Object?> get props => [id, name, isMicEnabled, isSpeaking, attributes];
}

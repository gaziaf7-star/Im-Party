import 'package:general/src/features/room/domain/entities/lucky_box_entity.dart';

import '../../../../core/index.dart';

class LuckyBoxModel extends LuckyBoxEntity {
  const LuckyBoxModel({required super.normalBox, required super.superBox});

  factory LuckyBoxModel.fromJson(Map<String, dynamic> json) {
    return LuckyBoxModel(
      normalBox: List<TypeBoxModel>.from(
        (json['normal'] is List ? json['normal'] as List : const [])
            .whereType<Map<String, dynamic>>()
            .map(
          (element) => TypeBoxModel.fromJson(element),
        ),
      ).toList(),
      superBox: List<TypeBoxModel>.from(
        (json['super'] is List ? json['super'] as List : const [])
            .whereType<Map<String, dynamic>>()
            .map(
              (element) => TypeBoxModel.fromJson(element),
            )
            .toList(),
      ),
    );
  }

  @override
  List<Object?> get props => [normalBox, superBox];
}

class TypeBoxModel extends TypeBoxEntity {
  const TypeBoxModel({
    required super.id,
    required super.type,
    required super.coins,
    required super.userNum,
    required super.isLabel,
    required super.time,
  });

  factory TypeBoxModel.fromJson(Map<String, dynamic> json) => TypeBoxModel(
        id: json['id'],
        type: json['type'],
        coins: json['coins'] ?? 0,
        userNum: json['users_num'] == null
            ? null
            : json['users_num'] is int
                ? parseValue<int>(json['users_num'], 0)
                : _userNumOrDefault(
                    parseValue<List<String>>(json['users_num'], [])),
        isLabel: json['is_label'],
        time: parseValue<String>(json['time'], '0'),
      );

  /// Fallback quantity options (1/3/5/7/10 winners) when the admin panel
  /// hasn't configured any real `users_num` for this box tier, on request.
  ///
  /// The admin panel doesn't actually send `[]` for "unconfigured" -- it
  /// sends a list holding ONE blank string (`[""]`). `List.isEmpty` is false
  /// for that (length 1), so the old `userNum.isEmpty` check never tripped;
  /// the blank string silently became the only "quantity" option, which is
  /// why the picker showed a single empty pill (and `[""]`/`[]` print
  /// identically, which is what made this so hard to spot from logs alone).
  /// Filtering out blank entries first makes both cases hit the fallback.
  static List<String> _userNumOrDefault(List<String> userNum) {
    final real = userNum.where((e) => e.trim().isNotEmpty).toList();
    return real.isEmpty ? const ['1', '3', '5', '7', '10'] : real;
  }

  @override
  List<Object?> get props => [id, type, coins, userNum, isLabel, time];
}

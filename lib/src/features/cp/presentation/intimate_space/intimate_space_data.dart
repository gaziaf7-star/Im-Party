import 'package:general/src/core/index.dart';

/// The four relationship kinds of the Intimate Space page, in tab order.
enum RelationKind { cp, bestFriend, sister, brother }

extension RelationKindX on RelationKind {
  String get label => switch (this) {
    RelationKind.cp => 'CP',
    RelationKind.bestFriend => 'Best Friend',
    RelationKind.sister => 'Sister',
    RelationKind.brother => 'Brother',
  };

  /// "Become sisters" style wording for the level-1 requirement.
  String get becomeText => switch (this) {
    RelationKind.cp => 'Become a CP',
    RelationKind.bestFriend => 'Become best friends',
    RelationKind.sister => 'Become sisters',
    RelationKind.brother => 'Become brothers',
  };

  IconData get icon => switch (this) {
    RelationKind.cp => Icons.favorite_rounded,
    RelationKind.bestFriend => Icons.handshake_rounded,
    RelationKind.sister => Icons.girl_rounded,
    RelationKind.brother => Icons.boy_rounded,
  };

  /// `type` sent to `cp-levels-gifts` (null = the CP table).
  String? get levelsType => switch (this) {
    RelationKind.cp => null,
    RelationKind.bestFriend => 'friend',
    RelationKind.sister => 'sister',
    RelationKind.brother => 'brother',
  };

  /// Which kind a server relation is, from its `type` / `title`.
  static RelationKind classify(String type, String title) {
    final s = '$type $title'.toLowerCase();
    // Couple words first: "girlfriend" / "boyfriend" also contain "friend".
    const couple = [
      'girlfriend',
      'girl friend',
      'boyfriend',
      'boy friend',
      'lover',
      'couple',
      'wife',
      'husband',
      'love',
      'cp',
    ];
    if (couple.any(s.contains)) return RelationKind.cp;
    if (s.contains('sister') || s.contains('sis')) return RelationKind.sister;
    if (s.contains('brother') || s.contains('bro')) return RelationKind.brother;
    if (s.contains('friend') || s.contains('bestie') || s.contains('close')) {
      return RelationKind.bestFriend;
    }
    return RelationKind.cp;
  }
}

/// One relationship of the profile owner with a partner.
class IntimateBond {
  final RelationKind kind;
  final String relationTitle;
  final String partnerId;
  final String partnerName;
  final String partnerImage;
  final String partnerUuid;
  final int level;
  final int points;

  /// 0..1 progress towards the next level, when the server sends it.
  final double? progress;

  const IntimateBond({
    required this.kind,
    required this.relationTitle,
    required this.partnerId,
    required this.partnerName,
    required this.partnerImage,
    required this.partnerUuid,
    required this.level,
    required this.points,
    this.progress,
  });

  static IntimateBond? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final user = raw['user'] is Map ? raw['user'] as Map : const {};
    final relation = raw['relation'] is Map ? raw['relation'] as Map : const {};
    final partnerId = '${user['id'] ?? ''}';
    if (partnerId.isEmpty || partnerId == '0') return null;
    final type = '${relation['type'] ?? ''}';
    final title = '${relation['title'] ?? ''}';
    final ratio = double.tryParse('${raw['ratio'] ?? ''}');
    final di = int.tryParse('${raw['di'] ?? 0}') ?? 0;
    final next = int.tryParse('${raw['next_level'] ?? 0}') ?? 0;
    double? progress;
    if (ratio != null) {
      progress = (ratio > 1 ? ratio / 100 : ratio).clamp(0.0, 1.0);
    } else if (next > 0) {
      progress = (di / next).clamp(0.0, 1.0);
    }
    return IntimateBond(
      kind: RelationKindX.classify(type, title),
      relationTitle: title,
      partnerId: partnerId,
      partnerName: '${user['name'] ?? ''}',
      partnerImage: '${user['image'] ?? ''}',
      partnerUuid: '${user['uid'] ?? user['uuid'] ?? partnerId}',
      level: int.tryParse('${raw['level'] ?? 0}') ?? 0,
      points: di,
      progress: progress,
    );
  }
}

class IntimateReward {
  final String title;
  final String image;

  const IntimateReward({required this.title, required this.image});
}

int _int(Object? v) => int.tryParse('${v ?? ''}') ?? 0;

String _str(Object? v) {
  final s = '${v ?? ''}';
  return s == 'null' ? '' : s;
}

class IntimateLevel {
  final int level;
  final String title;
  final bool have;
  final String image;

  /// Admin `effect` for the level (the mic-link animation), may be empty.
  final String effect;

  /// Intimacy the pair needs to reach this level (`need_intimacy`).
  final int needIntimacy;

  /// What reaching the level gives (admin `rewards`, plus legacy `gifts`).
  final List<IntimateReward> rewards;

  /// What the level unlocks (admin `privileges`: badge, mic link, ...).
  final List<IntimateReward> privileges;

  const IntimateLevel({
    required this.level,
    required this.title,
    required this.have,
    required this.image,
    this.effect = '',
    required this.needIntimacy,
    required this.rewards,
    required this.privileges,
  });

  static IntimateLevel fromJson(Map raw) {
    final rewards = <IntimateReward>[];
    final adminRewards = raw['rewards'];
    if (adminRewards is List) {
      for (final r in adminRewards) {
        if (r is! Map) continue;
        final title = _str(r['title']);
        final count = _int(r['count']);
        final days = _int(r['days']);
        final suffix = [
          if (count > 1) 'x$count',
          if (days > 0) '${days}d',
        ].join(' · ');
        rewards.add(
          IntimateReward(
            title: suffix.isEmpty ? title : '$title $suffix',
            image: _str(r['image']),
          ),
        );
      }
    }
    final gifts = raw['gifts'];
    if (gifts is List) {
      for (final g in gifts) {
        if (g is! Map) continue;
        final images = g['images'];
        var image = '';
        if (images is List && images.isNotEmpty) {
          image = '${images.first}';
        } else if (g['image'] != null) {
          image = '${g['image']}';
        }
        rewards.add(IntimateReward(title: _str(g['title']), image: image));
      }
    }
    final privileges = <IntimateReward>[];
    final adminPrivileges = raw['privileges'];
    if (adminPrivileges is List) {
      for (final p in adminPrivileges) {
        if (p is! Map) continue;
        privileges.add(
          IntimateReward(
            title: _str(p['title']),
            image: _str(p['icon'] ?? p['image']),
          ),
        );
      }
    }
    var image = _str(raw['image'] ?? raw['img'] ?? raw['icon']);
    if (image.isEmpty) {
      image = rewards.isNotEmpty ? rewards.first.image : '';
    }
    return IntimateLevel(
      level: _int(raw['level']),
      title: _str(raw['title']),
      have: raw['have'] == true || '${raw['have']}' == '1',
      image: image,
      effect: _str(raw['effect']),
      needIntimacy: _int(raw['need_intimacy']),
      rewards: rewards,
      privileges: privileges,
    );
  }
}

/// Where a pair stands on one level of the table.
class LevelStatus {
  final bool unlocked;

  /// The first level not reached yet — the one being worked towards.
  final bool isNext;

  /// 0..1 towards this level.
  final double progress;

  /// The pair's intimacy now, and what this level needs.
  final int intimacy;
  final int need;

  int get remaining => (need - intimacy).clamp(0, need);

  const LevelStatus({
    required this.unlocked,
    required this.isNext,
    required this.progress,
    required this.intimacy,
    required this.need,
  });

  /// Level the pair has really reached. The server's `level` stays 0 after
  /// binding, so it is also worked out from the table: every level whose
  /// `need_intimacy` the pair's intimacy already covers counts as reached.
  static int reachedLevel(List<IntimateLevel> levels, IntimateBond? bond) {
    if (bond == null) return 0;
    var reached = bond.level;
    for (final l in levels) {
      if (l.needIntimacy <= bond.points && l.level > reached) {
        reached = l.level;
      }
    }
    return reached;
  }

  static LevelStatus of(
    List<IntimateLevel> levels,
    int index,
    IntimateBond? bond,
  ) {
    final level = levels[index.clamp(0, levels.length - 1)];
    final intimacy = bond?.points ?? 0;
    final reached = reachedLevel(levels, bond);
    bool isUnlocked(IntimateLevel l) =>
        l.have ||
        (bond != null && (l.needIntimacy <= intimacy || l.level < reached));
    final unlocked = isUnlocked(level);
    final firstLocked = levels.indexWhere((l) => !isUnlocked(l));
    final isNext = !unlocked && index == firstLocked;
    final need = level.needIntimacy;
    final progress =
        unlocked
            ? 1.0
            : need <= 0
            ? 0.0
            : (intimacy / need).clamp(0.0, 1.0);
    return LevelStatus(
      unlocked: unlocked,
      isNext: isNext,
      progress: progress,
      intimacy: intimacy,
      need: need,
    );
  }
}

/// A relation the user can buy and send as a request (`cp-relations`).
class RelationOffer {
  final int id;
  final String title;
  final int price;

  const RelationOffer({
    required this.id,
    required this.title,
    required this.price,
  });
}

/// Loads everything the Intimate Space page shows. Offers are kept for the
/// app session; levels are fetched fresh every time.
class IntimateSpaceRepo {
  IntimateSpaceRepo._();
  static final IntimateSpaceRepo instance = IntimateSpaceRepo._();

  Map<RelationKind, RelationOffer>? _offers;

  DioFactory get _dio => di<DioFactory>();

  static Object? _data(Object? body) => body is Map ? body['data'] : null;

  /// The profile owner's relationships, grouped by kind.
  Future<Map<RelationKind, List<IntimateBond>>> bonds(String userId) async {
    final res = await _dio.get(EndPoints.cpProfile(userId), forceRefresh: true);
    final data = _data(res.data);
    final out = {for (final k in RelationKind.values) k: <IntimateBond>[]};
    if (data is Map) {
      final main = IntimateBond.fromJson(data['main_cp']);
      if (main != null) out[main.kind]!.add(main);
      final rest = data['remaining_cp'];
      if (rest is List) {
        for (final r in rest) {
          final bond = IntimateBond.fromJson(r);
          if (bond != null) out[bond.kind]!.add(bond);
        }
      }
    }
    return out;
  }

  /// Always fetched fresh, so levels the admin adds, edits or deletes show
  /// up the next time the page opens.
  Future<List<IntimateLevel>> levels(RelationKind kind) async {
    final list = await _fetchLevels(kind.levelsType);
    list.sort((a, b) => a.level.compareTo(b.level));
    return list;
  }

  Future<List<IntimateLevel>> _fetchLevels(String? type) async {
    try {
      final res = await _dio.get(
        EndPoints.cpRelationsLevelsGifts,
        queryParameters: type == null ? null : {'type': type},
        forceRefresh: true,
      );
      final data = _data(res.data);
      if (data is! List) return [];
      return [
        for (final e in data)
          if (e is Map) IntimateLevel.fromJson(e),
      ];
    } catch (e) {
      Methods.printLog('[IntimateSpace] levels($type) failed: $e');
      return [];
    }
  }

  /// The relation to request for each kind, from the relation store.
  Future<Map<RelationKind, RelationOffer>> offers() async {
    final cached = _offers;
    if (cached != null) return cached;
    final res = await _dio.get(EndPoints.getCpRelations);
    final data = _data(res.data);
    final out = <RelationKind, RelationOffer>{};
    if (data is List) {
      for (final e in data) {
        if (e is! Map) continue;
        final title = '${e['title'] ?? ''}';
        final kind = RelationKindX.classify('${e['type'] ?? ''}', title);
        out.putIfAbsent(
          kind,
          () => RelationOffer(
            id: int.tryParse('${e['id'] ?? 0}') ?? 0,
            title: title,
            price: int.tryParse('${e['price'] ?? 0}') ?? 0,
          ),
        );
      }
    }
    _offers = out;
    return out;
  }
}

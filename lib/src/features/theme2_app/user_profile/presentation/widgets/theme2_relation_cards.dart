import 'dart:math' as math;

import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/cp/data/model/cp_profile_model.dart';
import 'package:general/src/features/cp/presentation/cp_store/bloc/cp_profile_bloc/cp_profile_bloc.dart';
import 'package:general/src/features/cp/presentation/intimate_space/intimate_space_data.dart';
import 'package:general/src/features/cp/presentation/intimate_space/intimate_space_page.dart';

/// The four relation cards of the profile (CP, Best Friend, Sister,
/// Brother), in im_Chat's framed-artwork style: header bar, the owner's
/// avatar on the left, a wavy line, the relation badge + label in the middle,
/// another wavy line and the partner on the right — or a "+" add slot.
class Theme2RelationCards extends StatelessWidget {
  final UserEntity? user;
  final CpProfileBloc cpProfileBloc;

  const Theme2RelationCards({
    super.key,
    required this.user,
    required this.cpProfileBloc,
  });

  static const Color _cpAccent = Color(0xFFE8527F);
  static const Color _friendAccent = Color(0xFF3D82E6);

  bool get _isMine => Methods.isMe(user?.id.toString() ?? '');

  void _openSpace(BuildContext context, RelationKind kind) {
    final u = user ?? const UserEntity();
    IntimateSpacePage.open(
      context,
      IntimateSpaceArgs(
        userId: u.id?.toString() ?? '',
        name: u.name ?? '',
        image: u.profile?.image ?? '',
        uuid: u.uuid ?? u.id?.toString() ?? '',
        isMine: _isMine,
        initial: kind,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CpProfileBloc, CpProfileStates>(
      bloc: cpProfileBloc,
      builder: (context, state) {
        final data = state.data;
        final all = <_Relation>[
          if (data?.mainCp != null) _Relation.main(data!.mainCp!),
          for (final cp in data?.remainingCp ?? const <RemainingCp>[])
            _Relation.remaining(cp),
        ];
        // First relation of each kind fills that kind's card.
        final byKind = <RelationKind, _Relation>{};
        for (final r in all) {
          byKind.putIfAbsent(RelationKindX.classify(r.type, r.title), () => r);
        }

        Widget card(RelationKind kind) {
          final r = byKind[kind];
          final isCp = kind == RelationKind.cp;
          final intimacy = r?.intimacy ?? 0;
          return _IntimacyCard(
            bgAsset:
                isCp
                    ? AssetsManager.intimacyCpCard
                    : AssetsManager.intimacyFriendCard,
            accent: isCp ? _cpAccent : _friendAccent,
            header: '${_headerText(kind)}  ·  $intimacy intimacy',
            badgeAsset: isCp ? AssetsManager.heartCpProfile : null,
            badgeIcon: kind.icon,
            kind: kind,
            level: r?.level ?? 0,
            intimacy: intimacy,
            badgeLabel: (r == null || r.title.isEmpty) ? kind.label : r.title,
            ownerName: user?.name ?? '',
            ownerImage: user?.profile?.image ?? '',
            partnerName: r?.partnerName ?? '',
            partnerImage: r?.partnerImage ?? '',
            onTap: () => _openSpace(context, kind),
            onAdd:
                (r == null && _isMine)
                    ? () => Navigator.pushNamed(context, Routes.cpStorePage)
                    : null,
            onPartnerTap:
                r == null
                    ? null
                    : () => Methods().userProfileNavigator(
                      context: context,
                      userId: r.partnerId?.toString(),
                    ),
          );
        }

        return Column(children: [for (final k in RelationKind.values) card(k)]);
      },
    );
  }

  static String _headerText(RelationKind kind) => switch (kind) {
    RelationKind.cp => 'Fall in love',
    RelationKind.bestFriend => 'Best friends',
    RelationKind.sister => 'Sisters',
    RelationKind.brother => 'Brothers',
  };
}

class _Relation {
  final String type;
  final String title;
  final int intimacy;
  final int level;
  final int? partnerId;
  final String partnerName;
  final String partnerImage;

  const _Relation({
    required this.type,
    required this.title,
    required this.intimacy,
    required this.level,
    required this.partnerId,
    required this.partnerName,
    required this.partnerImage,
  });

  factory _Relation.main(MainCp cp) => _Relation(
    type: cp.relation?.type ?? '',
    title: cp.relation?.title ?? '',
    intimacy: cp.di ?? 0,
    level: cp.level ?? 0,
    partnerId: cp.user?.id,
    partnerName: cp.user?.name ?? '',
    partnerImage: cp.user?.image ?? '',
  );

  factory _Relation.remaining(RemainingCp cp) => _Relation(
    type: cp.relation?.type ?? '',
    title: cp.relation?.title ?? '',
    intimacy: cp.di ?? 0,
    level: cp.level ?? 0,
    partnerId: cp.user?.id,
    partnerName: cp.user?.name ?? '',
    partnerImage: cp.user?.image ?? '',
  );
}

/// One framed relation card. Positions are fractions of the card so it
/// scales with the screen width.
class _IntimacyCard extends StatelessWidget {
  final String bgAsset;
  final Color accent;
  final String header;
  final String badgeLabel;
  final String ownerName;
  final String ownerImage;
  final String? badgeAsset;
  final IconData badgeIcon;
  final RelationKind kind;
  final int level;
  final int intimacy;
  final String partnerName;
  final String partnerImage;
  final VoidCallback? onTap;

  /// Tap on the empty "+" slot (null on someone else's profile).
  final VoidCallback? onAdd;
  final VoidCallback? onPartnerTap;

  const _IntimacyCard({
    required this.bgAsset,
    required this.accent,
    required this.header,
    required this.badgeLabel,
    required this.ownerName,
    required this.ownerImage,
    required this.badgeIcon,
    required this.kind,
    required this.level,
    required this.intimacy,
    this.badgeAsset,
    this.partnerName = '',
    this.partnerImage = '',
    this.onTap,
    this.onAdd,
    this.onPartnerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      // heightFactor trims the artwork's blank margin so consecutive cards sit
      // close together (the content still paints in full).
      child: Align(
        heightFactor: 0.97,
        child: AspectRatio(
          aspectRatio: 1.75,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final h = c.maxHeight;
                final d = w * 0.135; // slot diameter
                final midY = h * 0.50;
                final leftX = w * 0.19;
                final rightX = w * 0.81;
                final badge = w * 0.17;
                final hasPartner =
                    partnerImage.isNotEmpty || partnerName.isNotEmpty;

                Widget slot({required Widget child, VoidCallback? onTap}) {
                  return GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: d,
                      height: d,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.85),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.55),
                          width: 1.4,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: child,
                    ),
                  );
                }

                Widget avatar(String image) => ImageViewWidget(
                  url: EndPoints.getImage(image),
                  height: d,
                  width: d,
                  boxFit: BoxFit.cover,
                  radius: d,
                  padding: EdgeInsetsDirectional.zero,
                  margin: EdgeInsetsDirectional.zero,
                );

                Widget name(double x, String text) => Positioned(
                  left: x - w * 0.14,
                  width: w * 0.28,
                  top: midY + d / 2 + 6,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accent,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Image.asset(bgAsset, fit: BoxFit.fill),
                    ),
                    // Header bar
                    Positioned(
                      top: h * 0.10,
                      left: w * 0.11,
                      right: w * 0.11,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: h * 0.025),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          header,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // Wavy lines between the slots and the badge
                    Positioned(
                      left: leftX + d / 2 + 4,
                      top: midY - 14,
                      width: (w * 0.5 - badge / 2 - 6) - (leftX + d / 2 + 4),
                      height: 28,
                      child: CustomPaint(painter: _WavePainter(accent)),
                    ),
                    Positioned(
                      left: w * 0.5 + badge / 2 + 6,
                      top: midY - 14,
                      width: (rightX - d / 2 - 4) - (w * 0.5 + badge / 2 + 6),
                      height: 28,
                      child: CustomPaint(painter: _WavePainter(accent)),
                    ),
                    // Owner (left) slot
                    Positioned(
                      left: leftX - d / 2,
                      top: midY - d / 2,
                      child: slot(
                        child:
                            ownerImage.isNotEmpty
                                ? avatar(ownerImage)
                                : Icon(
                                  Icons.person_rounded,
                                  color: accent.withValues(alpha: 0.5),
                                  size: d * 0.5,
                                ),
                      ),
                    ),
                    name(leftX, ownerName),
                    // Partner (right) slot, or the "+" add slot
                    Positioned(
                      left: rightX - d / 2,
                      top: midY - d / 2,
                      child:
                          hasPartner
                              ? slot(
                                onTap: onPartnerTap,
                                child: avatar(partnerImage),
                              )
                              : slot(
                                onTap: onAdd ?? onTap,
                                child: Icon(
                                  Icons.add_rounded,
                                  color: accent,
                                  size: d * 0.62,
                                ),
                              ),
                    ),
                    if (hasPartner) name(rightX, partnerName),
                    // Middle badge + label
                    Positioned(
                      left: w * 0.5 - badge / 2,
                      top: midY - badge / 2,
                      width: badge,
                      height: badge,
                      child: _LevelBadge(
                        kind: kind,
                        level: level,
                        intimacy: intimacy,
                        size: badge,
                        fallback:
                            badgeAsset != null
                                ? Image.asset(badgeAsset!, fit: BoxFit.contain)
                                : Icon(
                                  badgeIcon,
                                  color: Colors.white,
                                  size: badge * 0.8,
                                  shadows: [
                                    Shadow(
                                      color: accent.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    Positioned(
                      left: w * 0.5 - w * 0.12,
                      width: w * 0.24,
                      top: midY + badge / 2 + 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8B8C2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white70, width: 1),
                        ),
                        child: Text(
                          badgeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// A smooth sine wave, used for the lines joining the avatars to the badge.
class _WavePainter extends CustomPainter {
  final Color color;

  _WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
    final path = Path();
    const periods = 2.5;
    final amp = size.height * 0.32;
    for (double x = 0; x <= size.width; x += 1) {
      final y =
          size.height / 2 +
          math.sin((x / size.width) * periods * 2 * math.pi) * amp;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// The middle badge: the admin's image for the level the pair has reached
/// (level 1 -> level 1 image, level 2 -> level 2 image, ...), or [fallback]
/// while loading / before level 1 / when the level has no image.
class _LevelBadge extends StatelessWidget {
  final RelationKind kind;
  final int level;
  final int intimacy;
  final double size;
  final Widget fallback;

  const _LevelBadge({
    required this.kind,
    required this.level,
    required this.intimacy,
    required this.size,
    required this.fallback,
  });

  /// One level-table fetch per kind while the profile is open.
  static final _levels = <RelationKind, Future<List<IntimateLevel>>>{};

  Future<String?> _imageFor() async {
    final future = _levels[kind] ??= IntimateSpaceRepo.instance.levels(kind);
    final levels = await future;
    if (levels.isEmpty) _levels.remove(kind);
    // The server level can lag behind; intimacy decides too.
    var reached = level;
    for (final l in levels) {
      if (l.needIntimacy <= intimacy && l.level > reached) reached = l.level;
    }
    if (reached <= 0) return null;
    final match = levels.where((l) => l.level == reached).firstOrNull;
    if (match == null) return null;
    for (final path in [match.image, match.effect]) {
      if (path.isNotEmpty) return path;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      key: ValueKey('$kind#$level#$intimacy'),
      future: _imageFor(),
      builder: (context, snap) {
        final path = snap.data;
        if (path == null) return fallback;
        final url = EndPoints.getImage(path);
        if (path.toLowerCase().endsWith('.svga')) {
          return ShowSVGA(
            url: url,
            width: size,
            height: size,
            fit: BoxFit.contain,
          );
        }
        return ImageViewWidget(
          url: url,
          width: size,
          height: size,
          boxFit: BoxFit.contain,
        );
      },
    );
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/data/model/family_model.dart';
import 'package:general/src/features/cp/cp.dart';
import 'package:general/src/features/profile/data/model/top.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/gift_history_bloc/gift_history_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/gift_history_bloc/gift_history_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/gift_history_bloc/gift_history_state.dart';

/// Pieces of the room profile sheet: the avatar pair (user + CP partner),
/// the family chip, the "Gift Sender Top3" and agency cards, and the round
/// action buttons along the bottom.

/// The user's framed avatar, with their CP partner's avatar beside it and a
/// heart between the two when they have a CP.
class ProfileAvatarPair extends StatelessWidget {
  const ProfileAvatarPair({
    super.key,
    required this.image,
    required this.name,
    required this.frame,
    required this.frameType,
    required this.onTap,
    this.cp,
  });

  final String image;
  final String name;
  final String? frame;
  final String? frameType;
  final VoidCallback onTap;
  final MainCp? cp;

  @override
  Widget build(BuildContext context) {
    final partner = cp?.user;
    final me = GestureDetector(
      onTap: onTap,
      child: UserImage(
        image: image,
        displayName: name,
        imageSize: 80,
        frame: frame,
        frameType: frameType,
        frameSize: 125,
      ),
    );
    // Same 130 box with or without a CP, so the frame (125) never pokes
    // out of the block above or below.
    if (partner == null || (partner.id ?? 0) == 0) {
      return SizedBox(height: 130.w, child: Center(child: me));
    }
    // Photos are 80 wide inside 125 frames: inset the photo by the frame's
    // overhang (22.5) so neither frame leaves the box.
    const inset = 23.0;
    return SizedBox(
      width: 300.w,
      height: 130.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: inset, child: me),
          Positioned(
            right: inset,
            child: GestureDetector(
              onTap: () {
                // Close the profile sheet first, then open the CP profile.
                final nav = Navigator.of(context);
                nav.pop();
                Methods().userProfileNavigator(
                  context: nav.context,
                  userId: '${partner.id}',
                );
              },
              child: UserImage(
                image: partner.image ?? '',
                displayName: partner.name ?? '',
                imageSize: 80,
                frame: partner.frame,
                frameSize: 125,
              ),
            ),
          ),
          // Animated heartbeat line joining the two photos, heart centred.
          Positioned(
            left: inset + 80,
            right: inset + 80,
            child: CpHeartbeatConnector(level: cp?.level ?? 0),
          ),
        ],
      ),
    );
  }
}

/// ECG-style line between the CP pair with a pulse running along it and a
/// heart in the middle that beats twice per cycle, like a real heartbeat.
class CpHeartbeatConnector extends StatefulWidget {
  const CpHeartbeatConnector({super.key, this.level = 0});
  final int level;

  @override
  State<CpHeartbeatConnector> createState() => _CpHeartbeatConnectorState();
}

class _CpHeartbeatConnectorState extends State<CpHeartbeatConnector>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  // Lub-dub: two quick beats, then rest.
  late final Animation<double> _beat = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 10),
    TweenSequenceItem(tween: Tween(begin: 1.28, end: 1.0), weight: 10),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 10),
    TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 12),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 58),
  ]).animate(_c);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heart = 34.w;
    return SizedBox(
      height: 46.w,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _HeartbeatLinePainter(progress: _c.value),
              ),
            ),
            Transform.scale(
              scale: _beat.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF2E63)
                          .withValues(alpha: .25 + .35 * (_beat.value - 1) / .28),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Image.asset(
                  AssetsManager.heartCpProfile,
                  width: heart,
                  height: heart,
                ),
              ),
            ),
            if (widget.level > 0)
              Positioned(
                bottom: -4.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B9A), Color(0xFFFF2E63)],
                    ),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text(
                    'Lv${widget.level}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeartbeatLinePainter extends CustomPainter {
  _HeartbeatLinePainter({required this.progress});
  final double progress;

  Path _ecg(Size size) {
    final w = size.width;
    final mid = size.height / 2;
    final a = size.height * .42;
    // Pulse spike on each side of the centre heart, flat elsewhere.
    void spike(Path p, double x) {
      p
        ..lineTo(x - w * .06, mid)
        ..lineTo(x - w * .035, mid - a * .35)
        ..lineTo(x - w * .015, mid + a * .25)
        ..lineTo(x + w * .01, mid - a)
        ..lineTo(x + w * .035, mid + a * .55)
        ..lineTo(x + w * .055, mid);
    }

    final p = Path()..moveTo(0, mid);
    spike(p, w * .2);
    p.lineTo(w * .5, mid);
    spike(p, w * .8);
    p.lineTo(w, mid);
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;
    final path = _ecg(size);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFFF7AA8).withValues(alpha: .45),
    );
    // Bright pulse travelling left to right.
    for (final m in path.computeMetrics()) {
      final len = m.length;
      final head = len * progress;
      final seg = m.extractPath((head - len * .28).clamp(0, len), head);
      canvas.drawPath(
        seg,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFFFF2E63)
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeartbeatLinePainter old) =>
      old.progress != progress;
}

/// "Gift Wall" chip on the right edge; opens the gifts this user received.
class ProfileGiftWallChip extends StatelessWidget {
  const ProfileGiftWallChip(
      {super.key, required this.userId, required this.name});
  final String userId;
  final String name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close the profile sheet, then show the Gift Wall on its own.
        final nav = Navigator.of(context);
        nav.pop();
        showModalBottomSheet(
          context: nav.context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => _GiftWallSheet(userId: userId, name: name),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(8.w, 5.h, 10.w, 5.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(22.r)),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB347), Color(0xFFFF7A3D)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AssetsManager.dailyRewardGiftBox,
                width: 22.w, height: 22.w),
            5.wBox,
            Text(
              StringManager.giftWall.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftWallSheet extends StatefulWidget {
  const _GiftWallSheet({required this.userId, required this.name});
  final String userId;
  final String name;

  @override
  State<_GiftWallSheet> createState() => _GiftWallSheetState();
}

class _GiftWallSheetState extends State<_GiftWallSheet> {
  late final GiftHistoryBloc _bloc = di<GiftHistoryBloc>()
    ..add(GetGiftHistory(id: widget.userId, force: true));

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            10.hBox,
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E3E8),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            12.hBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AssetsManager.dailyRewardGiftBox,
                    width: 26.w, height: 26.w),
                6.wBox,
                Text(
                  StringManager.giftWall.tr(),
                  style: TextStyle(
                    color: const Color(0xFF1B1B1F),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            10.hBox,
            Flexible(
              child: BlocBuilder<GiftHistoryBloc, GiftHistoryState>(
                bloc: _bloc,
                builder: (context, state) {
                  final gifts = state.giftModel ?? const [];
                  if (state.requestState.isLoading && gifts.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(30.h),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  if (gifts.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(30.h),
                      child: Text(
                        StringManager.noGifts.tr(),
                        style: TextStyle(
                          color: const Color(0xFF8E8F96),
                          fontSize: 13.sp,
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 16.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: .78,
                    ),
                    itemCount: gifts.length,
                    itemBuilder: (context, i) {
                      final g = gifts[i];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFFF4EA), Color(0xFFFFE7F0)],
                          ),
                          border: Border.all(color: const Color(0xFFF6DEC8)),
                        ),
                        padding: EdgeInsets.all(6.w),
                        child: Column(
                          children: [
                            Expanded(
                              child: ImageViewWidget(
                                url: EndPoints.getImage(g.data.showImg),
                                boxFit: BoxFit.contain,
                              ),
                            ),
                            4.hBox,
                            Text(
                              g.data.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF3A3A40),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'x${g.num}',
                              style: TextStyle(
                                color: const Color(0xFFE0457B),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small chip on the right edge naming the user's family.
class ProfileFamilyChip extends StatelessWidget {
  const ProfileFamilyChip({super.key, required this.family});
  final FamilyModel family;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close the profile sheet, then open the family page.
        final nav = Navigator.of(context);
        nav.pop();
        nav.pushNamed(Routes.familyScreen, arguments: '${family.id ?? 0}');
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(4.w, 4.h, 10.w, 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(22.r)),
          gradient: const LinearGradient(
            colors: [Color(0xFF2FBF71), Color(0xFF1E9E5A)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: ImageViewWidget(
                url: EndPoints.getImage(family.img ?? ''),
                width: 28.w,
                height: 28.w,
                boxFit: BoxFit.cover,
              ),
            ),
            6.wBox,
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 80.w),
              child: Text(
                (family.name ?? '').isEmpty
                    ? StringManager.family.tr()
                    : family.name!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Gift Sender Top3": the three people who sent this user the most gifts.
class ProfileTopSendersCard extends StatelessWidget {
  const ProfileTopSendersCard({super.key, required this.top});
  final List<Top> top;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74.h,
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 8.w, 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD6E8), Color(0xFFFFEEF5)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gift Sender Top3',
                  style: TextStyle(
                    color: const Color(0xFFE0457B),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                6.hBox,
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        for (var i = 0; i < 3; i++)
                          Padding(
                            padding: EdgeInsets.only(right: 6.w),
                            child: _seat(i < top.length ? top[i] : null, i),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Real gift-box artwork instead of a flat icon.
          Image.asset(
            AssetsManager.dailyRewardGiftBox,
            width: 38.w,
            height: 38.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _seat(Top? t, int rank) {
    const ring = [Color(0xFFFFC94A), Color(0xFFC9D2DE), Color(0xFFE3A06B)];
    return Container(
      width: 32.w,
      height: 32.w,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(shape: BoxShape.circle, color: ring[rank]),
      child: ClipOval(
        child: t == null
            ? Container(
                color: Colors.white,
                child: Icon(Icons.person_outline_rounded,
                    size: 16.sp, color: const Color(0xFFFFB3CD)),
              )
            : ImageViewWidget(
                url: EndPoints.getImage(t.image ?? ''),
                boxFit: BoxFit.cover,
                width: 32.w,
                height: 32.w,
              ),
      ),
    );
  }
}

/// Agency the user belongs to.
class ProfileAgencyCard extends StatelessWidget {
  const ProfileAgencyCard({
    super.key,
    required this.image,
    required this.name,
    required this.id,
  });

  final String image;
  final String name;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74.h,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFD9C7A6), Color(0xFFEFE3CC)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .8)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: ImageViewWidget(
              url: EndPoints.getImage(image),
              width: 54.w,
              height: 54.w,
              boxFit: BoxFit.cover,
            ),
          ),
          8.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF6B4F2A),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                3.hBox,
                Text(
                  'ID: $id',
                  style: TextStyle(
                    color: const Color(0xFF8C7351),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Round action button for the sheet's bottom row.
class ProfileRoundAction extends StatelessWidget {
  const ProfileRoundAction({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.label,
    this.labelColor,
  });

  final IconData icon;
  final Color? labelColor;
  final Color color;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .12),
            ),
            child: Icon(icon, color: color, size: 26.sp),
          ),
          if (label != null) ...[
            4.hBox,
            Text(
              label!,
              style: TextStyle(
                color: labelColor ?? const Color(0xFF6B6C74),
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A soft white highlight that sweeps across [child] (the user's name),
/// keeping the text's own colours underneath.
class NameShine extends StatefulWidget {
  const NameShine({super.key, required this.child});
  final Widget child;

  @override
  State<NameShine> createState() => _NameShineState();
}

class _NameShineState extends State<NameShine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        // Sweep from off-left to off-right, then rest a moment.
        final t = (_c.value * 1.6 - 1.0).clamp(-1.0, 1.0);
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: .85),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const [.35, .5, .65],
            transform: _SlideGradient(t),
          ).createShader(rect),
          child: child,
        );
      },
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.t);
  final double t;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * t, 0, 0);
}

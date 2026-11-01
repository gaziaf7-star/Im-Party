import 'dart:math' as math;

import 'package:general/src/features/cp/presentation/cp_rank/bloc/cp_bloc.dart';
import 'package:general/src/features/family/family.dart';
import 'package:general/src/features/games/presentation/ranking/bloc/other_ranking/ranking_bloc.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_top_ranking_manager/fetch_top_ranking_bloc.dart';
import '../../../../../../core/index.dart';

/// Three ranking cards -- Gift, Family, CP -- on the home feed. Each shows the
/// MONTHLY top three (so the cards are filled even when today's ranking is
/// still empty), falling back to the shorter period if the month is empty.
/// Destinations: Gift -> Routes.rankScreen (wealth), Family ->
/// Routes.familyRankPage, CP -> Routes.cpRank.
class HomeRankingCardsRow extends StatefulWidget {
  const HomeRankingCardsRow({super.key});

  @override
  State<HomeRankingCardsRow> createState() => _HomeRankingCardsRowState();
}

class _HomeRankingCardsRowState extends State<HomeRankingCardsRow> {
  @override
  void initState() {
    super.initState();
    // Gift: monthly wealth ranking; the home top-ranking call is the fallback.
    if (di<RankingBloc>().state.cMState == RequestState.idle) {
      di<RankingBloc>().add(const FetchCoinsMonthlyEvent());
    }
    if (!di<FetchTopUserImageBloc>().state.requestState.isLoaded) {
      di<FetchTopUserImageBloc>().add(const FetchTopUserImageEvent());
    }
    // Family: monthly, weekly as fallback.
    if (di<GetFamilyRankingBloc>().state.monthlyRequestState ==
        RequestState.idle) {
      di<GetFamilyRankingBloc>()
          .add(const GetMonthlyFamilyRankingEvent(isFirstLoading: false));
    }
    if (di<GetFamilyRankingBloc>().state.weeklyRequestState ==
        RequestState.idle) {
      di<GetFamilyRankingBloc>()
          .add(const GetWeeklyFamilyRankingEvent(isFirstLoading: false));
    }
    // CP: the #1 couple of the MONTHLY CP ranking (the home top-ranking
    // API's `top_cp` comes back empty).
    if (di<CpBloc>().state.cpLoveMState != RequestState.loaded &&
        di<CpBloc>().state.cpLoveMState != RequestState.loading) {
      di<CpBloc>().add(const FetchLoveCpMonthlyEvent());
    }
  }

  static const double _cardHeight = 90;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _cardHeight.h,
      child: Row(
        children: [
          // 1. Gift
          Expanded(
            child: BlocBuilder<RankingBloc, RankingStates>(
              bloc: di<RankingBloc>(),
              buildWhen: (prev, curr) => prev.usersRankCM != curr.usersRankCM,
              builder: (context, monthly) {
                return BlocBuilder<FetchTopUserImageBloc,
                    FetchTopRankingState>(
                  bloc: di<FetchTopUserImageBloc>(),
                  buildWhen: (prev, curr) =>
                      prev.rankingEntity != curr.rankingEntity,
                  builder: (context, daily) {
                    final month = (monthly.usersRankCM?.usersEntity ?? const [])
                        .map((u) => u.avatar ?? '')
                        .where((u) => u.isNotEmpty)
                        .toList();
                    return _MiniRankCard(
                      colors: _HomeCard.orange,
                      title: StringManager.giftRank.tr(),
                      avatarUrls: month.isNotEmpty
                          ? month
                          : (daily.rankingEntity?.sender ?? const []),
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.rankScreen,
                        arguments: 1,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          8.wBox,
          // 2. Family
          Expanded(
            child: BlocBuilder<GetFamilyRankingBloc, GetFamilyRankingState>(
              bloc: di<GetFamilyRankingBloc>(),
              buildWhen: (prev, curr) =>
                  prev.monthlyTopFamilies != curr.monthlyTopFamilies ||
                  prev.weeklyTopFamilies != curr.weeklyTopFamilies,
              builder: (context, state) {
                List<String> imgs(List<FamilyRankModel>? f) => (f ?? const [])
                    .map((e) => e.img ?? '')
                    .where((u) => u.isNotEmpty)
                    .toList();
                final month = imgs(state.monthlyTopFamilies);
                return _MiniRankCard(
                  colors: _HomeCard.purple,
                  title: StringManager.family.tr(),
                  avatarUrls:
                      month.isNotEmpty ? month : imgs(state.weeklyTopFamilies),
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.familyRankPage),
                );
              },
            ),
          ),
          8.wBox,
          // 3. CP Ranking
          Expanded(
            child: BlocBuilder<CpBloc, CpStates>(
              bloc: di<CpBloc>(),
              buildWhen: (prev, curr) =>
                  prev.usersRankLoveCpM != curr.usersRankLoveCpM,
              builder: (context, state) {
                final top = state.usersRankLoveCpM?.firstThree ?? const [];
                final first = top.isNotEmpty ? top.first : null;
                return _MiniCpRankCard(
                  userOneImage: first?.userOne?.image ?? '',
                  userTwoImage: first?.userTwo?.image ?? '',
                  onTap: () => Navigator.pushNamed(context, Routes.cpRank),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Drives the avatars' motion: they pop in one after another, then take
/// turns doing a small lift, on a loop. Children are laid out left to right;
/// [turns] gives each position's turn (0 goes first).
class _StaggerMotion extends StatefulWidget {
  const _StaggerMotion({
    required this.turns,
    required this.builder,
    this.row = true,
    super.key,
  });

  final List<int> turns;

  /// (position, entrance 0..1, lift 0..1) -> avatar.
  final Widget Function(int position, double entrance, double lift) builder;

  /// Lay the children out in a Row (false: the builder places them).
  final bool row;

  @override
  State<_StaggerMotion> createState() => _StaggerMotionState();
}

class _StaggerMotionState extends State<_StaggerMotion>
    with TickerProviderStateMixin {
  late final int _n = widget.turns.length;

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 380 + 220 * _n),
  )..forward();

  // One slot per avatar plus one resting slot.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 750 * (_n + 1)),
  )..repeat();

  @override
  void dispose() {
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  Widget _child(int p) {
    final k = widget.turns[p];
    // Entrance: each starts a little after the previous one.
    final start = (k * 0.22).clamp(0.0, 0.7);
    final t = ((_enter.value - start) / 0.45).clamp(0.0, 1.0);
    final entrance = Curves.easeOutBack.transform(t);
    // Lift: during its own slot of the loop, once everyone is in.
    final phase = _loop.value * (_n + 1) - k;
    final lift = (_enter.isCompleted && phase >= 0 && phase <= 1)
        ? math.sin(math.pi * phase)
        : 0.0;
    return widget.builder(p, entrance, lift);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_enter, _loop]),
      builder: (context, _) {
        final kids = [for (int p = 0; p < _n; p++) _child(p)];
        return widget.row
            ? Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: kids,
              )
            : Stack(clipBehavior: Clip.none, children: kids);
      },
    );
  }
}

/// The shared "gradient card + title + 3 overlapping ranked avatars" card,
/// used by Gift and Family (CP gets its own two-avatar layout below).
class _MiniRankCard extends StatelessWidget {
  const _MiniRankCard({
    required this.colors,
    required this.title,
    required this.avatarUrls,
    required this.onTap,
  });

  final List<Color> colors;
  final String title;
  final List<String> avatarUrls;
  final VoidCallback onTap;

  String _at(int index) => index < avatarUrls.length ? avatarUrls[index] : '';

  @override
  Widget build(BuildContext context) {
    // Positions left to right show ranks #2, #1, #3; #1 moves first.
    const rankAt = [1, 0, 2];
    final frames = [
      AssetsManager.frameHomeTopTwo,
      AssetsManager.frameHomeTopOne,
      AssetsManager.frameHomeTopThree,
    ];
    return _HomeCard(
      colors: colors,
      title: title,
      onTap: onTap,
      child: _StaggerMotion(
        // Replays the entrance when the people change.
        key: ValueKey(avatarUrls.take(3).join('|')),
        turns: const [1, 0, 2],
        builder: (p, entrance, lift) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: _RankAvatar(
            url: _at(rankAt[p]),
            frame: frames[p],
            big: p == 1,
            entrance: entrance,
            lift: lift,
          ),
        ),
      ),
    );
  }
}

/// Soft placeholder shown in an empty slot so the card never looks blank.
class _EmptyAvatar extends StatelessWidget {
  const _EmptyAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.55),
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * 0.7,
        color: Colors.white,
      ),
    );
  }
}

class _RankAvatar extends StatelessWidget {
  const _RankAvatar({
    required this.url,
    required this.frame,
    this.big = false,
    this.entrance = 1,
    this.lift = 0,
  });

  final String url;
  final String frame;
  final bool big;
  final double entrance;
  final double lift;

  @override
  Widget build(BuildContext context) {
    // The frame art's ring sits well inside its canvas, so the avatar is
    // ~0.62 of the frame box to land inside the ring.
    final frameSize = (big ? 34.0 : 27.0).h;
    final avatarSize = frameSize * 0.62;
    return Transform.translate(
      offset: Offset(0, -4.h * lift),
      child: Transform.scale(
        scale: (0.35 + 0.65 * entrance) * (1 + 0.06 * lift),
        child: Opacity(
          opacity: entrance.clamp(0.0, 1.0),
          child: SizedBox(
            height: frameSize,
            width: frameSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                url.isNotEmpty
                    ? ClipOval(
                        child: ImageViewWidget(
                          url: url,
                          displayName: '',
                          height: avatarSize,
                          width: avatarSize,
                          boxFit: BoxFit.cover,
                        ),
                      )
                    : _EmptyAvatar(size: avatarSize),
                Image.asset(frame,
                    height: frameSize, width: frameSize, fit: BoxFit.contain),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// CP Ranking's own layout: the couple inside the pair frame.
class _MiniCpRankCard extends StatelessWidget {
  const _MiniCpRankCard({
    required this.userOneImage,
    required this.userTwoImage,
    required this.onTap,
  });

  final String userOneImage;
  final String userTwoImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HomeCard(
      colors: _HomeCard.love,
      title: StringManager.cP.tr(),
      onTap: onTap,
      child: _CpPairFrame(
        key: ValueKey('$userOneImage|$userTwoImage'),
        userOneImage: userOneImage,
        userTwoImage: userTwoImage,
      ),
    );
  }
}

/// The couple's two avatars inside the CP pair frame (two crowned rings
/// joined by a heart). Ring centres/size measured from the 327x258 artwork.
/// The avatars pop in one after the other, then pulse in turn inside their
/// rings.
class _CpPairFrame extends StatelessWidget {
  const _CpPairFrame({
    required this.userOneImage,
    required this.userTwoImage,
    super.key,
  });

  final String userOneImage;
  final String userTwoImage;

  static const double _aspect = 327 / 258;
  static const double _ringY = 177 / 258;
  static const double _leftX = 100 / 327;
  static const double _rightX = 227 / 327;
  static const double _hole = 88 / 327; // ring hole diameter / frame width

  @override
  Widget build(BuildContext context) {
    final height = 58.h;
    final width = height * _aspect;
    final d = width * _hole;
    final urls = [userOneImage, userTwoImage];
    final xs = [_leftX, _rightX];
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: _StaggerMotion(
              row: false,
              turns: const [0, 1],
              builder: (p, entrance, lift) => Positioned(
                left: width * xs[p] - d / 2,
                top: height * _ringY - d / 2,
                width: d,
                height: d,
                child: Transform.scale(
                  scale: (0.35 + 0.65 * entrance) * (1 + 0.08 * lift),
                  child: Opacity(
                    opacity: entrance.clamp(0.0, 1.0),
                    child: ClipOval(
                      child: urls[p].isNotEmpty
                          ? ImageViewWidget(
                              url: urls[p],
                              displayName: '',
                              height: d,
                              width: d,
                              boxFit: BoxFit.cover,
                            )
                          : _EmptyAvatar(size: d),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                'assets/icons/ui_icons/cp_top1_border_img.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reference-style home card: rounded gradient tile with soft sparkles, a big
/// white bold title at the top and the card's own content (avatars) under it.
class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.colors,
    required this.title,
    required this.onTap,
    required this.child,
  });

  // Top-left -> bottom-right, matching the reference cards.
  static const List<Color> orange = [Color(0xFFFFB534), Color(0xFFFF8A1E)];
  static const List<Color> purple = [Color(0xFFC583FF), Color(0xFF9B5BF7)];
  static const List<Color> love = [Color(0xFFFF7BAC), Color(0xFFF23A5E)];

  final List<Color> colors;
  final String title;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: Stack(
            children: [
              // Soft light glow in the upper middle.
              Positioned(
                top: -20.h,
                left: 0,
                right: 0,
                height: 70.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.28),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              // Small sparkles.
              _sparkle(top: 8.h, left: 8.w, size: 9),
              _sparkle(top: 30.h, right: 8.w, size: 11),
              _sparkle(bottom: 10.h, left: 14.w, size: 7),
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    4.hBox,
                    child,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sparkle({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Icon(
        Icons.auto_awesome,
        size: size.sp,
        color: Colors.white.withValues(alpha: 0.55),
      ),
    );
  }
}

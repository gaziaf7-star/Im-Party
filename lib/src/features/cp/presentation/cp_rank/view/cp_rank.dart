import 'package:flutter/cupertino.dart';
import 'package:general/src/features/cp/domain/entities/cp_entity.dart';
import 'package:general/src/features/cp/presentation/cp_rank/bloc/cp_bloc.dart';
import 'package:general/src/features/cp/presentation/cp_rank/view/components/bottom_user_cp_widget.dart';
import 'package:general/src/features/cp/presentation/cp_rank/view/components/list_cp_body.dart';
import 'package:general/src/features/cp/presentation/cp_rank/view/components/rose_petals.dart';
import '../../../../../core/index.dart';

part 'components/inner_tab_bar.dart';

/// CP ranking: the pink "Cp-Ranking" art (assets/icons/ui_icons/cp ranking
/// page.png) with the top three couples standing on its three podiums, rose
/// petals drifting over the art, period pills (today / week / month) and the
/// rest of the ranking below.
class CpRank extends StatefulWidget {
  const CpRank({super.key});

  @override
  State<CpRank> createState() => _CpRankState();
}

class _CpRankState extends State<CpRank> {
  static const String _background = 'assets/icons/ui_icons/cp ranking page.png';

  // Background art is 941 x 1672; everything on the podiums is placed in
  // those pixel coordinates and scaled to the screen width.
  static const double _artW = 941;
  static const double _artH = 1672;

  /// Height of the art region the podium overlay covers (podium bottoms).
  static const double _podiumAreaH = 1060;

  /// Page colour below the art (the art's own bottom colour).
  static const Color _pageBottom = Color(0xFFFBD2E3);
  static const Color _pink = Color(0xFFF2387A);

  int _period = 0; // 0 today, 1 week, 2 month

  @override
  void initState() {
    super.initState();
    _fetch(0);
  }

  void _fetch(int period) {
    final state = di<CpBloc>().state;
    switch (period) {
      case 0:
        if (state.cpLoveDState != RequestState.loaded) {
          di<CpBloc>().add(const FetchLoveCpDayEvent());
        }
        break;
      case 1:
        if (state.cpLoveWState != RequestState.loaded) {
          di<CpBloc>().add(const FetchLoveCpWeeklyEvent());
        }
        break;
      default:
        if (state.cpLoveMState != RequestState.loaded) {
          di<CpBloc>().add(const FetchLoveCpMonthlyEvent());
        }
    }
  }

  void _select(int period) {
    if (period == _period) return;
    setState(() => _period = period);
    _fetch(period);
  }

  CpEntity? _data(CpStates s) => switch (_period) {
        0 => s.usersRankLoveCpD,
        1 => s.usersRankLoveCpW,
        _ => s.usersRankLoveCpM,
      };

  RequestState _req(CpStates s) => switch (_period) {
        0 => s.cpLoveDState,
        1 => s.cpLoveWState,
        _ => s.cpLoveMState,
      };

  void _showRules() {
    showDialog(
      context: context,
      builder: (context) => AnimatedDialog(
        width: 30.w,
        height: 55.h,
        onTap: () => Navigator.of(context).pop(),
        titleDivider: false,
        description: StringManager.rulesCpRank.tr(),
        title: StringManager.rule.tr(),
        conText: StringManager.know.tr(),
        color: ColorManager.primary,
        isUpdateDialog: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBottom,
      body: BlocBuilder<CpBloc, CpStates>(
        bloc: di<CpBloc>(),
        builder: (context, state) {
          final data = _data(state);
          final top = data?.firstThree ?? const <CpUserRankEntity>[];
          final others = data?.others ?? const <CpUserRankEntity>[];
          CpUserRankEntity? at(int i) => i < top.length ? top[i] : null;

          return LayoutBuilder(builder: (context, c) {
            final w = c.maxWidth;
            final s = w / _artW;
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  width: w,
                  height: _artH * s,
                  child: Image.asset(_background, fit: BoxFit.fitWidth),
                ),
                // Rose petals over the art.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: _podiumAreaH * s,
                  child: const RosePetals(),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: _podiumAreaH * s,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Ranks 2 and 3 first so #1 draws on top.
                          ..._podium(w, s, rank: 2, entity: at(1)),
                          ..._podium(w, s, rank: 3, entity: at(2)),
                          ..._podium(w, s, rank: 1, entity: at(0)),
                          _topBar(context),
                        ],
                      ),
                    ),
                    _periodPills(),
                    Expanded(child: _list(state, others)),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomUserCpWidget(userEntity: data?.user),
                ),
              ],
            );
          });
        },
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              onPressed: _showRules,
              icon: const Icon(CupertinoIcons.question_circle,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// One podium: the couple standing on its top surface, names and score
  /// under them, and the big rank number on the podium's front.
  List<Widget> _podium(
    double w,
    double s, {
    required int rank,
    required CpUserRankEntity? entity,
  }) {
    // Podium top-surface centres in art pixels (measured from the art).
    final double cx = switch (rank) { 1 => 470, 2 => 178, _ => 762 } * s;
    final double feet = (rank == 1 ? 605 : 815) * s; // avatars' bottom edge
    final double numberY = (rank == 1 ? 790 : 935) * s;
    final double d = w * (rank == 1 ? 0.165 : 0.135); // avatar diameter
    final double boxW = w * (rank == 1 ? 0.48 : 0.38);

    return [
      Positioned(
        left: cx - boxW / 2,
        top: feet - d,
        width: boxW,
        child: _CouplePair(entity: entity, diameter: d, large: rank == 1),
      ),
      Positioned(
        left: cx - 40,
        top: numberY,
        width: 80,
        child: Text(
          '$rank',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: w * 0.11,
            fontWeight: FontWeight.w900,
            height: 1,
            color: _pink.withValues(alpha: 0.75),
            shadows: const [
              Shadow(color: Colors.white, blurRadius: 8),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _periodPills() {
    final labels = [
      StringManager.daily.tr(),
      StringManager.weekly.tr(),
      StringManager.monthly.tr(),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 6.h),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) 10.wBox,
            GestureDetector(
              onTap: () => _select(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22.r),
                  color: i == _period ? null : Colors.white,
                  gradient: i == _period
                      ? const LinearGradient(
                          colors: [Color(0xFFFF7FAF), _pink],
                        )
                      : null,
                  border: i == _period
                      ? null
                      : Border.all(color: const Color(0xFFF7A9C6), width: 1.2),
                  boxShadow: i == _period
                      ? [
                          BoxShadow(
                            color: _pink.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: i == _period ? Colors.white : _pink,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _list(CpStates state, List<CpUserRankEntity> others) {
    final req = _req(state);
    if (others.isEmpty) {
      if (req == RequestState.loading) {
        return const Center(child: CircularProgressIndicator(color: _pink));
      }
      return const SizedBox.shrink();
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 120.h),
      itemCount: others.length,
      itemBuilder: (context, i) => _RankRow(rank: i + 4, entity: others[i]),
    );
  }
}

/// Two avatars in gold rings with a heart badge between them, then both
/// names and the couple's score.
class _CouplePair extends StatelessWidget {
  const _CouplePair({
    required this.entity,
    required this.diameter,
    required this.large,
  });

  final CpUserRankEntity? entity;
  final double diameter;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final d = diameter;
    final one = entity?.userOne;
    final two = entity?.userTwo;
    final nameStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w800,
      fontSize: (large ? 13 : 11.5).sp,
      shadows: [
        Shadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 4),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: d,
          width: d * 2 + 4,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(left: 0, child: _GoldAvatar(url: one?.image, d: d)),
              Positioned(right: 0, child: _GoldAvatar(url: two?.image, d: d)),
              Positioned(
                bottom: -d * 0.08,
                child: Container(
                  width: d * 0.38,
                  height: d * 0.38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8DB8), Color(0xFFF2387A)],
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.favorite_rounded,
                      color: Colors.white, size: d * 0.2),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: d * 0.12),
        Row(
          children: [
            Expanded(
              child: Text(one?.name ?? '--',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: nameStyle),
            ),
            Expanded(
              child: Text(two?.name ?? '--',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: nameStyle),
            ),
          ],
        ),
        2.hBox,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.diamond_rounded,
                size: 12.sp, color: const Color(0xFF7FD3FF)),
            3.wBox,
            Text(
              const ListBodyCp().formatNumber(entity?.exp ?? 0),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
                shadows: [
                  Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 3),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Round avatar in a glowing gold ring; an empty seat shows a soft white disc.
class _GoldAvatar extends StatelessWidget {
  const _GoldAvatar({required this.url, required this.d});

  final String? url;
  final double d;

  @override
  Widget build(BuildContext context) {
    final image = url ?? '';
    return Container(
      width: d,
      height: d,
      padding: EdgeInsets.all(d * 0.05),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF1A8), Color(0xFFF5B521), Color(0xFFFFE07A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD15C).withValues(alpha: 0.7),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipOval(
        child: image.isNotEmpty
            ? ImageViewWidget(
                url: image,
                displayName: '',
                height: d,
                width: d,
                boxFit: BoxFit.cover,
              )
            : Container(color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }
}

/// Rank 4+ row: rank number, the couple with a heart, names and score.
class _RankRow extends StatelessWidget {
  const _RankRow({required this.rank, required this.entity});

  final int rank;
  final CpUserRankEntity entity;

  @override
  Widget build(BuildContext context) {
    final d = 42.h;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28.w,
            child: Text(
              '$rank',
              style: TextStyle(
                color: const Color(0xFFF2387A),
                fontWeight: FontWeight.w900,
                fontSize: 16.sp,
              ),
            ),
          ),
          _GoldAvatar(url: entity.userOne?.image, d: d),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Icon(Icons.favorite_rounded,
                color: const Color(0xFFF2387A), size: 16.sp),
          ),
          _GoldAvatar(url: entity.userTwo?.image, d: d),
          10.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entity.userOne?.name ?? '--'} & ${entity.userTwo?.name ?? '--'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF3A2230),
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
                3.hBox,
                Row(
                  children: [
                    Icon(Icons.diamond_rounded,
                        size: 12.sp, color: const Color(0xFF4FB8F0)),
                    3.wBox,
                    Text(
                      const ListBodyCp().formatNumber(entity.exp ?? 0),
                      style: TextStyle(
                        color: const Color(0xFF8A6A7A),
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

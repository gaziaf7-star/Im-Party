import 'package:general/src/features/family/family.dart';
import 'package:general/src/features/home/presentation/home/bloc/fetch_top_ranking_manager/fetch_top_ranking_bloc.dart';
import '../../../../../../core/index.dart';

/// Three ranking cards -- Gift, Family, CP -- replacing the old two-banner
/// promo strip on the home feed, on request. Order and destinations, per the
/// owner: Gift -> Routes.rankScreen (wealth/sender), Family ->
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
    if (!di<FetchTopUserImageBloc>().state.requestState.isLoaded) {
      di<FetchTopUserImageBloc>().add(const FetchTopUserImageEvent());
    }
    if (di<GetFamilyRankingBloc>().state.weeklyRequestState ==
        RequestState.idle) {
      di<GetFamilyRankingBloc>().add(const GetWeeklyFamilyRankingEvent());
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
            child: BlocBuilder<FetchTopUserImageBloc, FetchTopRankingState>(
              bloc: di<FetchTopUserImageBloc>(),
              buildWhen: (prev, curr) =>
                  prev.rankingEntity != curr.rankingEntity,
              builder: (context, state) {
                return _MiniRankCard(
                  background: AssetsManager.backgroundRankHomeWealth,
                  title: StringManager.giftRank.tr(),
                  avatarUrls: state.rankingEntity?.sender ?? const [],
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.rankScreen,
                    arguments: 1,
                  ),
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
                  prev.weeklyTopFamilies != curr.weeklyTopFamilies,
              builder: (context, state) {
                final families = state.weeklyTopFamilies ?? const [];
                return _MiniRankCard(
                  background: AssetsManager.backgroundRankHomeRoom,
                  title: StringManager.family.tr(),
                  avatarUrls: families.map((f) => f.img ?? '').toList(),
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.familyRankPage),
                );
              },
            ),
          ),
          8.wBox,
          // 3. CP Ranking
          Expanded(
            child: BlocBuilder<FetchTopUserImageBloc, FetchTopRankingState>(
              bloc: di<FetchTopUserImageBloc>(),
              buildWhen: (prev, curr) =>
                  prev.rankingEntity != curr.rankingEntity,
              builder: (context, state) {
                final topCp = state.rankingEntity?.topCpEntity ?? const [];
                final first = topCp.isNotEmpty ? topCp.first : null;
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

/// The shared "background image + title + 3 overlapping ranked avatars"
/// card, used by Gift and Family (CP gets its own two-avatar-plus-heart
/// layout below).
class _MiniRankCard extends StatelessWidget {
  const _MiniRankCard({
    required this.background,
    required this.title,
    required this.avatarUrls,
    required this.onTap,
  });

  final String background;
  final String title;
  final List<String> avatarUrls;
  final VoidCallback onTap;

  String _at(int index) => index < avatarUrls.length ? avatarUrls[index] : '';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: 10.radius,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(background),
            fit: BoxFit.cover,
          ),
          borderRadius: 10.radius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              title,
              style: context.bodySmall.bold
                  .colorExt(ColorManager.textPrimary)
                  .size(11),
            ),
            2.hBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _RankAvatar(url: _at(1), frame: AssetsManager.frameHomeTopTwo),
                4.wBox,
                _RankAvatar(
                  url: _at(0),
                  frame: AssetsManager.frameHomeTopOne,
                  big: true,
                ),
                4.wBox,
                _RankAvatar(
                    url: _at(2), frame: AssetsManager.frameHomeTopThree),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RankAvatar extends StatelessWidget {
  const _RankAvatar({
    required this.url,
    required this.frame,
    this.big = false,
  });

  final String url;
  final String frame;
  final bool big;

  @override
  Widget build(BuildContext context) {
    // The frame art's own ring sits well inside its canvas, so the avatar
    // has to be sized noticeably smaller than the frame box (not just a
    // couple px) to actually land inside the ring instead of poking out
    // past it -- same ~0.65 ratio RankSliderWidget's full-size cards use.
    final frameSize = (big ? 34.0 : 27.0).h;
    final avatarSize = frameSize * 0.62;
    return SizedBox(
      height: frameSize,
      width: frameSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (url.isNotEmpty)
            ClipOval(
              child: ImageViewWidget(
                url: url,
                displayName: '',
                height: avatarSize,
                width: avatarSize,
                boxFit: BoxFit.cover,
              ),
            ),
          Image.asset(frame,
              height: frameSize, width: frameSize, fit: BoxFit.contain),
        ],
      ),
    );
  }
}

/// CP Ranking's own layout: two avatars with a connecting heart between
/// them, matching the reference design, rather than the 3-avatar frame
/// pattern the other two cards use.
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
    return InkWell(
      borderRadius: 10.radius,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsManager.backgroundRankHomeCharm),
            fit: BoxFit.cover,
          ),
          borderRadius: 10.radius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              StringManager.cP.tr(),
              style: context.bodySmall.bold
                  .colorExt(ColorManager.textPrimary)
                  .size(11),
            ),
            4.hBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CpAvatar(url: userOneImage),
                Image.asset(
                  AssetsManager.heartCpProfile,
                  height: 20.h,
                  width: 20.h,
                ),
                _CpAvatar(url: userTwoImage),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CpAvatar extends StatelessWidget {
  const _CpAvatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final size = 26.0.h;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ColorManager.white, width: 1.5),
      ),
      child: url.isNotEmpty
          ? ClipOval(
              child: ImageViewWidget(
                url: url,
                displayName: '',
                height: size,
                width: size,
                boxFit: BoxFit.cover,
              ),
            )
          : CircleAvatar(
              radius: size / 2,
              backgroundColor: ColorManager.grey2,
            ),
    );
  }
}

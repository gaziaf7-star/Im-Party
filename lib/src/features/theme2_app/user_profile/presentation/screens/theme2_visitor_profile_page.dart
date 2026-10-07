import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/animated_dialog.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/add_or_delete_block/add_or_delete_block_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/add_or_delete_block/add_or_delete_block_event.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/cp/presentation/cp_store/bloc/cp_profile_bloc/cp_profile_bloc.dart';
import 'package:general/src/features/moment/moment.dart';
import 'package:general/src/features/moment/presentation/view/widgets/moment_item.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/badge_bloc/badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_badge/user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_event.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/get_reels/get_reels_bloc.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/view/play_myreels_view.dart';
import 'package:general/reels_viewer/reels_viewer.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_intro_bloc/get_user_intro_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_intro_bloc/get_user_intro_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_rooms/get_user_rooms_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_rooms/get_user_rooms_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/gift_history_bloc/gift_history_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/gift_history_bloc/gift_history_event.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/user_online/user_online_bloc.dart';
import 'package:general/src/features/theme2_app/user_profile/presentation/widgets/theme2_visitor_profile_header.dart';
import 'package:general/src/features/theme2_app/user_profile/presentation/widgets/theme2_visitor_action_bar.dart';
import 'package:general/src/features/theme2_app/user_profile/presentation/widgets/theme2_visitor_relation_tab.dart';
import 'package:general/src/features/theme2_app/user_profile/presentation/widgets/theme2_visitor_honor_tab.dart';

/// Redesigned to match the reference image exactly: cover photo with an
/// "Add photos" prompt when empty, the avatar straddling the cover/white
/// boundary, name/ID/stat-pills on white, and a real tab bar — Personal /
/// Moment / Gift / Relation / Achievements — underneath. This replaces the
/// single continuous scroll from the previous revision; every underlying
/// feature (Moments, Reels, gifts, entrance effects, Family/CP/Friend/
/// Agency/Supporters) is kept, just re-homed under the tab it belongs to.
class Theme2VisitorProfilePage extends StatefulWidget {
  final UserEntity? userData;
  final String? userId;
  final bool? comesFromRoom;

  const Theme2VisitorProfilePage({
    super.key,
    this.userData,
    this.userId,
    this.comesFromRoom,
  });

  /// The user id of the profile currently open on screen (empty when none).
  /// Single source of truth used by deep-link handling to avoid re-opening the
  /// same profile. (Relocated here from the retired UserProfileScreen.)
  static String currentUserId = '';

  @override
  State<Theme2VisitorProfilePage> createState() =>
      _Theme2VisitorProfilePageState();
}

class _Theme2VisitorProfilePageState extends State<Theme2VisitorProfilePage>
    with SingleTickerProviderStateMixin {
  bool isMyProfile = true;
  late final GiftHistoryBloc giftHistoryBloc;
  late final FetchUserDataBloc fetchUserDataBloc;
  late final UserBadgesBloc userBadgesBloc;
  late final GetSupporterBloc getSupporterBloc;
  late final GetUserIntroBloc getUserIntroBloc;
  late final MomentBloc momentBloc;
  late final CpProfileBloc cpProfileBloc;
  late final GetBadgesBloc getBadgesBloc;
  late final GetUserRoomsBloc getUserRoomsBloc;
  late final GetReelsBloc getReelsBloc;
  late final TabController _tabController;

  /// Tracks whether the sticky tab bar is currently stuck at the very top
  /// of the screen (vs. still sitting in its normal spot below the cover
  /// header) — used to only show the extra top gap once it's actually
  /// pinned, per request.
  late final ScrollController _outerScrollController;
  final GlobalKey _headerBoxKey = GlobalKey();
  bool _isTabBarPinned = false;

  /// Page-scoped presence bloc for the visited profile's header. A fresh
  /// instance (NOT di<UserOnlineBloc>(), which the chat header owns) so opening a
  /// peer profile from a chat never repoints/stops the chat's presence watch.
  late final UserOnlineBloc onlineBloc;

  /// Profile user id resolved in initState; used by the data fetchers below.
  String? _profileUserId;

  /// Set when the DI lookups in initState failed (container reset race). build()
  /// renders an empty scaffold and the screen pops on the next frame.
  bool _initFailed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _outerScrollController = ScrollController()
      ..addListener(_handleOuterScroll);
    // CR-3 guard: a DI container reset (logout / switch account) mid-navigation
    // makes these di<>() lookups throw GetIt "Object/factory not registered"
    // (throwIfNot Bad state). Wrap them so a half-initialized screen pops safely
    // instead of crashing.
    try {
      giftHistoryBloc = di<GiftHistoryBloc>();
      fetchUserDataBloc = di<FetchUserDataBloc>();
      userBadgesBloc = di<UserBadgesBloc>();
      getUserIntroBloc = di<GetUserIntroBloc>();
      getSupporterBloc = di<GetSupporterBloc>();
      getBadgesBloc = di<GetBadgesBloc>();
      momentBloc = di<MomentBloc>();
      cpProfileBloc = di<CpProfileBloc>();
      getUserRoomsBloc = di<GetUserRoomsBloc>();
      getReelsBloc = di<GetReelsBloc>();
      onlineBloc = UserOnlineBloc(di());
    } catch (_) {
      _initFailed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
      return;
    }

    if (widget.userId == null) {
      isMyProfile = true;
      final ownId = widget.userData?.id ?? MyDataModel.getInstance().id;
      _profileUserId = (ownId != null && ownId != 0) ? '$ownId' : null;
    } else {
      isMyProfile = false;
      Theme2VisitorProfilePage.currentUserId = widget.userId ?? '';
      _profileUserId = '${widget.userId}';
    }

    // Defer all network dispatch until after the first frame so the page
    // paints (and the route transition runs) before HTTP work starts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      momentBloc.add(const ResetMyMomentsEvent());

      final id = _profileUserId;
      if (id == null) return;

      if (!isMyProfile) {
        fetchUserDataBloc
            .add(FetchUserEvent(userId: id, isVisit: true));
        getUserRoomsBloc.add(GetUserRooms(id: int.tryParse(id) ?? 0));
        // Keep the header's presence label live from the unified presence
        // source (GET /user-status/{id}) via this page's OWN bloc.
        onlineBloc.add(UserOnlineEvent(userId: id));
      }
      // Every tab's data loads up front — none of them is heavy enough to
      // need the old lazy per-tab-selection loading.
      _fetchAllData(id);
    });
  }

  /// Load everything every tab needs.
  void _fetchAllData(String id) {
    cpProfileBloc.add(GetCpProfileEvents(userId: id));
    getSupporterBloc.add(GetUserSupporterEvent(userId: id));
    userBadgesBloc.add(GetUserBadges(id: id));
    getBadgesBloc.add(GetMyAllBadges(id: id));
    // The admin-assigned badges (host/agency/etc, /api/badges/users/{id}) --
    // a separate source from the achievement badges above. Same bloc/event
    // the Mine tab and the room profile sheet already use.
    di<GetUserBadgesBloc>().add(GetUserBadgesData(id: int.tryParse(id) ?? 0));
    giftHistoryBloc.add(GetGiftHistory(id: id));
    getUserIntroBloc.add(GetUserIntro(id: id));
    momentBloc.add(FetchMyMomentData(type: '1', userId: id));
    getReelsBloc.add(GetMyReels(userId: id));
  }

  /// Flips [_isTabBarPinned] once the outer scroll has passed the cover
  /// header's rendered height — i.e. the exact moment the tab bar becomes
  /// stuck at the top of the screen instead of sitting under the header.
  void _handleOuterScroll() {
    if (!_outerScrollController.hasClients) return;
    final renderBox =
    _headerBoxKey.currentContext?.findRenderObject() as RenderBox?;
    final headerHeight = renderBox?.size.height ?? 0;
    if (headerHeight <= 0) return;
    final pinned = _outerScrollController.offset >= headerHeight - 1;
    if (pinned != _isTabBarPinned) {
      setState(() => _isTabBarPinned = pinned);
    }
  }

  void _showReportDialog(BuildContext context, String userId) {
    // Open the reporting flow: navigate to the user profile with report intent.
    // The existing UserReportBloc + ReportUserUseCase handle the actual submission.
    Methods().userProfileNavigator(
      context: context,
      userId: userId,
    );
  }

  void _showMoreOptions(BuildContext context, UserEntity? user) {
    final userId = '${user?.id ?? 0}';
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        isHideConfirm: true,
        isUpdateDialog: false,
        titleDivider: false,
        showIcon: false,
        radius: 5,
        horizontalPadding: 50,
        contentPadding: context.paddingZero(),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context, userId);
              },
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: Center(
                  child: TextWidget(
                    StringManager.report.tr(),
                    style: context.bodyMedium.size(16).colorExt(ColorManager.textPrimary),
                  ),
                ),
              ),
            ),
            const Divider(height: 0.5, color: ColorManager.grey2, thickness: 0.5),
            InkWell(
              onTap: () {
                if (user?.hasAntiBan ?? false) {
                  Methods.showToast(context,
                      message: StringManager.userHasAntiBan.tr(), isError: true);
                  return;
                }
                di<AddOrRemoveBlock>().add(AddBlockListEvent(context, userId: userId));
                Navigator.pop(context);
              },
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: Center(
                  child: TextWidget(
                    StringManager.addToBlacklist.tr(),
                    style: context.bodyMedium.size(16).colorExt(ColorManager.textPrimary),
                  ),
                ),
              ),
            ),
            const Divider(height: 0.5, color: ColorManager.grey2, thickness: 0.5),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: Center(
                  child: TextWidget(
                    StringManager.cancel.tr(),
                    style: context.bodyMedium.size(16).colorExt(ColorManager.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _outerScrollController.removeListener(_handleOuterScroll);
    _outerScrollController.dispose();
    Theme2VisitorProfilePage.currentUserId = "";
    // Close this page's own presence bloc (cancels its poll); the chat's shared
    // di<UserOnlineBloc>() is untouched, so the chat header stays live.
    if (!_initFailed) {
      onlineBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DI lookups failed in initState (container reset race) — render nothing;
    // the post-frame callback pops the route.
    if (_initFailed) {
      return const Scaffold(backgroundColor: Colors.transparent);
    }
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
        bloc: isMyProfile ? di<FetchUserDataBloc>() : fetchUserDataBloc,
        buildWhen: (prev, curr) =>
        prev.reqState != curr.reqState ||
            prev.reqStateUser != curr.reqStateUser ||
            prev.otherUserEntity != curr.otherUserEntity,
        builder: (context, state) {
          final reqState = isMyProfile ? state.reqState : state.reqStateUser;
          final user = isMyProfile ? widget.userData : state.otherUserEntity;
          final userId = isMyProfile
              ? widget.userData?.id.toString() ?? ''
              : widget.userId ?? '';

          return HandlingDataWidget(
            reqState: reqState,
            title: '',
            subTitle: '',
            child: NestedScrollView(
              controller: _outerScrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: KeyedSubtree(
                    key: _headerBoxKey,
                    child: Theme2VisitorProfileHeader(
                      user: user,
                      isMyProfile: isMyProfile,
                      cpProfileBloc: cpProfileBloc,
                      userOnlineBloc: onlineBloc,
                      userBadgesBloc: userBadgesBloc,
                      onEditTap: () => Navigator.pushNamed(
                        context,
                        Routes.editProfile,
                        arguments: MyDataModel.getInstance(),
                      ),
                      onMoreTap: () => _showMoreOptions(context, user),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _Theme2StickyTabBarDelegate(
                    isPinned: _isTabBarPinned,
                    // CP-tabbar look, on request: gradient-filled pills (no
                    // icons, text only), same select/unselect gradients and
                    // size as CpTabPill — replaces the old icon+underline
                    // Material TabBar.
                    tabBar: PreferredSize(
                      preferredSize: Size.fromHeight(66.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: AnimatedBuilder(
                            animation: _tabController,
                            builder: (context, _) {
                              final labels = [
                                StringManager.personal.tr(),
                                StringManager.moment.tr(),
                                StringManager.gift.tr(),
                                // No exact "Relation" string exists in this
                                // app's StringManager — plain text, same as
                                // before.
                                'Relation',
                                StringManager.achievements.tr(),
                              ];
                              return Row(
                                // A horizontal SingleChildScrollView gives its
                                // child unbounded width — a Row defaults to
                                // MainAxisSize.max and tries to fill that
                                // unbounded space, which throws during layout
                                // ("RenderBox was not laid out") and corrupts
                                // the whole NestedScrollView's sliver
                                // pipeline (the "Null check operator used on
                                // a null value" crash). MainAxisSize.min
                                // makes the Row hug its children instead.
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (int i = 0; i < labels.length; i++) ...[
                                    if (i != 0) 8.wBox,
                                    SizedBox(
                                      // Widened on request.
                                      width: 108.w,
                                      child: Padding(
                                        // Bottom margin, on request.
                                        padding: EdgeInsets.only(bottom: 6.h),
                                        child: _ProfileTabPill(
                                          text: labels[i],
                                          selected: _tabController.index == i,
                                          onTap: () =>
                                              _tabController.animateTo(i),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _PersonalTab(user: user),
                  _MomentAndReelsTab(
                    momentBloc: momentBloc,
                    getReelsBloc: getReelsBloc,
                    userId: userId,
                  ),
                  _GiftTab(
                    userBadgesBloc: userBadgesBloc,
                    getBadgesBloc: getBadgesBloc,
                    getUserIntroBloc: getUserIntroBloc,
                    giftHistoryBloc: giftHistoryBloc,
                    userId: userId,
                  ),
                  _RelationTabScroll(
                    user: user,
                    isMyProfile: isMyProfile,
                    getSupporterBloc: getSupporterBloc,
                    cpProfileBloc: cpProfileBloc,
                  ),
                  _AchievementsTab(userBadgesBloc: userBadgesBloc),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: isMyProfile
          ? null
          : BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
        bloc: fetchUserDataBloc,
        buildWhen: (prev, curr) =>
        prev.reqStateUser != curr.reqStateUser ||
            prev.otherUserEntity != curr.otherUserEntity,
        builder: (context, state) {
          if (!state.reqStateUser.isLoaded) {
            return const SizedBox.shrink();
          }
          return Theme2VisitorActionBar(user: state.otherUserEntity);
        },
      ),
    );
  }
}

/// Sticky tab bar delegate.
class _Theme2StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  // Was typed `TabBar` — generalized to accept the custom CP-style pill row
  // (any PreferredSizeWidget), since this delegate only ever reads
  // `preferredSize`.
  final PreferredSizeWidget tabBar;

  // Whether the tab bar is currently stuck at the very top of the screen
  // (vs. still in its normal spot right under the cover header). The extra
  // top gap below only applies once it's actually pinned there — on
  // request, no gap while it's still sitting in its normal position.
  final bool isPinned;

  // While pinned at the top, sit this far below the very top edge instead
  // of flush against it (10px, then another 20px more on request = 30px).
  static const double _topGap = 30;

  _Theme2StickyTabBarDelegate({required this.tabBar, required this.isPinned});

  // minExtent/maxExtent used to change with [isPinned] (+_topGap once
  // pinned). A pinned SliverPersistentHeader rebuilding with a DIFFERENT
  // extent mid-scroll (triggered by the scroll-listener's setState) leaves
  // the sliver's old geometry (computed with the previous extent) and the
  // new layoutExtent out of sync for one frame, throwing "layoutExtent
  // exceeds paintExtent" and, downstream, "Null check operator used on a
  // null value" inside NestedScrollView's viewport. Reserving the gap's
  // space UNCONDITIONALLY keeps the extent constant across pin/unpin, so
  // the sliver geometry never becomes invalid; only the visible padding
  // (harmless, doesn't affect layout) still toggles with [isPinned].
  @override
  double get minExtent => tabBar.preferredSize.height + _topGap.h;

  @override
  double get maxExtent => tabBar.preferredSize.height + _topGap.h;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Explicit `height: minExtent` (== maxExtent, this header never shrinks)
    // is the actual fix for the SliverGeometry crash: without it, a
    // Container shrink-wraps to its child's natural height — only the
    // tabBar's 66.h when unpinned (no top padding) — while the sliver
    // machinery still lays this out against the DECLARED maxExtent
    // (tabBar height + _topGap). Flutter computes paintExtent from the
    // real measured child size but layoutExtent from the declared extent,
    // and the two fall out of sync ("layoutExtent exceeds paintExtent")
    // whenever they don't match. Forcing the Container to always occupy
    // the full declared extent makes the two always agree; the leftover
    // space when unpinned just shows as more of the gradient background
    // below the tab bar instead of a gap above it.
    return Container(
      height: minExtent,
      // A soft gradient wash instead of flat white, on request.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFDF2FF), Color(0xFFF3F0FF), Color(0xFFEFF7FF)],
        ),
      ),
      padding: EdgeInsets.only(top: isPinned ? _topGap.h : 0),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_Theme2StickyTabBarDelegate oldDelegate) =>
      oldDelegate.isPinned != isPinned || oldDelegate.tabBar != tabBar;
}

/// Same gradient/colors as CpTabPill (the CP page's tab pill), but tuned
/// separately for this screen on request: no shadow/glow, and a thicker
/// border. Kept as its own widget instead of adding params to CpTabPill so
/// the CP page's own tabs (which DO want the glow) are unaffected.
class _ProfileTabPill extends StatelessWidget {
  const _ProfileTabPill({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: selected
                ? const [Color(0xFFFF8AC2), Color(0xFFAC55E7)]
                : const [Color(0xFF4FC3FF), Color(0xFF3556E8)],
          ),
          border: Border.all(
            color: selected
                ? const Color(0xE6FFD98A)
                : const Color(0x99FFD98A),
            width: selected ? 3.4 : 2.8,
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.bodySmall
              .copyWith(fontSize: 14)
              .colorExt(selected ? Colors.white : Colors.white70)
              .copyWith(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

/// Personal tab: the account's own info fields, same shape as the reference
/// image's list — label on the left, value on the right. "Current dressup"
/// from the reference isn't included: there's no equipped-outfit/decoration
/// feature in this codebase to source it from, so it's left out rather than
/// invented.
class _PersonalTab extends StatelessWidget {
  final UserEntity? user;

  const _PersonalTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[
      ['${StringManager.appName} ID', '${user?.uuid ?? user?.id ?? ''}'],
      [
        StringManager.birthDay.tr(),
        (user?.profile?.birthday ?? '').isNotEmpty
            ? user!.profile!.birthday!
            : StringManager.noDataYet.tr(),
      ],
      [
        'Country',
        user?.country?.nameEn ?? StringManager.noDataYet.tr(),
      ],
      [
        StringManager.personalizedSignature.tr(),
        (user?.bio ?? '').isNotEmpty ? user!.bio! : StringManager.bio.tr(),
      ],
    ];

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      itemCount: rows.length,
      separatorBuilder: (_, __) => Divider(
        height: 28.h,
        color: ColorManager.grey2.withValues(alpha: 0.4),
      ),
      itemBuilder: (context, i) {
        final label = rows[i][0];
        final value = rows[i][1];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110.w,
              child: Text(
                label,
                style: TextStyle(
                    color: ColorManager.black, fontSize: 13.5.sp),
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: ColorManager.black,
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Moment tab: posts, then the reels grid underneath — both features kept
/// exactly as they worked before, just combined onto one scroll under one
/// tab instead of two separate tabs.
class _MomentAndReelsTab extends StatelessWidget {
  final MomentBloc momentBloc;
  final GetReelsBloc getReelsBloc;
  final String userId;

  const _MomentAndReelsTab({
    required this.momentBloc,
    required this.getReelsBloc,
    required this.userId,
  });

  void _openReel(BuildContext context, int index) {
    final reelViewerBloc = di<ReelViewerBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayMyReelsView(
          getReelsBloc: getReelsBloc,
          reelViewerBloc: reelViewerBloc,
          param: PlayMyReelParam(
            userId: userId,
            index: index,
            getReelsBloc: getReelsBloc,
            reelViewerBloc: reelViewerBloc,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteReel(BuildContext context, ReelsEntity reel, int index) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AnimatedDialog(
        title: StringManager.delete.tr(),
        conText: StringManager.confirm.tr(),
        cancelText: StringManager.cancel.tr(),
        onTap: () {
          Navigator.pop(dialogContext);
          getReelsBloc.add(DeleteReelEvent(index, reel.id.toString()));
        },
        onTapCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(12.r),
      children: [
        BlocBuilder<MomentBloc, MomentStates>(
          bloc: momentBloc,
          buildWhen: (prev, curr) =>
          prev.myReqState != curr.myReqState ||
              prev.myMoments != curr.myMoments,
          builder: (context, state) {
            if (state.myMoments.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.article_outlined,
                          color: ColorManager.greyText, size: 40.sp),
                      8.hBox,
                      Text(StringManager.noMomentsFound.tr(),
                          style: TextStyle(
                              color: ColorManager.black,
                              fontSize: 14.sp)),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (int i = 0; i < state.myMoments.length; i++)
                // A plain list row before — now a proper card: white,
                // rounded, a soft shadow, its own margin — on request
                // ("card ar profational design").
                  Container(
                    margin: EdgeInsets.only(bottom: 14.h),
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.black.withValues(alpha: 0.06),
                          blurRadius: 12.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: MomentItem(
                      type: '1',
                      momentBloc: momentBloc,
                      momentType: MomentType.myMoment,
                      moment: state.myMoments[i],
                      currentMomentIndex: i,
                      isProfile: true,
                    ),
                  ),
              ],
            );
          },
        ),
        16.hBox,
        Text(
          StringManager.reels.tr(),
          style: TextStyle(
            color: ColorManager.black,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        8.hBox,
        BlocBuilder<GetReelsBloc, GetReelsState>(
          bloc: getReelsBloc,
          buildWhen: (prev, curr) =>
          prev.requestMyReelsState != curr.requestMyReelsState ||
              prev.myReelsList != curr.myReelsList,
          builder: (context, state) {
            if (state.myReelsList.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.video_library_outlined,
                          color: ColorManager.greyText, size: 36.sp),
                      6.hBox,
                      Text(StringManager.noDataYet.tr(),
                          style: TextStyle(
                              color: ColorManager.black,
                              fontSize: 13.sp)),
                    ],
                  ),
                ),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.w,
                mainAxisSpacing: 4.h,
                childAspectRatio: 9 / 16,
              ),
              itemCount: state.myReelsList.length,
              itemBuilder: (context, index) {
                final reel = state.myReelsList[index];
                final isOwnReel = reel.user?.id != null &&
                    reel.user?.id == MyDataModel.getInstance().id;
                return GestureDetector(
                  onTap: () => _openReel(context, index),
                  onLongPress: isOwnReel
                      ? () => _confirmDeleteReel(context, reel, index)
                      : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ImageViewWidget(
                          url: EndPoints.getImage(reel.subFrame ?? ''),
                          boxFit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 4.h,
                          left: 4.w,
                          child: Icon(Icons.play_circle_fill,
                              color: ColorManager.white, size: 18.sp),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// Gift tab: gifts received + entrance effects — the same content
/// [Theme2VisitorHonorTab] already rendered, just under its own tab now
/// instead of appended below the relation section.
class _GiftTab extends StatelessWidget {
  final UserBadgesBloc userBadgesBloc;
  final GetBadgesBloc getBadgesBloc;
  final GetUserIntroBloc getUserIntroBloc;
  final GiftHistoryBloc giftHistoryBloc;
  final String userId;

  const _GiftTab({
    required this.userBadgesBloc,
    required this.getBadgesBloc,
    required this.getUserIntroBloc,
    required this.giftHistoryBloc,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Theme2VisitorHonorTab(
        userBadgesBloc: userBadgesBloc,
        getBadgesBloc: getBadgesBloc,
        getUserIntroBloc: getUserIntroBloc,
        giftHistoryBloc: giftHistoryBloc,
        userId: userId,
      ),
    );
  }
}

/// Relation tab: Family / CP / Friend / Agency / Supporters — unchanged
/// content from [Theme2VisitorRelationTab], just given its own scrollable
/// tab instead of sitting inline on the old single-scroll page.
class _RelationTabScroll extends StatelessWidget {
  final UserEntity? user;
  final bool isMyProfile;
  final GetSupporterBloc getSupporterBloc;
  final CpProfileBloc cpProfileBloc;

  const _RelationTabScroll({
    required this.user,
    required this.isMyProfile,
    required this.getSupporterBloc,
    required this.cpProfileBloc,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Theme2VisitorRelationTab(
        user: user,
        isMyProfile: isMyProfile,
        getSupporterBloc: getSupporterBloc,
        cpProfileBloc: cpProfileBloc,
      ),
    );
  }
}

/// Achievements tab: the full badge collection (not just the top few shown
/// on the header) — [UserBadgesBloc] already fetches this for the profile
/// being viewed; it just wasn't surfaced anywhere on this screen before.
class _AchievementsTab extends StatelessWidget {
  final UserBadgesBloc userBadgesBloc;

  const _AchievementsTab({required this.userBadgesBloc});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBadgesBloc, UserBadgesState>(
      bloc: userBadgesBloc,
      buildWhen: (prev, curr) => prev.userBadge != curr.userBadge,
      builder: (context, state) {
        final badges = state.userBadge ?? [];
        if (badges.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_outlined,
                      color: ColorManager.greyText, size: 40.sp),
                  8.hBox,
                  Text(StringManager.noDataYet.tr(),
                      style: TextStyle(
                          color: ColorManager.black, fontSize: 14.sp)),
                ],
              ),
            ),
          );
        }
        return GridView.builder(
          padding: EdgeInsets.all(16.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            // 4 per row and bigger, on request (was 3).
            crossAxisCount: 4,
            // Tighter 3px gap, on request (was 6).
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.72,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Was a filled surfaceCardColor tile -- now transparent (no
                // background), on request, and the icon itself bigger still.
                Padding(
                  padding: EdgeInsets.all(4.r),
                  child: ImageViewWidget(
                    url: EndPoints.getImage(badge.image),
                    height: 80.h,
                    width: 80.h,
                    boxFit: BoxFit.contain,
                  ),
                ),
                6.hBox,
                Text(
                  badge.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorManager.black,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
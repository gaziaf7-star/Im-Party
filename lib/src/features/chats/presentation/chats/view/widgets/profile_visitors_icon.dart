import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_event.dart';

/// Footprints icon (TikTok-style "profile views") for the Wats Jo top bar (next
/// to the notifications bell). Tapping it
/// opens the existing "who visited my profile" list (FFFScreen, index 3) and
/// marks the new-visitors counter as read. A small badge shows the unseen
/// visitor count, kept live from [FetchUserDataBloc] (same source the me-tab
/// used), so it appears/clears in realtime.
class ProfileVisitorsIcon extends StatelessWidget {
  const ProfileVisitorsIcon({super.key});

  void _open(BuildContext context) {
    // Reload the visitors list so the screen shows the latest entries, mirroring
    // the me-tab tap behaviour (f_f_f_body) — only force-load when there are
    // unseen visitors, otherwise let FFFScreen's own initState load it.
    final hasUnseen = (di<FetchUserDataBloc>()
        .state
        .userEntity
        ?.unreadCounterEntity
        ?.visitor ??
        0) >
        0;
    if (hasUnseen) {
      di<GetFollowerOrFollowingBloc>().add(const GetVisitorsEvent(loading: true));
    }
    Navigator.pushNamed(context, Routes.friendFollowing, arguments: 3);
    // Clear the unseen-visitors badge (resets unreadCounterEntity.visitor to 0).
    di<FetchUserDataBloc>().add(const ReadCounterVistorsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchUserDataBloc, FetchUserDataState>(
      bloc: di<FetchUserDataBloc>(),
      buildWhen: (p, c) =>
      p.userEntity?.unreadCounterEntity?.visitor !=
          c.userEntity?.unreadCounterEntity?.visitor,
      builder: (context, state) {
        final count = state.userEntity?.unreadCounterEntity?.visitor ?? 0;
        final icon = IconButton(
          onPressed: () => _open(context),
          // shoePrints points right by default; rotate a quarter turn
          // counter-clockwise so the footprints face upward.
          icon: RotatedBox(
            quarterTurns: 3,
            // Fixed white — this icon now always sits on the Chats page's
            // Home-style gradient band, not the panel's textPrimary.
            child: FaIcon(FontAwesomeIcons.shoePrints,
                color: ColorManager.homeHeaderTextColor, size: 20),
          ),
          tooltip: StringManager.visitors.tr(),
        );
        if (count <= 0) return icon;
        return Badge(
          label: Text(count > 99 ? '99+' : '$count'),
          backgroundColor: ColorManager.brandGradientColors.last,
          textColor: ColorManager.onBrandGradient,
          offset: const Offset(-4, 4),
          child: icon,
        );
      },
    );
  }
}
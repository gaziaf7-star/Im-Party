import 'package:general/src/core/index.dart';
import 'package:general/src/features/theme2_app/user_profile/presentation/widgets/theme2_honor_card.dart';
import 'package:general/src/features/profile/presentation/medals/bloc/badge_bloc/badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_badge/user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_intro_bloc/get_user_intro_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_intro_bloc/get_user_intro_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_intro_bloc/get_user_intro_state.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/gift_history_bloc/gift_history_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/gift_history_bloc/gift_history_state.dart';

/// تاب شرف - Medals + Gift Wall (Frames) + Titles + Entrance effects
class Theme2VisitorHonorTab extends StatelessWidget {
  final UserBadgesBloc userBadgesBloc;
  final GetBadgesBloc getBadgesBloc;
  final GetUserIntroBloc getUserIntroBloc;
  final GiftHistoryBloc giftHistoryBloc;
  final String userId;

  const Theme2VisitorHonorTab({
    super.key,
    required this.userBadgesBloc,
    required this.getBadgesBloc,
    required this.getUserIntroBloc,
    required this.giftHistoryBloc,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Nested inside _Theme2GeneralTab's scroll → shrink-wrap and disable its
      // own scrolling so the parent NestedScrollView owns all vertical scroll.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Left/right gap reduced further still on request.
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 12.h),
      children: [
        // Sent-gifts section — badges removed from profile per product
        // decision (the feature still exists elsewhere).
        _SimpleSectionTitle(title: StringManager.giftsSent.tr()),

        BlocBuilder<GiftHistoryBloc, GiftHistoryState>(
          bloc: giftHistoryBloc,
          buildWhen: (prev, curr) => prev.giftModel != curr.giftModel,
          builder: (context, state) {
            final gifts = state.giftModel ?? [];
            if (gifts.isEmpty) {
              return _EmptySection(label: StringManager.noGifts.tr());
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 8.h),
              gridDelegate: theme2HonorGridDelegate(),
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                // `show_img` is the static thumbnail (`img` is the .svga
                // send-effect).
                return Theme2HonorCard(
                  image: gift.data.showImg,
                  count: gift.num,
                  label: gift.data.name,
                );
              },
            );
          },
        ),
        // Gap between sections reduced on request.
        8.hBox,

        // Entrance effects section (دخولية)
        _SimpleSectionTitle(title: StringManager.rideQuantity.tr()),
        2.hBox,
        BlocBuilder<GetUserIntroBloc, GetUserIntroState>(
          bloc: getUserIntroBloc,
          buildWhen: (prev, curr) =>
          prev.requestState != curr.requestState ||
              prev.userIntroModel != curr.userIntroModel,
          builder: (context, state) {
            final intros = state.userIntroModel ?? [];
            if (intros.isEmpty) {
              return GestureDetector(
                onTap: () =>
                    getUserIntroBloc.add(GetUserIntro(id: userId)),
                child: _EmptySection(label: StringManager.noDataYet.tr()),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 8.h),
              gridDelegate: theme2HonorGridDelegate(),
              itemCount: intros.length,
              itemBuilder: (context, index) {
                final intro = intros[index];
                return Theme2HonorCard(
                  image: intro.image,
                  count: '${intro.count}',
                  label: StringManager.rideQuantity.tr(),
                  leadingIcon: Icons.auto_awesome_rounded,
                );
              },
            );
          },
        ),
        20.hBox,
      ],
    );
  }
}

class _SimpleSectionTitle extends StatelessWidget {
  final String title;

  const _SimpleSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: ColorManager.black,
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String label;

  const _EmptySection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: ColorManager.black,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}
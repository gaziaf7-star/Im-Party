import 'package:general/src/core/index.dart';
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                // Taller than 1:1 now that each cell shows the icon PLUS
                // both a name and a count line underneath it.
                childAspectRatio: 0.75,
              ),
              itemCount: gifts.length > 8 ? 8 : gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // `img` is the animated .svga send-effect, not a
                    // displayable static image — it never rendered here.
                    // `show_img` is the static thumbnail meant for exactly
                    // this kind of grid.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: ImageViewWidget(
                        url: EndPoints.getImage(gift.data.showImg),
                        height: 50.h,
                        width: 50.h,
                        boxFit: BoxFit.cover,
                      ),
                    ),
                    4.hBox,
                    if (gift.data.name.isNotEmpty)
                      Text(
                        gift.data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.black),
                      ),
                    if (gift.num.isNotEmpty)
                      Text('x${gift.num}',
                          style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.black)),
                  ],
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
              // 4 square-ish cards per row, matching the reference layout
              // (was 2 wide landscape banners).
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 0.8,
              ),
              itemCount: intros.length,
              itemBuilder: (context, index) {
                final intro = intros[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        // Subtle light gradient behind each card, on request
                        // (was fully transparent/card-free).
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF3E9FF),
                              Color(0xFFE6E0FF),
                            ],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: (intro.image).contains('.svga')
                              ? CacheSvgaWidget(
                            url: EndPoints.getImage(intro.image),
                            boxFit: BoxFit.cover,
                          )
                              : ImageViewWidget(
                            url: EndPoints.getImage(intro.image),
                            boxFit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    4.hBox,
                    // The reference shows a star-rarity row here instead of
                    // a count -- the backend doesn't send a rarity field for
                    // these yet (only `count`), so this stays the owned
                    // count until that's added.
                    if (intro.count > 0)
                      Text('x${intro.count}',
                          style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.black)),
                  ],
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
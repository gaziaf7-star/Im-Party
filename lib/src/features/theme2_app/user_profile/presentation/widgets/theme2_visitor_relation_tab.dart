import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/manager_show_agency/show_agency_bloc.dart';
import 'package:general/src/features/agency/presentation/search_agency_screen/view/show_hosts_agency.dart';
import 'package:general/src/features/agency/presentation/search_agency_screen/view/show_shipping_agency.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/info_charge_agency/bloc/manager_get_charge_agency_info/get_charge_agency_bloc.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/cp/presentation/cp_store/bloc/cp_profile_bloc/cp_profile_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_state.dart';
import 'package:general/src/features/theme2_app/user_profile/presentation/widgets/theme2_visitor_cp_card.dart';

/// Family + CP + Friend + Agency + Supporters section, in the reference
/// image's order (Family, then CP, then Friend). CP is back exactly as it
/// was before — on request it was removed for one revision, then put back.
class Theme2VisitorRelationTab extends StatelessWidget {
  final UserEntity? user;
  final bool isMyProfile;
  final GetSupporterBloc getSupporterBloc;
  final CpProfileBloc cpProfileBloc;

  const Theme2VisitorRelationTab({
    super.key,
    required this.user,
    required this.isMyProfile,
    required this.getSupporterBloc,
    required this.cpProfileBloc,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Nested inside the page's own SingleChildScrollView → shrink-wrap and
      // disable its own scrolling so the outer scroll owns all of it.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        // Agency section
        if (user?.myAgency != null) ...[
          _SectionTitle(
            title: StringManager.agency1.tr(),
            color: ColorManager.primary,
          ),
          8.hBox,
          _RelationInfoCard(
            name: user!.myAgency!.name ?? '',
            image: user!.myAgency!.img ?? '',
            idLabel: 'Agency ID',
            id: user!.myAgency!.id ?? 0,
            trailingText: user!.myAgency!.memberCount?.toString() ?? '0',
            gradientColors: const [Color(0xFFE879F9), Color(0xFFA855F7)],
            pillColor: const Color(0xFF7B1FA2),
            textColor: Colors.white,
            onTap: () {
              di<ShowAgencyBloc>().add(ShowAgencyEvent(
                  agencyId: user!.myAgency!.id, isFirstLoading: true));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShowHostsAgency(
                    agencyData: null,
                    isProfile: true,
                  ),
                ),
              );
            },
          ),
          16.hBox,
        ],

        // Shipping Agency section
        if (user?.myShippingAgency != null &&
            ConstantsManager.isHostAgencyVisible) ...[
          _SectionTitle(
            title: StringManager.chargeAgency.tr(),
            color: ColorManager.primary,
          ),
          8.hBox,
          _RelationInfoCard(
            name: user!.myShippingAgency!.name ?? '',
            image: user!.myShippingAgency!.img ?? '',
            idLabel: 'Agency ID',
            id: user!.myShippingAgency!.id ?? 0,
            trailingText: '',
            gradientColors: const [Color(0xFF60A5FA), Color(0xFF3B82F6)],
            pillColor: const Color(0xFF1D4ED8),
            textColor: Colors.white,
            onTap: () {
              di<GetChargeAgencyBloc>().add(GetChargeAgencyEvent(
                  agencyId: user!.myShippingAgency!.id,
                  isFirstLoading: true));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShowShippingAgency(
                    agencyData: null,
                    isProfile: true,
                    id: user!.myShippingAgency!.id,
                  ),
                ),
              );
            },
          ),
          16.hBox,
        ],

        // Family section — explicit empty state when the user has not
        // joined a family yet, per the reference image (was silently
        // omitted entirely before).
        _SectionTitle(
          title: StringManager.family.tr(),
          color: ColorManager.primary,
        ),
        8.hBox,
        if (user?.familyData != null)
          _RelationInfoCard(
            name: user!.familyData!.name ?? '',
            image: user!.familyData!.img ?? '',
            idLabel: 'Family ID',
            id: user!.familyData!.id ?? 0,
            trailingText:
                '${user!.familyData!.memberNum ?? 0}/${user!.familyData!.maxNum ?? 0}',
            gradientColors: const [Color(0xFFFFE7A0), Color(0xFFFFC15E)],
            pillColor: const Color(0xFFB3261E),
            textColor: const Color(0xFF6B4A00),
            onTap: () {
              if (user!.familyData!.ownerFamilyId != 0) {
                Navigator.pushNamed(context, Routes.familyScreen,
                    arguments: '${user!.familyId}');
              } else {
                context.pushNamedRoute(Routes.familyRankPage);
              }
            },
          )
        else
          _EmptyRow(label: StringManager.noFamilys.tr()),
        16.hBox,

        // CP section — exactly as it was before.
        _SectionTitle(
          title: StringManager.cP.tr(),
          color: ColorManager.primary,
        ),
        8.hBox,
        Theme2VisitorCpCard(
          // Matches exactly how this was wired before this section was
          // briefly removed and restored.
          myProfile: Methods.isMe(user?.id.toString() ?? ''),
          userEntity: user ?? const UserEntity(),
          cpProfileBloc: cpProfileBloc,
        ),
        16.hBox,

        // Friend section — count only; the drill-down list (Routes.
        // friendFollowing) is always built around the SIGNED-IN user's own
        // data, so it only makes sense to open it from your own profile.
        _SectionTitle(
          title: StringManager.friends.tr(),
          color: ColorManager.primary,
        ),
        8.hBox,
        _FriendRow(
          count: '${user?.numberOfFriends ?? 0}',
          isMyProfile: isMyProfile,
          onTap: isMyProfile
              ? () => Navigator.pushNamed(context, Routes.friendFollowing,
              arguments: 2)
              : null,
        ),
        16.hBox,

        // Supporters section
        _SectionTitle(
          title: StringManager.supporters.tr(),
          color: ColorManager.primary,
        ),
        8.hBox,
        BlocBuilder<GetSupporterBloc, GetUserSupporterState>(
          bloc: getSupporterBloc,
          buildWhen: (prev, curr) => prev.topSupport != curr.topSupport,
          builder: (context, state) {
            final supporters = [
              ...(state.topSupport?.topUser ?? []),
              ...(state.topSupport?.otherUsers ?? []),
            ];

            if (supporters.isEmpty) {
              return _EmptyRow(label: StringManager.noDataYet.tr());
            }

            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, Routes.supportScreen,
                    arguments: SupportScreenParam(
                      userId: user?.id.toString() ?? '',
                      getSupporterBloc: getSupporterBloc,
                    ));
              },
              child: SizedBox(
                height: 80.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: supporters.length > 8 ? 8 : supporters.length,
                  separatorBuilder: (_, __) => 12.wBox,
                  itemBuilder: (context, index) {
                    final supporter = supporters[index];
                    return GestureDetector(
                      onTap: () {
                        Methods().userProfileNavigator(
                          context: context,
                          userId: '${supporter.id}',
                        );
                      },
                      child: Column(
                        children: [
                          UserImage(
                            image: supporter.image ?? '',
                            displayName: supporter.name ?? '',
                            imageSize: 52.r,
                          ),
                          4.hBox,
                          SizedBox(
                            width: 52.w,
                            child: Text(
                              _formatTotal(supporter.total ?? '0'),
                              style: TextStyle(
                                color: ColorManager.black,
                                fontSize: 10.sp,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatTotal(String total) {
    final num = double.tryParse(total) ?? 0;
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}m';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(0)}k';
    return total;
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        8.wBox,
        Text(
          title,
          style: TextStyle(
            // Hardcoded black, not the panel-driven textPrimary token — on
            // request, every section title on this white sheet (Family,
            // Supporters, etc.) must read as plain black regardless of what
            // the panel's text-colour setting is.
            color: ColorManager.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// A plain "no data" line, same look for Family's and Supporters' empty
/// states.
class _EmptyRow extends StatelessWidget {
  final String label;

  const _EmptyRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(color: ColorManager.black, fontSize: 13.sp),
      ),
    );
  }
}

/// Friend count row with a chevron — tappable (into Followers/Following/
/// Friends/Visitors, on the Friends tab) only on your own profile, since
/// that screen is always built around the signed-in user's own data.
class _FriendRow extends StatelessWidget {
  final String count;
  final bool isMyProfile;
  final VoidCallback? onTap;

  const _FriendRow({
    required this.count,
    required this.isMyProfile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(Icons.people_alt_rounded,
                color: ColorManager.primary, size: 20.sp),
            10.wBox,
            Expanded(
              child: Text(
                '$count ${StringManager.friends.tr()}',
                style: TextStyle(
                  color: ColorManager.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isMyProfile)
              Icon(Icons.arrow_forward_ios,
                  color: ColorManager.secondaryText, size: 14.sp),
          ],
        ),
      ),
    );
  }
}

/// Shared "relation" card look (Family, Agency, Shipping Agency all use this
/// now, on request — was the Family-only design, generalized so Agency gets
/// the same layout with its own gradient). Crest on the left, name in a
/// colored pill, an "ID:" line, and a trailing count on the right.
///
/// `FamilyModel`/agency models don't carry a level, a rank number, or the
/// current member's role, so the Family reference image's "Lv.16" /
/// "No.99+" pills and its "Co-Leader" badge aren't shown here — add those
/// fields to the API response and they can be wired in the same way.
class _RelationInfoCard extends StatelessWidget {
  final String name;
  final String image;
  final String idLabel;
  final int id;
  final String trailingText;
  final List<Color> gradientColors;
  final Color pillColor;
  final Color textColor;
  final VoidCallback onTap;

  const _RelationInfoCard({
    required this.name,
    required this.image,
    required this.idLabel,
    required this.id,
    required this.trailingText,
    required this.gradientColors,
    required this.pillColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          // Reduced from 14 to 2, on request, shared by every card using
          // this widget.
          borderRadius: BorderRadius.circular(2.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: ImageViewWidget(
                url: EndPoints.getImage(image),
                displayName: name,
                height: 46.h,
                width: 46.w,
                boxFit: BoxFit.cover,
              ),
            ),
            10.wBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: pillColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  6.hBox,
                  Text(
                    '$idLabel:$id',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText.isNotEmpty) ...[
              10.wBox,
              Row(
                children: [
                  Icon(Icons.people_alt_rounded,
                      color: textColor, size: 15.sp),
                  4.wBox,
                  Text(
                    trailingText,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/widgets/custom_row_widget.dart';

import 'package:general/src/core/index.dart';
import '../../../../games/domain/entities/user_top_entity.dart';
import '../../../agency.dart';
import 'component/rank_container_widget.dart';
import 'component/top_three_widget.dart';

part 'component/agency_member.dart';

class ShowHostsAgency extends StatefulWidget {
  final AgenciesEntity? agencyData;
  final bool isProfile;

  const ShowHostsAgency({
    super.key,
    this.agencyData,
    required this.isProfile,
  });

  @override
  State<ShowHostsAgency> createState() => _ShowHostsAgencyState();
}

class _ShowHostsAgencyState extends State<ShowHostsAgency> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBg,
      appBar: const AppBarWidget(
        title: StringManager.agency1,
      ),
      body: BlocBuilder<AgencySearchBloc, AgencySearchState>(
        bloc: di<AgencySearchBloc>(),
        buildWhen: (prev, curr) => prev.agencyModel != curr.agencyModel || prev.agencySearchModel != curr.agencySearchModel,
        builder: (context, agencySearchState) {
          Methods.printLog('di<AgencySearchBloc>() rebuilded');
          final AgenciesEntity? resolvedAgency = (() {
            final List<AgenciesEntity> agencies = [
              ...?agencySearchState.agencyModel?.agencies,
              ...?agencySearchState.agencySearchModel?.agencies,
            ];
            final fallback = widget.agencyData;

            if (fallback == null || agencies.isEmpty) {
              return fallback;
            }

            for (final agency in agencies) {
              if (agency.id == fallback.id) {
                return agency;
              }
            }

            return fallback;
          })();
          return BlocBuilder<ShowAgencyBloc, ShowAgencyState>(
            bloc: di<ShowAgencyBloc>(),
            buildWhen: (prev, curr) => prev.requestState != curr.requestState || prev.data != curr.data,
            builder: (context, state) {
              if (widget.isProfile && widget.agencyData == null) {
                return Stack(
                  children: [
                    HandlingDataWidget(
                      reqState: state.requestState,
                      title: StringManager.someThingWentWrong,
                      subTitle: StringManager.someThingWentWrong,
                      child: _buildAgencyUI(
                        ProfileParams(
                          img: state.data?.image ?? '',
                          agencyType: state.data?.agencyType ?? 'shipping',
                          name: state.data?.name ?? '',
                          id: state.data?.id?.toString() ?? '',
                          ownerImage: state.data?.owner?.profile?.image ?? '',
                          ownerName: state.data?.owner?.name ?? '',
                          owneruuid: state.data?.owner?.uuid?.toString() ?? '',
                          ownerId: state.data?.owner?.id ?? 0,
                          members: state.data?.members ?? [],
                          admins: state.data?.admins ?? [],
                          stars: state.data?.stars ?? [],
                          isJoinRequested: state.data?.isJoinRequest ?? false,
                        ),
                      ),
                    ),
                    if (state.data?.isJoinRequest == false &&
                        (!(StringManager.userType[1]! ||
                            StringManager.userType[2]! ||
                            StringManager.userType[6]!)))
                      Positioned(
                        bottom: 10.h,
                        left: 0,
                        right: 0,
                        child: _buildJoinButton(
                          ProfileParams(
                            img: state.data?.image ?? '',
                            agencyType: state.data?.agencyType ?? 'shipping',
                            name: state.data?.name ?? '',
                            id: state.data?.id?.toString() ?? '',
                            ownerImage: state.data?.owner?.profile?.image ?? '',
                            ownerName: state.data?.owner?.name ?? '',
                            owneruuid:
                                state.data?.owner?.uuid?.toString() ?? '',
                            ownerId: state.data?.owner?.id ?? 0,
                            members: state.data?.members ?? [],
                            admins: state.data?.admins ?? [],
                            stars: state.data?.stars ?? [],
                            isJoinRequested: state.data?.isJoinRequest ?? false,
                          ),
                        ),
                      ),
                  ],
                );
              }

              return Stack(
                children: [
                  _buildAgencyUI(
                    ProfileParams(
                      img: resolvedAgency?.image ?? '',
                      agencyType: resolvedAgency?.agencyType ?? 'shipping',
                      name: resolvedAgency?.name ?? '',
                      id: resolvedAgency?.id?.toString() ?? '',
                      ownerImage: resolvedAgency?.owner?.image ?? '',
                      ownerName: resolvedAgency?.owner?.name ?? '',
                      owneruuid: resolvedAgency?.owner?.uuid?.toString() ?? '',
                      ownerId: resolvedAgency?.owner?.id ?? 0,
                      members: resolvedAgency?.members ?? [],
                      admins: resolvedAgency?.admins ?? [],
                      stars: resolvedAgency?.stars ?? [],
                      isJoinRequested: resolvedAgency?.isJoinRequest ?? false,
                    ),
                  ),
                  if ((!(StringManager.userType[1]! ||
                      StringManager.userType[2]! ||
                      StringManager.userType[6]!)))
                    Positioned(
                      bottom: 10.h,
                      left: 0,
                      right: 0,
                      child: _buildJoinButton(
                        ProfileParams(
                          img: resolvedAgency?.image ?? '',
                          agencyType: resolvedAgency?.agencyType ?? 'shipping',
                          name: resolvedAgency?.name ?? '',
                          id: resolvedAgency?.id?.toString() ?? '',
                          ownerImage: resolvedAgency?.owner?.image ?? '',
                          ownerName: resolvedAgency?.owner?.name ?? '',
                          owneruuid:
                              resolvedAgency?.owner?.uuid?.toString() ?? '',
                          ownerId: resolvedAgency?.owner?.id ?? 0,
                          members: resolvedAgency?.members ?? [],
                          admins: resolvedAgency?.admins ?? [],
                          stars: resolvedAgency?.stars ?? [],
                          isJoinRequested:
                              resolvedAgency?.isJoinRequest ?? false,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  UserTopEntity memberEntityToUserTopEntity(MemberEntity member) {
    return UserTopEntity(
      userId: int.parse(member.uuid ?? '0'),
      name: member.name,
      avatar: member.image,
    );
  }

  List<UserTopEntity> convertMemberListToUserTopList(
      List<MemberEntity> members) {
    return members.map(memberEntityToUserTopEntity).toList();
  }

  Widget _buildAgencyUI(ProfileParams param) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 10),
      child: ListView(
        children: [
          Row(
            children: [
              UserImage(
                image: param.img,
                displayName: param.name,
                borderRadius: 50.radius,
                imageSize: 65.w,
              ),
              15.wBox,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: ScreenUtil().screenWidth * 0.7,
                    child: TextWidget(
                      param.name,
                      style: context.bodyMedium.w600.size(14),
                    ),
                  ),
                  IdWithCopyIcon(
                    userId: param.id.toString(),
                    idStyle: context.bodyMedium.w500.size(10),
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                ],
              ),
            ],
          ),
          15.hBox,
          Row(
            children: [
              Text(
                StringManager.hostCenter.tr().toUpperCase(),
                style: context.bodyMedium
                    .size(12)
                    .colorExt(ColorManager.textPrimary)
                    .w600,
              ),
            ],
          ),
          10.hBox,
          CustomRowWidget(
            title: StringManager.officeAdmin.tr(),
            iconName: AssetsManager.identitySetting2,
            scale: 2,
            color: ColorManager.primary,
            onTap: () {
              Methods().userProfileNavigator(
                context: context,
                userId: param.ownerId.toString(),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                UserImage(
                  image: param.ownerImage,
                  displayName: param.ownerName,
                  borderRadius: 50.radius,
                  imageSize: 30.w,
                ),
                5.wBox,
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ScreenUtil().screenWidth * 0.4,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      param.ownerName,
                      style: context.bodyLarge.w400.size(14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          10.hBox,
          CustomRowWidget(
            title: StringManager.agencyAdmins.tr(),
            iconName: AssetsManager.adminIcon,
            scale: 3,
            onTap: () => Navigator.pushNamed(context, Routes.adminsScreen,
                arguments: param.id),
            child: Row(
              children: List.generate(
                param.admins?.length ?? 0,
                (index) => Padding(
                  padding: context.paddingSymmetric(horizontal: 4),
                  child: UserImage(
                    image: param.admins?[index].image ?? '',
                    displayName: param.admins?[index].name ?? '',
                    borderRadius: 50.radius,
                    imageSize: 30.w,
                  ),
                ),
              ),
            ),
          ),
          10.hBox,
          CustomRowWidget(
            title: StringManager.agencyStars.tr(),
            iconName: AssetsManager.agencyStar,
            scale: 15,
            onTap: () => Navigator.pushNamed(context, Routes.starsScreen,
                arguments: param.id),
            isNeedArrow: false,
            child: const SizedBox(),
          ),
          10.hBox,
          if ((param.stars ?? []).isEmpty)
            const EmptyStateWidget()
          else ...[
            TopThreeWidgetAgency(
              usersEntity: param.stars ?? [],
              imageRank: '',
              isNeedSmallIcon: false,
              onTapImage: () {},
              nameColor: ColorManager.textPrimary,
            ),
            RankContainerWidgetAgency(
              usersRank: (param.stars?.length ?? 0) > 3
                  ? List.of((param.stars ?? []).skip(3))
                  : [],
            ),
          ],
          30.hBox,
        ],
      ),
    );
  }

  Widget _buildJoinButton(ProfileParams param) {
    return BlocBuilder<JoinToAgenciesBloc, JoinToAgencyState>(
      bloc: di<JoinToAgenciesBloc>(),
      buildWhen: (prev, curr) => prev.state != curr.state,
      builder: (context, state) {
        return ButtonWidget(
          height: 40.h,
          width: ScreenUtil().screenWidth * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          isLoading: state.state.isLoading,
          backgroundColor:
              param.isJoinRequested == true ? ColorManager.greenChat1 : null,
          onPressed: param.isJoinRequested == true
              ? null
              : () {
                  if (!state.state.isLoading) {
                    di<JoinToAgenciesBloc>().add(
                      JoinToAgencyEvent(agencyId: param.id, context: context),
                    );
                  }
                },
          title: param.isJoinRequested == true
              ? StringManager.joinRequest.tr()
              : StringManager.join.tr(),
        );
      },
    );
  }
}

class ProfileParams {
  final String img;
  final String name;
  final String id;
  final String ownerImage;
  final String ownerName;
  final String owneruuid;
  final int ownerId;
  final String agencyType;
  final bool isJoinRequested;
  final List<MemberEntity> members;
  final List<StarEntity>? stars;
  final List<StarEntity>? admins;

  const ProfileParams({
    required this.img,
    required this.name,
    required this.id,
    required this.ownerImage,
    required this.ownerName,
    required this.owneruuid,
    required this.ownerId,
    required this.members,
    required this.agencyType,
    required this.stars,
    required this.admins,
    required this.isJoinRequested,
  });
}

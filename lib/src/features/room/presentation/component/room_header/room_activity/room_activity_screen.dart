import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/room_activity_model.dart';
import 'package:general/src/features/room/presentation/component/room_header/room_activity/bloc/get_room_activity_data_bloc.dart';
import 'package:general/src/features/room/presentation/component/room_header/room_information/user_row_widget.dart';

import '../../../admins_in_room/bloc/admin_room_bloc.dart';
import '../../../room_controller.dart';

class RoomActivityScreen extends StatefulWidget {
  const RoomActivityScreen({super.key});

  @override
  State<RoomActivityScreen> createState() => _RoomActivityScreenState();
}

class _RoomActivityScreenState extends State<RoomActivityScreen> {
  @override
  void initState() {
    super.initState();

    final room = RoomData.instance.room;
    final ownerId = room.ownerId ?? -1;

    di<GetRoomActivityDataBloc>().add(FetchRoomActivityDataEvent(ownerId));
    di<AdminRoomBloc>().add(GetAdminsEvent(
      ownerId: ownerId.toString(),
      roomId: room.id?.toString() ?? '',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fixed white/black, matching the rest of the Room Information flow --
      // this page previously had no explicit colours at all, so it rode
      // whatever the admin panel's theme happened to be (could go dark).
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        title: StringManager.administratorManagement.tr(),
        backgroundColor: ColorManager.white,
        iconColor: ColorManager.black,
        titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
      ),
      body: BlocBuilder<GetRoomActivityDataBloc, GetRoomActivityDataState>(
        bloc: di<GetRoomActivityDataBloc>(),
        buildWhen: (prev, curr) => prev.requestState != curr.requestState || prev.dataModel != curr.dataModel,
        builder: (context, state) {
          return HandlingDataWidget(
            title: StringManager.noRoomData.tr(),
            subTitle: StringManager.checkBackLater.tr(),
            reqState: state.requestState,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTrophySection(state.dataModel),
                  12.hBox,
                  _buildRewardsSection(state.dataModel),
                  12.hBox,
                  _buildOwnerSection(),
                  12.hBox,
                  if (RoomData.instance.room.ownerId ==
                      MyDataModel.getInstance().id) ...[
                    _buildSupportedAdminsSection(),
                    20.hBox,
                  ],
                  _buildRulesSection(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------
  // Private widget methods
  // --------------------------

  Widget _buildTrophySection(RoomRewardModel? dataModel) {
    final trophies = dataModel?.trophies;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
          child: GestureDetector(
            onTap: () {
              di<GetRoomActivityDataBloc>()
                  .add(FetchRoomActivityWebViewLinkEvent(context));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWidget(
                  StringManager.roomTrophy.tr(),
                  style: context.bodyMedium
                      .size(13)
                      .colorExt(ColorManager.black.withValues(alpha: 0.55)),
                ),
                4.wBox, // small space between text and icon
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorManager.grey.withValues(alpha: 0.5),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.question_mark,
                    size: 10.sp,
                    color: ColorManager.onDark,
                  ),
                ),
              ],
            ),
          ),
        ),

        // card -- fixed white with a faint border/shadow (was the
        // admin-mutable surfaceCardColor with no border at all, flat
        // against the equally-mutable scaffold behind it).
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: ColorManager.black.withValues(alpha: 0.04),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // first row
              Padding(
                padding: context.paddingSymmetric(horizontal: 45),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _valueLabelItem(
                      trophies?.current?.totalCurrent?.toString() ?? '0',
                      StringManager.thisWeek.tr(),
                    ),
                    _valueLabelItem(
                      trophies?.last?.totalCurrent?.toString() ?? '0',
                      StringManager.lastWeek.tr(),
                    ),
                  ],
                ),
              ),

              10.hBox,

              // second row
              Padding(
                padding: context.paddingSymmetric(horizontal: 45),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _valueLabelItem(
                      trophies?.current?.totalVisitors?.toString() ?? '0',
                      StringManager.roomVisitors.tr(),
                    ),
                    _valueLabelItem(
                      trophies?.level?.toString() ?? '0',
                      StringManager.levelSmall.tr(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsSection(RoomRewardModel? dataModel) {
    final rewards = dataModel?.roomReward;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title outside the card
        Padding(
          padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
          child: TextWidget(
            StringManager.roomRewards.tr(),
            style: context.bodyMedium
                .size(13)
                .colorExt(ColorManager.black.withValues(alpha: 0.55)),
          ),
        ),

        // card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: ColorManager.black.withValues(alpha: 0.04),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Padding(
            padding: context.paddingSymmetric(horizontal: 45),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _valueLabelItem(
                  rewards?.owner?.toString() ?? '0',
                  StringManager.roomOwner.tr(),
                ),
                _valueLabelItem(
                  rewards?.admins?.toString() ?? '0',
                  StringManager.admin.tr(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerSection() {
    final room = RoomData.instance.room;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title outside
        Padding(
          padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
          child: TextWidget(
            StringManager.roomOwner.tr(),
            style:
            context.bodyMedium.size(13).colorExt(const Color(0xFF616161)),
          ),
        ),

        // card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: ColorManager.black.withValues(alpha: 0.04),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            children: [
              ImageViewWidget(
                url: room.ownerImage ?? '',
                displayName: room.ownerName ?? '',
                height: 40,
                width: 40,
                radius: 50,
              ),
              10.wBox,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    room.ownerName ?? '',
                    style: context.bodyMedium.w400
                        .size(13)
                        .colorExt(const Color(0xFF333333)),
                  ),
                  TextWidget(
                    "ID: ${room.uuidOwnerRoom ?? ''}",
                    style: context.bodySmall
                        .size(12)
                        .colorExt(ColorManager.black.withValues(alpha: 0.55)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportedAdminsSection() {
    final room = RoomData.instance.room;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title outside the card
        Padding(
          padding: context.paddingOnly(bottom: 6.0, start: 4.0),
          child: TextWidget(
            "${StringManager.supportedAdmin.tr()} (${di<AdminRoomBloc>().state.admins.length})",
            style: context.bodyMedium
                .size(13)
                .colorExt(ColorManager.black.withValues(alpha: 0.55)),
          ),
        ),

        // card
        Container(
          width: ScreenUtil().screenWidth,
          padding: context.paddingAll(12.5),
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: 12.0.radius,
            border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: ColorManager.black.withValues(alpha: 0.04),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: BlocBuilder<AdminRoomBloc, AdminRoomStates>(
            bloc: di<AdminRoomBloc>(),
            buildWhen: (prev, curr) => prev.adminsReqState != curr.adminsReqState || prev.admins != curr.admins,
            builder: (context, state) {
              return RefreshIndicatorWidget(
                onRefresh: () async {
                  di<AdminRoomBloc>().add(
                    GetAdminsEvent(
                      ownerId: room.ownerId.toString(),
                      roomId: room.id.toString(),
                    ),
                  );
                },
                child: HandlingDataWidget(
                  reqState: state.adminsReqState,
                  title: StringManager.noAdmins.tr(),
                  subTitle: StringManager.noAdminsEmptySubTitle.tr(),
                  titleStyle:
                  context.bodyLarge.bold.colorExt(ColorManager.black),
                  onTap: () {
                    di<AdminRoomBloc>().add(GetAdminsEvent(
                      ownerId: room.ownerId.toString(),
                      roomId: room.id.toString(),
                    ));
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: state.admins.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => Divider(
                      color: ColorManager.grey.withValues(alpha: 0.1),
                      height: 1.h,
                    ),
                    itemBuilder: (context, index) {
                      final admin = state.admins[index];
                      final colorName = admin.colorName ?? '';
                      final nameColor = Methods.safeHexColor(colorName) ??
                          Colors.black.withValues(alpha: 0.7);

                      return UserRowWidget(
                        isAdmin: false,
                        ownerId: room.ownerId.toString(),
                        frame: admin.frame ?? '',
                        frameType: admin.frameType ?? '',
                        vip: admin.vip?.img1 ?? '',
                        image: admin.profile?.image ?? '',
                        name: admin.name ?? '',
                        id: admin.id.toString(),
                        gender: admin.profile?.gender ?? 1,
                        senderImage: admin.level?.senderImage ?? '',
                        receiverImage: admin.level?.receiverImage ?? '',
                        uuid: admin.uuid.toString(),
                        age: 0,
                        coloredName: nameColor,
                        textStyle: context.bodyMedium,
                        imageColorEntity: admin.imageColorEntity,
                        specialId: admin.specialId,
                        idImage: admin.idImage ?? '',
                        padding: context.paddingSymmetric(
                            vertical: 2, horizontal: 5),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRulesSection(BuildContext context) {
    return TextWidget(
      StringManager.adminManagementRules.tr(),
      style: context.bodySmall.copyWith(
        color: ColorManager.black.withValues(alpha: 0.55),
        height: 1.4,
      ),
    );
  }

  // --------------------------
  // Small helpers (used inline)
  // --------------------------
  Widget _valueLabelItem(String value, String label) {
    return SizedBox(
      width: ScreenUtil().screenWidth * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextWidget(value,
              style: context.bodySmall.size(12).colorExt(ColorManager.black)),
          4.hBox,
          TextWidget(label,
              style: context.bodySmall.size(10).colorExt(Colors.grey)),
        ],
      ),
    );
  }
}
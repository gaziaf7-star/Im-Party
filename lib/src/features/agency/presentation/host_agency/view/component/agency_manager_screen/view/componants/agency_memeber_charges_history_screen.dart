import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/agency/data/model/agency_history_model.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/agency_memeber_charges_history/agency_memeber_charges_history_bloc.dart';

import '../../../../../../../../../core/widgets/md_indicator.dart';

class AgencyMemberChargesHistoryScreen extends StatefulWidget {
  const AgencyMemberChargesHistoryScreen({super.key});

  @override
  State<AgencyMemberChargesHistoryScreen> createState() =>
      _AgencyMemberChargesHistoryScreenState();
}

class _AgencyMemberChargesHistoryScreenState
    extends State<AgencyMemberChargesHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  late ScrollController _userScrollController;
  late ScrollController _agencyScrollController;
  final AgencyMemeberChargesHistoryBloc bloc =
  di<AgencyMemeberChargesHistoryBloc>();
  int userPage = 1;
  int agencyPage = 1;

  @override
  void initState() {
    super.initState();
    if (!bloc.state.userState.isLoaded) {
      bloc.add(
          const AgencyMemeberToUserChargesHistoryEvent(isFirstLoading: true));
    }
    _userScrollController = ScrollController()..addListener(_onUserScroll);
    _agencyScrollController = ScrollController()..addListener(_onAgencyScroll);

    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(() {
      if (_controller.index == 1 && !bloc.state.agencyState.isLoaded) {
        bloc.add(const AgencyMemeberToAgencyChargesHistoryEvent(
            isFirstLoading: true));
      }
    });
  }

  void _onUserScroll() {
    if (_userScrollController.position.pixels >=
        _userScrollController.position.maxScrollExtent - 100) {
      userPage++;
      di<AgencyMemeberChargesHistoryBloc>().add(
        AgencyMemeberToUserChargesHistoryEvent(page: userPage),
      );
    }
  }

  void _onAgencyScroll() {
    if (_agencyScrollController.position.pixels >=
        _agencyScrollController.position.maxScrollExtent - 100) {
      agencyPage++;
      di<AgencyMemeberChargesHistoryBloc>().add(
        AgencyMemeberToAgencyChargesHistoryEvent(page: agencyPage),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        iconColor: ColorManager.black,
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.primary,
            ColorManager.primary.withValues(alpha: 0.75),
          ],
        ),
        title: StringManager.record.tr(),
        titleStyle: context.bodyLarge.w600.colorExt(ColorManager.black),
      ),
      body: Column(
        children: [
          _TabBarBody(controller: _controller),
          SizedBox(
            height: ScreenUtil().screenHeight * 0.55,
            child: BlocBuilder<AgencyMemeberChargesHistoryBloc,
                AgencyMemeberChargesHistoryState>(
              bloc: di<AgencyMemeberChargesHistoryBloc>(),
              buildWhen: (prev, curr) =>
              prev.userState != curr.userState ||
                  prev.agencyState != curr.agencyState ||
                  prev.userModel != curr.userModel ||
                  prev.agencyModel != curr.agencyModel,
              builder: (context, state) {
                return TabBarView(
                  controller: _controller,
                  children: [
                    HandlingDataWidget(
                      reqState: state.userState,
                      title: StringManager.noDetailsReportsTitle.tr(),
                      subTitle: StringManager.noDetailsReportsSubTitle.tr(),
                      titleStyle:
                      context.bodyLarge.w600.colorExt(ColorManager.black),
                      subTitleStyle: context.bodyMedium.copyWith(
                          color: ColorManager.black, height: 1.30),
                      buttonBackgroundColors: [
                        ColorManager.primary,
                        ColorManager.primary
                      ],
                      onTap: () {
                        bloc.add(
                            const AgencyMemeberToUserChargesHistoryEvent());
                      },
                      child: _TabBarViewBody(
                        isUser: true,
                        controller: _userScrollController,
                        data: state.userModel,
                      ),
                    ),
                    HandlingDataWidget(
                      reqState: state.agencyState,
                      title: StringManager.noDetailsReportsTitle.tr(),
                      subTitle: StringManager.noDetailsReportsSubTitle.tr(),
                      titleStyle:
                      context.bodyLarge.w600.colorExt(ColorManager.black),
                      subTitleStyle: context.bodyMedium.copyWith(
                          color: ColorManager.black, height: 1.30),
                      buttonBackgroundColors: [
                        ColorManager.primary,
                        ColorManager.primary
                      ],
                      onTap: () {
                        bloc.add(
                            const AgencyMemeberToAgencyChargesHistoryEvent());
                      },
                      child: _TabBarViewBody(
                        isUser: false,
                        controller: _agencyScrollController,
                        data: state.agencyModel,
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class _TabBarBody extends StatelessWidget {
  const _TabBarBody({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 10),
      width: ScreenUtil().screenWidth,
      color: ColorManager.white,
      child: TabBar(
        controller: controller,
        isScrollable: false,
        padding: context.paddingZero(),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 1.0,
        indicatorColor: ColorManager.primary,
        indicator: MDIndicator(
          radius: 20.r,
          indicatorSize: MDIndicatorSize.normal,
          indicatorHeight: 3,
          indicatorWidth: 35.w,
          indicatorColor: ColorManager.primary,
        ),
        unselectedLabelStyle: context.bodyMedium
            .colorExt(
          ColorManager.black,
        )
            .w500
            .size(17)
            .copyWith(
          fontFamily: "AppFont",
        ),
        labelStyle: context.bodyMedium.bold.size(17).colorExt(ColorManager.black).copyWith(
          fontFamily: "AppFont",
        ),
        dividerHeight: 0,
        tabs: [
          Text(StringManager.user.tr()),
          Text(StringManager.agency1.tr()),
        ],
      ),
    );
  }
}

class _TabBarViewBody extends StatelessWidget {
  const _TabBarViewBody({
    required this.data,
    required this.controller,
    required this.isUser,
  });

  final List<AgencyMemberChargesHistoryModel>? data;
  final ScrollController controller;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: ColorManager.primary,
      backgroundColor: ColorManager.white,
      onRefresh: () async {
        final bloc = di<AgencyMemeberChargesHistoryBloc>();
        if (isUser) {
          bloc.add(const AgencyMemeberToUserChargesHistoryEvent());
        } else {
          bloc.add(const AgencyMemeberToAgencyChargesHistoryEvent());
        }
      },
      child: ListView.builder(
        padding: context.paddingSymmetric(horizontal: 0, vertical: 5),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: data?.length ?? 0,
        controller: controller,
        itemBuilder: (context, index) {
          return _CustomRowData(
            model: data![index],
            isUser: isUser,
          );
        },
      ),
    );
  }
}

class _CustomRowData extends StatelessWidget {
  const _CustomRowData({
    required this.model,
    required this.isUser,
  });

  final AgencyMemberChargesHistoryModel model;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Methods().userProfileNavigator(
          context: context,
          userId: model.id.toString(),
        );
      },
      child: Container(
        padding: context.paddingSymmetric(horizontal: 15, vertical: 5),
        margin: context.paddingSymmetric(vertical: 5, horizontal: 7),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: 15.radius,
          border: Border.all(
            color: ColorManager.grey2.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: ColorManager.black.withValues(alpha: 0.05),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        width: ScreenUtil().screenWidth,
        child: Row(
          children: [
            Row(
              children: [
                SizedBox(
                  height: 55.h,
                  width: 55.w,
                  child: ImageViewWidget(
                    url: EndPoints.getImage(model.image),
                    displayName: model.name ?? '',
                    height: 55.h,
                    width: 55.w,
                    radius: isUser ? 60 : 0,
                  ),
                ),
                10.wBox,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientTextVip(
                      isVip: model.coloredName != "",
                      width: ScreenUtil().screenWidth * 0.5,
                      text: model.name,
                      color: model.coloredName != ""
                          ? Color((int.parse(
                          model.coloredName.replaceAll('#', '0xff'))))
                          : ColorManager.black,
                      mainAxisAlignment: MainAxisAlignment.center,
                      textAlign: TextAlign.center,
                      textStyle: context.bodyMedium.size(14).w600.colorExt(
                        model.coloredName != ""
                            ? Color((int.parse(
                            model.coloredName.replaceAll('#', '0xff'))))
                            : ColorManager.black,
                      ),
                    ),
                    7.hBox,
                    IdWithCopyIcon(
                      userId: model.uuid,
                      idStyle: context.bodyMedium.size(12).colorExt(
                          ColorManager.black),
                      idColor: ColorManager.black,
                    ),
                    TextWidget(
                      Methods.formatTime(model.date),
                      style: context.bodyMedium.size(12).colorExt(
                          ColorManager.black),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              height: 20.h,
              width: 50.w,
              decoration: BoxDecoration(
                color: model.isSender
                    ? (Colors.green.withValues(alpha: 0.2))
                    : (Colors.red.withValues(alpha: 0.2)),
                borderRadius: 3.radius,
              ),
              child: Center(
                child: FittedBox(
                  child: TextWidget(
                    '${model.totalUsed}',
                    style: context.bodyMedium
                        .size(16)
                        .bold
                        .colorExt(model.isSender ? Colors.green : Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
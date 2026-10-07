import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/core/widgets/user_level_container.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/componants/daily_level.dart';
import 'package:general/src/features/agency/domain/entity/agency_more_info_entity.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/fetch_agency_admins/fetch_agency_admins_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/fetch_agency_heros/fetch_agency_heros_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/fetch_agency_stars/fetch_agency_stars_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/widgets/custom_row_widget.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/component/agency_member_screen/components/daily_data.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/component/agency_member_screen/components/monthly_data.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/widgets/add_all_datat_dialog.dart';
import 'package:general/src/features/agency/presentation/host_agency/view/widgets/monthly_data_item_widget.dart';
import 'package:general/src/features/home/presentation/home/bloc/home_manager/home_bloc.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../bloc/fetch_more_info_agency/fetch_more_info_agency_bloc.dart';

part '../../../widgets/dialog_remove_anchor.dart';

part '../../../widgets/first_tab_manager_screen.dart';

part '../../../widgets/tab_bar_view_application.dart';

part '../../../widgets/tab_bar_view_record.dart';

part '../../../widgets/user_row_application.dart';

part 'componants/admins_screen.dart';

part 'componants/header_body.dart';

part 'componants/heros_screen.dart';

part 'componants/identity_setting_screen.dart';

part 'componants/join_requests_screen.dart';

part 'componants/stars_screen.dart';

part 'widgets/user_row_member.dart';

part 'widgets/user_row_record.dart';

class AgencyManagerScreen extends StatefulWidget {
  final String? agencyId;

  const AgencyManagerScreen({super.key, this.agencyId});

  @override
  State<AgencyManagerScreen> createState() => _AgencyManagerScreenState();
}

// Default to a valid "year / month" so the ~10 `.value.split('/')[1]` call sites
// across the agency feature never throw RangeError on the old '' default (which
// crashed the agency screens on entry/refresh — "tapping an agency kicks you out").
final ValueNotifier<String> secondTabAgencyTimeFilter =
    ValueNotifier("${DateTime.now().year} / ${DateTime.now().month}");
final ValueNotifier<String> firstTabAgencyTimeFilter =
    ValueNotifier("${DateTime.now().year} / ${DateTime.now().month}");
final ValueNotifier<String> agencyIdsFilter = ValueNotifier('');

class _AgencyManagerScreenState extends State<AgencyManagerScreen>
    with TickerProviderStateMixin {
  final _informationAgencyBloc = di<InformationAgencyBloc>();
  late final TickerProvider _tickerProvider;
  TabController? controller;
  bool _isDialogShown = false;

  @override
  void initState() {
    di<HomeBloc>().add(const FetchHostLevelsEvent());
    secondTabAgencyTimeFilter.value = (secondTabAgencyTimeFilter.value == '')
        ? "${DateTime.now().year} / ${DateTime.now().month}"
        : secondTabAgencyTimeFilter.value;
    firstTabAgencyTimeFilter.value = (firstTabAgencyTimeFilter.value == '')
        ? "${DateTime.now().year} / ${DateTime.now().month}"
        : firstTabAgencyTimeFilter.value;

    if (!_informationAgencyBloc.state.requestState.isLoaded ||
        ((_informationAgencyBloc.state.data?.id ?? -1) !=
            (MyDataModel.getInstance().myAgencyModel?.id ?? 0)) ||
        widget.agencyId != null ||
        widget.agencyId != '') {
      _informationAgencyBloc.add(
        InformationAgencyEvent(
            month: secondTabAgencyTimeFilter.value.split('/')[1],
            year: secondTabAgencyTimeFilter.value.split('/')[0],
            isFirstLoading:
                !(_informationAgencyBloc.state.requestState.isLoaded),
            agencyId: widget.agencyId ??
                (MyDataModel.getInstance().myAgencyModel?.id ?? 1).toString()),
      );
    }
    if (!di<FetchMoreInfoAgencyBloc>().state.requestState.isLoaded) {
      di<FetchMoreInfoAgencyBloc>().add(FetchMoreInfoForMonthEvent(
          month: secondTabAgencyTimeFilter.value.split('/')[1],
          year: secondTabAgencyTimeFilter.value.split('/')[0],
          agencyId: (MyDataModel.getInstance().myAgencyModel?.id ??
                  widget.agencyId ??
                  0)
              .toString(),
          page: (di<FetchMoreInfoAgencyBloc>().state.userTargetCurrentPage)
              .toString()));
    }
    if (!di<FetchMoreInfoAgencyBloc>().state.hostsRequestState.isLoaded) {
      di<FetchMoreInfoAgencyBloc>().add(
        HostSAgencyDataUCEvent(
          month: '${DateTime.now().month}',
          year: '${DateTime.now().year}',
          agencyId: (MyDataModel.getInstance().myAgencyModel?.id ??
                  widget.agencyId ??
                  0)
              .toString(),
        ),
      );
    }
    _tickerProvider = this;
    if (_informationAgencyBloc.state.requestState.isLoaded) {
      final tabsLength =
          ((_informationAgencyBloc.state.data?.userStates ?? 0) == 1 ||
                  StringManager.userType[2]!)
              ? 3
              : 2;
      controller = TabController(length: tabsLength, vsync: _tickerProvider);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ConstantsManager.isShowHostLevels == true
          ? const FloatingActionButtonBody()
          : null,
      body: Container(
        color: ColorManager.scaffoldBgAlt,
        child: BlocConsumer<InformationAgencyBloc, InformationAgencyState>(
          bloc: _informationAgencyBloc,
          listener: (context, state) {
            int oldTabsLength = controller?.length ?? 0;

            final userStates =
                _informationAgencyBloc.state.data?.userStates ?? 0;
            final isSpecialUser = userStates == 1 || StringManager.userType[2]!;

            int newTabsLength = isSpecialUser ? 3 : 2;

            if (_informationAgencyBloc.state.requestState.isLoaded &&
                (controller == null || oldTabsLength != newTabsLength)) {
              controller?.dispose();
              controller =
                  TabController(length: newTabsLength, vsync: _tickerProvider);
            }
            if (!_isDialogShown &&
                _informationAgencyBloc.state.requestState.isLoaded &&
                StringManager.userType[2]! &&
                ((_informationAgencyBloc.state.data?.img ?? '').isEmpty ||
                    (_informationAgencyBloc.state.data?.bio ?? '').isEmpty)) {
              _isDialogShown = true;
              showCustomDialog(context, _informationAgencyBloc.state.data!);
            }
          },
          builder: (context, state) {
            if (state.requestState.isError) {
              return Padding(
                padding: context.paddingOnly(start: 10, end: 10),
                child: Align(
                  alignment: AlignmentDirectional.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        AssetsManager.error,
                        height: 90.h,
                        width: 90.w,
                      ),
                      10.hBox,
                      TextWidget(
                        StringManager.noAgencyDataNowTitle.tr(),
                        textAlign: TextAlign.center,
                        style: context.bodyLarge.w600
                            .colorExt(ColorManager.textPrimary),
                      ),
                      5.hBox,
                      TextWidget(
                        StringManager.noAgencyDataNowSubTitle.tr(),
                        textAlign: TextAlign.center,
                        style: context.bodyMedium.copyWith(
                          color: ColorManager.secondaryText,
                          height: 1.30,
                        ),
                      ),
                      50.hBox,
                      Padding(
                        padding: context.paddingSymmetric(horizontal: 30),
                        child: ButtonWidget(
                          title: StringManager.refresh.tr(),
                          backgroundColor: ColorManager.transparent,
                          titleColor: ColorManager.secondaryColor,
                          borderColor: ColorManager.secondaryColor,
                          fontWeight: FontWeight.w400,
                          onPressed: () {
                            _informationAgencyBloc.add(
                              InformationAgencyEvent(
                                month: secondTabAgencyTimeFilter.value
                                    .split('/')[1],
                                year: secondTabAgencyTimeFilter.value
                                    .split('/')[0],
                                isFirstLoading: !(_informationAgencyBloc
                                    .state.requestState.isLoaded),
                                agencyId: widget.agencyId ??
                                    (MyDataModel.getInstance()
                                                .myAgencyModel
                                                ?.id ??
                                            1)
                                        .toString(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return HandlingDataWidget(
              reqState: state.requestState,
              title: StringManager.noAgencyDataNowTitle.tr(),
              subTitle: StringManager.noAgencyDataNowSubTitle.tr(),
              child: Container(
                padding: context.paddingSymmetric(horizontal: 8),
                height: ScreenUtil().screenHeight,
                width: ScreenUtil().screenWidth,
                child: RefreshIndicator(
                  onRefresh: () async {
                    secondTabAgencyTimeFilter.value =
                        "${DateTime.now().year} / ${DateTime.now().month}";
                    _informationAgencyBloc.add(
                      InformationAgencyEvent(
                        month: secondTabAgencyTimeFilter.value.split('/')[1],
                        year: secondTabAgencyTimeFilter.value.split('/')[0],
                        agencyId: widget.agencyId ??
                            (MyDataModel.getInstance().myAgencyModel?.id ?? 1)
                                .toString(),
                      ),
                    );
                    di<FetchMoreInfoAgencyBloc>().add(
                        FetchMoreInfoForMonthEvent(
                            month:
                                secondTabAgencyTimeFilter.value.split('/')[1],
                            year: secondTabAgencyTimeFilter.value.split('/')[0],
                            agencyId:
                                (MyDataModel.getInstance().myAgencyModel?.id ??
                                        0)
                                    .toString(),
                            page: (di<FetchMoreInfoAgencyBloc>()
                                    .state
                                    .userTargetCurrentPage)
                                .toString()));
                    di<FetchMoreInfoAgencyBloc>().add(
                      HostSAgencyDataUCEvent(
                        month: '${DateTime.now().month}',
                        year: '${DateTime.now().year}',
                        agencyId:
                            (MyDataModel.getInstance().myAgencyModel?.id ?? 0)
                                .toString(),
                      ),
                    );
                    di<MyStoreBloc>().add(const GetMyStoreEvent());
                    di<AgencyHostReportBloc>().add(
                      AgencyHostReportEvent(
                        isFirsLoading: true,
                        mounth: '${DateTime.now().month}',
                        year: '${DateTime.now().year}',
                      ),
                    );
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: AppBarWidget(
                          title: StringManager.agencyCenter.tr(),
                          backgroundColor: ColorManager.scaffoldBg,
                          height: 70.h,
                          iconLasted: (StringManager.userType[2]!)
                              ? IconButton(
                                  onPressed: () {
                                    context.pushNamedRoute(
                                        Routes.agencySettingScreen);
                                  },
                                  icon: Column(
                                    children: [
                                      Icon(
                                        Icons.settings,
                                        color: ColorManager.textPrimary,
                                      ),
                                      TextWidget(StringManager.settings.tr()),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ),
                      if ((_informationAgencyBloc.state.data?.img ?? '')
                              .isEmpty ||
                          (_informationAgencyBloc.state.data?.bio ?? '')
                              .isEmpty)
                        SliverToBoxAdapter(
                          child: Container(
                            height: ScreenUtil().screenHeight,
                            width: ScreenUtil().screenWidth,
                            color: ColorManager.white,
                          ),
                        )
                      else ...[
                        SliverToBoxAdapter(child: _HeaderBody(state: state)),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              15.hBox,
                              TabBarAgency(
                                isOwner: true,
                                controller: controller,
                              ),
                              10.hBox,
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: ScreenUtil().screenHeight * 0.7,
                            child: TabBarView(
                              controller: controller,
                              children: [
                                const FirstTabManagerScreen(),
                                TabBarViewApplication(
                                  state: state,
                                ),
                                if (StringManager.userType[2]! ||
                                    (_informationAgencyBloc
                                                .state.data?.userStates ??
                                            0) ==
                                        1)
                                  TabBarViewData(
                                    month: secondTabAgencyTimeFilter.value
                                        .split('/')[1],
                                    year: secondTabAgencyTimeFilter.value
                                        .split('/')[0],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

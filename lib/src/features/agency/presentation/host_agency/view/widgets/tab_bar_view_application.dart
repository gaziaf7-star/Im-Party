part of 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

class TabBarViewApplication extends StatefulWidget {
  final InformationAgencyState state;

  const TabBarViewApplication({super.key, required this.state});

  @override
  State<TabBarViewApplication> createState() => _TabBarViewApplicationState();
}

class _TabBarViewApplicationState extends State<TabBarViewApplication> {
  String selectedDate = "${DateTime.now().year} / ${DateTime.now().month}";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InformationAgencyBloc, InformationAgencyState>(
      bloc: di<InformationAgencyBloc>(),
      buildWhen: (prev, curr) =>
          prev.requestState != curr.requestState || prev.data != curr.data,
      builder: (context, state) {
        return HandlingDataWidget(
          reqState: state.requestState,
          title: StringManager.noRequestsNowTitle.tr(),
          subTitle: StringManager.noRequestsNowSubTitle.tr(),
          child: RefreshIndicator(
            onRefresh: () async {
              secondTabAgencyTimeFilter.value =
                  "${DateTime.now().year} / ${DateTime.now().month}";

              di<InformationAgencyBloc>().add(
                InformationAgencyEvent(
                  month: '${DateTime.now().month}',
                  year: '${DateTime.now().year}',
                ),
              );
              di<FetchMoreInfoAgencyBloc>().add(
                HostSAgencyDataUCEvent(
                  month: '${DateTime.now().month}',
                  year: '${DateTime.now().year}',
                  agencyId: (MyDataModel.getInstance().myAgencyModel?.id ?? 0)
                      .toString(),
                ),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: context.paddingSymmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    10.hBox,
                    CustomRowWidget(
                      title: StringManager.officeAdmin.tr(),
                      iconName: AssetsManager.identitySetting2,
                      scale: 2,
                      color: ColorManager.primary,
                      onTap: () {
                        Methods().userProfileNavigator(
                          context: context,
                          userId: state.data?.owner?.id.toString(),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          UserImage(
                            image: state.data?.owner?.profile?.image ?? '',
                            displayName: state.data?.owner?.name ?? '',
                            borderRadius: 50.radius,
                            imageSize: 30.w,
                          ),
                          5.wBox,
                          GradientTextVip(
                            text: state.data?.owner?.name ?? "",
                            width: ScreenUtil().screenWidth * 0.4,
                            isVip: (state.data?.owner?.coloredName ?? '') != '',
                            color: (state.data?.owner?.coloredName ?? '') != ''
                                ? Color((int.parse(state
                                    .data!.owner!.coloredName!
                                    .replaceAll('#', '0xff'))))
                                : ColorManager.textPrimary,
                            mainAxisAlignment: MainAxisAlignment.center,
                            textAlign: TextAlign.center,
                            textStyle:
                                context.bodyMedium.size(14).w600.colorExt(
                                      state.data?.owner?.coloredName != ""
                                          ? Color((int.parse(state
                                              .data!.owner!.coloredName!
                                              .replaceAll('#', '0xff'))))
                                          : ColorManager.textPrimary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    10.hBox,
                    if (StringManager.userType[2]!) ...[
                      Column(
                        children: [
                          CustomRowWidget(
                            title: StringManager.agencyAdmins.tr(),
                            iconName: AssetsManager.adminIcon,
                            scale: 3,
                            onTap: () => Navigator.pushNamed(
                                context, Routes.adminsScreen,
                                arguments: (MyDataModel.getInstance()
                                            .myAgencyModel
                                            ?.id ??
                                        0)
                                    .toString()),
                            child: ((state.data?.admins ?? []).isEmpty)
                                ? const TextWidget(StringManager.noAdminsAgency)
                                : Row(
                                    children: List.generate(
                                      state.nowAdmins?.length ?? 0,
                                      (index) => Padding(
                                        padding: context.paddingSymmetric(
                                            horizontal: 4),
                                        child: UserImage(
                                          image:
                                              state.nowAdmins?[index].image ??
                                                  '',
                                          displayName:
                                              state.nowAdmins?[index].name ?? '',
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
                            onTap: () => Navigator.pushNamed(
                                context, Routes.starsScreen,
                                arguments: (MyDataModel.getInstance()
                                            .myAgencyModel
                                            ?.id ??
                                        -1)
                                    .toString()),
                            child: ((state.nowStars ?? []).isEmpty)
                                ? const TextWidget(StringManager.noStars)
                                : Row(
                                    children: List.generate(
                                      (state.nowStars?.length ?? 0).clamp(0, 3),
                                      (index) => Padding(
                                        padding: context.paddingSymmetric(
                                            horizontal: 4),
                                        child: UserImage(
                                          image: state.nowStars?[index].image ??
                                              '',
                                          displayName:
                                              state.nowStars?[index].name ?? '',
                                          borderRadius: 50.radius,
                                          imageSize: 30.w,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      10.hBox,
                    ],
                    DateWidget(
                      isFirstNotifier: false,
                      selectedDate: (value) {
                        secondTabAgencyTimeFilter.value = value;
                        secondTabAgencyTimeFilter.notifyListeners();
                      },
                      onPressed: () {
                        di<InformationAgencyBloc>().add(
                          InformationAgencyEvent(
                            month:
                                secondTabAgencyTimeFilter.value.split('/')[1],
                            year: secondTabAgencyTimeFilter.value.split('/')[0],
                          ),
                        );
                        di<FetchMoreInfoAgencyBloc>().add(
                          HostSAgencyDataUCEvent(
                            month:
                                secondTabAgencyTimeFilter.value.split('/')[1],
                            year: secondTabAgencyTimeFilter.value.split('/')[0],
                            agencyId:
                                (MyDataModel.getInstance().myAgencyModel?.id ??
                                        0)
                                    .toString(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    10.hBox,
                    BlocBuilder<FetchMoreInfoAgencyBloc,
                        FetchMoreInfoAgencyState>(
                      bloc: di<FetchMoreInfoAgencyBloc>(),
                      buildWhen: (prev, curr) =>
                          prev.requestState != curr.requestState ||
                          prev.hostSAgencyDataModel !=
                              curr.hostSAgencyDataModel,
                      builder: (context, state) {
                        return HandlingDataWidget(
                          reqState: state.requestState,
                          title: StringManager.noRequestsNowTitle.tr(),
                          subTitle: StringManager.noRequestsNowSubTitle.tr(),
                          onTap: () {
                            di<FetchMoreInfoAgencyBloc>().add(
                              HostSAgencyDataUCEvent(
                                month: '${DateTime.now().month}',
                                year: '${DateTime.now().year}',
                                agencyId: (MyDataModel.getInstance()
                                            .myAgencyModel
                                            ?.id ??
                                        0)
                                    .toString(),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomRowWidget(
                                title: StringManager.agencyHeros.tr(),
                                iconName: AssetsManager.agencySuperHero,
                                scale: 17,
                                onTap: () => Navigator.pushNamed(
                                    context, Routes.herosScreen),
                                child: ((state.hostSAgencyDataModel?.heroes ??
                                            [])
                                        .isEmpty)
                                    ? const TextWidget(StringManager.noHeros)
                                    : Row(
                                        children: List.generate(
                                          (state.hostSAgencyDataModel?.heroes
                                                      .length ??
                                                  0)
                                              .clamp(0, 5),
                                          (index) => Padding(
                                            padding: context.paddingSymmetric(
                                                horizontal: 4),
                                            child: UserImage(
                                              image: state.hostSAgencyDataModel
                                                      ?.heroes[index].image ??
                                                  '',
                                              displayName: state
                                                      .hostSAgencyDataModel
                                                      ?.heroes[index]
                                                      .name ??
                                                  '',
                                              borderRadius: 50.radius,
                                              imageSize: 30.w,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              10.hBox,
                              if (StringManager.userType[2]!) ...[
                                10.hBox,
                                TextWidget(
                                  StringManager.agencyMounthlyData.tr(),
                                  style: context.bodyLarge.w500.size(13),
                                ),
                                10.hBox,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MonthlyDataItemWidget(
                                      value:
                                          Methods().convertToAbbreviatedString(
                                        double.parse(state
                                                .hostSAgencyDataModel?.salary ??
                                            '0'),
                                      ),
                                      title: StringManager.anchorSalary.tr(),
                                      textColor: ColorManager.primary,
                                      icon: AssetsManager.moneyBag,
                                      scale: 14,
                                    ),
                                    20.wBox,
                                    MonthlyDataItemWidget(
                                      value: Methods()
                                          .convertToAbbreviatedString(state
                                                  .hostSAgencyDataModel
                                                  ?.target ??
                                              0),
                                      title: StringManager.diamond.tr(),
                                      textColor: ColorManager.primary,
                                      icon: AssetsManager.moneyBag,
                                      scale: 14,
                                    ),
                                  ],
                                ),
                              ]
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

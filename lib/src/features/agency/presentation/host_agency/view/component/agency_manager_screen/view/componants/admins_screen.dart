part of 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

class AdminsScreen extends StatefulWidget {
  final String agencyId;

  const AdminsScreen({super.key, required this.agencyId});

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  int currentPage = 1;
  bool _isLoadingMore = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    di<FetchAgencyAdminsBloc>().add(FetchAdminsForMonthEvent(
      month: "${DateTime.now().month}",
      year: "${DateTime.now().year}",
      agencyId: widget.agencyId,
      page: currentPage.toString(),
    ));
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MakeUserAdminBloc, MakeUserAdminState>(
      bloc: di<MakeUserAdminBloc>(),
      listener: (context, state) {
        if (state.requestState.isLoaded) {
          di<FetchAgencyAdminsBloc>().add(FetchAdminsForMonthEvent(
            month: '${DateTime.now().month}',
            year: '${DateTime.now().year}',
            agencyId:
                (MyDataModel.getInstance().myAgencyModel?.id ?? 0).toString(),
          ));
        }
      },
      child: Scaffold(
        appBar: AppBarWidget(
          backgroundColor: ColorManager.scaffoldBg,
          title: StringManager.agencyAdmins.tr().toUpperCase(),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    currentPage = 1;
                    _isLoadingMore = false;
                    final parts = secondTabAgencyTimeFilter.value.split('/');
                    final fYear = (parts.isNotEmpty && parts[0].isNotEmpty)
                        ? parts[0]
                        : DateTime.now().year.toString();
                    final fMonth = (parts.length > 1 && parts[1].isNotEmpty)
                        ? parts[1]
                        : DateTime.now().month.toString().padLeft(2, '0');
                    di<FetchAgencyAdminsBloc>().add(FetchAdminsForMonthEvent(
                      month: fMonth,
                      year: fYear,
                      agencyId: widget.agencyId,
                    ));
                  },
                  child: BlocBuilder<FetchAgencyAdminsBloc,
                      FetchAgencyAdminsState>(
                    bloc: di<FetchAgencyAdminsBloc>(),
                    buildWhen: (prev, curr) =>
                        prev.requestState != curr.requestState ||
                        prev.admins != curr.admins,
                    builder: (context, state) {
                      return HandlingDataWidget(
                        reqState: state.requestState,
                        title: StringManager.noAgencyAdminsNowTitle.tr(),
                        subTitle: StringManager.noAgencyAdminsNowSubTitle.tr(),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: state.admins?.length ?? 0,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: context.paddingSymmetric(horizontal: 10),
                              child: AdminRowMember(
                                userStarEntity: state.admins![index],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollListener() {
    if (_isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _isLoadingMore = true;
      currentPage++;
      di<FetchAgencyAdminsBloc>().add(FetchAdminsForMonthEvent(
        year: '${DateTime.now().year}',
        month: '${DateTime.now().month}',
        agencyId: widget.agencyId,
        page: currentPage.toString(),
      ));
      // Reset the guard after 1s so a genuine next page can be fetched
      Future.delayed(const Duration(seconds: 1), () => _isLoadingMore = false);
    }
  }
}

class AdminRowMember extends StatelessWidget {
  const AdminRowMember({
    super.key,
    required this.userStarEntity,
    this.endIcon,
  });

  final UserStarEntity userStarEntity;
  final Widget? endIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingAll(10),
      child: InkWell(
        onTap: () {
          Methods().userProfileNavigator(
            context: context,
            userId: userStarEntity.id.toString(),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UserImage(
              image: userStarEntity.image!,
              displayName: userStarEntity.name ?? '',
              imageSize: 40.w,
            ),
            10.wBox,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GradientTextVip(
                      text: userStarEntity.name ?? "",
                      width: 110.w,
                      isVip: (userStarEntity.coloredName ?? '') != '',
                      color: (userStarEntity.coloredName ?? '') != ''
                          ? Color((int.parse(userStarEntity.coloredName!
                              .replaceAll('#', '0xff'))))
                          : ColorManager.textPrimary,
                      mainAxisAlignment: MainAxisAlignment.center,
                      textAlign: TextAlign.center,
                      textStyle: context.bodyMedium.size(14).w600.colorExt(
                            userStarEntity.coloredName != ""
                                ? Color((int.parse(userStarEntity.coloredName!
                                    .replaceAll('#', '0xff'))))
                                : ColorManager.textPrimary,
                          ),
                    ),
                    10.wBox,
                  ],
                ),
                IdWithCopyIcon(
                    userId: userStarEntity.uuid ?? '',
                    isNeedCopyIcon: true,
                    isSpecial: ((userStarEntity.idImage ?? '') != ''),
                    specialImg: userStarEntity.idImage ?? '',
                    color: userStarEntity.imageColorEntity?.color,
                    img: userStarEntity.imageColorEntity?.image,
                    mainAxisAlignment: MainAxisAlignment.start,
                    idColor: ColorManager.secondaryText,
                    idStyle: context.bodyMedium.size(11).w500.colorExt(
                        ColorManager.secondaryText)),
              ],
            ),
            const Spacer(),
            if (StringManager.userType[2]!)
              ButtonWidget(
                onPressed: () => _showRemoveDialog(
                  context,
                  userStarEntity.id ?? 0,
                ),
                title: Center(
                  child: TextWidget(
                    StringManager.removeAdmin.tr(),
                    style: context.bodyMedium
                        .copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        )
                        .colorExt(ColorManager.textPrimary),
                  ),
                ),
                height: 40.h,
                width: 110.w,
                isFittedBox: false,
                backgroundColor: ColorManager.primary,
                padding: context.paddingAll(5),
                paddingButton: context.paddingAll(5),
              ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showRemoveDialog(BuildContext context, int id) {
    return showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        title: StringManager.confirmation.tr(),
        description: StringManager.removeUserAgent.tr(),
        onTap: () {
          di<MakeUserAdminBloc>()
              .add(MakeUserAdminEvent(id: id, type: 'remove'));
          Navigator.pop(context);
        },
      ),
    );
  }
}

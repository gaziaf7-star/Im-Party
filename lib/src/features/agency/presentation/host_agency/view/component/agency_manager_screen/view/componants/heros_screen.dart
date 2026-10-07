part of 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

class HerosScreen extends StatefulWidget {
  const HerosScreen({super.key});

  @override
  State<HerosScreen> createState() => _HerosScreenState();
}

class _HerosScreenState extends State<HerosScreen> {
  int currentPage = 1;
  late final ScrollController _scrollController;

  @override
  void initState() {
    secondTabAgencyTimeFilter.value =
        "${DateTime.now().year} / ${DateTime.now().month}";
    di<FetchAgencyHerosBloc>().add(FetchHerosForMonthEvent(
      month: "${DateTime.now().month}",
      year: "${DateTime.now().year}",
      agencyId: (MyDataModel.getInstance().myAgencyModel?.id ?? 0).toString(),
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
    return Scaffold(
      appBar: AppBarWidget(
        backgroundColor: ColorManager.scaffoldBg,
        title: StringManager.agencyHeros.tr().toUpperCase(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  di<FetchAgencyHerosBloc>().add(FetchHerosForMonthEvent(
                    month: secondTabAgencyTimeFilter.value.split('/')[1],
                    year: secondTabAgencyTimeFilter.value.split('/')[0],
                    agencyId: (MyDataModel.getInstance().myAgencyModel?.id ?? 0)
                        .toString(),
                  ));
                },
                child: BlocBuilder<FetchAgencyHerosBloc, FetchAgencyHerosState>(
                  bloc: di<FetchAgencyHerosBloc>(),
                  buildWhen: (prev, curr) =>
                      prev.requestState != curr.requestState ||
                      prev.heros != curr.heros,
                  builder: (context, state) {
                    return HandlingDataWidget(
                        reqState: state.requestState,
                        title: StringManager.noAgencyHostsNowTitle.tr(),
                        subTitle: StringManager.noAgencyHostsNowSubTitle.tr(),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: state.heros?.length ?? 0,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: context.paddingSymmetric(horizontal: 10),
                              child: HerosRowMember(
                                userStarEntity: state.heros![index],
                              ),
                            );
                          },
                        ));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      currentPage++;
      di<FetchAgencyHerosBloc>().add(FetchHerosForMonthEvent(
        year: '${DateTime.now().year}',
        month: '${DateTime.now().month}',
        agencyId: (MyDataModel.getInstance().myAgencyModel?.id ?? 0).toString(),
        page: currentPage.toString(),
      ));
    }
  }
}

class HerosRowMember extends StatelessWidget {
  const HerosRowMember({
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
              // fit: BoxFit.cover,
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
            TextWidget('${userStarEntity.exp}'),
          ],
        ),
      ),
    );
  }
}

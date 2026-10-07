part of 'package:general/src/features/agency/presentation/host_agency/view/component/agency_manager_screen/view/agency_manager_screen.dart';

class StarsScreen extends StatefulWidget {
  final String agencyId;

  const StarsScreen({super.key, required this.agencyId});

  @override
  State<StarsScreen> createState() => _StarsScreenState();
}

class _StarsScreenState extends State<StarsScreen> {
  int currentPage = 1;
  bool _isLoadingMore = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    di<FetchAgencyStarsBloc>().add(FetchStarsForMonthEvent(
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
    return Scaffold(
      appBar: AppBarWidget(
        backgroundColor: ColorManager.scaffoldBg,
        title: StringManager.agencyStars.tr().toUpperCase(),
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
                  di<FetchAgencyStarsBloc>().add(FetchStarsForMonthEvent(
                    month: fMonth,
                    year: fYear,
                    agencyId: widget.agencyId,
                  ));
                },
                child: BlocBuilder<FetchAgencyStarsBloc, FetchAgencyStarsState>(
                  bloc: di<FetchAgencyStarsBloc>(),
                  buildWhen: (prev, curr) =>
                      prev.requestState != curr.requestState ||
                      prev.stars != curr.stars,
                  builder: (context, state) {
                    return HandlingDataWidget(
                        reqState: state.requestState,
                        title: StringManager.noAgencyHostsNowTitle.tr(),
                        subTitle: StringManager.noAgencyHostsNowSubTitle.tr(),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: state.stars?.length ?? 0,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: context.paddingSymmetric(horizontal: 10),
                              child: StarsRowMember(
                                userStarEntity: state.stars![index],
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
    if (_isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _isLoadingMore = true;
      currentPage++;
      di<FetchAgencyStarsBloc>().add(FetchStarsForMonthEvent(
        year: '${DateTime.now().year}',
        month: '${DateTime.now().month}',
        agencyId: widget.agencyId,
        page: currentPage.toString(),
      ));
      Future.delayed(const Duration(seconds: 1), () => _isLoadingMore = false);
    }
  }
}

class StarsRowMember extends StatelessWidget {
  const StarsRowMember({
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
                      isVip: userStarEntity.coloredName != "",
                      width: 110.w,
                      text: userStarEntity.name ?? "",
                      color: userStarEntity.coloredName != ""
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

import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/show_svga.dart';
import 'package:general/src/features/cp/cp.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/cp_design.dart';

class MyRelationCpView extends StatefulWidget {
  const MyRelationCpView({super.key});

  @override
  State<MyRelationCpView> createState() => _MyRelationCpViewState();
}

class _MyRelationCpViewState extends State<MyRelationCpView> {
  @override
  void initState() {
    BlocProvider.of<CpRelationsLevelsBloc>(context)
        .add(GetCpRelationsLevelsEvent());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(vertical: 10),
      child: Column(
        children: [
          const MyCpWidget(),
          10.hBox,
          const MyRelationCpWidget(),
        ],
      ),
    );
  }
}

class MyRelationCpWidget extends StatelessWidget {
  const MyRelationCpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CpRelationsLevelsBloc, CpRelationsLevelsState>(
      buildWhen: (prev, curr) => prev.reqStateLevelsGift != curr.reqStateLevelsGift || prev.levelsGift != curr.levelsGift,
      builder: (context, state) {
        return HandlingDataWidget(
          reqState: state.reqStateLevelsGift,
          title: StringManager.noDataYet.tr(),
          subTitle: StringManager.pleaseTryAgine.tr(),
          child: CpLegendBox(
            label: StringManager.cpLevelPrivileges.tr(),
            backgroundGradient: const [Color(0xFF6A3FD1), Color(0xFF4B2A9E)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (int i = 0; i < (state.levelsGift?.length ?? 0); i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == (state.levelsGift!.length - 1) ? 0 : 8.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CpLevelBadge(
                          level: state.levelsGift![i].level,
                          topConnector: i != 0,
                          bottomConnector: i != state.levelsGift!.length - 1,
                        ),
                        10.wBox,
                        CpLevelTile(
                          title: state.levelsGift![i].gifts!.first.title!,
                          rewardImageUrl:
                              state.levelsGift![i].gifts?.first.images?.isNotEmpty ==
                                      true
                                  ? state.levelsGift![i].gifts!.first.images![0]
                                  : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyCpWidget extends StatelessWidget {
  const MyCpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CpProfileBloc, CpProfileStates>(
      buildWhen: (prev, curr) =>
          prev.reqStates != curr.reqStates || prev.data != curr.data,
      builder: (context, state) {
        final level = state.data?.mainCp?.level ?? 1;
        return CpLegendBox(
          // Top pill shows the CP level, like the reference card, instead of
          // a plain "My CP" label.
          label: 'Lv.$level',
          backgroundGradient: const [Color(0xFFFF6FA5), Color(0xFF7A1E4A)],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              HandlingDataWidget(
                reqState: state.reqStates,
                title: StringManager.noDataYet.tr(),
                subTitle: StringManager.pleaseTryAgine.tr(),
                child: state.data?.mainCp != null
                    ? _CpPersonColumn(
                        image: state.data?.mainCp?.user?.image ?? "",
                        name: state.data?.mainCp?.user?.name ?? '',
                      )
                    : Column(
                        children: [
                          Container(
                            width: 60.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                              border: Border.all(color: CpPalette.surfaceBorder),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white70,
                            ),
                          ),
                          8.hBox,
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, Routes.cpStorePage);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                gradient: LinearGradient(colors: CpPalette.accent),
                              ),
                              child: Padding(
                                padding: context.paddingSymmetric(
                                    vertical: 8, horizontal: 18),
                                child: Text(
                                  StringManager.invite.tr(),
                                  style: context.bodySmall.bold
                                      .colorExt(Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              // Heart connector between the two profiles, matching the
              // reference card, in place of the old plain "LVL n" circle.
              Padding(
                padding: EdgeInsets.only(top: 14.h),
                child: SizedBox(
                  width: 60.w,
                  height: 60.w,
                  child: ShowSVGA(
                    svgaAssetPath: AssetsManager.cpLoveIcon,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              _CpPersonColumn(
                image: MyDataModel.getInstance().profile?.image ?? "",
                name: MyDataModel.getInstance().name ?? '',
                frame: MyDataModel.getInstance().frame,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Avatar + name, stacked — the reference card labels each side of the
/// connector with the person's name instead of leaving it unlabeled.
class _CpPersonColumn extends StatelessWidget {
  const _CpPersonColumn({
    required this.image,
    required this.name,
    this.frame,
  });

  final String image;
  final String name;
  final String? frame;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserImage(
          image: image,
          displayName: name,
          imageSize: 70.h,
          frameSize: 100.h,
          frame: frame,
        ),
        6.hBox,
        SizedBox(
          width: 90.w,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.bodySmall.bold.colorExt(Colors.white),
          ),
        ),
      ],
    );
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/domain/entities/replace_with_gold_entity.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/profile/presentation/coins/view/coins_page.dart';
import 'package:general/src/features/profile/profile.dart';

part 'widgets/diamonds_card_item.dart'; 

class ExchangeDiamondPage extends StatefulWidget {
  const ExchangeDiamondPage({super.key});

  @override
  State<ExchangeDiamondPage> createState() => _ExchangeDiamondPageState();
}

class _ExchangeDiamondPageState extends State<ExchangeDiamondPage> {
  @override
  void initState() {
    if (!di<DiamondBloc>().state.reqStateDiamond.isLoaded) {
      di<DiamondBloc>().add(const GetDiamondDataEvent());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBarWidget(
        title: StringManager.exchangeDiamond.tr(),
      ),
      body: BlocBuilder<DiamondBloc, DiamondState>(
        bloc: di<DiamondBloc>(),
        buildWhen: (prev, curr) => prev.reqStateDiamond != curr.reqStateDiamond || prev.diamondData != curr.diamondData,
        builder: (context, state) {
          return SizedBox(
            height: ScreenUtil().screenHeight,
            child: Padding(
              padding: context.paddingSymmetric(horizontal: 10),
              child: Column(
                children: [
                  Padding(
                    padding: context.paddingOnly(
                      top: 20,
                      bottom: 30,
                    ),
                    child: const GoldenDiamondCard(isCoins: false),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        StringManager.rechargeCoins.tr(),
                        style: context.bodyLarge.w600,
                      ),
                      InkWell(
                        onTap: () {
                          di<MyStoreBloc>().add(const GetMyStoreEvent());
                          di<DiamondBloc>().add(const GetDiamondDataEvent());
                        },
                        child: Image.asset(
                          AssetsManager.refresh,
                          scale: 2,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: HandlingDataWidget(
                      reqState: state.reqStateDiamond,
                      title: StringManager.noDataYet.tr(),
                      subTitle: StringManager.pleaseTryAgine.tr(),
                      onTap: () {
                        di<DiamondBloc>().add(const GetDiamondDataEvent());
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: context.paddingSymmetric(
                              vertical: 5,
                            ),
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AnimatedDialog(
                                    title: StringManager.confirmation.tr(),
                                    description: StringManager.youWillEx(
                                      coin: state.diamondData!.data[index].coin
                                          .toString(),
                                      dimond: state
                                          .diamondData!.data[index].diamonds
                                          .toString(),
                                    ),
                                    conText: StringManager.confirm.tr(),
                                    onTap: () {
                                      di<DiamondBloc>().add(
                                        ExchangeDiamondEvent(
                                          itemId: state
                                                  .diamondData?.data[index].id
                                                  .toString() ??
                                              "",
                                          context: context,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: DiamondsCardItem(
                                replaceWithGoldItemEntity:
                                    state.diamondData!.data[index],
                              ),
                            ),
                          );
                        },
                        itemCount: state.diamondData?.data.length ?? 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/widgets/information_card.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/search_manager/search_user_agency_bloc.dart';
import 'package:general/src/features/payment/presentation/view/components/dollars_view.dart';
import '../../../profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

part 'view/widgets/app_bar_body.dart';

class ChargeAgencyScreen extends StatefulWidget {
  const ChargeAgencyScreen({super.key});

  @override
  State<ChargeAgencyScreen> createState() => _ChargeAgencyScreenState();
}

class _ChargeAgencyScreenState extends State<ChargeAgencyScreen> {
  late final TextEditingController userIdController,
      agencyIdController,
      amountController;
  final _getChargeAgencyBloc = di<GetChargeAgencyBloc>();
  final _chargeCoinForUserBloc = di<ChargeCoinForUserBloc>();
  ValueNotifier<int> userType = ValueNotifier<int>(0);

  @override
  void initState() {
    userIdController = TextEditingController();
    agencyIdController = TextEditingController();
    amountController = TextEditingController();
    _getChargeAgencyBloc.add(const GetChargeAgencyEvent());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    userIdController.dispose();
    agencyIdController.dispose();
    amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalPage =
        BlocListener<ChargeCoinForUserBloc, ChargeCoinForUserState>(
      bloc: _chargeCoinForUserBloc,
      listener: (context, state) {
        if (state.requestState.isLoaded) {
          userIdController.clear();
          agencyIdController.clear();
          amountController.clear();
        } else if (state.requestState.isError) {
          Methods.showToast(context, isError: true, message: state.error ?? '');
          userIdController.clear();
          agencyIdController.clear();
          amountController.clear();
        } else if (state.requestState.isLoading) {
          Methods.showToast(context, isLoading: true);
        }
      },
      child: Scaffold(
          appBar: const _AppBarBody(),
          body: Container(
            padding: context.paddingSymmetric(horizontal: 20),
            height: ScreenUtil().screenHeight,
            width: ScreenUtil().screenWidth,
            color: ColorManager.scaffoldBgAlt,
            child: RefreshIndicator(
              onRefresh: () async {
                _getChargeAgencyBloc.add(const GetChargeAgencyEvent());
                di<MyStoreBloc>().add(const GetMyStoreEvent());
              },
              child: ListView(
                children: [
                  InformationCard(
                    state: _getChargeAgencyBloc.state,
                  ),
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Container(
                      width: ScreenUtil().screenWidth,
                      margin: context.paddingSymmetric(
                        horizontal: 10,
                      ),
                      padding: context.paddingSymmetric(vertical: 5),
                      decoration:
                          const BoxDecoration(color: ColorManager.transparent),
                      child: Column(
                        children: [
                          BlocBuilder<GetChargeAgencyBloc,
                              GetChargeAgencyStates>(
                            bloc: _getChargeAgencyBloc,
                            buildWhen: (prev, curr) =>
                                prev.requestState != curr.requestState ||
                                prev.myChargeAgencyData !=
                                    curr.myChargeAgencyData,
                            builder: (context, state) {
                              return Text(
                                "${state.requestState.isLoaded ? state.myChargeAgencyData?.coins.toString() : 0}",
                                style: context.bodyMedium
                                    .size(40)
                                    .colorExt(ColorManager.textPrimary)
                                    .w700,
                              );
                            },
                          ),
                          TextWidget(
                            StringManager.availableBalance.tr(),
                            style: context.bodyMedium
                                .size(14)
                                .colorExt(ColorManager.textPrimary)
                                .w700,
                          )
                        ],
                      ),
                    ),
                  ),
                  20.hBox,
                  UserTypeSwitcherWidget(userType: userType),
                  15.hBox,
                  UserTypeContentWidget(
                    userType: userType,
                    agencyIdController: agencyIdController,
                    userIdController: userIdController,
                    amountController: amountController,
                    onPressedTransfer: () {
                      if ((di<SearchUserAgencyBloc>().state.param?.id ??
                              '-1') ==
                          (MyDataModel.getInstance()
                                      .myShippingAgencyEntity
                                      ?.id ??
                                  0)
                              .toString()) {
                        Methods.showToast(context,
                            isError: true, message: StringManager.stopCharge);
                      } else if (!_chargeCoinForUserBloc
                          .state.requestState.isLoading) {
                        _chargeCoinForUserBloc.add(
                          ChargeCoinForUserEvent(
                            context: context,
                            id: di<SearchUserAgencyBloc>().state.param?.id ??
                                '-1',
                            amount: amountController.text,
                            type: userType.value == 1 ? "user" : "agency",
                          ),
                        );
                      }
                    },
                    dialogSubTitle: StringManager.theAmountOfCoins,
                    isDollarsValue: false,
                  ),
                ],
              ),
            ),
          )),
    );
    return normalPage;
  }
}

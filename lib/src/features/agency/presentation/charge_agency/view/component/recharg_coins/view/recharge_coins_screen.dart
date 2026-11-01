import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/view/host_withdrawel_screen.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/info_charge_agency/bloc/manager_get_charge_agency_info/get_charge_agency_bloc.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_bloc.dart';
import 'package:general/src/features/payment/presentation/bloc/buy_coins_bloc/buy_coins_event.dart';
import 'package:general/src/features/payment/presentation/bloc/fetch_coins/fetch_coins_bloc.dart';
import 'package:general/src/features/payment/presentation/bloc/fetch_coins/fetch_coins_event.dart';
import 'package:general/src/features/payment/presentation/bloc/fetch_coins/fetch_coins_state.dart';
import 'package:general/src/features/payment/presentation/view/components/coins_view.dart';
import 'package:general/src/features/payment/presentation/view/in_app_purchases.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Coin seller recharge screen with two tabs:
/// - Seller: seller packages (`coins/payment?type=shipping`, FetchCoinsBloc
///   shippingData).
/// - User: the normal user packages (`coins/payment`, FetchCoinsBloc data),
///   reusing the wallet's CoinsView and its buy flow as-is.
class RechargeCoinsScreen extends StatefulWidget {
  const RechargeCoinsScreen({super.key});

  @override
  State<RechargeCoinsScreen> createState() => _RechargeCoinsScreenState();
}

class _RechargeCoinsScreenState extends State<RechargeCoinsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (!di<FetchCoinsBloc>().state.shippingReqState.isLoaded) {
      di<FetchCoinsBloc>().add(const FetchCoinsEvent(type: 'shipping'));
    }
    if (!di<FetchCoinsBloc>().state.reqState.isLoaded) {
      di<FetchCoinsBloc>().add(const FetchCoinsEvent());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: StringManager.rechargeCoins.tr(),
        iconLasted: InkWell(
          onTap: () {
            Navigator.pushNamed(context, Routes.recordsScreen);
          },
          child: const TextWidget(StringManager.record),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.hBox,
          Align(
            alignment: AlignmentDirectional.center,
            child: Column(
              children: [
                BlocBuilder<GetChargeAgencyBloc, GetChargeAgencyStates>(
                  bloc: di<GetChargeAgencyBloc>(),
                  buildWhen: (prev, curr) =>
                      prev.requestState != curr.requestState ||
                      prev.myChargeAgencyData != curr.myChargeAgencyData,
                  builder: (context, state) {
                    return Text(
                      "${state.requestState.isLoaded ? state.myChargeAgencyData?.coins.toString() : 0}",
                      style: context.bodyMedium.size(40).w700,
                    );
                  },
                ),
                TextWidget(
                  StringManager.availableBalance.tr(),
                  style: context.bodyMedium.size(14).w700,
                )
              ],
            ),
          ),
          20.hBox,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: _RechargeTypeTabBar(controller: _tabController),
          ),
          4.hBox,
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _SellerPackagesTab(),
                CoinsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small left-aligned pill tabs (Seller / User); sized to its labels instead
/// of stretching across the screen.
class _RechargeTypeTabBar extends StatelessWidget {
  const _RechargeTypeTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final labels = [StringManager.seller.tr(), StringManager.user.tr()];
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: ColorManager.greyLight,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(labels.length, (i) {
              final selected = controller.index == i;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.animateTo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? ColorManager.coinsAccent
                        : ColorManager.transparent,
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                  child: TextWidget(
                    labels[i],
                    isTranslate: false,
                    style: selected
                        ? context.bodySmall
                            .size(12)
                            .bold
                            .colorExt(ColorManager.black)
                        : context.bodySmall
                            .size(12)
                            .w600
                            .colorExt(ColorManager.grey),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Seller packages list -- the screen's original content, moved into its tab.
class _SellerPackagesTab extends StatelessWidget {
  const _SellerPackagesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchCoinsBloc, FetchCoinsState>(
      bloc: di<FetchCoinsBloc>(),
      buildWhen: (prev, curr) =>
          prev.shippingReqState != curr.shippingReqState ||
          prev.shippingData != curr.shippingData,
      builder: (context, state) {
        return HandlingDataWidget(
          isNeedLoadingWidget: true,
          reqState: state.shippingReqState,
          title: StringManager.noDataYet.tr(),
          subTitle: StringManager.pleaseTryAgine.tr(),
          onTap: () {
            di<FetchCoinsBloc>().add(const FetchCoinsEvent(type: 'shipping'));
            di<MyStoreBloc>().add(const GetMyStoreEvent(isLoading: false));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: context.paddingSymmetric(horizontal: 18, vertical: 10),
            children: [
              if (di<ConfigAppBloc>().state.config?.isShowChargeAgencies !=
                  false)
                Container(
                  decoration: BoxDecoration(
                    color: ColorManager.surfaceCardColor,
                    borderRadius: 10.radius,
                  ),
                  margin: context.paddingSymmetric(vertical: 5),
                  padding:
                      context.paddingSymmetric(vertical: 8, horizontal: 18),
                  child: GestureDetector(
                    onTap: () {
                      bottomDailog(
                        context: context,
                        widget: const HostWithdrawelScreen(
                          param: CoinsScreenParam(
                            stopTransferButton: true,
                            isFromCoinsScreen: true,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          AssetsManager.coinsVip,
                          width: 40.w,
                          height: 40.h,
                        ),
                        15.wBox,
                        TextWidget(
                          StringManager.shippingFromTheAgency.tr(),
                          style: context.bodyMedium.bold,
                        ),
                        const Spacer(),
                        Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: ColorManager.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              Skeletonizer(
                enabled: state.shippingReqState == RequestState.loading,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.shippingReqState == RequestState.loading
                      ? 5
                      : state.shippingData?.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (context, ind) {
                    return Container(
                      decoration: BoxDecoration(
                        color: ColorManager.surfaceCardColor,
                        borderRadius: 10.radius,
                      ),
                      margin: context.paddingSymmetric(vertical: 5),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                            dividerColor: ColorManager.surfaceCardColor),
                        child: state.shippingReqState.isLoading
                            ? Container(
                                width: 40.w,
                                height: 40.h,
                                color: Colors.grey[300],
                              )
                            : _sellerGateway(context, state, ind),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sellerGateway(BuildContext context, FetchCoinsState state, int ind) {
    final gateway = state.shippingData![ind];
    return ExpansionTile(
      leading: ImageViewWidget(
        url: gateway.photo ?? "",
        width: 40.w,
        height: 40.h,
        boxFit: BoxFit.contain,
      ),
      title: TextWidget(
        gateway.title != null
            ? StringManager.getGateWay(gateway: gateway.title!)
            : "",
        style: context.bodyMedium.bold,
      ),
      children: [
        Column(
          children: List.generate(
            gateway.coins?.length ?? 0,
            (index) {
              final coin = gateway.coins?[index];
              return Container(
                padding: context.paddingSymmetric(horizontal: 15),
                margin: context.paddingSymmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      AssetsManager.coinsVip,
                      scale: 2.5,
                    ),
                    10.wBox,
                    Expanded(
                      child: TextWidget(
                        coin?.coin.toString() ?? '',
                        style: context.bodyMedium.bold.size(18),
                      ),
                    ),
                    ButtonWidget(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      backgroundColor: ColorManager.coinsAccent,
                      onPressed: () async {
                        if (gateway.title == "google_pay") {
                          di<PurchaseService>().buyProduct(di<PurchaseService>()
                              .result!
                              .productDetails
                              .where((element) =>
                                  element.id.toString() == coin?.id.toString())
                              .single);
                        } else {
                          if (!di<BuyCoinsBloc>().state.reqState.isLoading) {
                            di<BuyCoinsBloc>().add(BuyCoinsEvent(
                              context: context,
                              // The seller gateway's own method (was read
                              // from the user list `state.data` by mistake).
                              method: gateway.title ?? '',
                              productId: coin?.id.toString() ?? "",
                            ));
                          }
                        }
                        Methods.showToast(context, isLoading: true);
                      },
                      height: 33.h,
                      width: 110.w,
                      title: coin?.usd != null ? "${coin!.usd} \$" : '',
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/view/host_withdrawel_screen.dart';
import 'package:general/src/features/auth/presentation/splash/config_app/config_app_bloc.dart';
import 'package:general/src/features/payment/presentation/bloc/fetch_coins/fetch_coins_event.dart';
import 'package:general/src/features/payment/presentation/view/in_app_purchases.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:general/src/core/index.dart';
import '../../bloc/buy_coins_bloc/buy_coins_bloc.dart';
import '../../bloc/buy_coins_bloc/buy_coins_event.dart';
import '../../bloc/fetch_coins/fetch_coins_bloc.dart';
import '../../bloc/fetch_coins/fetch_coins_state.dart';

class CoinsView extends StatefulWidget {
  const CoinsView({super.key});

  @override
  State<CoinsView> createState() => _CoinsViewState();
}

class _CoinsViewState extends State<CoinsView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchCoinsBloc, FetchCoinsState>(
      bloc: di<FetchCoinsBloc>(),
      buildWhen: (prev, curr) =>
      prev.reqState != curr.reqState || prev.data != curr.data,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            110.hBox,
            Padding(
              padding: context.paddingSymmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    StringManager.recharge.tr(),
                    style: context.bodyMedium.size(15).w600.colorExt(
                        ColorManager.black),
                  ),
                  InkWell(
                    onTap: () {
                      di<MyStoreBloc>().add(const GetMyStoreEvent());
                      di<FetchCoinsBloc>().add(const FetchCoinsEvent());
                    },
                    child: Image.asset(
                      AssetsManager.refreshIcon,
                      scale: 2,
                      color: ColorManager.coinsAccent,
                    ),
                  ),
                ],
              ),
            ),
            5.hBox,
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.paddingSymmetric(horizontal: 18, vertical: 10),
                children: [
                  if (di<ConfigAppBloc>().state.config?.isShowChargeAgencies !=
                      false)
                    Container(
                      decoration: BoxDecoration(
                        color: ColorManager.white,
                        borderRadius: 12.radius,
                        border: Border.all(
                            color: ColorManager.grey2.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: ColorManager.black.withValues(alpha: 0.05),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
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
                              style: context.bodyMedium.bold
                                  .colorExt(ColorManager.black),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.keyboard_arrow_down_outlined,
                              color: ColorManager.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  HandlingDataWidget(
                    isNeedLoadingWidget: true,
                    reqState: state.reqState,
                    title: StringManager.noDataYet.tr(),
                    subTitle: StringManager.pleaseTryAgine.tr(),
                    titleStyle: context.bodyLarge.w600
                        .colorExt(ColorManager.black),
                    subTitleStyle: context.bodyMedium
                        .copyWith(color: ColorManager.black, height: 1.30),
                    buttonBackgroundColors: [
                      ColorManager.primary,
                      ColorManager.primary
                    ],
                    onTap: () {
                      di<FetchCoinsBloc>().add(const FetchCoinsEvent());
                      di<MyStoreBloc>()
                          .add(const GetMyStoreEvent(isLoading: false));
                    },
                    child: Skeletonizer(
                      enabled: state.reqState == RequestState.loading,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.reqState == RequestState.loading
                            ? 5
                            : state.data?.length ?? 0,
                        shrinkWrap: true,
                        itemBuilder: (context, ind) {
                          return Container(
                            decoration: BoxDecoration(
                              color: ColorManager.white,
                              borderRadius: 12.radius,
                              border: Border.all(
                                  color: ColorManager.grey2
                                      .withValues(alpha: 0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  ColorManager.black.withValues(alpha: 0.05),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            margin: context.paddingSymmetric(vertical: 5),
                            child: Material(
                              color: ColorManager.transparent,
                              child: Theme(
                                data: Theme.of(context)
                                    .copyWith(dividerColor: ColorManager.white),
                                child: state.reqState.isLoading
                                    ? Container(
                                    width: 40.w,
                                    height: 40.h,
                                    color: Colors.grey[300])
                                    : ExpansionTile(
                                  leading: ImageViewWidget(
                                    url: state.data?[ind].photo ?? "",
                                    width: 40.w,
                                    height: 40.h,
                                    boxFit: BoxFit.contain,
                                  ),
                                  title: TextWidget(
                                    state.data?[ind].title != null
                                        ? StringManager.getGateWay(
                                        gateway:
                                        state.data![ind].title!)
                                        : "",
                                    style: context.bodyMedium.bold
                                        .colorExt(ColorManager.black),
                                  ),
                                  children: [
                                    Column(
                                      children: List.generate(
                                        state.data?[ind].coins?.length ?? 0,
                                            (index) {
                                          final coin = state
                                              .data?[ind].coins?[index];
                                          return Container(
                                            padding:
                                            context.paddingSymmetric(
                                                horizontal: 15),
                                            margin:
                                            context.paddingSymmetric(
                                                vertical: 10),
                                            child: Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  AssetsManager.coinsVip,
                                                  scale: 2.5,
                                                ),
                                                10.wBox,
                                                Expanded(
                                                  child: TextWidget(
                                                    coin?.coin.toString() ??
                                                        '',
                                                    style: context
                                                        .bodyMedium.bold
                                                        .colorExt(
                                                        ColorManager.black)
                                                        .size(18),
                                                  ),
                                                ),
                                                ButtonWidget(
                                                  fontWeight:
                                                  FontWeight.w500,
                                                  fontSize: 16,
                                                  backgroundColor:
                                                  ColorManager
                                                      .coinsAccent,
                                                  onPressed: () async {
                                                    if (state.data![ind]
                                                        .title ==
                                                        "google_pay" &&
                                                        di<PurchaseService>()
                                                            .result !=
                                                            null) {
                                                      // ✅ ফিক্স: iamparty_coin_1, coin_1 এবং coin.id সঠিকভাবে ম্যাচ করবে
                                                      final matches = di<
                                                          PurchaseService>()
                                                          .result!
                                                          .productDetails
                                                          .where((element) =>
                                                      element.id == 'iamparty_coin_${coin?.id}' ||
                                                          element.id == 'coin_${coin?.id}' ||
                                                          element.id == coin?.id.toString());

                                                      if (matches.isEmpty) {
                                                        Methods.showToast(
                                                          context,
                                                          message:
                                                          'This package is not available right now',
                                                          isError: true,
                                                        );
                                                        return;
                                                      }
                                                      di<PurchaseService>()
                                                          .buyProduct(
                                                          matches.first);
                                                    } else {
                                                      if (!di<BuyCoinsBloc>()
                                                          .state
                                                          .reqState
                                                          .isLoading) {
                                                        di<BuyCoinsBloc>()
                                                            .add(
                                                          BuyCoinsEvent(
                                                            context: context,
                                                            method: state
                                                                .data?[
                                                            ind]
                                                                .title ??
                                                                '',
                                                            productId: coin
                                                                ?.id
                                                                .toString() ??
                                                                "",
                                                          ),
                                                        );
                                                      }
                                                    }
                                                    Methods.showToast(
                                                        context,
                                                        isLoading: true);
                                                  },
                                                  height: 33.h,
                                                  width: 110.w,
                                                  title: coin?.usd != null
                                                      ? "${coin!.usd % 1 == 0 ? coin.usd.toInt() : coin.usd.toString()} \$"
                                                      : '',
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
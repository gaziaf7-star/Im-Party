import 'package:general/src/features/payment/presentation/bloc/fetch_coins/fetch_coins_event.dart';
import 'package:general/src/features/payment/presentation/view/in_app_purchases.dart';
import 'package:general/src/features/payment/presentation/view/manual_recharge/manual_recharge_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:general/src/core/index.dart';
import '../../bloc/buy_coins_bloc/buy_coins_bloc.dart';
import '../../bloc/buy_coins_bloc/buy_coins_event.dart';
import '../../bloc/fetch_coins/fetch_coins_bloc.dart';
import '../../bloc/fetch_coins/fetch_coins_state.dart';
import '../../../domain/entities/coins_entity.dart';

class CoinsView extends StatefulWidget {
  const CoinsView({super.key});

  @override
  State<CoinsView> createState() => _CoinsViewState();
}

class _CoinsViewState extends State<CoinsView> {
  /// Gateways whose package grid is open (the first one by default).
  final Set<int> _open = {0};

  /// Selected package: (gateway index, package index).
  (int, int)? _selected;

  static String _price(double usd) =>
      usd % 1 == 0 ? usd.toInt().toString() : usd.toString();

  /// Same purchase flow as before: Google Play billing for google_pay,
  /// otherwise the server-side BuyCoinsEvent.
  void _buy(FetchCoinsState state, int ind, CoinEntity? coin) {
    if (state.data![ind].title == "google_pay" &&
        di<PurchaseService>().result != null) {
      final matches = di<PurchaseService>()
          .result!
          .productDetails
          .where((element) =>
              element.id == 'iamparty_coin_${coin?.id}' ||
              element.id == 'coin_${coin?.id}' ||
              element.id == coin?.id.toString());

      if (matches.isEmpty) {
        Methods.showToast(
          context,
          message: 'This package is not available right now',
          isError: true,
        );
        return;
      }
      di<PurchaseService>().buyProduct(matches.first);
    } else {
      if (!di<BuyCoinsBloc>().state.reqState.isLoading) {
        di<BuyCoinsBloc>().add(
          BuyCoinsEvent(
            context: context,
            method: state.data?[ind].title ?? '',
            productId: coin?.id.toString() ?? "",
          ),
        );
      }
    }
    Methods.showToast(context, isLoading: true);
  }

  Widget _section({required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );
  }

  Widget _logoBox(Widget child) {
    return Container(
      width: 64.w,
      height: 44.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFE3E4E8)),
      ),
      child: child,
    );
  }

  /// Manual recharge (bKash/Nagad/...), shown above every other gateway in
  /// the same card style; opens its own step-by-step page.
  Widget _manualRecharge() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ManualRechargePage()),
      ),
      child: _section(
        child: Row(
          children: [
            _logoBox(
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5F7E), Color(0xFFF8284D)],
                  ),
                ),
                child: Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 22.sp),
              ),
            ),
            12.wBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seller',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF1C1C1E),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  2.hBox,
                  Text(
                    'bKash · Nagad · Bank transfer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF8E8F96),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFB5B6BC),
              size: 28.sp,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 320))
        .slideY(begin: .08, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _gateway(FetchCoinsState state, int ind) {
    final gw = state.data![ind];
    final coins = gw.coins ?? [];
    final open = _open.contains(ind);
    return _section(
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(
                () => open ? _open.remove(ind) : _open.add(ind)),
            child: Row(
              children: [
                _logoBox(ImageViewWidget(
                  url: gw.photo ?? '',
                  boxFit: BoxFit.contain,
                )),
                12.wBox,
                Expanded(
                  child: Text(
                    gw.title != null
                        ? StringManager.getGateWay(gateway: gw.title!)
                        : '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF1C1C1E),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  open
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFB5B6BC),
                  size: 28.sp,
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: !open
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: EdgeInsets.only(top: 14.h),
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: coins.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10.h,
                        crossAxisSpacing: 10.w,
                        childAspectRatio: 1.32,
                      ),
                      itemBuilder: (context, i) => _pack(
                        coins[i],
                        selected: _selected == (ind, i),
                        onTap: () => setState(() => _selected = (ind, i)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _pack(CoinEntity coin,
      {required bool selected, required VoidCallback onTap}) {
    const pink = Color(0xFFF8284D);
    final extra = coin.extraValue ?? 0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF4F6) : const Color(0xFFF3F4F7),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? pink : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(AssetsManager.coinsVip, height: 18.h),
                        4.wBox,
                        Text(
                          '${coin.coin}',
                          style: TextStyle(
                            color: const Color(0xFF1C1C1E),
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (extra > 0)
                          Text(
                            '+$extra',
                            style: TextStyle(
                              color: const Color(0xFFF5A623),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  4.hBox,
                  Text(
                    '${_price(coin.usd)} \$',
                    style: TextStyle(
                      color: const Color(0xFF8E8F96),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            // Check mark in the bottom-right corner of the selected pack.
            if (selected)
              Positioned(
                right: 0,
                bottom: 0,
                child: ClipPath(
                  clipper: _CornerClipper(),
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    color: pink,
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.only(right: 2, bottom: 1),
                    child: Icon(Icons.check_rounded,
                        color: Colors.white, size: 12.sp),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getButton(FetchCoinsState state) {
    final sel = _selected;
    final coin = (sel != null &&
            (state.data?.length ?? 0) > sel.$1 &&
            (state.data![sel.$1].coins?.length ?? 0) > sel.$2)
        ? state.data![sel.$1].coins![sel.$2]
        : null;
    final enabled = coin != null;
    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: () {
          if (!enabled) {
            Methods.showToast(context, message: 'Choose a package first');
            return;
          }
          _buy(state, sel!.$1, coin);
        },
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: Container(
            height: 60.h,
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32.r),
              gradient: const LinearGradient(
                colors: [Color(0xFF2EE6CC), Color(0xFF00D0E8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D0E8).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Image.asset(AssetsManager.coinsVip, height: 20.h),
                    4.wBox,
                    Text(
                      enabled
                          ? '${coin.coin + (coin.extraValue ?? 0)}'
                          : '--',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (enabled)
                  Text(
                    'Total: ${_price(coin.usd)} \$',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14.sp,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchCoinsBloc, FetchCoinsState>(
      bloc: di<FetchCoinsBloc>(),
      buildWhen: (prev, curr) =>
          prev.reqState != curr.reqState || prev.data != curr.data,
      builder: (context, state) {
        final loading = state.reqState == RequestState.loading;
        return Column(
          children: [
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
                children: [
                  _manualRecharge(),
                  HandlingDataWidget(
                    isNeedLoadingWidget: true,
                    reqState: state.reqState,
                    title: StringManager.noDataYet.tr(),
                    subTitle: StringManager.pleaseTryAgine.tr(),
                    titleStyle:
                        context.bodyLarge.w600.colorExt(ColorManager.black),
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
                    child: loading
                        ? Skeletonizer(
                            enabled: true,
                            child: Column(
                              children: List.generate(
                                2,
                                (_) => _section(
                                  child: SizedBox(
                                    height: 150.h,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: List.generate(
                              state.data?.length ?? 0,
                              (ind) => _gateway(state, ind),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            if (!loading && (state.data?.isNotEmpty ?? false))
              _getButton(state),
          ],
        );
      },
    );
  }
}

/// Bottom-right triangle for the selected package's check mark.
class _CornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

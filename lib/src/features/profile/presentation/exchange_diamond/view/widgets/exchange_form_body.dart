import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:general/src/features/profile/profile.dart';

import '../../bloc/exchange_v2_bloc/exchange_v2_bloc.dart';
import '../exchange_logs_page.dart';

/// The actual diamond -> coin Exchange form (v2 API) -- live balance/rate,
/// diamond-amount input, computed coin preview, confirm + submit, history
/// link. Extracted out of ExchangeV2Page so the exact same form can be
/// embedded directly as the "Exchange" tab inside the Wallet screen's
/// Diamond view (diamond_view.dart), per request, without duplicating
/// this logic.
class ExchangeFormBody extends StatefulWidget {
  const ExchangeFormBody({super.key, this.showBalanceCard = true});

  /// Whether to show the live diamond-balance + rate gradient card at the
  /// top. The Diamond tab already shows its own balance card above these
  /// tabs, so it embeds this with `showBalanceCard: false` to avoid
  /// showing the same balance twice.
  final bool showBalanceCard;

  @override
  State<ExchangeFormBody> createState() => _ExchangeFormBodyState();
}

class _ExchangeFormBodyState extends State<ExchangeFormBody> {
  final TextEditingController _diamondsController = TextEditingController();
  num _exchangeCoins = 0;

  @override
  void initState() {
    super.initState();
    di<ExchangeV2Bloc>().add(const GetExchangeSettingsEvent());
    _diamondsController.addListener(_recompute);
  }

  @override
  void dispose() {
    _diamondsController.removeListener(_recompute);
    _diamondsController.dispose();
    super.dispose();
  }

  void _recompute() {
    final rate = di<ExchangeV2Bloc>().state.settings?.rate ?? 1;
    final entered = num.tryParse(_diamondsController.text.trim()) ?? 0;
    setState(() {
      _exchangeCoins = entered * rate;
    });
  }

  void _confirmExchange(BuildContext context) {
    final entered = num.tryParse(_diamondsController.text.trim()) ?? 0;
    if (entered <= 0) {
      Methods.showToast(context, message: StringManager.invalidAmount.tr(), isError: true);
      return;
    }
    // Was a local "entered > _currentDiamonds" balance block -- removed on
    // request, same as Withdraw: the server (exchange v2 API) is the source
    // of truth for balance checks.
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        title: StringManager.confirmation.tr(),
        description: StringManager.youWillEx(
          coin: _exchangeCoins.round().toString(),
          dimond: entered.round().toString(),
        ),
        conText: StringManager.confirm.tr(),
        // White dialog card with black title/description (was the
        // panel-driven scaffoldBg/textPrimary/secondaryText). Confirm button
        // is the brand gradient with white text; Cancel stays black text on
        // a plain outline.
        dialogBackgroundColor: ColorManager.white,
        titleColor: ColorManager.black,
        descriptionColor: ColorManager.black,
        confirmGradientColors: ColorManager.brandGradientColors,
        cancelTextColor: ColorManager.black,
        onTap: () {
          di<ExchangeV2Bloc>().add(MakeExchangeEvent(
            diamonds: entered.round(),
            exchange: _exchangeCoins.round(),
            context: context,
          ));
          _diamondsController.clear();
          // Close the confirmation popup on tap (AnimatedDialog's Confirm
          // button has no built-in auto-close, unlike Cancel).
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExchangeV2Bloc, ExchangeV2State>(
      bloc: di<ExchangeV2Bloc>(),
      listenWhen: (prev, curr) =>
      prev.reqStateExchange != curr.reqStateExchange,
      listener: (context, state) {},
      builder: (context, state) {
        final rate = state.settings?.rate ?? 1;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.paddingAll(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showBalanceCard) ...[
                // Balance + live rate card.
                Container(
                  width: double.infinity,
                  padding: context.paddingAll(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ColorManager.diamondsAccent,
                        ColorManager.diamondsAccent.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: 16.radius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(AssetsManager.diamondsIcon,
                              height: 28.h, width: 28.w),
                          8.wBox,
                          TextWidget(
                            StringManager.diamondBalance.tr(),
                            style: context.bodyMedium
                                .colorExt(ColorManager.white)
                                .size(14),
                          ),
                        ],
                      ),
                      8.hBox,
                      BlocBuilder<MyStoreBloc, MyStoreState>(
                        bloc: di<MyStoreBloc>(),
                        buildWhen: (prev, curr) =>
                        prev.myStore != curr.myStore,
                        builder: (context, myStoreState) {
                          return TextWidget(
                            '${myStoreState.myStore?.diamonds ?? 0}',
                            style: context.bodyLarge
                                .w700
                                .size(32)
                                .colorExt(ColorManager.white),
                          );
                        },
                      ),
                      12.hBox,
                      Container(
                        padding: context.paddingSymmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: ColorManager.white.withValues(alpha: 0.18),
                          borderRadius: 20.radius,
                        ),
                        child: state.reqStateSettings.isLoading
                            ? SizedBox(
                          height: 14.h,
                          width: 14.h,
                          child: LoadingWidget(
                              color: ColorManager.white, size: 14),
                        )
                            : TextWidget(
                          '${StringManager.exchangeRateLabel.tr()}: 1 ${StringManager.diamond.tr()} = $rate ${StringManager.coins.tr()}',
                          style: context.bodyMedium
                              .colorExt(ColorManager.white)
                              .size(12),
                        ),
                      ),
                    ],
                  ),
                ),
                20.hBox,
              ] else ...[
                // No balance card here -- shown by the embedding screen
                // (Diamond tab) already -- but still show the live rate so
                // the user knows the conversion while typing.
                Container(
                  padding:
                  context.paddingSymmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorManager.diamondsAccent.withValues(alpha: 0.1),
                    borderRadius: 10.radius,
                  ),
                  child: state.reqStateSettings.isLoading
                      ? SizedBox(
                    height: 14.h,
                    width: 14.h,
                    child: LoadingWidget(
                        color: ColorManager.diamondsAccent, size: 14),
                  )
                      : TextWidget(
                    '${StringManager.exchangeRateLabel.tr()}: 1 ${StringManager.diamond.tr()} = $rate ${StringManager.coins.tr()}',
                    style: context.bodyMedium
                        .colorExt(ColorManager.diamondsAccent)
                        .w600
                        .size(13),
                  ),
                ),
                16.hBox,
              ],
              TextWidget(
                StringManager.enterDiamondsAmount.tr(),
                style: context.bodyMedium.w600
                    .colorExt(ColorManager.black)
                    .size(15),
              ),
              10.hBox,
              TextField(
                controller: _diamondsController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                // Explicit black on request -- both the typed value and the
                // placeholder need to read clearly against the light field
                // background instead of relying on a theme default.
                style: context.bodyMedium
                    .colorExt(ColorManager.black)
                    .size(18),
                cursorColor: ColorManager.diamondsAccent,
                decoration: InputDecoration(
                  hintText: StringManager.enterDiamondsAmount.tr(),
                  hintStyle: context.bodyMedium
                      .colorExt(ColorManager.black.withValues(alpha: 0.45))
                      .size(18),
                  prefixIcon: Padding(
                    padding: context.paddingAll(12),
                    child: Image.asset(AssetsManager.diamondsIcon,
                        height: 20.h, width: 20.w),
                  ),
                  filled: true,
                  fillColor: ColorManager.grey2.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: 12.radius,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              16.hBox,
              Container(
                width: double.infinity,
                padding: context.paddingAll(14),
                decoration: BoxDecoration(
                  color: ColorManager.grey2.withValues(alpha: 0.08),
                  borderRadius: 12.radius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      StringManager.youWillReceive.tr(),
                      style: context.bodyMedium
                          .colorExt(ColorManager.black)
                          .size(14),
                    ),
                    Row(
                      children: [
                        Image.asset(AssetsManager.coinsVip,
                            height: 22.h, width: 22.w),
                        6.wBox,
                        TextWidget(
                          _exchangeCoins.round().toString(),
                          style: context.bodyLarge.w700
                              .colorExt(ColorManager.black)
                              .size(20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              24.hBox,
              ButtonWidget(
                title: StringManager.exchangeNow.tr(),
                isLoading: state.reqStateExchange.isLoading,
                backgroundColors: [
                  ColorManager.diamondsAccent,
                  ColorManager.diamondsAccent.withValues(alpha: 0.8),
                ],
                radius: 12,
                height: 50,
                onPressed: state.reqStateExchange.isLoading
                    ? null
                    : () => _confirmExchange(context),
              ),
              16.hBox,
              Center(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ExchangeLogsPage()),
                  ),
                  child: TextWidget(
                    StringManager.exchangeHistory.tr(),
                    style: context.bodyMedium
                        .colorExt(ColorManager.primary)
                        .size(14)
                        .copyWith(decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
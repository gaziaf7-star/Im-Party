import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/profile.dart';

import '../bloc/exchange_v2_bloc/exchange_v2_bloc.dart';

/// History of past v2 diamond -> coin exchanges
/// (`GET /wallets/exchange/logs`), opened from the new Exchange screen.
class ExchangeLogsPage extends StatefulWidget {
  const ExchangeLogsPage({super.key});

  @override
  State<ExchangeLogsPage> createState() => _ExchangeLogsPageState();
}

class _ExchangeLogsPageState extends State<ExchangeLogsPage> {
  @override
  void initState() {
    super.initState();
    di<ExchangeV2Bloc>().add(const GetExchangeLogsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        title: StringManager.exchangeHistory.tr(),
        // Fixed black title + back-arrow icon (was the panel-driven
        // textPrimary, which can resolve light/near-invisible on this
        // screen's white app bar).
        titleStyle: context.titleLarge.w600
            .size(16)
            .colorExt(ColorManager.black),
        iconColor: ColorManager.black,
      ),
      body: BlocBuilder<ExchangeV2Bloc, ExchangeV2State>(
        bloc: di<ExchangeV2Bloc>(),
        buildWhen: (prev, curr) =>
        prev.reqStateLogs != curr.reqStateLogs || prev.logs != curr.logs,
        builder: (context, state) {
          return RefreshIndicatorWidget(
            onRefresh: () async {
              di<ExchangeV2Bloc>().add(const GetExchangeLogsEvent());
            },
            child: HandlingDataWidget(
              reqState: state.reqStateLogs,
              title: StringManager.noExchangeHistory.tr(),
              subTitle: StringManager.pleaseTryAgine.tr(),
              // Fixed black text (was panel-driven) and a brand-gradient
              // retry button with white text (was a flat/outline button).
              titleStyle: context.bodyLarge.w600.colorExt(ColorManager.black),
              subTitleStyle: context.bodyMedium
                  .colorExt(ColorManager.black.withValues(alpha: 0.6)),
              buttonBackgroundColors: ColorManager.brandGradientColors,
              buttonBorderColor: ColorManager.transparent,
              onTap: () => di<ExchangeV2Bloc>().add(const GetExchangeLogsEvent()),
              child: ListView.separated(
                padding: context.paddingAll(16),
                itemCount: state.logs?.data.length ?? 0,
                separatorBuilder: (_, __) => 10.hBox,
                itemBuilder: (context, index) {
                  final item = state.logs!.data[index];
                  return Container(
                    padding: context.paddingAll(14),
                    decoration: BoxDecoration(
                      color: ColorManager.grey2.withValues(alpha: 0.08),
                      borderRadius: 12.radius,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(AssetsManager.diamondsIcon,
                                height: 22.h, width: 22.w),
                            6.wBox,
                            TextWidget(
                              '-${item.diamonds}',
                              style: context.bodyMedium
                                  .w600
                                  .colorExt(ColorManager.black)
                                  .size(15),
                            ),
                            10.wBox,
                            Icon(Icons.arrow_forward,
                                size: 16.sp,
                                color: ColorManager.black.withValues(alpha: 0.4)),
                            10.wBox,
                            Image.asset(AssetsManager.coinsVip,
                                height: 22.h, width: 22.w),
                            6.wBox,
                            TextWidget(
                              '+${item.exchange}',
                              style: context.bodyMedium
                                  .w600
                                  .colorExt(ColorManager.black)
                                  .size(15),
                            ),
                          ],
                        ),
                        if (item.date != null)
                          TextWidget(
                            item.date!,
                            style: context.bodyMedium
                                .colorExt(ColorManager.black.withValues(alpha: 0.5))
                                .size(11),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
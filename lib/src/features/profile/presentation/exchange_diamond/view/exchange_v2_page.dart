import 'package:general/src/core/index.dart';

import 'exchange_logs_page.dart';
import 'widgets/exchange_form_body.dart';

/// New professional diamond -> coin Exchange screen (v2 API). Shows the
/// live balance + exchange rate, lets the user type a diamond amount, and
/// shows the coin amount they'll receive computed live from the rate
/// before they confirm -- replacing the old fixed-tier-list flow.
///
/// The actual form now lives in [ExchangeFormBody] so it can be reused
/// both here (as a standalone page, still reachable via
/// Routes.exchangeV2Page) and embedded directly as the "Exchange" tab
/// inside the Wallet screen's Diamond view, next to the Withdraw tab.
class ExchangeV2Page extends StatelessWidget {
  const ExchangeV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        iconColor: ColorManager.white,
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.diamondsAccent,
            ColorManager.diamondsAccent.withValues(alpha: 0.75),
          ],
        ),
        title: StringManager.exchangeDiamondsToCoins.tr(),
        titleStyle:
        context.bodyMedium.size(16).w600.colorExt(ColorManager.white),
        actions: [
          Padding(
            padding: context.paddingSymmetric(horizontal: 12),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExchangeLogsPage()),
              ),
              child: Icon(Icons.history, color: ColorManager.white),
            ),
          ),
        ],
      ),
      body: const ExchangeFormBody(),
    );
  }
}
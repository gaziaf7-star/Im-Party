import 'package:general/src/core/index.dart';

import '../../wallet_withdraw/view/widgets/withdraw_form_body.dart';

/// Wallet withdrawal hub, backed by the saved-payment-method withdrawal API.
/// Named `WalletWithdrawPage` (not `WithdrawScreen`) to avoid any
/// collision with the existing, unrelated host/agency USD withdraw flow
/// already in the app.
///
/// The actual form now lives in [WithdrawFormBody] so it can be reused
/// both here (as a standalone page, still reachable via
/// Routes.walletWithdrawPage) and embedded directly as the "Withdraw" tab
/// inside the Wallet screen's Diamond view -- per request, Withdraw is no
/// longer a separate Profile menu row, it's a tab next to Exchange there.
class WalletWithdrawPage extends StatelessWidget {
  const WalletWithdrawPage({super.key, this.initialTab = 0});

  /// Opens straight on the "Incoming" tab (index 3, Coin Seller only) when
  /// launched from the Coin Seller dashboard's Withdraw button, instead of
  /// always landing on the "Withdraw" (request money) tab.
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        title: StringManager.withdrawal.tr(),
        backgroundColor: Colors.white,
        iconColor: Colors.black,
        titleStyle: context.titleLarge.w600.copyWith(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorManager.primary.withValues(alpha: .08),
              ColorManager.white,
            ],
            stops: const [0, .34],
          ),
        ),
        child: WithdrawFormBody(initialTab: initialTab),
      ),
    );
  }
}

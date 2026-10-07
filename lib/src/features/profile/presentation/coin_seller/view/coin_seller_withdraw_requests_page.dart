import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/wallet_withdraw_models.dart';
import 'package:general/src/features/profile/presentation/wallet_withdraw/bloc/wallet_withdraw_bloc.dart';

/// Dedicated "who sent me a withdraw request" screen for a Coin Seller --
/// on request, this is NOT the full Withdraw hub (no Withdraw/Payment
/// Methods/History tabs, no way to submit a withdraw of their own here),
/// just the incoming-requests list with Accept/Reject, reached straight from
/// the Coin Seller dashboard's AppBar button.
class CoinSellerWithdrawRequestsPage extends StatefulWidget {
  const CoinSellerWithdrawRequestsPage({super.key});

  @override
  State<CoinSellerWithdrawRequestsPage> createState() =>
      _CoinSellerWithdrawRequestsPageState();
}

class _CoinSellerWithdrawRequestsPageState
    extends State<CoinSellerWithdrawRequestsPage> {
  late final WalletWithdrawBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di<WalletWithdrawBloc>()..add(const LoadIncomingWithdrawEvent());
  }

  String _mask(String value) {
    if (value.length <= 4) return value;
    final start = value.substring(0, value.length >= 7 ? 3 : 1);
    final end = value.substring(value.length - 2);
    final hidden = List.filled(value.length - start.length - 2, '•').join();
    return '$start$hidden$end';
  }

  String _title(String value) =>
      value.isEmpty ? '' : '${value[0].toUpperCase()}${value.substring(1).replaceAll('_', ' ')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FA),
      appBar: AppBarWidget(
        title: StringManager.withdrawal.tr(),
        backgroundColor: Colors.white,
        iconColor: Colors.black,
        titleStyle: context.titleLarge.w600.copyWith(color: Colors.black, fontSize: 16),
      ),
      body: BlocConsumer<WalletWithdrawBloc, WalletWithdrawState>(
        bloc: _bloc,
        listenWhen: (a, b) => a.message != b.message,
        listener: (context, state) {
          if (state.message?.isNotEmpty == true) {
            Methods.showToast(context, message: state.message!, isError: state.isError);
            _bloc.add(const ClearWalletWithdrawMessageEvent());
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async => _bloc.add(const LoadIncomingWithdrawEvent()),
            child: state.incoming.isEmpty && !state.incomingState.isLoading
                ? ListView(
                    padding: EdgeInsets.all(16.w),
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inbox_outlined, color: Colors.black87),
                            12.wBox,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    'No withdraw requests',
                                    isTranslate: false,
                                    style: context.bodyMedium.bold.colorExt(Colors.black),
                                  ),
                                  TextWidget(
                                    'Requests sent to you will show up here.',
                                    isTranslate: false,
                                    style: context.bodySmall.colorExt(Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: EdgeInsets.all(16.w),
                    children: [
                      ...state.incoming.map((item) => _RequestCard(
                            item: item,
                            mask: _mask,
                            title: _title,
                            actions: item.status.toLowerCase() == 'pending'
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: state.processState.isLoading
                                              ? null
                                              : () => _bloc.add(ProcessIncomingWithdrawEvent(
                                                    requestId: item.id,
                                                    accept: false,
                                                  )),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: ColorManager.red,
                                            side: BorderSide(color: ColorManager.red),
                                          ),
                                          child: Text(
                                            StringManager.reject.tr(),
                                            style: TextStyle(color: ColorManager.red),
                                          ),
                                        ),
                                      ),
                                      8.wBox,
                                      Expanded(
                                        child: _AcceptButton(
                                          loading: state.processingRequestId == item.id,
                                          onPressed: state.processState.isLoading
                                              ? null
                                              : () => _bloc.add(ProcessIncomingWithdrawEvent(
                                                    requestId: item.id,
                                                    accept: true,
                                                  )),
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          )),
                      if (state.incomingState.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.item,
    required this.mask,
    required this.title,
    this.actions,
  });

  final WithdrawHistoryItem item;
  final String Function(String) mask;
  final String Function(String) title;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final status = item.status.isEmpty ? 'pending' : item.status;
    final color = status.toLowerCase() == 'accepted'
        ? Colors.green
        : status.toLowerCase() == 'rejected'
            ? Colors.red
            : Colors.orange;
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.only(bottom: 10.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: ColorManager.grey2.withValues(alpha: .24)),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextWidget(
                    '${item.amount.round()} coins',
                    isTranslate: false,
                    style: context.bodyLarge.bold.colorExt(Colors.black),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: TextWidget(
                    title(status),
                    isTranslate: false,
                    style: context.bodySmall.copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            8.hBox,
            TextWidget(
              [item.methodName, mask(item.methodAccount)].where((e) => e.isNotEmpty).join(' • '),
              isTranslate: false,
              style: const TextStyle(color: Colors.black),
            ),
            if (item.user != null)
              TextWidget(
                '${item.user!.name} • ID ${item.user!.id}',
                isTranslate: false,
                style: context.bodySmall.colorExt(Colors.black),
              ),
            if (item.createdAt.isNotEmpty)
              TextWidget(
                item.createdAt,
                isTranslate: false,
                style: context.bodySmall.colorExt(Colors.black54),
              ),
            if (actions != null) ...[12.hBox, actions!],
          ],
        ),
      ),
    );
  }
}

class _AcceptButton extends StatelessWidget {
  const _AcceptButton({required this.onPressed, this.loading = false});
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final gradient = ColorManager.primaryGradient ??
        LinearGradient(colors: [ColorManager.primary, ColorManager.primary.withValues(alpha: .72)]);
    return Opacity(
      opacity: onPressed == null ? .5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Ink(
            height: 42.h,
            decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12.r)),
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 18.h,
                      height: 18.h,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : TextWidget(
                      StringManager.accept.tr(),
                      isTranslate: false,
                      style: context.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

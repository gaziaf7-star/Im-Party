import 'package:flutter/services.dart';
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
    required this.title,
    this.actions,
  });

  final WithdrawHistoryItem item;
  final String Function(String) title;
  final Widget? actions;

  static const Color _ink = Color(0xFF16161A);
  static const Color _muted = Color(0xFF6B6C74);

  /// "5 minutes ago · 18 Oct 2026, 8:00 PM" from the API's ISO time.
  String _when() {
    final t = DateTime.tryParse(item.createdAt)?.toLocal();
    if (t == null) return item.createdAt;
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final date =
        '${t.day} ${months[t.month - 1]} ${t.year}, $h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
    return '${Methods.timeAgo(t)} · $date';
  }

  void _copy(BuildContext context, String number) {
    Clipboard.setData(ClipboardData(text: number));
    Methods.showToast(context, message: 'Number copied');
  }

  @override
  Widget build(BuildContext context) {
    final status = item.status.isEmpty ? 'pending' : item.status;
    final color = status.toLowerCase() == 'accepted'
        ? Colors.green
        : status.toLowerCase() == 'rejected'
            ? Colors.red
            : Colors.orange;
    final number = item.methodAccount.trim();
    final method = item.methodName.trim();
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
                    style: context.bodyLarge.bold.colorExt(_ink),
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
                    style: context.bodySmall
                        .copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            12.hBox,
            // Where to send the money: method + full number, copyable.
            Container(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 6.w, 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFFE3E4E8)),
                    ),
                    child: Text(
                      method.isNotEmpty ? method : 'Method —',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  10.wBox,
                  Expanded(
                    child: SelectableText(
                      number.isNotEmpty ? number : 'Number not provided',
                      maxLines: 1,
                      style: TextStyle(
                        color: number.isNotEmpty ? _ink : _muted,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  if (number.isNotEmpty)
                    IconButton(
                      tooltip: 'Copy',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _copy(context, number),
                      icon: Icon(Icons.copy_rounded,
                          size: 20.sp, color: ColorManager.primary),
                    ),
                ],
              ),
            ),
            10.hBox,
            if (item.user != null)
              Row(
                children: [
                  Icon(Icons.person_outline_rounded, size: 15.sp, color: _muted),
                  4.wBox,
                  Expanded(
                    child: TextWidget(
                      '${item.user!.name} • ID ${item.user!.displayId}',
                      isTranslate: false,
                      style: context.bodySmall.colorExt(_ink),
                    ),
                  ),
                ],
              ),
            if (item.createdAt.isNotEmpty) ...[
              4.hBox,
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 15.sp, color: _muted),
                  4.wBox,
                  Expanded(
                    child: TextWidget(
                      _when(),
                      isTranslate: false,
                      style: context.bodySmall.colorExt(_muted),
                    ),
                  ),
                ],
              ),
            ],
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

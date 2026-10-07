import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/wallet_withdraw_models.dart';
import 'package:general/src/features/profile/presentation/wallet_withdraw/bloc/wallet_withdraw_bloc.dart';

class WithdrawFormBody extends StatefulWidget {
  const WithdrawFormBody({super.key, this.showBalanceCard = true, this.initialTab = 0});
  final bool showBalanceCard;
  final int initialTab;

  @override
  State<WithdrawFormBody> createState() => _WithdrawFormBodyState();
}

class _WithdrawFormBodyState extends State<WithdrawFormBody> {
  final _amount = TextEditingController();
  final _sellerSearch = TextEditingController();
  late final WalletWithdrawBloc _bloc;
  late int _tab = widget.initialTab;
  int? _paymentId;
  int? _resellerId;
  String _receivedType = 'admin';

  @override
  void initState() {
    super.initState();
    _bloc = di<WalletWithdrawBloc>()..add(const LoadWalletWithdrawEvent());
    if (_tab == 3) _bloc.add(const LoadIncomingWithdrawEvent());
  }

  @override
  void dispose() {
    _amount.dispose();
    _sellerSearch.dispose();
    super.dispose();
  }

  void _toast(WalletWithdrawState state) {
    if (state.message?.isNotEmpty == true) {
      Methods.showToast(context, message: state.message!, isError: state.isError);
      _bloc.add(const ClearWalletWithdrawMessageEvent());
    }
  }

  WithdrawMethod? _globalMethod(WalletWithdrawState state) {
    UserPaymentMethod? saved;
    for (final item in state.paymentMethods) {
      if (item.id == _paymentId) saved = item;
    }
    if (saved == null) return null;
    for (final method in state.methods) {
      if (method.name.trim().toLowerCase() == saved.methodName.trim().toLowerCase()) return method;
    }
    return null;
  }

  void _submit(WalletWithdrawState state) {
    if (!state.systemOn) return;
    final amount = num.tryParse(_amount.text.trim()) ?? 0;
    final method = _globalMethod(state);
    Methods.printLog(
      '💸 [Withdraw] amount=$amount earnedCoins=${state.earnedCoins} '
      'methodId=$_paymentId receivedType=$_receivedType resellerId=$_resellerId '
      'methodMin=${method?.minimumCoin} methodMax=${method?.maximumCoin}',
    );
    String? error;
    if (_paymentId == null) error = StringManager.pleaseSelectPaymentMethod.tr();
    else if (method == null) error = 'Selected payment method is unavailable';
    else if (amount <= 0) error = StringManager.invalidAmount.tr();
    else if (method != null && amount < method.minimumCoin) error = '${StringManager.minWithdraw.tr()}: ${method.minimumCoin}';
    else if (method != null && method.maximumCoin > 0 && amount > method.maximumCoin) error = '${StringManager.maxWithdraw.tr()}: ${method.maximumCoin}';
    // Was a local "amount > earnedCoins" block -- removed on request, the
    // server (/withdrow_create) is the source of truth for balance checks.
    else if (_receivedType == 'reseller' && _resellerId == null) error = StringManager.pleaseSelectCoinSeller.tr();
    if (error != null) {
      Methods.showToast(context, message: error, isError: true);
      return;
    }
    FocusScope.of(context).unfocus();
    _bloc.add(SubmitWalletWithdrawEvent(methodId: _paymentId!, amount: amount, receivedType: _receivedType, resellerId: _receivedType == 'reseller' ? _resellerId : null));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletWithdrawBloc, WalletWithdrawState>(
      bloc: _bloc,
      listenWhen: (a, b) => a.message != b.message || a.submitState != b.submitState,
      listener: (context, state) {
        if (state.submitState.isLoaded) _amount.clear();
        _toast(state);
      },
      builder: (context, state) {
        final isCoinSeller = StringManager.isCoinSeller || StringManager.userType[7] == true;
        final tabs = ['Withdraw', 'Payment Methods', 'History', if (isCoinSeller) 'Incoming'];
        return Column(
          children: [
            if (widget.showBalanceCard) _BalanceCard(balance: state.earnedCoins),
            _Tabs(labels: tabs, selected: _tab, onChanged: (i) { setState(() => _tab = i); if (i == 3) _bloc.add(const LoadIncomingWithdrawEvent()); }),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _WithdrawPane(state: state, amount: _amount, sellerSearch: _sellerSearch, paymentId: _paymentId, receivedType: _receivedType, resellerId: _resellerId, globalMethod: _globalMethod(state), onPaymentChanged: (v) => setState(() => _paymentId = v), onTypeChanged: (v) { setState(() { _receivedType = v; if (v == 'admin') _resellerId = null; }); if (v == 'reseller') _bloc.add(const LoadResellersEvent()); }, onResellerChanged: (v) => setState(() => _resellerId = v), onSubmit: () => _submit(state)),
                  _PaymentMethodsPane(state: state, bloc: _bloc),
                  _HistoryPane(state: state, bloc: _bloc),
                  if (isCoinSeller) _IncomingPane(state: state, bloc: _bloc),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});
  final num balance;
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 14, 16, 10), padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ColorManager.grey2.withValues(alpha: .22)), boxShadow: [BoxShadow(color: ColorManager.primary.withValues(alpha: .12), blurRadius: 18, offset: const Offset(0, 7))]),
    child: Row(children: [Container(width: 5, height: 44, decoration: BoxDecoration(gradient: _primaryGradient, borderRadius: BorderRadius.circular(8))), const SizedBox(width: 12), Container(width: 44, height: 44, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: ColorManager.primary.withValues(alpha: .1), shape: BoxShape.circle), child: Image.asset(AssetsManager.coinsIcon, fit: BoxFit.contain, filterQuality: FilterQuality.high)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Earned Coins', style: context.bodySmall.copyWith(color: Colors.black)), const SizedBox(height: 3), Text('${balance.round()}', style: context.titleLarge.bold.copyWith(color: Colors.black, fontSize: 25))]))]),
  );
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.labels, required this.selected, required this.onChanged});
  final List<String> labels; final int selected; final ValueChanged<int> onChanged;
  @override Widget build(BuildContext context) => SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Row(children: List.generate(labels.length, (i) { final active = selected == i; return Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: InkWell(onTap: () => onChanged(i), borderRadius: BorderRadius.circular(22), child: Ink(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(gradient: active ? _primaryGradient : null, color: active ? null : ColorManager.grey2.withValues(alpha: .1), borderRadius: BorderRadius.circular(22), boxShadow: active ? [BoxShadow(color: ColorManager.primary.withValues(alpha: .18), blurRadius: 10, offset: const Offset(0, 4))] : null), child: Text(labels[i], style: context.bodySmall.copyWith(color: Colors.black, fontWeight: FontWeight.w700))))); })));
}

class _WithdrawPane extends StatelessWidget {
  const _WithdrawPane({required this.state, required this.amount, required this.sellerSearch, required this.paymentId, required this.receivedType, required this.resellerId, required this.globalMethod, required this.onPaymentChanged, required this.onTypeChanged, required this.onResellerChanged, required this.onSubmit});
  final WalletWithdrawState state; final TextEditingController amount, sellerSearch; final int? paymentId, resellerId; final String receivedType; final WithdrawMethod? globalMethod; final ValueChanged<int?> onPaymentChanged, onResellerChanged; final ValueChanged<String> onTypeChanged; final VoidCallback onSubmit;
  @override Widget build(BuildContext context) => RefreshIndicator(onRefresh: () async => di<WalletWithdrawBloc>().add(const LoadWalletWithdrawEvent()), child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
    if (!state.systemOn) _InfoCard(icon: Icons.lock_outline_rounded, title: 'Withdrawal is currently unavailable', subtitle: 'Payment methods and history remain available.'),
    _Section(title: 'Saved Payment Method', child: DropdownButtonFormField<int>(initialValue: paymentId, isExpanded: true, style: const TextStyle(color: Colors.black), dropdownColor: Colors.white, decoration: _input('Select a saved payment method'), items: state.paymentMethods.map((m) => DropdownMenuItem(value: m.id, child: Text('${m.methodName}  •  ${_mask(m.methodAccount)}', overflow: TextOverflow.ellipsis))).toList(), onChanged: state.systemOn ? onPaymentChanged : null)),
    if (state.paymentMethods.isEmpty) const _InfoCard(icon: Icons.account_balance_wallet_outlined, title: 'No payment methods yet', subtitle: 'Add one from the Payment Methods tab.'),
    if (globalMethod != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Expanded(child: _Limit(label: 'Minimum', value: globalMethod!.minimumCoin)), const SizedBox(width: 10), Expanded(child: _Limit(label: 'Maximum', value: globalMethod!.maximumCoin))])),
    _Section(title: 'Amount', child: TextField(controller: amount, enabled: state.systemOn, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], style: const TextStyle(color: Colors.black), cursorColor: ColorManager.primary, decoration: _input('Enter earned coins'))),
    _Section(title: 'Process With', child: Row(children: [Expanded(child: _SelectCard(label: 'Admin', selected: receivedType == 'admin', onTap: () => onTypeChanged('admin'))), const SizedBox(width: 10), Expanded(child: _SelectCard(label: 'Coin Seller', selected: receivedType == 'reseller', onTap: () => onTypeChanged('reseller')))])),
    if (receivedType == 'reseller') _Section(title: 'Coin Seller', child: state.resellerState.isLoading ? const Center(child: CircularProgressIndicator()) : ValueListenableBuilder<TextEditingValue>(valueListenable: sellerSearch, builder: (context, value, _) { final q = value.text.trim().toLowerCase(); final sellers = state.resellers.where((s) => q.isEmpty || s.name.toLowerCase().contains(q) || s.id.toString().contains(q)).toList(); return Column(children: [if (state.resellers.length > 12) ...[TextField(controller: sellerSearch, style: const TextStyle(color: Colors.black), cursorColor: ColorManager.primary, decoration: _input('Search sellers')), const SizedBox(height: 8)], DropdownButtonFormField<int>(initialValue: sellers.any((s) => s.id == resellerId) ? resellerId : null, isExpanded: true, style: const TextStyle(color: Colors.black), dropdownColor: Colors.white, decoration: _input('Select Coin Seller'), items: sellers.map((s) => DropdownMenuItem(value: s.id, child: Row(children: [ImageViewWidget(url: s.image, displayName: s.name, width: 28, height: 28, radius: 20, padding: EdgeInsetsDirectional.zero), const SizedBox(width: 8), Expanded(child: Text('${s.name}  •  ID ${s.id}', overflow: TextOverflow.ellipsis))]))).toList(), onChanged: onResellerChanged)]); })),
    const SizedBox(height: 8), ButtonWidget(title: 'Withdraw', titleColor: Colors.black, height: 50, radius: 14, isLoading: state.submitState.isLoading, onPressed: !state.systemOn || state.submitState.isLoading ? null : onSubmit),
  ]));
}

class _PaymentMethodsPane extends StatelessWidget {
  const _PaymentMethodsPane({required this.state, required this.bloc}); final WalletWithdrawState state; final WalletWithdrawBloc bloc;
  @override Widget build(BuildContext context) => RefreshIndicator(onRefresh: () async => bloc.add(const RefreshPaymentMethodsEvent()), child: ListView(padding: const EdgeInsets.all(16), children: [
    Row(children: [Expanded(child: Text('My Payment Methods', style: context.bodyLarge.bold.copyWith(color: Colors.black))), _GradientAction(label: 'Add', icon: Icons.add, onPressed: state.methods.isEmpty ? null : () => _paymentSheet(context, state, bloc))]), const SizedBox(height: 12),
    if (state.paymentState.isLoading) const LinearProgressIndicator(),
    if (state.paymentMethods.isEmpty) const _InfoCard(icon: Icons.credit_card_off_outlined, title: 'No payment methods yet', subtitle: 'Add an admin-supported method to withdraw.'),
    ...state.paymentMethods.map((m) => Card(margin: const EdgeInsets.only(bottom: 10), elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: ListTile(textColor: Colors.black, iconColor: Colors.black87, contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8), leading: CircleAvatar(backgroundColor: ColorManager.primary.withValues(alpha: .12), child: Padding(padding: const EdgeInsets.all(8), child: Image.asset(AssetsManager.coinPayment, fit: BoxFit.contain, filterQuality: FilterQuality.high))), title: Text(m.methodName, style: context.bodyMedium.bold.copyWith(color: Colors.black)), subtitle: Text(_mask(m.methodAccount), style: const TextStyle(color: Colors.black)), trailing: Wrap(spacing: 0, children: [IconButton(tooltip: 'Edit', onPressed: () => _paymentSheet(context, state, bloc, existing: m), icon: const Icon(Icons.edit_outlined, color: Colors.black87)), IconButton(tooltip: 'Delete', onPressed: () => _confirmDelete(context, bloc, m), icon: Icon(Icons.delete_outline, color: ColorManager.red))])))),
  ]));
}

Future<void> _paymentSheet(BuildContext context, WalletWithdrawState state, WalletWithdrawBloc bloc, {UserPaymentMethod? existing}) async {
  final account = TextEditingController(text: existing?.methodAccount ?? '');
  String? name = state.methods.any((m) => m.name == existing?.methodName)
      ? existing?.methodName
      : null;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              existing == null ? 'Add Payment Method' : 'Edit Payment Method',
              style: context.titleLarge.bold.copyWith(color: Colors.black),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: name,
              isExpanded: true,
              style: const TextStyle(color: Colors.black),
              dropdownColor: Colors.white,
              decoration: _input('Payment method'),
              items: state.methods
                  .map((m) => DropdownMenuItem(
                        value: m.name,
                        child: Text(m.name),
                      ))
                  .toList(),
              onChanged: (value) => setSheetState(() => name = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: account,
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.black),
              cursorColor: ColorManager.primary,
              decoration: _input('Method account'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: _GradientAction(
                label: existing == null
                    ? 'Save Payment Method'
                    : 'Update Payment Method',
                onPressed: () {
                  if (name == null || account.text.trim().isEmpty) return;
                  bloc.add(SavePaymentMethodEvent(
                    id: existing?.id,
                    methodName: name!,
                    methodAccount: account.text.trim(),
                  ));
                  Navigator.pop(sheetContext);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
  account.dispose();
}

Future<void> _confirmDelete(BuildContext context, WalletWithdrawBloc bloc, UserPaymentMethod method) async {
  final yes = await showDialog<bool>(context: context, builder: (context) => AlertDialog(backgroundColor: Colors.white, title: const Text('Delete payment method?', style: TextStyle(color: Colors.black)), content: Text('${method.methodName} ${_mask(method.methodAccount)} will be removed.', style: const TextStyle(color: Colors.black)), actions: [TextButton(style: TextButton.styleFrom(foregroundColor: Colors.black), onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(style: FilledButton.styleFrom(backgroundColor: ColorManager.red, foregroundColor: Colors.white), onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))]));
  if (yes == true) bloc.add(DeletePaymentMethodEvent(method.id));
}

class _HistoryPane extends StatelessWidget {
  const _HistoryPane({required this.state, required this.bloc});
  final WalletWithdrawState state;
  final WalletWithdrawBloc bloc;

  @override
  Widget build(BuildContext context) {
    void refresh() => bloc.add(LoadHistoryEvent(
          status: state.historyStatus,
          receivedType: state.historyReceivedType,
        ));
    return RefreshIndicator(
      onRefresh: () async => refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Withdrawal History', style: context.bodyLarge.bold.copyWith(color: Colors.black)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            children: <String?>[null, 'pending', 'accepted', 'rejected']
                .map((value) => _GradientFilter(
                      label: value == null ? 'All' : _title(value),
                      selected: state.historyStatus == value,
                      onTap: () => bloc.add(LoadHistoryEvent(
                        status: value,
                        receivedType: state.historyReceivedType,
                      )),
                    ))
                .toList(),
          ),
          Wrap(
            spacing: 7,
            children: <String?>[null, 'admin', 'reseller']
                .map((value) => _GradientFilter(
                      label: value == null
                          ? 'All'
                          : value == 'admin'
                              ? 'Admin'
                              : 'Coin Seller',
                      selected: state.historyReceivedType == value,
                      onTap: () => bloc.add(LoadHistoryEvent(
                        status: state.historyStatus,
                        receivedType: value,
                      )),
                    ))
                .toList(),
          ),
          if (state.history.isEmpty && !state.historyState.isLoading)
            const _InfoCard(
              icon: Icons.receipt_long_outlined,
              title: 'No withdrawal history',
              subtitle: 'Your requests will appear here.',
            ),
          ...state.history.map((item) => _RequestCard(item: item)),
          if (state.historyState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (state.historyPage < state.historyLastPage)
            TextButton(
              onPressed: () => bloc.add(LoadHistoryEvent(
                status: state.historyStatus,
                receivedType: state.historyReceivedType,
                loadMore: true,
              )),
              child: const Text('Load more', style: TextStyle(color: Colors.black)),
            ),
        ],
      ),
    );
  }
}

class _IncomingPane extends StatelessWidget {
  const _IncomingPane({required this.state, required this.bloc});
  final WalletWithdrawState state;
  final WalletWithdrawBloc bloc;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () async => bloc.add(const LoadIncomingWithdrawEvent()),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Incoming Requests', style: context.bodyLarge.bold.copyWith(color: Colors.black)),
            const SizedBox(height: 12),
            if (state.incoming.isEmpty && !state.incomingState.isLoading)
              const _InfoCard(
                icon: Icons.inbox_outlined,
                title: 'No incoming requests',
                subtitle: 'Assigned withdrawal requests will appear here.',
              ),
            ...state.incoming.map((item) => _RequestCard(
                  item: item,
                  actions: item.status.toLowerCase() == 'pending'
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: state.processState.isLoading
                                    ? null
                                    : () => bloc.add(
                                          ProcessIncomingWithdrawEvent(
                                            requestId: item.id,
                                            accept: false,
                                          ),
                                        ),
                                style: OutlinedButton.styleFrom(foregroundColor: ColorManager.red, side: BorderSide(color: ColorManager.red)),
                                child: Text('Reject', style: TextStyle(color: ColorManager.red)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _GradientAction(
                                onPressed: state.processState.isLoading
                                    ? null
                                    : () => bloc.add(
                                          ProcessIncomingWithdrawEvent(
                                            requestId: item.id,
                                            accept: true,
                                          ),
                                        ),
                                label: 'Accept',
                                loading: state.processingRequestId == item.id,
                              ),
                            ),
                          ],
                        )
                      : null,
                )),
            if (state.incomingState.isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.item, this.actions}); final WithdrawHistoryItem item; final Widget? actions;
  @override Widget build(BuildContext context) { final color = item.status.toLowerCase() == 'accepted' ? Colors.green : item.status.toLowerCase() == 'rejected' ? Colors.red : Colors.orange; return Card(color: Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: ColorManager.grey2.withValues(alpha: .24))), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text('${item.amount.round()} coins', style: context.bodyLarge.bold.copyWith(color: Colors.black))), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)), child: Text(_title(item.status.isEmpty ? 'pending' : item.status), style: context.bodySmall.copyWith(color: color, fontWeight: FontWeight.w700)))]), const SizedBox(height: 8), Text([item.methodName, _mask(item.methodAccount)].where((e) => e.isNotEmpty).join(' • '), style: const TextStyle(color: Colors.black)), Text('${_title(item.receivedType)}${item.createdAt.isEmpty ? '' : ' • ${item.createdAt}'}', style: context.bodySmall.copyWith(color: Colors.black54)), if (item.user != null) Text('${item.user!.name} • ID ${item.user!.id}', style: context.bodySmall.copyWith(color: Colors.black)), if (actions != null) ...[const SizedBox(height: 12), actions!]]))); }
}

class _Section extends StatelessWidget { const _Section({required this.title, required this.child}); final String title; final Widget child; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: context.bodyMedium.bold.copyWith(color: Colors.black)), const SizedBox(height: 8), child])); }
class _Limit extends StatelessWidget { const _Limit({required this.label, required this.value}); final String label; final num value; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: context.bodySmall.copyWith(color: Colors.black)), Text('${value.round()}', style: context.bodyMedium.bold.copyWith(color: Colors.black))])); }
class _SelectCard extends StatelessWidget { const _SelectCard({required this.label, required this.selected, required this.onTap}); final String label; final bool selected; final VoidCallback onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? ColorManager.primary : ColorManager.grey2.withValues(alpha: .35))), child: Center(child: Text(label, style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: Colors.black))))); }
class _InfoCard extends StatelessWidget { const _InfoCard({required this.icon, required this.title, required this.subtitle}); final IconData icon; final String title, subtitle; @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(icon, color: Colors.black87), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: context.bodyMedium.bold.copyWith(color: Colors.black)), Text(subtitle, style: context.bodySmall.copyWith(color: Colors.black54))]))])); }

class _GradientAction extends StatelessWidget {
  const _GradientAction({required this.label, required this.onPressed, this.icon, this.loading = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  @override Widget build(BuildContext context) => Opacity(opacity: onPressed == null ? .5 : 1, child: Material(color: Colors.transparent, child: InkWell(onTap: onPressed, borderRadius: BorderRadius.circular(12), child: Ink(height: 42, padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(gradient: _primaryGradient, borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [if (loading) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) else ...[if (icon != null) ...[Icon(icon, size: 18, color: Colors.black), const SizedBox(width: 6)], Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.bodyMedium.copyWith(color: Colors.black, fontWeight: FontWeight.w700))]])))));
}

class _GradientFilter extends StatelessWidget {
  const _GradientFilter({required this.label, required this.selected, required this.onTap});
  final String label; final bool selected; final VoidCallback onTap;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 7), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Ink(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(gradient: selected ? _primaryGradient : null, color: selected ? null : ColorManager.grey2.withValues(alpha: .1), borderRadius: BorderRadius.circular(20)), child: Text(label, style: context.bodySmall.copyWith(color: Colors.black, fontWeight: FontWeight.w600)))));
}

Gradient get _primaryGradient => ColorManager.primaryGradient ?? LinearGradient(colors: [ColorManager.primary, ColorManager.primary.withValues(alpha: .72)]);
InputDecoration _input(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.black54), labelStyle: const TextStyle(color: Colors.black87), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorManager.grey2.withValues(alpha: .35))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorManager.primary, width: 1.4)), disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorManager.grey2.withValues(alpha: .2))));
String _mask(String value) { if (value.length <= 4) return value; final start = value.substring(0, value.length >= 7 ? 3 : 1); final end = value.substring(value.length - 2); final hidden = List.filled(value.length - start.length - 2, '•').join(); return '$start$hidden$end'; }
String _title(String value) => value.isEmpty ? '' : '${value[0].toUpperCase()}${value.substring(1).replaceAll('_', ' ')}';

import 'dart:io';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/data/model/manual_payment_models.dart';
import 'package:general/src/features/payment/data/remotely_data_source/manual_payment_api.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

import 'manual_recharge_history_page.dart';
import 'manual_recharge_widgets.dart';

/// Manual recharge: pick a coin bundle, pick bKash/Nagad/..., send the money
/// to the shown number, then submit the TrxID (+ screenshot). An admin
/// approves it and the coins are added.
class ManualRechargePage extends StatefulWidget {
  /// Sent as `recharge_type`: 'user' (normal) or 'coinseller'.
  final String rechargeType;

  const ManualRechargePage({super.key, this.rechargeType = 'user'});

  @override
  State<ManualRechargePage> createState() => _ManualRechargePageState();
}

class _ManualRechargePageState extends State<ManualRechargePage> {
  final _api = ManualPaymentApi();
  final _picker = ImagePicker();
  final _form = GlobalKey<FormState>();
  final _sender = TextEditingController();
  final _trx = TextEditingController();
  final _name = TextEditingController();

  bool _loading = true;
  String? _error;
  bool _submitting = false;

  /// Screenshot upload progress 0..1 (0 while nothing is being sent).
  double _progress = 0;

  List<ManualPaymentPackage> _allPackages = const [];
  List<ManualPaymentMethod> _methods = const [];
  ManualPaymentPackage? _package;
  ManualPaymentMethod? _method;
  File? _screenshot;

  /// Coin sellers open on the Seller tab; everyone else on the User tab.
  /// Both tabs are always shown.
  bool get _isSeller =>
      widget.rechargeType == 'coinseller' || StringManager.isCoinSeller;

  late bool _sellerTab = _isSeller;

  List<ManualPaymentPackage> get _packages =>
      _allPackages.where((p) => p.isForCoinSeller == _sellerTab).toList();

  String get _rechargeType => _sellerTab ? 'coinseller' : 'user';

  void _selectTab(bool seller) {
    if (seller == _sellerTab) return;
    setState(() {
      _sellerTab = seller;
      _package = _packages.firstOrNull;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _sender.dispose();
    _trx.dispose();
    _name.dispose();
    super.dispose();
  }

  /// First load shows the skeleton; a pull-to-refresh keeps the form on
  /// screen (and whatever the user typed) and only swaps the data.
  bool _loaded = false;

  Future<void> _load() async {
    if (!_loaded) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final results = await Future.wait([_api.packages(), _api.methods()]);
      if (!mounted) return;
      setState(() {
        _allPackages = results[0] as List<ManualPaymentPackage>;
        _methods = results[1] as List<ManualPaymentMethod>;
        // Keep the user's picks across a refresh when they still exist.
        _package = _packages.where((p) => p.id == _package?.id).firstOrNull ??
            _packages.firstOrNull;
        _method = _methods.where((m) => m.id == _method?.id).firstOrNull ??
            _methods.firstOrNull;
        _loading = false;
        _loaded = true;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (_loaded) {
        Methods.showToast(context, message: e.toString(), isError: true);
        return;
      }
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _pickScreenshot() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _screenshot = File(picked.path));
      }
    } catch (_) {
      if (mounted) {
        Methods.showToast(context,
            message: 'Could not open the gallery', isError: true);
      }
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_package == null) {
      Methods.showToast(context, message: 'Choose a package first', isError: true);
      return;
    }
    if (_method == null) {
      Methods.showToast(context,
          message: 'Choose a payment method first', isError: true);
      return;
    }
    if (!(_form.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _progress = 0;
    });
    try {
      final message = await _api.submit(
        methodId: _method!.id,
        package: _package!,
        senderNumber: _sender.text,
        userTrxId: _trx.text,
        senderName: _name.text,
        screenshot: _screenshot,
        rechargeType: _rechargeType,
        onUploadProgress: (sent, total) {
          if (!mounted || total <= 0) return;
          setState(() => _progress = sent / total);
        },
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      _sender.clear();
      _trx.clear();
      _name.clear();
      setState(() => _screenshot = null);
      di<MyStoreBloc>().add(const GetMyStoreEvent(isLoading: false));
      _showSuccess(message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      Methods.showToast(context, message: e.toString(), isError: true);
    }
  }

  void _openHistory() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ManualRechargeHistoryPage()),
      );

  void _showSuccess(String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SuccessSheet(
        message: message,
        onHistory: () {
          Navigator.pop(ctx);
          _openHistory();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MR.bg,
      appBar: AppBarWidget(
        backgroundColor: Colors.white,
        iconColor: MR.ink,
        title: 'Seller',
        titleStyle: context.bodyMedium.size(19).w800.colorExt(MR.ink),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: _openHistory,
            icon: Icon(Icons.receipt_long_rounded, color: MR.ink, size: 24.sp),
          ),
          4.wBox,
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _loading
              ? const _LoadingSkeleton(key: ValueKey('loading'))
              : _error != null
                  ? Center(
                      key: const ValueKey('error'),
                      child: MRMessage(
                        icon: Icons.wifi_off_rounded,
                        title: 'Couldn\'t load recharge options',
                        subtitle: _error,
                        action: 'Try again',
                        onAction: _load,
                      ),
                    )
                  : _content(),
        ),
      ),
      bottomNavigationBar:
          _loading || _error != null || _packages.isEmpty || _methods.isEmpty
              ? null
              : _submitBar(),
    );
  }

  Widget _content() {
    return RefreshIndicator(
      key: const ValueKey('content'),
      color: MR.pink,
      onRefresh: _load,
      child: Form(
        key: _form,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
          children: [
            const _HowItWorks().entrance(0),
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  _TypeTab(
                    label: 'User',
                    selected: !_sellerTab,
                    onTap: () => _selectTab(false),
                  ),
                  8.wBox,
                  _TypeTab(
                    label: 'Seller',
                    selected: _sellerTab,
                    onTap: () => _selectTab(true),
                  ),
                ],
              ),
            ),
            MRCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MRStepTitle(step: 1, title: 'Choose a package'),
                  _packages.isEmpty
                      ? MRMessage(
                          icon: Icons.inventory_2_outlined,
                          title: 'No packages yet',
                          subtitle: _sellerTab
                              ? 'Coin seller packages will show up here soon.'
                              : 'Recharge packages will show up here soon.',
                        )
                      : _packageGrid(),
                ],
              ),
            ).entrance(1),
            MRCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MRStepTitle(step: 2, title: 'Choose payment method'),
                  _methods.isEmpty
                      ? const MRMessage(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'No payment methods yet',
                          subtitle: 'Please check back a little later.',
                        )
                      : _methodPicker(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SizeTransition(
                        sizeFactor: anim,
                        alignment: Alignment.topCenter,
                        child: child,
                      ),
                    ),
                    child: _method == null
                        ? const SizedBox(width: double.infinity)
                        : _AccountBox(
                            key: ValueKey(_method!.id),
                            method: _method!,
                            package: _package,
                          ),
                  ),
                ],
              ),
            ).entrance(2),
            if (_packages.isNotEmpty && _methods.isNotEmpty)
              MRCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MRStepTitle(step: 3, title: 'Send payment proof'),
                    _field(
                      controller: _sender,
                      label: 'Your sender number',
                      hint: 'The number you paid from',
                      icon: Icons.phone_iphone_rounded,
                      keyboard: TextInputType.phone,
                      formatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                      ],
                      validator: (v) => (v ?? '').trim().length < 6
                          ? 'Enter the number you sent money from'
                          : null,
                    ),
                    12.hBox,
                    _field(
                      controller: _trx,
                      label: 'Transaction ID (TrxID)',
                      hint: 'e.g. 9JK4L2M8QX',
                      icon: Icons.tag_rounded,
                      capitalization: TextCapitalization.characters,
                      formatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      validator: (v) => (v ?? '').trim().length < 4
                          ? 'Enter the TrxID from your payment SMS'
                          : null,
                    ),
                    12.hBox,
                    _field(
                      controller: _name,
                      label: 'Your name (optional)',
                      hint: 'Account holder name',
                      icon: Icons.person_outline_rounded,
                      capitalization: TextCapitalization.words,
                    ),
                    14.hBox,
                    _screenshotBox(),
                  ],
                ),
              ).entrance(3),
          ],
        ),
      ),
    );
  }

  Widget _packageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _packages.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 1.08,
      ),
      itemBuilder: (context, i) {
        final p = _packages[i];
        return _PackageTile(
          package: p,
          selected: _package?.id == p.id,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _package = p);
          },
        )
            .animate(delay: Duration(milliseconds: 40 * i))
            .fadeIn(duration: const Duration(milliseconds: 260))
            .scaleXY(begin: .92, end: 1, curve: Curves.easeOutBack);
      },
    );
  }

  Widget _methodPicker() {
    return SizedBox(
      height: 46.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _methods.length,
        separatorBuilder: (_, __) => 10.wBox,
        itemBuilder: (context, i) {
          final m = _methods[i];
          final selected = _method?.id == m.id;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _method = m);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: selected ? MR.pinkSoft : MR.field,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: selected ? MR.pink : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MethodLogo(method: m, size: 26.w),
                  8.wBox,
                  Text(
                    m.name,
                    style: TextStyle(
                      color: selected ? MR.pink : MR.ink,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    child: selected
                        ? Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: Icon(Icons.check_circle_rounded,
                                color: MR.pink, size: 16.sp),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboard,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: c, width: w),
        );
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      textCapitalization: capitalization,
      inputFormatters: formatters,
      validator: validator,
      textInputAction: TextInputAction.next,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: MR.pink,
      style: TextStyle(
        color: MR.ink,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: MR.muted, fontSize: 14.sp),
        floatingLabelStyle: TextStyle(color: MR.pink, fontSize: 14.sp),
        hintStyle: TextStyle(color: const Color(0xFFB5B6BC), fontSize: 13.sp),
        prefixIcon: Icon(icon, color: MR.muted, size: 20.sp),
        filled: true,
        fillColor: MR.field,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(MR.pink, 1.5),
        errorBorder: border(const Color(0xFFE5484D)),
        focusedErrorBorder: border(const Color(0xFFE5484D), 1.5),
      ),
    );
  }

  Widget _screenshotBox() {
    final file = _screenshot;
    return GestureDetector(
      onTap: _pickScreenshot,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: file == null ? 104.h : 180.h,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: MR.field,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: MR.line),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: file == null
              ? Column(
                  key: const ValueKey('empty'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_rounded,
                        color: MR.pink, size: 32.sp),
                    6.hBox,
                    Text(
                      'Add payment screenshot',
                      style: TextStyle(
                        color: MR.ink,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    2.hBox,
                    Text(
                      'Optional · helps approve faster',
                      style: TextStyle(color: MR.muted, fontSize: 11.sp),
                    ),
                  ],
                )
              : Stack(
                  key: ValueKey(file.path),
                  fit: StackFit.expand,
                  children: [
                    Image.file(file, fit: BoxFit.cover),
                    Positioned(
                      right: 8.w,
                      top: 8.h,
                      child: GestureDetector(
                        onTap: () => setState(() => _screenshot = null),
                        child: Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded,
                              color: Colors.white, size: 16.sp),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8.w,
                      bottom: 8.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Tap to change',
                          style:
                              TextStyle(color: Colors.white, fontSize: 11.sp),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _submitBar() {
    final p = _package;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
        child: GestureDetector(
          onTap: _submitting ? null : _submit,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _submitting ? .7 : 1,
            child: Container(
              height: 58.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                gradient: const LinearGradient(colors: MR.button),
                boxShadow: [
                  BoxShadow(
                    color: MR.button.last.withValues(alpha: .3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _submitting
                    ? SizedBox(
                        key: const ValueKey('busy'),
                        width: 24.w,
                        height: 24.w,
                        child: CircularProgressIndicator(
                          value: _progress > 0 && _progress < 1
                              ? _progress
                              : null,
                          color: Colors.white,
                          strokeWidth: 2.6,
                        ),
                      )
                    : Column(
                        key: const ValueKey('idle'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Submit · Get ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Image.asset(AssetsManager.coinsVip, height: 18.h),
                              4.wBox,
                              Text(
                                p == null ? '--' : '${p.totalCoins}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          if (p != null)
                            Text(
                              'You pay ${MR.money(p.price, p.currency)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .9),
                                fontSize: 13.sp,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small left-aligned pill tab: Seller / User packages.
class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? MR.pink : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: selected ? MR.pink : Colors.black12),
        ),
        child: Text(
          label,
          style: context.bodyMedium
              .size(13)
              .w700
              .colorExt(selected ? Colors.white : MR.ink),
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    Widget step(IconData icon, String text) => Expanded(
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22.sp),
              4.hBox,
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        );
    Widget arrow() => Icon(Icons.chevron_right_rounded,
        color: Colors.white.withValues(alpha: .7), size: 18.sp);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: MR.brand,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          step(Icons.diamond_outlined, 'Pick a\npackage'),
          arrow(),
          step(Icons.send_to_mobile_rounded, 'Send\nmoney'),
          arrow(),
          step(Icons.fact_check_outlined, 'Submit\nTrxID'),
          arrow(),
          step(Icons.verified_rounded, 'Coins\nadded'),
        ],
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({
    required this.package,
    required this.selected,
    required this.onTap,
  });
  final ManualPaymentPackage package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = package;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: selected ? 1.03 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? MR.pinkSoft : MR.field,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? MR.pink : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
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
                              '${p.coins}',
                              style: TextStyle(
                                color: MR.ink,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (p.bonusCoins > 0)
                        Text(
                          '+${p.bonusCoins} bonus',
                          style: TextStyle(
                            color: MR.gold,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      4.hBox,
                      Text(
                        MR.money(p.price, p.currency),
                        style: TextStyle(
                          color: selected ? MR.pink : MR.muted,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (p.name.isNotEmpty)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 80.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: selected ? MR.pink : const Color(0xFFDADBE1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(11.r),
                        bottomRight: Radius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : MR.ink,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (selected)
                Positioned(
                  right: 6.w,
                  bottom: 6.h,
                  child: Icon(Icons.check_circle_rounded,
                          color: MR.pink, size: 16.sp)
                      .animate()
                      .scale(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo from the server, or a coloured initial when there is none.
class _MethodLogo extends StatelessWidget {
  const _MethodLogo({required this.method, required this.size});
  final ManualPaymentMethod method;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (method.logo.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: ImageViewWidget(url: method.logo, boxFit: BoxFit.contain),
      );
    }
    final n = method.name.toLowerCase();
    final color = n.contains('bkash')
        ? const Color(0xFFE2136E)
        : n.contains('nagad')
            ? const Color(0xFFF6921E)
            : n.contains('rocket')
                ? const Color(0xFF8C3494)
                : const Color(0xFF3B82F6);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        method.name.isEmpty ? '?' : method.name[0].toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * .5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Where to send the money: account number (copy), amount and QR code.
class _AccountBox extends StatelessWidget {
  const _AccountBox({super.key, required this.method, required this.package});
  final ManualPaymentMethod method;
  final ManualPaymentPackage? package;

  void _showQr(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Scan to pay with ${method.name}',
                style: TextStyle(
                  color: MR.ink,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              14.hBox,
              ImageViewWidget(
                url: method.qrCodeUrl,
                width: 240.w,
                height: 240.w,
                boxFit: BoxFit.contain,
              ),
              14.hBox,
              Text(
                method.accountNumber,
                style: TextStyle(
                  color: MR.ink,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(
            begin: const Offset(.9, .9),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = method;
    final p = package;
    return Container(
      margin: EdgeInsets.only(top: 14.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: MR.field,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: MR.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MethodLogo(method: m, size: 32.w),
              10.wBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send money to this ${m.name} number',
                      style: TextStyle(color: MR.muted, fontSize: 12.sp),
                    ),
                    2.hBox,
                    SelectableText(
                      m.accountNumber.isEmpty ? '—' : m.accountNumber,
                      maxLines: 1,
                      style: TextStyle(
                        color: MR.ink,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .8,
                      ),
                    ),
                  ],
                ),
              ),
              if (m.accountNumber.isNotEmpty)
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Copy number',
                    onPressed: () =>
                        MR.copy(context, m.accountNumber, 'Number'),
                    icon: Icon(Icons.copy_rounded, color: MR.pink, size: 20.sp),
                  ),
                ),
            ],
          ),
          10.hBox,
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              if (m.accountType.isNotEmpty)
                _chip(Icons.badge_outlined, m.accountType),
              if (p != null)
                _chip(Icons.payments_outlined,
                    'Send exactly ${MR.money(p.price, p.currency)}',
                    strong: true),
              _chip(Icons.swap_horiz_rounded,
                  m.accountType.toLowerCase() == 'agent'
                      ? 'Use Cash Out'
                      : 'Use Send Money'),
            ],
          ),
          if (m.instructions.isNotEmpty) ...[
            10.hBox,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: MR.muted, size: 16.sp),
                6.wBox,
                Expanded(
                  child: Text(
                    m.instructions,
                    style: TextStyle(
                        color: MR.muted, fontSize: 12.sp, height: 1.4),
                  ),
                ),
              ],
            ),
          ],
          if (m.qrCodeUrl.isNotEmpty) ...[
            12.hBox,
            Center(
              child: GestureDetector(
                onTap: () => _showQr(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      ImageViewWidget(
                        url: m.qrCodeUrl,
                        width: 130.w,
                        height: 130.w,
                        boxFit: BoxFit.contain,
                      ),
                      4.hBox,
                      Text(
                        'Tap to enlarge QR',
                        style: TextStyle(color: MR.muted, fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text, {bool strong = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: strong ? MR.pinkSoft : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: strong ? MR.pink : MR.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: strong ? MR.pink : MR.muted),
          4.wBox,
          Text(
            text,
            style: TextStyle(
              color: strong ? MR.pink : MR.ink,
              fontSize: 12.sp,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
      children: [
        MRSkeleton(height: 76.h, radius: 16.r),
        12.hBox,
        MRCard(
          child: Column(
            children: [
              MRSkeleton(height: 20.h, width: 160.w),
              12.hBox,
              Row(
                children: List.generate(
                  3,
                  (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 10.w : 0),
                      child: MRSkeleton(height: 82.h),
                    ),
                  ),
                ),
              ),
              10.hBox,
              Row(
                children: List.generate(
                  3,
                  (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 10.w : 0),
                      child: MRSkeleton(height: 82.h),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        MRCard(
          child: Column(
            children: [
              MRSkeleton(height: 20.h, width: 200.w),
              12.hBox,
              MRSkeleton(height: 44.h),
              12.hBox,
              MRSkeleton(height: 120.h),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet({required this.message, required this.onHistory});
  final String message;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22.w, 26.h, 22.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76.w,
              height: 76.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: MR.button),
              ),
              child: Icon(Icons.check_rounded,
                  color: Colors.white, size: 44.sp),
            )
                .animate()
                .scale(
                  begin: const Offset(.4, .4),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.elasticOut,
                )
                .then()
                .shimmer(duration: const Duration(milliseconds: 900)),
            16.hBox,
            Text(
              'Request submitted',
              style: TextStyle(
                color: MR.ink,
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 150)),
            6.hBox,
            Text(
              message.isEmpty
                  ? 'We\'ll check your payment and add the coins soon.'
                  : message,
              textAlign: TextAlign.center,
              style: TextStyle(color: MR.muted, fontSize: 14.sp, height: 1.4),
            ).animate().fadeIn(delay: const Duration(milliseconds: 220)),
            8.hBox,
            Text(
              'Coins are added after the admin approves it.',
              textAlign: TextAlign.center,
              style: TextStyle(color: MR.muted, fontSize: 12.sp),
            ).animate().fadeIn(delay: const Duration(milliseconds: 280)),
            20.hBox,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onHistory,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(46.h),
                      foregroundColor: MR.ink,
                      side: const BorderSide(color: MR.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23.r),
                      ),
                    ),
                    child: const Text('View history'),
                  ),
                ),
                12.wBox,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(46.h),
                      elevation: 0,
                      backgroundColor: MR.pink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23.r),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

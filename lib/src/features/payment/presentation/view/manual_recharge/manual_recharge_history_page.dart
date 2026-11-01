import 'package:flutter_animate/flutter_animate.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/data/model/manual_payment_models.dart';
import 'package:general/src/features/payment/data/remotely_data_source/manual_payment_api.dart';

import 'manual_recharge_widgets.dart';

/// The user's manual-recharge requests with their status (pending /
/// approved / rejected), newest first. Loads more as you scroll.
class ManualRechargeHistoryPage extends StatefulWidget {
  const ManualRechargeHistoryPage({super.key});

  @override
  State<ManualRechargeHistoryPage> createState() =>
      _ManualRechargeHistoryPageState();
}

class _ManualRechargeHistoryPageState extends State<ManualRechargeHistoryPage> {
  static const _pageSize = 20;

  final _api = ManualPaymentApi();
  final _scroll = ScrollController();

  final List<ManualPaymentHistoryItem> _items = [];
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _refresh();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 300) _loadMore();
  }

  Future<void> _refresh() async {
    if (_items.isEmpty) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final list = await _api.history(page: 1);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(list);
        _page = 1;
        _hasMore = list.length >= _pageSize;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (_items.isNotEmpty) {
        Methods.showToast(context, message: e.toString(), isError: true);
        return;
      }
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final list = await _api.history(page: _page + 1);
      if (!mounted) return;
      setState(() {
        // Skip rows we already have, in case a new request shifted the pages.
        final ids = _items.map((e) => e.id).toSet();
        _items.addAll(list.where((e) => !ids.contains(e.id)));
        _page++;
        _hasMore = list.length >= _pageSize;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MR.bg,
      appBar: AppBarWidget(
        backgroundColor: Colors.white,
        iconColor: MR.ink,
        title: 'Recharge History',
        titleStyle: context.bodyMedium.size(19).w800.colorExt(MR.ink),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _loading
            ? ListView(
                key: const ValueKey('loading'),
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                children: List.generate(
                  4,
                  (_) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: MRSkeleton(height: 130.h, radius: 16.r),
                  ),
                ),
              )
            : RefreshIndicator(
                key: const ValueKey('list'),
                color: MR.pink,
                onRefresh: _refresh,
                child: _error != null || _items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 90.h),
                          _error != null
                              ? MRMessage(
                                  icon: Icons.wifi_off_rounded,
                                  title: 'Couldn\'t load your history',
                                  subtitle: _error,
                                  action: 'Try again',
                                  onAction: _refresh,
                                )
                              : const MRMessage(
                                  icon: Icons.receipt_long_rounded,
                                  title: 'No recharge requests yet',
                                  subtitle:
                                      'Requests you submit will show up here with their status.',
                                ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scroll,
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
                        itemCount: _items.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= _items.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: MR.pink,
                                    strokeWidth: 2.4,
                                  ),
                                ),
                              ),
                            );
                          }
                          // Only the first screenful is staggered; later pages
                          // just fade in.
                          return _HistoryCard(item: _items[i])
                              .entrance(i < 8 ? i : 0);
                        },
                      ),
              ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});
  final ManualPaymentHistoryItem item;

  void _showScreenshot(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: InteractiveViewer(
          child: Center(
            child: ImageViewWidget(url: item.screenshotUrl, boxFit: BoxFit.contain),
          ),
        ),
      ).animate().fadeIn(duration: const Duration(milliseconds: 200)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final it = item;
    final rejected = it.status == 'rejected';
    return MRCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  it.methodName.isEmpty ? 'Seller' : it.methodName,
                  style: TextStyle(
                    color: MR.ink,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              MRStatusChip(status: it.status),
            ],
          ),
          10.hBox,
          Row(
            children: [
              Image.asset(AssetsManager.coinsVip, height: 20.h),
              5.wBox,
              Text(
                '${it.coins}',
                style: TextStyle(
                  color: MR.ink,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                MR.money(it.amount, it.currency),
                style: TextStyle(
                  color: MR.pink,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          12.hBox,
          Container(
            padding: EdgeInsets.fromLTRB(12.w, 8.h, 4.w, 8.h),
            decoration: BoxDecoration(
              color: MR.field,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _line('TrxID', it.userTrxId.isEmpty ? '—' : it.userTrxId,
                          strong: true),
                      if (it.senderNumber.isNotEmpty) ...[
                        4.hBox,
                        _line('From', it.senderNumber),
                      ],
                    ],
                  ),
                ),
                if (it.userTrxId.isNotEmpty)
                  IconButton(
                    tooltip: 'Copy TrxID',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => MR.copy(context, it.userTrxId, 'TrxID'),
                    icon: Icon(Icons.copy_rounded, color: MR.pink, size: 19.sp),
                  ),
                if (it.screenshotUrl.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showScreenshot(context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: ImageViewWidget(
                        url: it.screenshotUrl,
                        width: 42.w,
                        height: 42.w,
                        boxFit: BoxFit.cover,
                      ),
                    ),
                  ),
                4.wBox,
              ],
            ),
          ),
          if (it.adminNote.isNotEmpty) ...[
            10.hBox,
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: (rejected
                        ? const Color(0xFFE5484D)
                        : const Color(0xFF3B82F6))
                    .withValues(alpha: .08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sticky_note_2_outlined,
                      size: 16.sp,
                      color: rejected
                          ? const Color(0xFFE5484D)
                          : const Color(0xFF3B82F6)),
                  6.wBox,
                  Expanded(
                    child: Text(
                      it.adminNote,
                      style: TextStyle(
                        color: MR.ink,
                        fontSize: 12.sp,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (it.createdAt.isNotEmpty) ...[
            10.hBox,
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14.sp, color: MR.muted),
                4.wBox,
                Expanded(
                  child: Text(
                    MR.when(it.createdAt),
                    style: TextStyle(color: MR.muted, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(String label, String value, {bool strong = false}) {
    return Row(
      children: [
        SizedBox(
          width: 44.w,
          child: Text(
            label,
            style: TextStyle(color: MR.muted, fontSize: 12.sp),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: MR.ink,
              fontSize: strong ? 14.sp : 13.sp,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: strong ? .4 : 0,
            ),
          ),
        ),
      ],
    );
  }
}

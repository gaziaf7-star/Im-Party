import 'package:general/src/features/vip/vip.dart';

class VipBottomBar extends StatelessWidget {
  final String price;
  final String expire;
  final String id;
  final String name;
  final String vipBadge;
  final Color color;

  const VipBottomBar({
    required this.vipBadge,
    required this.name,
    required this.expire,
    required this.id,
    required this.price,
    required this.color,
    super.key,
  });

  void _buy(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AnimatedDialog(
          conText: StringManager.buy.tr(),
          onTap: () {
            di<BuyVipBloc>()
                .add(BuyVipEvent(type: '0', vipId: id, context: context));
            Navigator.pop(context);
          },
          title: name,
          child: vipBadge.contains('.svga') ||
                  vipBadge.contains('.zz') ||
                  vipBadge.contains('.zzz')
              ? CacheSvgaWidget(url: vipBadge, height: 120.h, width: 120.w)
              : ImageViewWidget(url: vipBadge, height: 120.h, width: 120.w),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          18.w, 14.h, 18.w, 14.h + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF26272C),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Top up  '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Image.asset(AssetsManager.coinsVip,
                      height: 16.h, width: 16.w),
                ),
                TextSpan(text: ' $price  for $expire days\nto upgrade to $name'),
              ]),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14.sp,
                height: 1.35,
              ),
            ),
          ),
          10.wBox,
          GestureDetector(
            onTap: () => _buy(context),
            child: Container(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE3CF), Color(0xFFF3B08C)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF3B08C).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'Top Up to Be SVIP',
                style: TextStyle(
                  color: const Color(0xFF3A2416),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

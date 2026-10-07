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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingOnly(bottom: 18, top: 18, start: 16, end: 16),
      width: MediaQuery.of(context).size.width,
      // Dark VIP theme: same near-black as the "SVIP Identity" panel above
      // it (seamless), plus a thin premium gold top border so the bar
      // still reads as its own distinct, polished section.
      decoration: BoxDecoration(
        color: ColorManager.backgroundBottomVip,
        border: Border(
          top: BorderSide(
            color: ColorManager.defaultTextVip.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AssetsManager.coin,
                  height: 28.h,
                  width: 28.h,
                ),
                6.wBox,
                // Dark VIP theme: bright gold reads clearly against the
                // near-black bar.
                Flexible(
                  child: TextWidget(
                    '$price${StringManager.coins_.tr()} /$expire ${StringManager.day.tr()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyLarge.bold
                        .colorExt(const Color(0xffFEC93A))
                        .copyWith(fontSize: 15.sp),
                  ),
                ),
              ],
            ),
          ),
          10.wBox,
          Expanded(
            child: ButtonWidget(
              width: 140.w,
              height: 42.h,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) {
                    return AnimatedDialog(
                      conText: StringManager.buy.tr(),
                      onTap: () {
                        di<BuyVipBloc>().add(BuyVipEvent(
                            type: '0', vipId: id, context: context));
                        Navigator.pop(context);
                      },
                      title: name,
                      child: vipBadge.contains('.svga') ||
                          vipBadge.contains('.zz') ||
                          vipBadge.contains('.zzz')
                          ? CacheSvgaWidget(
                        url: vipBadge,
                        height: 120.h,
                        width: 120.w,
                      )
                          : ImageViewWidget(
                        url: vipBadge,
                        height: 120.h,
                        width: 120.w,
                      ),
                    );
                  },
                );
              },
              beginGradient: AlignmentDirectional.topCenter,
              endGradient: AlignmentDirectional.bottomCenter,
              title: TextWidget(
                StringManager.becomeVip.tr(),
                style: context.bodyLarge.bold.colorExt(
                  ColorManager.textPrimary,
                ),
              ),
              backgroundColors: ColorManager.vipBuyButtonGradient,
              isFittedBox: false,
              fontSize: 15,
            ),
          )
        ],
      ),
    );
  }
}
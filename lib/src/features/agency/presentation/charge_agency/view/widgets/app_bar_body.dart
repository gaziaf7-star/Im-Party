part of 'package:general/src/features/agency/presentation/charge_agency/charge_agency_screen.dart';

class _AppBarBody extends StatefulWidget implements PreferredSizeWidget {
  const _AppBarBody();

  @override
  State<_AppBarBody> createState() => _AppBarBodyState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class _AppBarBodyState extends State<_AppBarBody> {
  List<String> titles = [
    StringManager.info.tr(),
    StringManager.theDetails.tr(),
    StringManager.rechargeCoins.tr(),
  ];

  List<String> icons = [
    AssetsManager.info,
    AssetsManager.detailsIcon,
    AssetsManager.rechargeChargeAgency,
  ];

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      backgroundColor: ColorManager.scaffoldBg,
      title: StringManager.balanceTransfer.tr(),
      iconLasted: SizedBox(
        width: 70.w,
        height: 50.h,
        child: PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_horiz,
          ),
          onSelected: (value) {
            if (value == titles[0]) {
              Navigator.pushNamed(context, Routes.infoChargeAgencyScreen);
            } else if (value == titles[1]) {
              Navigator.pushNamed(context, Routes.detailsChargeAgency);
            } else if (value == titles[2]) {
              Navigator.pushNamed(context, Routes.rechargeCoinsScreen);
            }
          },
          itemBuilder: (BuildContext context) {
            return titles.asMap().entries.map((entry) {
              final index = entry.key;
              final element = entry.value;

              return PopupMenuItem<String>(
                value: element,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      icons[index],
                      width: 20.w,
                      height: 30.h,
                      color: ColorManager.primary,
                      fit: BoxFit.fill,
                    ),
                    10.wBox,
                    Expanded(
                      child: Text(
                        element.tr(),
                        style: context.bodyMedium
                            .size(10)
                            .w600
                            .colorExt(ColorManager.onDark),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          shape: RoundedRectangleBorder(borderRadius: 15.radius),
          color: Colors.black.withValues(alpha: (00.89)),
        ),
      ),
      titleStyle: context.bodyLarge.w600,
    );
  }
}



import '../../../../../core/index.dart';

class TypeTabs extends StatelessWidget {
  final TabController typeController;

  const TypeTabs({required this.typeController, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.h,
      margin: context.paddingSymmetric(horizontal: 12),
      child: TabBar(
          controller: typeController,
          isScrollable: false,
          physics: const BouncingScrollPhysics(),
          labelColor: ColorManager.onDark,
          indicatorColor: ColorManager.white,
          dividerColor: ColorManager.transparent,
          unselectedLabelColor: ColorManager.onDark.withValues(alpha: (0.5 )),
          labelStyle: context.bodyLarge.w600.copyWith(fontFamily: "SegoeUI"),
          unselectedLabelStyle: context.bodyMedium.copyWith(fontFamily: "SegoeUI"),
          labelPadding: EdgeInsets.zero,
          tabs: [
            TextWidget(StringManager.rooms.tr()),
            TextWidget(StringManager.diamonds.tr()),
            TextWidget(StringManager.coins.tr()),
          ]),
    );
  }
}

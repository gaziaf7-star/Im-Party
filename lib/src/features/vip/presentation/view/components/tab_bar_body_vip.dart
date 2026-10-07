part of'../vip_screen.dart';

class TabBarBodyVip extends StatelessWidget {
  const TabBarBodyVip({super.key, required this.controller});
  final TabController controller;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 10,vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: context.paddingAll(2),
            alignment: AlignmentDirectional.center,
            decoration: const BoxDecoration(
              color: ColorManager.baseColor,
              shape: BoxShape.circle,
            ),
            child: InkWell(
              onTap: (){
                context.popRoute();
              },
              child: Icon(Icons.arrow_back_ios_new,size: 23.h,),
            ),
          ),

          TabBar(
            controller: controller,
            indicatorSize: TabBarIndicatorSize.label,
            dividerHeight: 0,
            tabAlignment: TabAlignment.start,
            indicator: MDIndicator(
                indicatorColor: ColorManager.white,
                indicatorWidth: 50.w,
                indicatorHeight: 25.h,
                radius: 20
            ),
            isScrollable: true,
            unselectedLabelStyle:
            context.bodyMedium.colorExt(ColorManager.textPrimary.withValues(alpha: (0.6 ))).w600,
            labelStyle: context.bodyLarge.colorExt(ColorManager.textPrimary).w600,
            tabs: [
              Text(StringManager.mine.tr()),
              Text(StringManager.vip.tr()),
            ],
          ),
          const SizedBox(),
        ],
      ),
    );
  }
}
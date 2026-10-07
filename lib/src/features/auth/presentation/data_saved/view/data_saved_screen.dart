import 'package:general/src/core/index.dart';

class SavedPage extends StatelessWidget {
  final SavedData savedData;

  const SavedPage({super.key, required this.savedData});

  @override
  Widget build(BuildContext context) {
    return BackgroundImgWidget(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110.h,
            backgroundColor: ColorManager.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: AppBarWidget(
                height: 110.h,
              ),
            ),
            pinned: true,
          ),
          SliverSafeArea(
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: context.paddingSymmetric(
                  horizontal: 30,
                ),
                child: Column(
                  children: [
                    20.hBox,
                    TextWidget(
                      StringManager.dataSaved.tr(),
                      style: context.bodyLarge.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.textPrimary),
                    ),
                    50.hBox,
                    // Image.asset(
                    //   AssetsManager.done,
                    //   width: 180.w,
                    //   height: 180.h,
                    // ),
                    150.hBox,
                    ButtonWidget(
                        title: StringManager.next.tr(),
                        onPressed: () {
                          savedData == SavedData.addInfo
                              ? context.pushNamedAndRemoveUntil(Routes.layout)
                              : null;
                        }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

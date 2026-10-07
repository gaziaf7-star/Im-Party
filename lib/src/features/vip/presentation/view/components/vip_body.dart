part of '../vip_screen.dart';

class VipBody extends StatefulWidget {
  const VipBody({super.key, this.index, required this.length});

  final int? index;
  final int length;

  @override
  State<VipBody> createState() => _VipBodyState();
}

class _VipBodyState extends State<VipBody> with TickerProviderStateMixin {
  late final TabController tabController;
  late final TabController tabVipController;

  @override
  void initState() {
    tabController = TabController(length: widget.length + 1, vsync: this);
    tabController.addListener(() {
      di<VipCenterBloc>().add(ChangeBackgroundEvent(tabController.index));
    });
    super.initState();
  }

  @override
  void dispose() {
    di<VipCenterBloc>().add(const ChangeBackgroundEvent(0));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VipCenterBloc, VipStates>(
      bloc: di<VipCenterBloc>(),
      buildWhen: (prev, curr) =>
      prev.vip != curr.vip || prev.vipBag != curr.vipBag,
      builder: (context, state) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            TabBarView(
              controller: tabController,
              children: List.generate(
                widget.length + 1,
                    (index) {
                  if (index == 0) {
                    return BlocBuilder<VipCenterBloc, VipStates>(
                      bloc: di<VipCenterBloc>(),
                      buildWhen: (prev, curr) => prev.vipBag != curr.vipBag,
                      builder: (context, state) {
                        return Column(
                          children: [
                            130.hBox,
                            MyVipCard(
                              vipLength: state.vipBag.length,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: context.paddingAll(20),
                                child: CustomMasonryGrid(
                                  columnCount: 2,
                                  spacing: 10.h,
                                  runSpacing: 10.h,
                                  children: List.generate(state.vipBag.length,
                                          (index) {
                                        final item = state.vipBag[index];
                                        return Container(
                                          padding: context.paddingSymmetric(
                                            horizontal: 10.w,
                                            vertical: 10.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ColorManager.scaffoldBg,
                                            borderRadius: 10.radius,
                                            border: item.isUsed == true
                                                ? Border.all(
                                              color: ColorManager.primary,
                                              width: 1.5,
                                            )
                                                : null,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Center(
                                                child: CacheSvgaWidget(
                                                  url: item.vip?.img ?? '',
                                                  height: 80,
                                                  width: 80,
                                                  boxFit: BoxFit.cover,
                                                ),
                                              ),
                                              10.hBox,
                                              TextWidget(
                                                item.vip?.name ?? '',
                                                style: context.titleLarge.bold
                                                    .colorExt(
                                                    ColorManager.textPrimary),
                                              ),
                                              5.hBox,
                                              TextWidget(
                                                item.remainingTime ?? '',
                                                style:
                                                context.bodySmall.bold.colorExt(
                                                  ColorManager.textPrimary
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                              10.hBox,
                                              if (item.isUsed == false)
                                                ButtonWidget(
                                                  onPressed: () {
                                                    di<VipCenterBloc>().add(
                                                      UseAndUnuseVipEvent(
                                                        type: '1',
                                                        context: context,
                                                        targetId: item.targetId
                                                            .toString(),
                                                      ),
                                                    );
                                                  },
                                                  title: StringManager.use.tr(),
                                                  height: 30.h,
                                                  radius: 8,
                                                  width: double.infinity,
                                                  paddingButton:
                                                  context.paddingAll(5),
                                                  titleColor: ColorManager.white,
                                                ),
                                              if (item.isUsed == true)
                                                ButtonWidget(
                                                  onPressed: () {
                                                    di<VipCenterBloc>().add(
                                                      UseAndUnuseVipEvent(
                                                        type: '0',
                                                        context: context,
                                                        targetId: item.targetId
                                                            .toString(),
                                                      ),
                                                    );
                                                  },
                                                  radius: 8,
                                                  height: 30.h,
                                                  width: double.infinity,
                                                  paddingButton:
                                                  context.paddingAll(5),
                                                  title: StringManager.unUse.tr(),
                                                  backgroundColor:
                                                  ColorManager.transparent,
                                                  borderColor: ColorManager.primary,
                                                  borderWidth: 2,
                                                  titleColor: ColorManager.primary,
                                                ),
                                              if (item.using != true) 5.hBox,
                                              if (item.using != true)
                                                ButtonWidget(
                                                  onPressed: () =>
                                                      customModalBottomSheet(
                                                        context,
                                                        height:
                                                        ScreenUtil().screenHeight,
                                                        child: SendVipBottomSheet(
                                                          vipId:
                                                          item.targetId.toString(),
                                                        ),
                                                      ),
                                                  height: 30.h,
                                                  width: double.infinity,
                                                  paddingButton:
                                                  context.paddingAll(5),
                                                  title: StringManager.send.tr(),
                                                  backgroundColor:
                                                  ColorManager.transparent,
                                                  borderColor: ColorManager.primary,
                                                  borderWidth: 2,
                                                  titleColor: ColorManager.primary,
                                                  radius: 8,
                                                ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  }
                  return VipBodyItem(
                    color: ColorManager.backgroundVipBottomWidget[(index - 1) %
                        ColorManager.backgroundVipBottomWidget.length],
                    vipCenterEntity: state.vip[index - 1],
                  );
                },
              ),
            ),
            Positioned(
              top: 90.h,
              child: TabBarBody(
                controller: tabController,
                length: widget.length,
                vipCenterEntity: state.vip,
              ),
            ),
            Padding(
              padding: context.paddingOnly(top: 32),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: context.paddingZero(),
                      backgroundColor: ColorManager.transparent,
                    ),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 20.5.h,
                      // Dark VIP theme: fixed white back icon reads clearly
                      // against the near-black VIP page.
                      color: tabController.index == 0
                          ? ColorManager.textPrimary
                          : ColorManager.white,
                    ),
                  ),
                  const Spacer(),
                  TextWidget(
                    // Hardcoded to "SVIP" on request, matching the
                    // reference image's app bar title exactly — the
                    // previous `StringManager.vip` constant was always
                    // the plain English "VIP" (no .tr(), so no
                    // translation/branding ever applied to it).
                    'SVIP',
                    style: context.titleLarge.w600.size(16).colorExt(
                      // Dark VIP theme: fixed white (onDark) title for
                      // the other VIP tabs against the dark page.
                      tabController.index == 0
                          ? ColorManager.textPrimary
                          : ColorManager.onDark,
                    ),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  60.wBox
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class CustomMasonryGrid extends StatelessWidget {
  final int columnCount;
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const CustomMasonryGrid({
    super.key,
    required this.columnCount,
    required this.children,
    this.spacing = 10,
    this.runSpacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    // split children into N columns
    final columns = List.generate(columnCount, (_) => <Widget>[]);

    for (int i = 0; i < children.length; i++) {
      columns[i % columnCount].add(
        Padding(
          padding: EdgeInsets.only(bottom: runSpacing),
          child: children[i],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(columnCount, (i) {
        return Expanded(
          child: Column(
            children: columns[i],
          ),
        );
      }).indexed.expand((entry) sync* {
        yield entry.$2;
        // Todo: remove this line
        if (entry.$1 != columnCount - 1) yield SizedBox(width: spacing);
      }).toList(),
    );
  }
}
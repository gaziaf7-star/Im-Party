part of '../vip_screen.dart';

class TabBarViewVipBody extends StatelessWidget {
  const TabBarViewVipBody({
    super.key,
    required this.tabController,
    required this.vipController,
    required this.vipCenterEntity,
    required this.length,
  });

  final TabController tabController;
  final TabController vipController;
  final List<VipCenterEntity> vipCenterEntity;
  final int length;

  @override
  Widget build(BuildContext context) {
    return TabBarView(controller: vipController, children: [
      SizedBox(
        height: ScreenUtil().screenHeight,
        child: BlocBuilder<VipCenterBloc, VipStates>(
            bloc: di<VipCenterBloc>(),
            buildWhen: (prev, curr) => prev.requestStateVipBag != curr.requestStateVipBag || prev.vipBag != curr.vipBag,
            builder: (context, state) {
              return Column(
                children: [
                  70.hBox,
                  MyVipCard(
                    vipLength: state.vipBag.length,
                  ),
                  SizedBox(
                    height: ScreenUtil().screenHeight - 184.h,
                    child: RefreshIndicatorWidget(
                      onRefresh: () async {
                        di<VipCenterBloc>().add(const GetVipBagEvent());
                      },
                      child: HandlingDataWidget(
                        reqState: state.requestStateVipBag,
                        title: StringManager.youDoNotHaveVip.tr(),
                        subTitle: StringManager.youDoNotHaveVipGoBuy.tr(),
                        onTap: () {
                          di<VipCenterBloc>().add(const GetVipBagEvent());
                        },
                        child: ListView.separated(
                            padding: context.paddingAll(20),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: context.paddingSymmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: ColorManager.white,
                                  borderRadius: 10.radius,
                                  border: state.vipBag[index].isUsed == true
                                      ? Border.all(
                                          color: ColorManager.primary,
                                          width: 1.5)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    ((state.vipBag[index].vip?.img ?? '')
                                                .contains('.zz') ||
                                            (state.vipBag[index].vip?.img ?? '')
                                                .contains('.svga') ||
                                            (state.vipBag[index].vip?.img ?? '')
                                                .contains('.zzz'))
                                        ? CacheSvgaWidget(
                                            url: state.vipBag[index].vip?.img ??
                                                '',
                                            height: 80,
                                            width: 80,
                                            boxFit: BoxFit.cover,
                                          )
                                        : ImageViewWidget(
                                            url: state.vipBag[index].vip?.img ??
                                                '',
                                            height: 80,
                                            width: 80,
                                            boxFit: BoxFit.cover,
                                          ),
                                    20.wBox,
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.vipBag[index].vip?.name ?? '',
                                          style: context.titleLarge.bold
                                              .colorExt(ColorManager.textPrimary),
                                        ),
                                        5.hBox,
                                        Text(
                                          state.vipBag[index].remainingTime ??
                                              '',
                                          style: context.bodySmall.bold
                                              .colorExt(ColorManager.textPrimary),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Column(
                                      children: [
                                        if (state.vipBag[index].isUsed == false)
                                          ButtonWidget(
                                            onPressed: () {
                                              di<VipCenterBloc>().add(
                                                UseAndUnuseVipEvent(
                                                  type: '1',
                                                  context: context,
                                                  targetId: state
                                                      .vipBag[index].targetId
                                                      .toString(),
                                                ),
                                              );
                                            },
                                            title: StringManager.use.tr(),
                                            height: 30.h,
                                            width: 60.h,
                                            paddingButton:
                                                context.paddingAll(5),
                                            titleColor: ColorManager.white,
                                          ),
                                        if (state.vipBag[index].using ==
                                                false &&
                                            state.vipBag[index].isUsed == false)
                                          10.hBox,
                                        if (state.vipBag[index].isUsed == true)
                                          ButtonWidget(
                                            onPressed: () {
                                              di<VipCenterBloc>().add(
                                                UseAndUnuseVipEvent(
                                                  type: '0',
                                                  context: context,
                                                  targetId: state
                                                      .vipBag[index].targetId
                                                      .toString(),
                                                ),
                                              );
                                            },
                                            height: 30.h,
                                            width: 60.h,
                                            paddingButton:
                                                context.paddingAll(5),
                                            title: StringManager.unUse.tr(),
                                            backgroundColor:
                                                ColorManager.transparent,
                                            borderColor: ColorManager.primary,
                                            borderWidth: 2,
                                            titleColor: ColorManager.primary,
                                          ),
                                        if (state.vipBag[index].using ==
                                                false &&
                                            state.vipBag[index].isUsed == true)
                                          10.hBox,
                                        if (state.vipBag[index].using != true)
                                          ButtonWidget(
                                            onPressed: () =>
                                                customModalBottomSheet(
                                              context,
                                              radius: 0,
                                              height: ScreenUtil().screenHeight,
                                              child: SendVipBottomSheet(
                                                vipId: state
                                                    .vipBag[index].targetId
                                                    .toString(),
                                              ),
                                            ),
                                            height: 30.h,
                                            width: 60.h,
                                            paddingButton:
                                                context.paddingAll(5),
                                            title: StringManager.send.tr(),
                                            backgroundColor:
                                                ColorManager.transparent,
                                            borderColor: ColorManager.primary,
                                            borderWidth: 2,
                                            titleColor: ColorManager.primary,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return 10.hBox;
                            },
                            itemCount: state.vipBag.length),
                      ),
                    ),
                  )
                ],
              );
            }),
      ),
      SizedBox(
        height: ScreenUtil().scaleHeight,
        child: Stack(
          children: [
            TabBarView(
              controller: tabController,
              children: List.generate(length, (index) {
                return VipBodyItem(
                  color: length > ColorManager.backgroundVipBottomWidget.length
                      ? ColorManager.backgroundVipBottomWidget[
                          ColorManager.backgroundVipBottomWidget.length - 1]
                      : ColorManager.backgroundVipBottomWidget[index],
                  vipCenterEntity: vipCenterEntity[index],
                );
              }),
            ),
            Positioned(
              top: 75.h,
              child: TabBarBody(
                controller: tabController,
                length: length,
                vipCenterEntity: vipCenterEntity,
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

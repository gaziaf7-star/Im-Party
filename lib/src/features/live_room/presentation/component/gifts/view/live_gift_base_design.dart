import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/md_indicator.dart';
import 'package:general/src/features/live_room/presentation/component/gifts/view/live_gift_bottom_bar.dart';
import 'package:general/src/features/live_room/presentation/component/gifts/view/live_gift_recipients.dart';
import 'package:general/src/features/room/domain/entities/gift_category_entity.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/gifts/view/widgets/search_textfield.dart';
import 'package:general/src/features/room/room.dart';

/// Old-theme layout for the live gift box. Forked from `GiftRoomBaseDesign` —
/// always shows the live recipient picker (no `isAudioRoom` gating), reuses the
/// shared gift grid (`PageViewGiftWidget`), and sends via [LiveGiftBottomBar].
class LiveGiftBaseDesign extends StatelessWidget {
  final FetchGiftsStates state;
  final List<GiftCategoryEntity> filteredCategories;
  final TabController? giftController;
  final MyDataModel myDataModel;
  final EnterRoomModel roomData;

  const LiveGiftBaseDesign({
    required this.state,
    required this.filteredCategories,
    required this.giftController,
    required this.myDataModel,
    required this.roomData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.45,
          width: double.infinity,
          decoration: const BoxDecoration(color: ColorManager.black),
          padding: context.paddingSymmetric(horizontal: 5),
          child: Column(
            children: [
              LiveGiftRecipients(
                useNewThemeLayout: false,
                containerHeight: 45.h,
                selectedBorderColor: ColorManager.primary,
                labelTextColor: ColorManager.white.withValues(alpha: 0.4),
                allButtonBackgroundColor: ColorManager.primary,
                allButtonTextColor: ColorManager.buttonTextColor,
                allButtonBorderRadius: 50,
              ),
              const SizedBox(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TabBar(
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: MDIndicator(
                    indicatorColor: ColorManager.white,
                    indicatorWidth: 18.0.w,
                    indicatorHeight: 4.h,
                    radius: 20.r,
                  ),
                  labelStyle: context.bodyMedium.colorExt(ColorManager.white),
                  unselectedLabelStyle: context.bodyMedium
                      .colorExt(ColorManager.white.withValues(alpha: 0.6)),
                  controller: giftController,
                  padding: EdgeInsets.zero,
                  labelPadding:
                      context.paddingSymmetric(vertical: 5, horizontal: 10),
                  automaticIndicatorColorAdjustment: false,
                  tabs: [
                    ...filteredCategories.map(
                      (category) => Padding(
                        padding: context.paddingOnly(end: 8.0),
                        child: Text(category.title),
                      ),
                    ),
                    Padding(
                      padding: context.paddingOnly(end: 8.0),
                      child: Text(StringManager.bagGift.tr()),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: GiftTabBarWithSearchState.showBagGiftNotifier,
                builder: (context, showBag, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable:
                        GiftTabBarWithSearchState.showSearchNotifier,
                    builder: (context, showSearch, _) {
                      if (showBag) {
                        return Expanded(child: _bagGrid());
                      }
                      if (showSearch) {
                        return Expanded(child: _searchGrid());
                      }
                      return Expanded(
                        child: TabBarView(
                          controller: giftController,
                          children: [
                            ...filteredCategories.map((category) {
                              return _categoryGrid(category);
                            }),
                            _bagGrid(),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              LiveGiftBottomBar(
                showData: true,
                roomData: roomData,
                sizeFactor: 1.0,
                containerBackgroundColor: ColorManager.transparent,
                containerTopPadding: 0,
                coinImageScale: 4,
                rechargeTextColor: ColorManager.orange,
                selectionColor: ColorManager.primary,
                showRechargeArrow: true,
                rechargeArrowColor: ColorManager.orange,
                sendButtonBorderWidth: 1,
                sendButtonBorderColor: ColorManager.primary,
                numberDropdownIconColor: const Color(0xFF2196F3),
                sendButtonGradientColors: const [],
                sendButtonBorderRadius: 30,
                dialogBackgroundColor: ColorManager.greyTabBar,
                dialogBorderColor: ColorManager.primary.withValues(alpha: 0.2),
                numberFormatPrefix: 'item',
              ),
            ],
          ),
        ),
      ],
    );
  }

  PageViewGiftWidget _categoryGrid(GiftCategoryEntity category) {
    return PageViewGiftWidget(
      giftType: TypeGift.fromString(category.type),
      data: state.getGiftsById(category.id),
      state: state.getReqStateById(category.id),
      message: state.getMessageById(category.id),
      userCoins: myDataModel.myStore?.coins.toString() ?? '',
      myData: myDataModel,
      categoryId: category.id,
      gridPaddingTop: 10,
      cardBackgroundColor: null,
      selectedBorderColor: ColorManager.primary,
      normalPriceColor: ColorManager.white,
      selectedPriceColor: ColorManager.orange,
      enableAnimation: false,
      showDownloadProgress: true,
      showMusicIcon: false,
    );
  }

  PageViewGiftWidget _bagGrid() {
    return PageViewGiftWidget(
      giftType: TypeGift.bag,
      data: state.bagGifts,
      state: state.bagReqState,
      message: state.bagMessage,
      userCoins: myDataModel.myStore?.coins.toString() ?? '',
      myData: myDataModel,
      categoryId: -2,
      gridPaddingTop: 10,
      cardBackgroundColor: null,
      selectedBorderColor: ColorManager.primary,
      normalPriceColor: ColorManager.white,
      selectedPriceColor: ColorManager.orange,
      enableAnimation: false,
      showDownloadProgress: true,
      showMusicIcon: false,
    );
  }

  PageViewGiftWidget _searchGrid() {
    return PageViewGiftWidget(
      giftType: TypeGift.vip,
      data: state.searchGifts,
      state: state.searchReqState,
      message: state.searchMessage,
      userCoins: myDataModel.myStore?.coins.toString() ?? '',
      myData: myDataModel,
      categoryId: -3,
      gridPaddingTop: 10,
      cardBackgroundColor: null,
      selectedBorderColor: ColorManager.primary,
      normalPriceColor: ColorManager.white,
      selectedPriceColor: ColorManager.orange,
      enableAnimation: false,
      showDownloadProgress: true,
      showMusicIcon: false,
    );
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/component/gifts/view/live_gift_bottom_bar.dart';
import 'package:general/src/features/live_room/presentation/component/gifts/view/live_gift_recipients.dart';
import 'package:general/src/features/room/domain/entities/gift_category_entity.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/gifts/view/widgets/gifts_section_description_header.dart';
import 'package:general/src/features/room/presentation/gifts/view/widgets/level_progress_widget.dart';
import 'package:general/src/features/room/presentation/gifts/view/widgets/search_textfield.dart';
import 'package:general/src/features/room/room.dart';

/// New-theme layout for the live gift box. Forked from `GiftRoomNewThemeDesign`
/// — always shows the live recipient picker, reuses the shared gift grid +
/// tab-bar/search + level progress, and sends via [LiveGiftBottomBar].
class LiveGiftNewThemeDesign extends StatelessWidget {
  final FetchGiftsStates state;
  final List<GiftCategoryEntity> filteredCategories;
  final GiftCategoryEntity category;
  final TabController? giftController;
  final MyDataModel myDataModel;
  final EnterRoomModel roomData;

  const LiveGiftNewThemeDesign({
    required this.state,
    required this.filteredCategories,
    required this.category,
    required this.giftController,
    required this.myDataModel,
    required this.roomData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Set<TypeGift> headerSupportedTypes = {
      TypeGift.vip,
      TypeGift.cp,
      TypeGift.lucky,
    };
    final giftType = TypeGift.fromString(category.type);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerSupportedTypes.contains(giftType)) ...[
          GiftsSectionDescriptionHeader(
            type: TypeGift.fromString(category.type),
            backgroundColor: ColorManager.black.withValues(alpha: 0.8),
            horizontalPadding: 5,
          ),
          5.hBox,
        ],
        Container(
          height: MediaQuery.of(context).size.height * 0.45,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorManager.black.withValues(alpha: 0.9),
          ),
          padding: context.paddingSymmetric(horizontal: 5),
          child: Column(
            children: [
              LiveGiftRecipients(
                useNewThemeLayout: true,
                containerHeight: 40.h,
                selectedBorderColor: ColorManager.primary,
                labelTextColor: ColorManager.white.withValues(alpha: 0.4),
                allButtonBackgroundColor: ColorManager.primary,
                allButtonTextColor: ColorManager.buttonTextColor,
                allButtonBorderRadius: 50,
              ),
              LevelProgressSection(
                levelTextColor: ColorManager.primary,
                progressBarColor: ColorManager.primary,
                progressBackgroundColor:
                    ColorManager.white.withValues(alpha: 0.5),
                descriptionTextColor: ColorManager.white.withValues(alpha: 0.5),
                progressBarHeight: 2,
                showDivider: true,
                dividerColor: Colors.white.withValues(alpha: 0.15),
              ),
              GiftTabBarWithSearch(
                giftController: giftController,
                selectedLabelColor: ColorManager.primary,
                unselectedLabelColor: ColorManager.white.withAlpha(150),
                labelColorWhenBagActive: ColorManager.white.withAlpha(150),
                showSearchIcon: true,
                briefcaseIconColor: ColorManager.white,
                tabs: [
                  ...filteredCategories.map(
                    (category) => Padding(
                      padding: context.paddingOnly(end: 8.0),
                      child: Text(category.title),
                    ),
                  ),
                ],
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
                            ...filteredCategories.map(_categoryGrid),
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
                sizeFactor: 0.8,
                containerBackgroundColor: ColorManager.black,
                containerTopPadding: 5.h,
                coinImageScale: 6,
                rechargeTextColor: ColorManager.orange,
                showRechargeArrow: false,
                rechargeArrowColor: ColorManager.orange,
                selectionColor: ColorManager.primary,
                sendButtonBorderWidth: 1,
                sendButtonBorderColor: ColorManager.primary,
                numberDropdownIconColor:
                    ColorManager.white.withValues(alpha: 0.5),
                sendButtonGradientColors: [
                  ColorManager.primary.withValues(alpha: 0.75),
                  ColorManager.primary.withValues(alpha: 0.95),
                  ColorManager.primary,
                  ColorManager.primary.withValues(alpha: 0.85),
                ],
                sendButtonBorderRadius: 30,
                dialogBackgroundColor: ColorManager.black,
                dialogBorderColor: ColorManager.transparent,
                numberFormatPrefix: '',
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
      gridPaddingTop: 0,
      cardBackgroundColor: ColorManager.black,
      selectedBorderColor: ColorManager.primary,
      normalPriceColor: ColorManager.white,
      selectedPriceColor: ColorManager.orange,
      enableAnimation: true,
      showDownloadProgress: true,
      showMusicIcon: true,
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
      gridPaddingTop: 0,
      cardBackgroundColor: ColorManager.black,
      selectedBorderColor: ColorManager.primary,
      normalPriceColor: ColorManager.white,
      selectedPriceColor: ColorManager.orange,
      enableAnimation: true,
      showDownloadProgress: true,
      showMusicIcon: true,
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
      gridPaddingTop: 0,
      cardBackgroundColor: ColorManager.black,
      selectedBorderColor: ColorManager.primary,
      normalPriceColor: ColorManager.white,
      selectedPriceColor: ColorManager.orange,
      enableAnimation: true,
      showDownloadProgress: true,
      showMusicIcon: true,
    );
  }
}

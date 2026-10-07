import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/md_indicator.dart';
import 'package:general/src/features/room/domain/entities/gift_category_entity.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/gifts/view/widgets/search_textfield.dart';
import 'package:general/src/features/room/room.dart';

class GiftRoomBaseDesign extends StatelessWidget {
  final FetchGiftsStates state;
  final List<GiftCategoryEntity> filteredCategories;
  final TabController? giftController;
  final MyDataModel myDataModel;
  final EnterRoomModel roomData;
  final bool isAudioRoom;
  final bool isSingleUser;
  final List<UTDParticipant>? users;
  final String? userId;
  final String? userImage;
  final String? userName;
  final String? momentId;

  const GiftRoomBaseDesign({
    required this.state,
    required this.filteredCategories,
    required this.giftController,
    required this.myDataModel,
    required this.roomData,
    required this.isAudioRoom,
    required this.isSingleUser,
    required this.users,
    required this.userId,
    required this.userImage,
    required this.userName,
    required this.momentId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = giftController;
    final expectedLength = filteredCategories.length + 1;

    // Never allow a TabBar/TabBarView to build with a null or stale
    // controller. A mismatch used to throw inside this subtree, Flutter
    // replaced it with a 100000px RenderErrorBox, and the parent Column then
    // reported a 99476px overflow.
    if (controller == null ||
        controller.length != expectedLength) {
      return SizedBox.expand(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            // Kept in sync with the real panel's height below (110px
            // shorter than the original 0.45, per request -- Audio Live's
            // gift box now matches the Video Live box's height change) so
            // this loading placeholder doesn't visibly resize once the
            // controller is ready.
            height: MediaQuery.of(context).size.height * 0.45 - 110.h,
            width: double.infinity,
            color: ColorManager.black,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // 110px shorter than before, on request -- Audio Live's gift box
          // now matches the height reduction already made to Video Live's.
          constraints: BoxConstraints(
            maxHeight:
            MediaQuery.of(context).size.height * 0.58 - 110.h,
          ),
          decoration: const BoxDecoration(
            color: ColorManager.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            5.w,
            6.h,
            5.w,
            6.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (isAudioRoom) ...[
                SizedBox(
                  height: 48.h,
                  child: isSingleUser
                      ? GiftUserOnly(
                    userId: userId ?? "",
                    ownerId: roomData.ownerId.toString(),
                    userImage: userImage ?? "",
                    userName: userName ?? "",
                    selectedBorderColor:
                    ColorManager.primary,
                  )
                      : GiftUser(
                    users: users ?? [],
                    ownerId: roomData.ownerId.toString(),
                    containerHeight: 45.h,
                    useNewThemeLayout: false,
                    selectedBorderColor:
                    ColorManager.primary,
                    labelTextColor:
                    ColorManager.white.withValues(
                      alpha: 0.4,
                    ),
                    seatNumberBackgroundColor:
                    ColorManager.primary,
                    seatNumberTextColor:
                    ColorManager.white,
                    allButtonBackgroundColor:
                    ColorManager.primary,
                    allButtonTextColor:
                    ColorManager.buttonTextColor,
                    allButtonBorderRadius: 50,
                  ),
                ),
                2.hBox,
              ],

              SizedBox(
                height: 42.h,
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 5.w),
                  child: TabBar(
                    controller: controller,
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
                    labelStyle: context.bodyMedium
                        .colorExt(ColorManager.white),
                    unselectedLabelStyle:
                    context.bodyMedium.colorExt(
                      ColorManager.white.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    labelPadding:
                    EdgeInsets.symmetric(
                      vertical: 5.h,
                      horizontal: 10.w,
                    ),
                    automaticIndicatorColorAdjustment:
                    false,
                    tabs: [
                      ...filteredCategories.map(
                            (category) => Padding(
                          padding:
                          EdgeInsets.only(right: 8.w),
                          child: Text(category.title),
                        ),
                      ),
                      Padding(
                        padding:
                        EdgeInsets.only(right: 8.w),
                        child: Text(
                          StringManager.bagGift,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Keep Expanded as a direct, stable child of this Column.
              // The ValueListenableBuilders now return only normal widgets,
              // preventing parent-data/layout churn while the dialog closes.
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable:
                  GiftTabBarWithSearchState
                      .showBagGiftNotifier,
                  builder:
                      (context, showBagGift, _) {
                    return ValueListenableBuilder<bool>(
                      valueListenable:
                      GiftTabBarWithSearchState
                          .showSearchNotifier,
                      builder:
                          (context, showSearch, __) {
                        if (showBagGift) {
                          return PageViewGiftWidget(
                            giftType: TypeGift.bag,
                            data: state.bagGifts,
                            state: state.bagReqState,
                            message: state.bagMessage,
                            userCoins: myDataModel
                                .myStore?.coins
                                .toString() ??
                                '',
                            myData: myDataModel,
                            categoryId: -2,
                            gridPaddingTop: 8,
                            cardBackgroundColor: null,
                            selectedBorderColor:
                            ColorManager.primary,
                            normalPriceColor:
                            ColorManager.white,
                            selectedPriceColor:
                            ColorManager.orange,
                            enableAnimation: false,
                            showDownloadProgress: true,
                            showMusicIcon: false,
                          );
                        }

                        if (showSearch) {
                          return PageViewGiftWidget(
                            giftType: TypeGift.vip,
                            data: state.searchGifts,
                            state: state.searchReqState,
                            message: state.searchMessage,
                            userCoins: myDataModel
                                .myStore?.coins
                                .toString() ??
                                '',
                            myData: myDataModel,
                            categoryId: -3,
                            gridPaddingTop: 8,
                            cardBackgroundColor: null,
                            selectedBorderColor:
                            ColorManager.primary,
                            normalPriceColor:
                            ColorManager.white,
                            selectedPriceColor:
                            ColorManager.orange,
                            enableAnimation: false,
                            showDownloadProgress: true,
                            showMusicIcon: false,
                          );
                        }

                        return TabBarView(
                          controller: controller,
                          children: [
                            ...filteredCategories.map(
                                  (category) {
                                return PageViewGiftWidget(
                                  giftType:
                                  TypeGift.fromString(
                                    category.type,
                                  ),
                                  data:
                                  state.getGiftsById(
                                    category.id,
                                  ),
                                  state:
                                  state.getReqStateById(
                                    category.id,
                                  ),
                                  message:
                                  state.getMessageById(
                                    category.id,
                                  ),
                                  userCoins: myDataModel
                                      .myStore
                                      ?.coins
                                      .toString() ??
                                      '',
                                  myData: myDataModel,
                                  categoryId:
                                  category.id,
                                  gridPaddingTop: 8,
                                  cardBackgroundColor:
                                  null,
                                  selectedBorderColor:
                                  ColorManager.primary,
                                  normalPriceColor:
                                  ColorManager.white,
                                  selectedPriceColor:
                                  ColorManager.orange,
                                  enableAnimation: false,
                                  showDownloadProgress:
                                  true,
                                  showMusicIcon: false,
                                );
                              },
                            ),
                            PageViewGiftWidget(
                              giftType: TypeGift.bag,
                              data: state.bagGifts,
                              state: state.bagReqState,
                              message: state.bagMessage,
                              userCoins: myDataModel
                                  .myStore?.coins
                                  .toString() ??
                                  '',
                              myData: myDataModel,
                              categoryId: -2,
                              gridPaddingTop: 8,
                              cardBackgroundColor: null,
                              selectedBorderColor:
                              ColorManager.primary,
                              normalPriceColor:
                              ColorManager.white,
                              selectedPriceColor:
                              ColorManager.orange,
                              enableAnimation: false,
                              showDownloadProgress: true,
                              showMusicIcon: false,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              GiftBottomBar(
                showData: true,
                roomData: roomData,
                isRoom: isAudioRoom,
                momentId: momentId ?? "",
                sizeFactor: 1.0,
                containerBackgroundColor:
                ColorManager.transparent,
                containerTopPadding: 0,
                coinImageScale: 4,
                rechargeTextColor:
                ColorManager.orange,
                selectionColor:
                ColorManager.primary,
                showRechargeArrow: true,
                rechargeArrowColor:
                ColorManager.orange,
                sendButtonBorderWidth: 1,
                sendButtonBorderColor:
                ColorManager.primary,
                numberDropdownIconColor:
                const Color(0xFF2196F3),
                sendButtonGradientColors: const [],
                sendButtonBorderRadius: 30,
                dialogBackgroundColor:
                ColorManager.greyTabBar,
                dialogBorderColor:
                ColorManager.primary.withValues(
                  alpha: 0.2,
                ),
                numberFormatPrefix: 'item',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
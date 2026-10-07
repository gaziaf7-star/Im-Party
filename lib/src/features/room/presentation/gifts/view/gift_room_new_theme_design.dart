import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/domain/entities/gift_category_entity.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/gifts/view/widgets/gifts_section_description_header.dart';
import 'package:general/src/features/room/presentation/gifts/view/widgets/level_progress_widget.dart';
import 'package:general/src/features/room/presentation/gifts/view/widgets/search_textfield.dart';
import 'package:general/src/features/room/room.dart';

class GiftRoomNewThemeDesign extends StatelessWidget {
  final FetchGiftsStates state;
  final List<GiftCategoryEntity> filteredCategories;
  final GiftCategoryEntity category;
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

  const GiftRoomNewThemeDesign({
    required this.state,
    required this.filteredCategories,
    required this.category,
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
          // 110px shorter than before, on request -- Audio Live's gift box
          // now matches the height reduction already made to Video Live's.
          height: MediaQuery.of(context).size.height * 0.45 - 110.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorManager.black.withValues(alpha: 0.9),
          ),
          padding: context.paddingSymmetric(horizontal: 5),
          child: Column(
            children: [
              if (isAudioRoom)
                isSingleUser
                    ? GiftUserOnly(
                  userId: userId ?? "",
                  ownerId: roomData.ownerId.toString(),
                  userImage: userImage ?? "",
                  userName: userName ?? "",
                  selectedBorderColor: ColorManager.primary,
                )
                    : GiftUser(
                  users: users ?? [],
                  ownerId: roomData.ownerId.toString(),
                  containerHeight: 40.h,
                  useNewThemeLayout: true,
                  selectedBorderColor: ColorManager.primary,
                  labelTextColor:
                  ColorManager.white.withValues(alpha: 0.4),
                  seatNumberBackgroundColor: ColorManager.primary,
                  seatNumberTextColor: ColorManager.white,
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
                builder: (context, showBagGiftNotifier, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable:
                    GiftTabBarWithSearchState.showSearchNotifier,
                    builder: (context, showSearch, _) {
                      if (showBagGiftNotifier) {
                        return Expanded(
                          child: PageViewGiftWidget(
                            giftType: TypeGift.bag,
                            data: state.bagGifts,
                            state: state.bagReqState,
                            message: state.bagMessage,
                            userCoins:
                            myDataModel.myStore?.coins.toString() ?? '',
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
                          ),
                        );
                      }
                      if (showSearch) {
                        return Expanded(
                          child: PageViewGiftWidget(
                            giftType: TypeGift.vip,
                            data: state.searchGifts,
                            state: state.searchReqState,
                            message: state.searchMessage,
                            userCoins:
                            myDataModel.myStore?.coins.toString() ?? '',
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
                          ),
                        );
                      } else {
                        return Expanded(
                          child: TabBarView(
                            controller: giftController,
                            children: [
                              ...filteredCategories.map((category) {
                                final typeGift =
                                TypeGift.fromString(category.type);
                                return PageViewGiftWidget(
                                  giftType: typeGift,
                                  data: state.getGiftsById(category.id),
                                  state: state.getReqStateById(category.id),
                                  message: state.getMessageById(category.id),
                                  userCoins:
                                  myDataModel.myStore?.coins.toString() ??
                                      '',
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
                              }),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              GiftBottomBar(
                showData: true,
                roomData: roomData,
                isRoom: isAudioRoom,
                momentId: momentId ?? "",
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
        )
      ],
    );
  }
}
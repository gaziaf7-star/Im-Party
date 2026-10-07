import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/component/gifts/view/live_gift_base_design.dart';
import 'package:general/src/features/live_room/presentation/component/gifts/view/live_gift_bottom_bar.dart';
import 'package:general/src/features/live_room/presentation/component/gifts/view/live_gift_new_theme_design.dart';
import 'package:general/src/features/live_room/presentation/component/gifts/view/live_gift_recipients.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_event.dart';
import 'package:general/src/features/room/data/model/gift_category_model.dart';
import 'package:general/src/features/room/domain/entities/gift_category_entity.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/gifts/view/widgets/search_textfield.dart';
import 'package:general/src/features/room/room.dart';

/// The live (video) room's own gift sheet — the standalone counterpart of the
/// audio `GiftScreen`. Always multi-recipient (host + on-stage guests), shows
/// all gift categories including lucky + bag, and drives the live send/broadcast
/// via [LiveGiftBottomBar]/[LiveSendGiftBloc]. Reuses the shared gift catalog
/// blocs ([FetchGiftBloc]/[GiftBloc]) and the shared gift grid.
class LiveGiftScreen extends StatefulWidget {
  final MyDataModel myDataModel;
  final EnterRoomModel roomData;

  const LiveGiftScreen({
    required this.myDataModel,
    required this.roomData,
    super.key,
  });

  @override
  State<LiveGiftScreen> createState() => _LiveGiftScreenState();
}

class _LiveGiftScreenState extends State<LiveGiftScreen>
    with TickerProviderStateMixin {
  TabController? giftController;

  bool get _isNewTheme =>
      ConstantsManager.isTheme1 || ConstantsManager.isTheme2;

  @override
  void initState() {
    super.initState();
    if (!di<FetchGiftBloc>().state.reqStateGiftCategory.isLoaded) {
      di<FetchGiftBloc>().add(const FetchGiftCategoryEvent());
    }
    if (_isNewTheme) {
      di<GetMyLevelBloc>().add(const GetMyLevelData());
    }
    // Reset shared gift-transaction state for a fresh sheet.
    GiftBottomBar.numberOfGift.value = 1;
    GiftBottomBar.giftType = TypeGift.normal;
    GiftScreen.chosenGift = null;
    LiveGiftRecipients.clearAll();

    _initTabController();
  }

  void _selectFirstGift(List<GiftsEntity> gifts, {int? categoryId}) {
    if (gifts.isNotEmpty) {
      final firstGift = gifts.first;
      GiftScreen.chosenGift = firstGift;
      di<GiftBloc>().add(
        ChangeGiftDataEvent(
          numOfGift: 0,
          giftId: firstGift.id,
          giftPrice: firstGift.price,
          categoryId: categoryId,
        ),
      );
    }
  }

  List<GiftCategoryEntity> get _categories =>
      di<FetchGiftBloc>().state.giftCategory;

  void _initTabController() {
    final state = di<FetchGiftBloc>().state;
    // Live box shows ALL categories (incl. lucky_gift).
    final categories = state.giftCategory;
    // Old theme adds a trailing bag tab; new theme shows the bag inline.
    final tabLength = _isNewTheme ? categories.length : categories.length + 1;

    // Dispose any controller from a prior build — _initTabController re-runs via
    // setState() once gift categories load, which would otherwise leak the old
    // TabController (created with length 0 on the first build).
    giftController?.dispose();
    giftController = TabController(length: tabLength, vsync: this);

    giftController?.addListener(() {
      final index = giftController?.index ?? 0;
      final state = di<FetchGiftBloc>().state;
      if (!_isNewTheme && index == categories.length) {
        // Bag tab (old theme).
        GiftBottomBar.giftType = TypeGift.bag;
        if (state.bagReqState != RequestState.loaded) {
          di<FetchGiftBloc>().add(const FetchBagGiftEvent());
        } else {
          _selectFirstGift(state.bagGifts, categoryId: -2);
        }
      } else if (index < categories.length) {
        final category = categories[index];
        GiftBottomBar.giftType = TypeGift.fromString(category.type);
        di<FetchGiftBloc>().add(SetCategoryIdEvent(category.id));
        if (state.getReqStateById(category.id) != RequestState.loaded) {
          di<FetchGiftBloc>().add(
            FetchGiftsByCategoryEvent(
              categoryId: category.id,
              typeId: category.id,
            ),
          );
        } else {
          _selectFirstGift(state.getGiftsById(category.id),
              categoryId: category.id);
        }
      }
    });

    if (categories.isNotEmpty) {
      final firstCategory = categories.first;
      if (state.getReqStateById(firstCategory.id) != RequestState.loaded) {
        di<FetchGiftBloc>().add(SetCategoryIdEvent(firstCategory.id));
        di<FetchGiftBloc>().add(
          FetchGiftsByCategoryEvent(
            categoryId: firstCategory.id,
            typeId: firstCategory.id,
          ),
        );
      } else {
        _selectFirstGift(state.getGiftsById(firstCategory.id),
            categoryId: firstCategory.id);
      }
    }
  }

  @override
  void dispose() {
    // Sheet dismissed mid-combo (barrier tap while the lucky candy is up):
    // close out the lucky session like the audio GiftRoomPage does, otherwise
    // numOfRequest/banners leak into the next sheet.
    if (GiftBottomBar.typeCandy.value == TypeCandy.luckyCandy) {
      LuckyGiftService.instance.resetGuard();
      LuckyGiftService.instance.endAllLuckyGift();
    }
    GiftBottomBar.typeCandy.value = TypeCandy.non;
    GiftScreen.chosenGift = null;
    final categories = _categories;
    if (categories.isNotEmpty) {
      di<FetchGiftBloc>().add(SetCategoryIdEvent(categories.first.id));
    }
    GiftTabBarWithSearchState.showBagGiftNotifier.value = false;
    GiftTabBarWithSearchState.showSearchNotifier.value = false;
    di<GiftBloc>().add(
      const ChangeGiftDataEvent(
        numOfGift: -1,
        giftId: -1,
        giftPrice: -1,
        categoryId: -1,
      ),
    );
    giftController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FetchGiftBloc, FetchGiftsStates>(
      bloc: di<FetchGiftBloc>(),
      buildWhen: (previous, current) =>
          previous.reqStateGiftCategory != current.reqStateGiftCategory ||
          previous.categoryReqStates != current.categoryReqStates ||
          previous.bagReqState != current.bagReqState ||
          previous.searchReqState != current.searchReqState,
      listener: (context, state) {
        if (state.reqStateGiftCategory == RequestState.loaded &&
            (giftController == null || giftController!.length == 0)) {
          setState(_initTabController);
        }
        final currentCategoryId = state.categoryId;
        if (currentCategoryId != null &&
            state.getReqStateById(currentCategoryId) == RequestState.loaded) {
          final gifts = state.getGiftsById(currentCategoryId);
          if (gifts.isNotEmpty && GiftScreen.chosenGift == null) {
            _selectFirstGift(gifts, categoryId: currentCategoryId);
          }
        }
        if (state.bagReqState == RequestState.loaded &&
            GiftBottomBar.giftType == TypeGift.bag &&
            GiftScreen.chosenGift == null) {
          _selectFirstGift(state.bagGifts, categoryId: -2);
        }
      },
      builder: (context, state) {
        if (state.reqStateGiftCategory == RequestState.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.reqStateGiftCategory == RequestState.error) {
          return Center(child: Text(state.msgGiftCategory));
        }

        // All categories (lucky included) for the live box.
        final filteredCategories = state.giftCategory;
        final category = state.giftCategory.firstWhere(
          (c) => c.id == state.categoryId,
          orElse: () => const GiftCategoryModel(id: -1, title: '', type: ''),
        );

        // Lucky-candy combo mode collapses the box to just the floating candy
        // bar so the room + fly animation stay visible while comboing — same
        // behavior as the audio GiftRoomPage.
        return ValueListenableBuilder<TypeCandy>(
          valueListenable: GiftBottomBar.typeCandy,
          builder: (context, typeCandy, _) {
            if (typeCandy == TypeCandy.luckyCandy) {
              return SizedBox(
                height: MediaQuery.of(context).size.height / 5,
                child: LiveGiftBottomBar(
                  roomData: widget.roomData,
                  showData: false,
                  sizeFactor: 1.0,
                  containerBackgroundColor: ColorManager.transparent,
                  containerTopPadding: 0,
                  coinImageScale: 4,
                  rechargeTextColor: ColorManager.orange,
                  showRechargeArrow: true,
                  rechargeArrowColor: ColorManager.orange,
                  selectionColor: ColorManager.primary,
                  sendButtonBorderWidth: 1,
                  sendButtonBorderColor: ColorManager.primary,
                  numberDropdownIconColor: ColorManager.white.withValues(alpha: 0.5),
                  sendButtonGradientColors: const [],
                  sendButtonBorderRadius: 30,
                  dialogBackgroundColor: ColorManager.black,
                  dialogBorderColor: ColorManager.transparent,
                  numberFormatPrefix: '',
                ),
              );
            }
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            return AnimatedPadding(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                child: _isNewTheme
                    ? LiveGiftNewThemeDesign(
                        state: state,
                        filteredCategories: filteredCategories,
                        category: category,
                        giftController: giftController,
                        myDataModel: widget.myDataModel,
                        roomData: widget.roomData,
                      )
                    : LiveGiftBaseDesign(
                        state: state,
                        filteredCategories: filteredCategories,
                        giftController: giftController,
                        myDataModel: widget.myDataModel,
                        roomData: widget.roomData,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}

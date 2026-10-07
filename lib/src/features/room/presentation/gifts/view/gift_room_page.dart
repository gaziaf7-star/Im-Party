import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_my_level/get_my_level_event.dart';
import 'package:general/src/features/room/data/model/gift_category_model.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import 'package:general/src/features/room/presentation/gifts/view/gift_room_base_design.dart';
import 'package:general/src/features/room/presentation/gifts/view/gift_room_new_theme_design.dart';
import 'package:general/src/features/room/presentation/gifts/view/widgets/search_textfield.dart';
import 'package:general/src/features/room/room.dart';

import '../../../domain/entities/gift_category_entity.dart';

class GiftScreen extends StatefulWidget {
  final MyDataModel myDataModel;
  final EnterRoomModel roomData;
  final List<UTDParticipant>? users;
  final bool isSingleUser;
  final bool isAudioRoom;
  final String? userId;
  final String? userImage;
  final String? userName;
  final String? momentId;

  const GiftScreen({
    required this.myDataModel,
    required this.users,
    required this.roomData,
    required this.isSingleUser,
    required this.isAudioRoom,
    required this.userId,
    required this.userImage,
    required this.userName,
    this.momentId,
    super.key,
  });

  static GiftsEntity? chosenGift;

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> with TickerProviderStateMixin {
  TabController? giftController;

  bool _controllerInitScheduled = false;
  bool _isDisposing = false;
  int _lastHandledTabIndex = -1;

  @override
  void initState() {
    super.initState();
    if (!di<FetchGiftBloc>().state.reqStateGiftCategory.isLoaded) {
      di<FetchGiftBloc>().add(const FetchGiftCategoryEvent());
    }
    if (ConstantsManager.isTheme1 || ConstantsManager.isTheme2) {
      di<GetMyLevelBloc>().add(const GetMyLevelData());
    }
    GiftBottomBar.numberOfGift.value = 1;

    if (widget.isAudioRoom == false) {
      GiftUser.userSelected.value.clear();
      GiftUserOnly.userSelected = widget.userId ?? "";
      GiftUser.userSelected.value.putIfAbsent(
        0,
            () => SelectedObject(
          userId: widget.userId ?? "",
          selected: true,
          name: widget.userName ?? "",
        ),
      );
    }

    GiftBottomBar.giftType = TypeGift.normal;
    GiftScreen.chosenGift = null;

    // Do not create a stale Bag-only controller before categories arrive.
    final giftState = di<FetchGiftBloc>().state;
    if (giftState.reqStateGiftCategory.isLoaded &&
        giftState.giftCategory.isNotEmpty) {
      _scheduleControllerInit();
    }
  }

  /// Selects the first gift in the given list
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

  List<GiftCategoryEntity> _filteredGiftCategories(
      FetchGiftsStates state,
      ) {
    return state.giftCategory.where((item) {
      if (item.type == 'lucky_gift') {
        return widget.isAudioRoom;
      }
      return true;
    }).toList(growable: false);
  }

  int _desiredTabLength(
      List<GiftCategoryEntity> categories,
      ) {
    return ConstantsManager.isTheme1 ||
        ConstantsManager.isTheme2
        ? categories.length
        : categories.length + 1;
  }

  void _scheduleControllerInit() {
    if (_controllerInitScheduled || _isDisposing) {
      return;
    }

    _controllerInitScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controllerInitScheduled = false;

      if (!mounted || _isDisposing) {
        return;
      }

      _ensureTabController();
    });
  }

  void _ensureTabController() {
    if (!mounted || _isDisposing) return;

    final state = di<FetchGiftBloc>().state;
    final categories = _filteredGiftCategories(state);

    if (categories.isEmpty) {
      return;
    }

    final desiredLength = _desiredTabLength(categories);

    if (desiredLength <= 0) return;

    if (giftController != null &&
        giftController!.length == desiredLength) {
      return;
    }

    // The builder renders a compact loading placeholder whenever the old
    // controller length is stale, so replacing it here (post-frame) never
    // reparents a live TabBar/TabBarView tree.
    final oldController = giftController;
    final previousIndex = oldController?.index ?? 0;

    oldController?.dispose();

    final safeInitialIndex = previousIndex.clamp(
      0,
      desiredLength - 1,
    );

    final controller = TabController(
      length: desiredLength,
      vsync: this,
      initialIndex: safeInitialIndex,
    );

    controller.addListener(() {
      if (!mounted || _isDisposing) return;
      if (controller.indexIsChanging) return;

      final index = controller.index;

      if (_lastHandledTabIndex == index) {
        return;
      }

      _lastHandledTabIndex = index;

      final latestState = di<FetchGiftBloc>().state;
      final latestCategories =
      _filteredGiftCategories(latestState);

      _loadGiftTab(
        index,
        latestCategories,
      );
    });

    setState(() {
      giftController = controller;
      _lastHandledTabIndex = safeInitialIndex;
    });

    // First open: load the active category immediately after the controller
    // is safely attached.
    _loadGiftTab(
      safeInitialIndex,
      categories,
    );
  }

  void _loadGiftTab(
      int index,
      List<GiftCategoryEntity> filteredCategories,
      ) {
    if (_isDisposing || filteredCategories.isEmpty) {
      return;
    }

    final state = di<FetchGiftBloc>().state;

    final hasBagTab =
        !ConstantsManager.isTheme1 &&
            !ConstantsManager.isTheme2;

    if (hasBagTab &&
        index == filteredCategories.length) {
      GiftBottomBar.giftType = TypeGift.bag;

      if (state.bagReqState != RequestState.loaded) {
        di<FetchGiftBloc>().add(
          const FetchBagGiftEvent(),
        );
      } else {
        _selectFirstGift(
          state.bagGifts,
          categoryId: -2,
        );
      }
      return;
    }

    if (index < 0 ||
        index >= filteredCategories.length) {
      return;
    }

    final category = filteredCategories[index];

    GiftBottomBar.giftType =
        TypeGift.fromString(category.type);

    if (state.categoryId != category.id) {
      di<FetchGiftBloc>().add(
        SetCategoryIdEvent(category.id),
      );
    }

    if (state.getReqStateById(category.id) !=
        RequestState.loaded) {
      di<FetchGiftBloc>().add(
        FetchGiftsByCategoryEvent(
          categoryId: category.id,
          typeId: category.id,
        ),
      );
    } else {
      _selectFirstGift(
        state.getGiftsById(category.id),
        categoryId: category.id,
      );
    }
  }

  @override
  void dispose() {
    _isDisposing = true;

    final wasLucky =
        GiftBottomBar.typeCandy.value == TypeCandy.luckyCandy;

    if (wasLucky) {
      LuckyGiftService.instance.resetGuard();
      LuckyGiftService.instance.endAllLuckyGift();
    }

    GiftScreen.chosenGift = null;

    giftController?.dispose();
    giftController = null;

    // IMPORTANT:
    // Never write to global ValueNotifiers/Blocs while this widget's subtree
    // is inside Flutter's deactivate/finalize pass. Doing so produced:
    // - Looking up a deactivated widget's ancestor is unsafe
    // - Tried to build dirty widget in the wrong build scope
    // - Duplicate OverlayEntry GlobalKeys
    //
    // Reset them only after this route has finished leaving the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GiftBottomBar.typeCandy.value = TypeCandy.non;
      GiftTabBarWithSearchState.showBagGiftNotifier.value = false;
      GiftTabBarWithSearchState.showSearchNotifier.value = false;

      final state = di<FetchGiftBloc>().state;
      final categories = state.giftCategory.where((item) {
        if (item.type == 'lucky_gift') {
          return widget.isAudioRoom;
        }
        return true;
      }).toList(growable: false);

      if (categories.isNotEmpty) {
        di<FetchGiftBloc>().add(
          SetCategoryIdEvent(categories.first.id),
        );
      }

      di<GiftBloc>().add(
        const ChangeGiftDataEvent(
          numOfGift: -1,
          giftId: -1,
          giftPrice: -1,
          categoryId: -1,
        ),
      );
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FetchGiftBloc, FetchGiftsStates>(
      bloc: di<FetchGiftBloc>(),
      buildWhen: (previous, current) {
        return previous.reqStateGiftCategory != current.reqStateGiftCategory ||
            previous.categoryReqStates != current.categoryReqStates ||
            previous.bagReqState != current.bagReqState ||
            previous.searchReqState != current.searchReqState;
      },
      listener: (context, state) {
        // Categories are async. Build/rebuild the controller only after the
        // current frame; never dispose/replace a controller from inside the
        // active widget build/finalize pass.
        if (state.reqStateGiftCategory == RequestState.loaded) {
          final categories =
          _filteredGiftCategories(state);
          final desiredLength =
          _desiredTabLength(categories);

          if (categories.isNotEmpty &&
              (giftController == null ||
                  giftController!.length != desiredLength)) {
            _scheduleControllerInit();
          }
        }

        // Auto-select first gift when gifts are loaded for current category
        final currentCategoryId = state.categoryId;
        if (currentCategoryId != null &&
            state.getReqStateById(currentCategoryId) == RequestState.loaded) {
          final gifts = state.getGiftsById(currentCategoryId);
          if (gifts.isNotEmpty && GiftScreen.chosenGift == null) {
            _selectFirstGift(gifts, categoryId: currentCategoryId);
          }
        }

        // Auto-select first bag gift when bag is loaded
        if (state.bagReqState == RequestState.loaded &&
            GiftBottomBar.giftType == TypeGift.bag &&
            GiftScreen.chosenGift == null) {
          _selectFirstGift(state.bagGifts,
              categoryId: -2); // Use -2 for bag category
        }
      },
      builder: (context, state) {
        if (state.reqStateGiftCategory == RequestState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.reqStateGiftCategory == RequestState.error) {
          return Center(child: Text(state.msgGiftCategory));
        }

        final filteredCategories =
        _filteredGiftCategories(state);

        if (state.reqStateGiftCategory == RequestState.loaded &&
            filteredCategories.isNotEmpty) {
          final desiredLength =
          _desiredTabLength(filteredCategories);

          if (giftController == null ||
              giftController!.length != desiredLength) {
            _scheduleControllerInit();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.60,
              width: double.infinity,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        }
        final category = di<FetchGiftBloc>().state.giftCategory.firstWhere(
              (c) => c.id == di<FetchGiftBloc>().state.categoryId,
          orElse: () =>
          const GiftCategoryModel(id: -1, title: '', type: ''),
        );

        return ValueListenableBuilder<TypeCandy>(
          valueListenable: GiftBottomBar.typeCandy,
          builder: (BuildContext context, TypeCandy type, _) {
            if (type == TypeCandy.luckyCandy) {
              return SizedBox(
                height: MediaQuery.of(context).size.height / 5,
                child: GiftBottomBar(
                  roomData: widget.roomData,
                  isRoom: widget.isAudioRoom,
                  showData: false,
                  momentId: widget.momentId,
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
                  dialogBorderColor:
                  ColorManager.primary.withValues(alpha: 0.2),
                  numberFormatPrefix: 'item',
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
                child: ConstantsManager.isTheme1 ||
                    ConstantsManager.isTheme2
                    ? GiftRoomNewThemeDesign(
                  state: state,
                  filteredCategories: filteredCategories,
                  category: category,
                  giftController: giftController,
                  myDataModel: widget.myDataModel,
                  roomData: widget.roomData,
                  isAudioRoom: widget.isAudioRoom,
                  isSingleUser: widget.isSingleUser,
                  users: widget.users,
                  userId: widget.userId,
                  userImage: widget.userImage,
                  userName: widget.userName,
                  momentId: widget.momentId,
                )
                    : GiftRoomBaseDesign(
                  state: state,
                  filteredCategories: filteredCategories,
                  giftController: giftController,
                  myDataModel: widget.myDataModel,
                  roomData: widget.roomData,
                  isAudioRoom: widget.isAudioRoom,
                  isSingleUser: widget.isSingleUser,
                  users: widget.users,
                  userId: widget.userId,
                  userImage: widget.userImage,
                  userName: widget.userName,
                  momentId: widget.momentId,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';

part 'my_bag_event.dart';

part 'my_bag_state.dart';

class MyBagBloc extends Bloc<MyBagEvent, MyBagState> {
  final GetBackBagUseCase getBackPackUseCase;

  MyBagBloc({required this.getBackPackUseCase}) : super(const MyBagState()) {
    on<GetEntrieMyBagEvent>(getEntrieBackPack);
    on<GetFramesMyBagEvent>(getFrames);
    on<GetVipMyBagEvent>(getVip);
    on<GetBubbleBackPackMyBagEvent>(getBubble);
    on<GetSpecialIdMyBagEvent>(getSpecialId);
    on<GetProfileFrameMyBagEvent>(getProfileFrames);

    on<LocalChangeDataEvent>(localChangeData);
    on<ChangeAppBarUIEvent>(changeAppBarUI);
    on<SelectBagItemEvent>(_onSelectBagItem);
  }

  Future<void> getFrames(
      GetFramesMyBagEvent event, Emitter<MyBagState> emit) async {
    if (event.isLoading == true) {
      emit(state.copyWith(frameBagRequest: RequestState.loading));
    }

    final result = await getBackPackUseCase("4");
    result.fold(
      (failure) => emit(
        state.copyWith(
          frameBagRequest: handleErrorResponse(failure),
          frameBagMessage: NetworkExceptions.getErrorMessage(failure),
        ),
      ),
      (success) async {
        emit(
          state.copyWith(
            framesBag: success.data,
            frameBagRequest:
                handleLoadedResponse<List<MyBagEntity>>(success.data),
          ),
        );
        for (var element in (success.data ?? [])) {
          if (element.isDress == 1) {
            emit(
              state.copyWith(
                selectedItemFrame: element,
              ),
            );
            break;
          }
        }
      },
    );
  }

  Future<void> getVip(GetVipMyBagEvent event, Emitter<MyBagState> emit) async {
    if (event.isLoading == true) {
      emit(state.copyWith(vipBagRequest: RequestState.loading));
    }

    final result = await getBackPackUseCase("22");
    result.fold(
      (failure) => emit(
        state.copyWith(
          vipBagRequest: handleErrorResponse(failure),
          vipBagMessage: NetworkExceptions.getErrorMessage(failure),
        ),
      ),
      (success) async {
        emit(
          state.copyWith(
            vipBag: success.data,
            vipBagRequest:
                handleLoadedResponse<List<MyBagEntity>>(success.data),
          ),
        );
      },
    );
  }

  Future<void> getEntrieBackPack(
      GetEntrieMyBagEvent event, Emitter<MyBagState> emit) async {
    if (event.isLoading == true) {
      emit(state.copyWith(carBagRequest: RequestState.loading));
    }

    final result = await getBackPackUseCase("6");
    result.fold(
      (left) => emit(
        state.copyWith(
          carBagRequest: handleErrorResponse(left),
          carBagMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) {
        emit(
          state.copyWith(
            carsBag: right.data,
            carBagRequest: handleLoadedResponse<List<MyBagEntity>>(right.data),
          ),
        );
        for (var element in (right.data ?? [])) {
          if (element.isDress == 1) {
            emit(
              state.copyWith(
                selectedItemIntro: element,
              ),
            );
            break;
          }
        }
      },
    );
  }

  Future<void> getBubble(
      GetBubbleBackPackMyBagEvent event, Emitter<MyBagState> emit) async {
    if (event.isLoading == true) {
      emit(state.copyWith(bubbleBagRequest: RequestState.loading));
    }
    final result = await getBackPackUseCase("5");
    result.fold(
      (left) => emit(
        state.copyWith(
          bubbleBagRequest: handleErrorResponse(left),
          bubbleBagMessage: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) {
        emit(
          state.copyWith(
            bubblesBag: right.data,
            bubbleBagRequest:
                handleLoadedResponse<List<MyBagEntity>>(right.data),
          ),
        );
        for (var element in (right.data ?? [])) {
          if (element.isDress == 1) {
            emit(
              state.copyWith(
                selectedItemBubble: element,
              ),
            );
            break;
          }
        }
      },
    );
  }

  Future<void> getSpecialId(
      GetSpecialIdMyBagEvent event, Emitter<MyBagState> emit) async {
    if (event.isLoading == true) {
      emit(state.copyWith(emojisBagRequest: RequestState.loading));
    }

    final result = await getBackPackUseCase("25");
    result.fold(
      (left) => emit(state.copyWith(
          emojisBagRequest: handleErrorResponse(left),
          emojisBagMessage: NetworkExceptions.getErrorMessage(left))),
      (right) {
        emit(
          state.copyWith(
            emojisBag: right.data,
            emojisBagRequest:
                handleLoadedResponse<List<MyBagEntity>>(right.data),
          ),
        );
        for (var element in (right.data ?? [])) {
          if (element.isDress == 1) {
            emit(
              state.copyWith(
                selectedItemSpecialId: element,
              ),
            );
            break;
          }
        }
      },
    );
  }

  Future<void> getProfileFrames(
      GetProfileFrameMyBagEvent event, Emitter<MyBagState> emit) async {
    if (event.isLoading == true) {
      emit(state.copyWith(profileFrameRequest: RequestState.loading));
    }

    final result = await getBackPackUseCase("28");
    result.fold(
      (failure) => emit(
        state.copyWith(
          profileFrameRequest: handleErrorResponse(failure),
          profileFrameMessage: NetworkExceptions.getErrorMessage(failure),
        ),
      ),
      (success) async {
        emit(
          state.copyWith(
            profileFrames: success.data,
            profileFrameRequest:
                handleLoadedResponse<List<MyBagEntity>>(success.data),
          ),
        );
        for (var element in (success.data ?? [])) {
          if (element.isDress == 1) {
            emit(
              state.copyWith(
                selectedItemProfileFrame: element,
              ),
            );
            break;
          }
        }
      },
    );
  }

  Future<void> changeAppBarUI(
    ChangeAppBarUIEvent event,
    Emitter<MyBagState> emit,
  ) async {
    emit(state.copyWith(tabBarIndex: event.index));
  }

  Future<void> localChangeData(
    LocalChangeDataEvent event,
    Emitter<MyBagState> emit,
  ) async {
    if (event.tabType == MallOrBagType.frame) {
      emit(
        state.copyWith(
          framesBag: _handleTabType(
            bagList: state.framesBag,
            itemId: event.itemId,
            useType: event.useType,
            isVip: false,
          ),
        ),
      );
    }

    if (event.tabType == MallOrBagType.intro) {
      emit(
        state.copyWith(
          carsBag: _handleTabType(
            bagList: state.carsBag,
            itemId: event.itemId,
            useType: event.useType,
            isVip: false,
          ),
        ),
      );
    }

    if (event.tabType == MallOrBagType.bubble) {
      emit(
        state.copyWith(
          bubblesBag: _handleTabType(
            bagList: state.bubblesBag,
            itemId: event.itemId,
            useType: event.useType,
            isVip: false,
          ),
        ),
      );
    }

    if (event.tabType == MallOrBagType.specialId) {
      emit(
        state.copyWith(
          emojisBag: _handleTabType(
            bagList: state.emojisBag,
            itemId: event.itemId,
            useType: event.useType,
            isVip: false,
          ),
        ),
      );
    }
    if (event.tabType == MallOrBagType.vip) {
      emit(
        state.copyWith(
          vipBag: _handleTabType(
            bagList: state.vipBag,
            itemId: event.itemId,
            useType: event.useType,
            isVip: true,
          ),
        ),
      );
    }

    if (event.tabType == MallOrBagType.profileFrame) {
      emit(
        state.copyWith(
          profileFrames: _handleTabType(
            bagList: state.profileFrames,
            itemId: event.itemId,
            useType: event.useType,
            isVip: false,
          ),
        ),
      );
    }
  }

  List<MyBagEntity> _handleTabType({
    required List<MyBagEntity> bagList,
    required String itemId,
    required bool useType,
    required bool isVip,
  }) {
    final List<MyBagEntity> result = List<MyBagEntity>.from(bagList);
    if (useType == true) {
      for (int i = 0; i < result.length; i++) {
        if (isVip) {
          if (itemId == result[i].id.toString()) {
            result[i] = result[i].copyWith(isUsed: true, use: true);
          } else {
            result[i] = result[i].copyWith(use: false);
          }
        } else {
          if (itemId == result[i].id.toString()) {
            result[i] = result[i].copyWith(isUsed: true);
          } else {
            result[i] = result[i].copyWith(isUsed: false);
          }
        }
      }
    } else {
      final index = result.indexWhere(
        (element) => element.id.toString() == itemId,
      );
      if (isVip) {
        result[index] = result[index].copyWith(use: result[index].isUsed);
      } else {
        result[index] = result[index].copyWith(isUsed: false);
      }
    }
    return result;
  }

  Future<void> _onSelectBagItem(
    SelectBagItemEvent event,
    Emitter<MyBagState> emit,
  ) async {
    if (event.type == 0) {
      emit(
        state.copyWith(
          selectedItemBubble: event.selectedItem,
          isBubbleNull: event.selectedItem == null ? true : false,
        ),
      );
    } else if (event.type == 1) {
      emit(
        state.copyWith(
          selectedItemFrame: event.selectedItem,
          isFrameNull: event.selectedItem == null ? true : false,
        ),
      );
    } else if (event.type == 2) {
      emit(
        state.copyWith(
          selectedItemIntro: event.selectedItem,
          isIntroNull: event.selectedItem == null ? true : false,
        ),
      );
    } else if (event.type == 3) {
      emit(
        state.copyWith(
          selectedItemSpecialId: event.selectedItem,
          isSpecialIdNull: event.selectedItem == null ? true : false,
        ),
      );
    } else if (event.type == 4) {
      emit(
        state.copyWith(
          selectedItemProfileFrame: event.selectedItem,
          isProfileFrameNull: event.selectedItem == null ? true : false,
        ),
      );
    } else {
      emit(state.copyWith(selectedItem: event.selectedItem));
    }
  }
}

import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';
import 'package:general/src/features/vip/domain/use_case/get_vip_center_use_case.dart';
import 'package:general/src/features/vip/domain/use_case/use_vip.dart';
import 'package:general/src/features/vip/presentation/bloc/vip_center/vip_center_event.dart';
import 'package:general/src/features/vip/presentation/bloc/vip_center/vip_center_state.dart';

import '../../../data/models/vip_bag_item_model.dart';
import '../../../domain/entity/vip_bag_item_entity.dart';
import '../../../domain/use_case/get_vip_user_bag_uc.dart';
import '../../../domain/use_case/send_vip_uc.dart';

class VipCenterBloc extends Bloc<VipCenterEvents, VipStates> {
  final GetVipCenterUseCase fetchVipCenterUseCase;
  final UseVipUseCase useVipUseCase;
  final SendVipUc sendVips;
  final GetVipUserBagUc getVipMyBag;

  VipCenterBloc({
    required this.fetchVipCenterUseCase,
    required this.useVipUseCase,
    required this.sendVips,
    required this.getVipMyBag,
  }) : super(const VipStates()) {
    on<GetVipCenterEvent>(_getVipCenterEvent);
    on<ChangeTabEvent>(_changeTabEvent);
    on<ChangeBackgroundEvent>(_changeBackgroundEvent);
    on<ChangeBackgroundVipEvent>(_changeBackgroundVipEvent);
    on<UseAndUnuseVipEvent>(_useAndUnuseVipEvent);
    on<SendVipEvent>(_sendVipEvent);
    on<GetVipBagEvent>(_getVipMyBagEvent);
    on<LocalChangVipDataEvent>(_localChangeData);
  }

  Future<void> _getVipCenterEvent(
      GetVipCenterEvent event, Emitter<VipStates> emit) async {
    if (event.isLoading == true) {
      emit(state.copyWith(requestState: RequestState.loading));
    }
    final result = await fetchVipCenterUseCase();
    result.fold(
      (left) {
        emit(
          state.copyWith(
            requestState: handleErrorResponse(left),
            message: NetworkExceptions.getErrorMessage(left),
          ),
        );
      },
      (right) {
        final List<VipCenterEntity> vipList =
            right.data!.where((privilege) => privilege.isBuy == true).toList();
        emit(
          state.copyWith(
              requestState:
                  handleLoadedResponse<List<VipCenterEntity>>(right.data),
              vip: right.data,
              boughtvip: vipList),
        );
      },
    );
  }

  Future<void> _getVipMyBagEvent(
      GetVipBagEvent event, Emitter<VipStates> emit) async {
    emit(state.copyWith(requestStateVipBag: RequestState.loading));

    final result = await getVipMyBag();
    result.fold(
      (left) {
        emit(
          state.copyWith(
            requestStateVipBag: handleErrorResponse(left),
            vipBagMessage: NetworkExceptions.getErrorMessage(left),
          ),
        );
      },
      (right) {
        // final List<VipCenterEntity> vipList =
        //     right.data!.where((privilege) => privilege.isBuy == true).toList();
        emit(
          state.copyWith(
            requestStateVipBag:
                handleLoadedResponse<List<VipBagItemModel>>(right.data),
            vipBag: right.data,
          ),
        );
      },
    );
  }

  Future<void> _sendVipEvent(
      SendVipEvent event, Emitter<VipStates> emit) async {
    Methods.showToast(event.context,
        message: StringManager.done.tr(), isLoading: true);
    final result = await sendVips(BuyVipParameter(
      type: '0',
      uuid: event.userId,
      vipId: event.targetId,
    ));
    result.fold(
      (left) {
        emit(
          state.copyWith(
            sendVipState: handleErrorResponse(left),
            sendVipMessage: NetworkExceptions.getErrorMessage(left),
          ),
        );
      },
      (right) {
        // final List<VipCenterEntity> vipList =
        //     right.data!.where((privilege) => privilege.isBuy == true).toList();
        emit(
          state.copyWith(
            sendVipState: RequestState.loaded,
            sendVipMessage: right,
          ),
        );

        Methods.showToast(event.context, message: StringManager.done.tr());
      },
    );
  }

  void _changeTabEvent(ChangeTabEvent event, Emitter<VipStates> emit) {
    emit(state.copyWith(selectedTab: event.selectedIndex));
  }

  void _changeBackgroundEvent(
      ChangeBackgroundEvent event, Emitter<VipStates> emit) {
    emit(state.copyWith(selectedBg: event.selectedIndex + 1));
  }

  void _changeBackgroundVipEvent(
      ChangeBackgroundVipEvent event, Emitter<VipStates> emit) {
    emit(state.copyWith(selectedBg: event.index + 1));
  }

  Future<void> _useAndUnuseVipEvent(
      UseAndUnuseVipEvent event, Emitter<VipStates> emit) async {
    emit(state.copyWith(reqStateUseUnuse: RequestState.loading));
    Methods.showToast(event.context, isLoading: true);
    final result = await useVipUseCase(
      BuyVipParameter(
        type: event.type,
        vipId: event.targetId,
      ),
    );

    result.fold(
      (left) => emit(
        state.copyWith(
          reqStateUseUnuse: RequestState.error,
          message: NetworkExceptions.getErrorMessage(left),
        ),
      ),
      (right) {
        emit(
          state.copyWith(
            reqStateUseUnuse: RequestState.loaded,
            message: right,
          ),
        );
        add(
          LocalChangVipDataEvent(
            targetId: event.targetId,
            useType: event.type == '0' ? false : true,
          ),
        );
        UsersCache().removeUser(MyDataModel.getInstance().id ?? -1);
        di<FetchUserDataBloc>().add(const FetchMyDataEvent(isLoading: false));
        Methods.showToast(event.context, message: StringManager.done.tr());
      },
    );
  }

  FutureOr<void> _localChangeData(
      LocalChangVipDataEvent event, Emitter<VipStates> emit) async {
    final List<VipBagItemEntity> result =
        List<VipBagItemEntity>.from(state.vipBag);

    if (event.useType == true) {
      for (int index = 0; index < result.length; index++) {
        if (event.targetId == result[index].targetId.toString()) {
          result[index] = result[index].copyWith(isUsed: true, using: true);
        } else {
          result[index] = result[index].copyWith(isUsed: false);
        }
      }
    } else {
      final index = result.indexWhere(
        (element) => element.targetId.toString() == event.targetId,
      );
      result[index] = result[index].copyWith(isUsed: false);
    }
    emit(state.copyWith(vipBag: result));
  }
}

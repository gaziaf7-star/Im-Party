import 'package:equatable/equatable.dart';
import 'package:general/src/core/constants/enums.dart';
import 'package:general/src/features/auth/auth.dart';

import '../../../domain/entity/vip_bag_item_entity.dart';

class VipStates extends Equatable {
  final List<VipCenterEntity> vip;
  final List<VipCenterEntity> boughtvip;
  final String message;
  final RequestState requestState, reqStateUseUnuse;
  final int selectedTab;
  final int selectedBg;
  final int vipBackground;
  final List<VipBagItemEntity> vipBag;
  final RequestState requestStateVipBag;
  final String vipBagMessage;

  final RequestState sendVipState;
  final String sendVipMessage;

  const VipStates({
    this.vip = const [],
    this.boughtvip = const [],
    this.vipBag = const [],
    this.message = '',
    this.vipBagMessage = '',
    this.sendVipMessage = '',
    this.requestState = RequestState.idle,
    this.requestStateVipBag = RequestState.idle,
    this.sendVipState = RequestState.idle,
    this.selectedTab = 1,
    this.selectedBg = 1,
    this.vipBackground = 1,
    this.reqStateUseUnuse = RequestState.idle,
  });

  VipStates copyWith({
    List<VipCenterEntity>? vip,
    List<VipCenterEntity>? boughtvip,
    String? message,
    RequestState? requestState,
    RequestState? reqStateUseUnuse,
    int? selectedTab,
    int? selectedBg,
    int? vipBackground,
    List<VipBagItemEntity>? vipBag,
    RequestState? requestStateVipBag,
    String? vipBagMessage,
    RequestState? sendVipState,
    String? sendVipMessage,
  }) {
    return VipStates(
      vip: vip ?? this.vip,
      boughtvip: boughtvip ?? this.boughtvip,
      message: message ?? this.message,
      requestState: requestState ?? this.requestState,
      reqStateUseUnuse: reqStateUseUnuse ?? this.reqStateUseUnuse,
      selectedTab: selectedTab ?? this.selectedTab,
      selectedBg: selectedBg ?? this.selectedBg,
      vipBackground: vipBackground ?? this.vipBackground,
      vipBag: vipBag ?? this.vipBag,
      requestStateVipBag: requestStateVipBag ?? this.requestStateVipBag,
      vipBagMessage: vipBagMessage ?? this.vipBagMessage,
      sendVipState: sendVipState ?? this.sendVipState,
      sendVipMessage: sendVipMessage ?? this.sendVipMessage,
    );
  }

  @override
  List<Object?> get props => [
        vip,
        boughtvip,
        message,
        requestState,
        selectedTab,
        selectedBg,
        reqStateUseUnuse,
        vipBackground,
        vipBag,
        requestStateVipBag,
        vipBagMessage,
        sendVipState,
        sendVipMessage,
      ];
}

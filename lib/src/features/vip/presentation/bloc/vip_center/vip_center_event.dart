import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class VipCenterEvents extends Equatable {
  const VipCenterEvents();
  @override
  List<Object?> get props => [];
}

class GetVipCenterEvent extends VipCenterEvents {
  final bool isLoading ;
  const GetVipCenterEvent({this.isLoading = true});

    @override
  List<Object?> get props => [isLoading];
}

class ChangeTabEvent extends VipCenterEvents {
  final int selectedIndex;
  const ChangeTabEvent(this.selectedIndex);
}

class ChangeUseLocalEvent extends VipCenterEvents {
  final int selectedIndex;
  const ChangeUseLocalEvent(this.selectedIndex);
}

class ChangeBackgroundEvent extends VipCenterEvents {
  final int selectedIndex;
  const ChangeBackgroundEvent(this.selectedIndex);
}
class ChangeBackgroundVipEvent extends VipCenterEvents {
  final int index;
  const ChangeBackgroundVipEvent(this.index);
}

class UseAndUnuseVipEvent extends VipCenterEvents {
  final String type;
  final String targetId;
  final BuildContext context;
  const UseAndUnuseVipEvent({
    required this.type,
    required this.targetId,
    required this.context,
  });
}

class GetVipBagEvent extends VipCenterEvents {
  const GetVipBagEvent();
}

class SendVipEvent extends VipCenterEvents {
  final String userId;
  final String targetId;
  final BuildContext context;
  const SendVipEvent({
    required this.userId,
    required this.targetId,
    required this.context,
  });
}

class LocalChangVipDataEvent extends VipCenterEvents {
  final String targetId;
  final bool useType;

  const LocalChangVipDataEvent({required this.targetId,
    required this.useType,
  });
}
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class BaseBuyVipEvent extends Equatable {
  const BaseBuyVipEvent();

  @override
  List<Object> get props => [];
}

class BuyVipEvent extends BaseBuyVipEvent {
  final String type;
  final String vipId;
  final String? toUid;
  final BuildContext context;
  const BuyVipEvent(
      {this.toUid,required this.type, required this.vipId, required this.context,});
}

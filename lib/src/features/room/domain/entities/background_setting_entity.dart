import 'package:equatable/equatable.dart';

class BackGroundSettingEntity extends Equatable {
  final String? cost;
  final String? expire;

  const BackGroundSettingEntity({ this.cost,  this.expire});

  @override
  List<Object?> get props => [cost, expire];
}
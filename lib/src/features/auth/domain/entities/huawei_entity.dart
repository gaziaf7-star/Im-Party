import 'package:general/src/core/index.dart';

class HuaweiEntity extends Equatable {
  final AuthAccount huawei;
  final MyDataModel data;

  const HuaweiEntity({required this.huawei, required this.data});

  @override
  List<Object?> get props => [huawei, data];
}
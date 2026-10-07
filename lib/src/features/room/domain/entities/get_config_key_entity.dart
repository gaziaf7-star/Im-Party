import 'package:equatable/equatable.dart';

class GetConfigKeyEntity extends Equatable {
  final String? specialBar;
  final int? wapelNum;
  final int? userCoin;
  final String? userCoinString;
  final String? familyPrice;

  const GetConfigKeyEntity({
    this.specialBar,
    this.wapelNum,
    this.userCoin,
    this.userCoinString,
    this.familyPrice,
  });

  @override
  List<Object?> get props => [specialBar, wapelNum, userCoin, userCoinString, familyPrice];
}

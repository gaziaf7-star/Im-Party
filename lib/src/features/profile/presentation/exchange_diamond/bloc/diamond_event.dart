part of'diamond_bloc.dart';

abstract class DiamondEvent extends Equatable {
  const DiamondEvent();

  @override
  List<Object> get props => [];
}

class GetDiamondDataEvent extends DiamondEvent {
final  bool isLoading;

  const GetDiamondDataEvent({this.isLoading = false});
}

class ExchangeDiamondEvent extends DiamondEvent {
  final String itemId;
  final BuildContext context;
  const ExchangeDiamondEvent({required this.itemId,required this.context});
  @override
  List<Object> get props => [
    itemId,
    context,
  ];
}

class SelectDiamondEvent extends DiamondEvent {
  final String itemId;
  final int coins;
  final int diamonds;
  const SelectDiamondEvent({
    required this.itemId,
    required this.coins,
    required this.diamonds,
  });
  @override
  List<Object> get props => [
    coins,
    diamonds,
  ];

}
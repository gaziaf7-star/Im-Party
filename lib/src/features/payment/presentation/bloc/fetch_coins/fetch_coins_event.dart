import 'package:equatable/equatable.dart';

abstract class BaseCoinsEvent extends Equatable {
  const BaseCoinsEvent();

  @override
  List<Object> get props => [];
}

class FetchCoinsEvent extends BaseCoinsEvent {

  final String? type;

  const FetchCoinsEvent( { this.type});
}
class CheckBoxEvent extends BaseCoinsEvent {
final bool isChecked;
  const CheckBoxEvent({this.isChecked=false});
}
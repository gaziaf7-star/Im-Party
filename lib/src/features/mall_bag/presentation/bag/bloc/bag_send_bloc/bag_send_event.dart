part of 'bag_send_bloc.dart';


abstract class BagSendEvent extends Equatable{

  @override
  List<Object?> get props => [];

  const BagSendEvent();
}
class SendBagItemEvent extends BagSendEvent {
  BuildContext context;
  final SendBagParam param;

  SendBagItemEvent({required this.param,required this.context});
}

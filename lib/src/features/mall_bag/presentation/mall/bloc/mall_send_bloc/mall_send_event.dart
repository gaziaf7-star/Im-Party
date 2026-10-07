part of 'mall_send_bloc.dart';

abstract class MallSendEvent extends Equatable {
  const MallSendEvent();

  @override
  List<Object> get props => [];
}

class SendItemEvent extends MallSendEvent {
  BuildContext context;
  final SendMallParam param;

   SendItemEvent({required this.param,required this.context});
}

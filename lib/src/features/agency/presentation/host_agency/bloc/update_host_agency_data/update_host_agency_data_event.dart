part of 'update_host_agency_data_bloc.dart';

sealed class BaseUpdateHostAgencyDataEvent extends Equatable {
  const BaseUpdateHostAgencyDataEvent();
}

class UpdateHostAgencyDataEvent extends BaseUpdateHostAgencyDataEvent {
  final UpdateAgencyParam param;

  const UpdateHostAgencyDataEvent(this.param);

  @override
  List<Object?> get props => [param];
}

class PickImageEvent extends BaseUpdateHostAgencyDataEvent {
  final ImageSource source;

  const PickImageEvent(this.source);

  @override
  List<Object?> get props => [source];
}
class AddTheImageEvent extends BaseUpdateHostAgencyDataEvent {
  final ImageSource source;

  const AddTheImageEvent(this.source);

  @override
  List<Object?> get props => [source];
}

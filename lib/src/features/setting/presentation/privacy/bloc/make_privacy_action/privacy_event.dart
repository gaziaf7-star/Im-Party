part of'privacy_bloc.dart';

abstract class PrivacyEvent extends Equatable {
  @override
  List<Object?> get props => [];

}


class ActivePrivacy extends PrivacyEvent {
  final String type;
  ActivePrivacy({required this.type});


}

class DisposePrivacy extends PrivacyEvent {
  final String type;
  DisposePrivacy({required this.type});

}

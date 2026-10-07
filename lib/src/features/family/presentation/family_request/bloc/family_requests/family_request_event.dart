part of 'family_request_bloc.dart';

abstract class BaseFamilyRequestEvent extends Equatable {
  const BaseFamilyRequestEvent();

  @override
  List<Object?> get props => const [];
}

class GetFamilyRequestEvent extends BaseFamilyRequestEvent {
  final bool isLoading;
  const GetFamilyRequestEvent({this.isLoading=true});
}

class LocalEditRequestEvent extends BaseFamilyRequestEvent {
  final String userId;
  const LocalEditRequestEvent({required this.userId});
}

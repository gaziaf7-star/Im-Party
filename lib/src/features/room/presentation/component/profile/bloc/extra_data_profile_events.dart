part of 'extra_data_profile_bloc.dart';


abstract class ExtraProfileDataEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchExtraDataProfile extends ExtraProfileDataEvent {
  final String userId;

  FetchExtraDataProfile(
      {required this.userId});
  @override
  List<Object?> get props => [userId];
}


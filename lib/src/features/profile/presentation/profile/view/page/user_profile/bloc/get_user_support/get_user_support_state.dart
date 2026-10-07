import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/data/model/top_support.dart';

class GetUserSupporterState extends Equatable {
  final TopSupportModel? topSupport ;
  final RequestState requestState;
  final RequestState requestOtherUsersState;
  final String massage;
  final String? loadedUserId;


  const GetUserSupporterState({
    this.topSupport,
    this.massage='',
    this.requestState=RequestState.idle,
    this.requestOtherUsersState=RequestState.idle,
    this.loadedUserId,

  });

  GetUserSupporterState copyWith({
    TopSupportModel? topSupport ,
    final String? massage,

    RequestState? requestState,
    RequestState? requestOtherUsersState,
    String? loadedUserId,
  }) {
    return GetUserSupporterState(
      topSupport: topSupport ?? this.topSupport,
      requestState: requestState ?? this.requestState,
      requestOtherUsersState: requestOtherUsersState ?? this.requestOtherUsersState,
      massage: massage ?? this.massage,
      loadedUserId: loadedUserId ?? this.loadedUserId,

    );
  }

  @override
  List<Object?> get props => [
    topSupport,
    requestState,
    requestOtherUsersState,
    loadedUserId,
  ];
}
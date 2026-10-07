part of 'get_user_profile_bloc.dart';

class GetUserProfilesState extends Equatable {
  final List<UserProfileModel> userProfileModel;
  final RequestState reqState;
  final String message;
  final ScrollController scrollController;
  final int currentPage, lastPage;

  const GetUserProfilesState({
    this.userProfileModel = const [],
    this.reqState = RequestState.loading,
    this.message = '',
    required this.scrollController,
    this.currentPage = 1,
    this.lastPage = -1,
  });

  GetUserProfilesState copyWith({
    String? message,
    List<UserProfileModel>? userProfileModel,
    RequestState? reqState,
    ScrollController? scrollController,
    int? currentPage,
    int? lastPage,
  }) {
    return GetUserProfilesState(
      message: message ?? this.message,
      userProfileModel: userProfileModel ?? this.userProfileModel,
      reqState: reqState ?? this.reqState,
      scrollController: scrollController ?? this.scrollController,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
    );
  }

  @override
  List<Object?> get props => [
        userProfileModel,
        reqState,
        message,
        scrollController,
        currentPage,
        lastPage,
      ];
}

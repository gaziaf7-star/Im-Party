part of 'get_all_family_bloc.dart';

class GetAllFamilyState extends Equatable {
  final RequestState req;
  final String errorMessage;
  final List<FamilyRankModel>? allFamilies;
  final int tabBarIndex;


  const GetAllFamilyState({
    this.req = RequestState.idle,
    this.errorMessage = '',
    this.allFamilies,
    this.tabBarIndex = 0,

  });

  GetAllFamilyState copyWith({
    RequestState? req,
    String? errorMessage,
    List<FamilyRankModel>? allFamilies,
    int? tabBarIndex,

  }) {
    return GetAllFamilyState(
      req: req ?? this.req,
      errorMessage: errorMessage ?? this.errorMessage,
      allFamilies: allFamilies ?? this.allFamilies,
      tabBarIndex: tabBarIndex ?? this.tabBarIndex,

    );
  }

  @override
  List<Object?> get props => [
  req,
  errorMessage,
  allFamilies,
  tabBarIndex,
  ];
}

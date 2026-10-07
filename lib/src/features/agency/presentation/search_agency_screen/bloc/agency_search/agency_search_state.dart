part of 'agency_search_bloc.dart';

class AgencySearchState extends Equatable {
  final RequestState state;
  final AgencySearchModel? agencySearchModel;
  final String? error;
  final RequestState agencyState;
  final AgencySearchModel? agencyModel;
  final String? agencyError;
  final List<FormEntity>? formListEntity;
  final RequestState formListState;
  final String? formListError;

  // [Pagination] regular (typed) agency search.
  final ScrollController agencyScrollCtrl;
  final int agencyCurrentPage;
  final int agencyLastPage;
  final bool isPaginatingAgency;

  AgencySearchState({
    this.state = RequestState.idle,
    this.agencySearchModel,
    this.error,
    this.agencyState = RequestState.idle,
    this.agencyModel,
    this.agencyError,
    this.formListEntity = const [],
    this.formListState = RequestState.idle,
    this.formListError,
    ScrollController? agencyScrollCtrl,
    this.agencyCurrentPage = 1,
    this.agencyLastPage = -1,
    this.isPaginatingAgency = false,
  }) : agencyScrollCtrl = agencyScrollCtrl ?? ScrollController();

  AgencySearchState copyWith({
    RequestState? state,
    AgencySearchModel? agencySearchModel,
    String? error,
    RequestState? agencyState,
    AgencySearchModel? agencyModel,
    String? agencyError,
    List<FormEntity>? formListEntity,
    RequestState? formListState,
    String? formListError,
    ScrollController? agencyScrollCtrl,
    int? agencyCurrentPage,
    int? agencyLastPage,
    bool? isPaginatingAgency,
  }) {
    return AgencySearchState(
      state: state ?? this.state,
      agencySearchModel: agencySearchModel ?? this.agencySearchModel,
      error: error ?? this.error,
      agencyState: agencyState ?? this.agencyState,
      agencyModel: agencyModel ?? this.agencyModel,
      agencyError: agencyError ?? this.agencyError,
      formListEntity: formListEntity ?? this.formListEntity,
      formListState: formListState ?? this.formListState,
      formListError: formListError ?? this.formListError,
      agencyScrollCtrl: agencyScrollCtrl ?? this.agencyScrollCtrl,
      agencyCurrentPage: agencyCurrentPage ?? this.agencyCurrentPage,
      agencyLastPage: agencyLastPage ?? this.agencyLastPage,
      isPaginatingAgency: isPaginatingAgency ?? this.isPaginatingAgency,
    );
  }

  @override
  List<Object?> get props => [
        state,
        agencySearchModel,
        error,
        agencyState,
        agencyModel,
        agencyError,
        formListEntity,
        formListState,
        formListError,
        agencyCurrentPage,
        agencyLastPage,
        isPaginatingAgency,
      ];
}

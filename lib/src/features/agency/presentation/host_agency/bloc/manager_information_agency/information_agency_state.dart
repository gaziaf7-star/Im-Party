part of 'information_agency_bloc.dart';

class InformationAgencyState extends Equatable {
  final InformationAgencyEntity? data;
  final String? error;
  final String? month;
  final String? year;
  final List<StarEntity>? nowStars;
  final List<StarEntity>? nowAdmins;
  final RequestState requestState;
  final int rebuildForTheListner;
  final bool resetTheController;

  const InformationAgencyState({
    this.data,
    this.error,
    this.month,
    this.year,
    this.nowStars,
    this.nowAdmins,
    this.resetTheController = true,
    this.rebuildForTheListner = 0,
    this.requestState = RequestState.idle,
  });

  // CopyWith method to create a new instance with modified values
  InformationAgencyState copyWith(
      {InformationAgencyEntity? data,
        String? error,
        String? month,
        String? year,
        bool? resetTheController,
        List<StarEntity>? nowStars,
        List<StarEntity>? nowAdmins,
        RequestState? requestState,
        int? rebuildForTheListner}) {
    return InformationAgencyState(
      data: data ?? this.data,
      error: error ?? this.error,
      year: year ?? this.year,
      resetTheController: resetTheController ?? this.resetTheController,
      month: month ?? this.month,
      nowStars: nowStars ?? this.nowStars,
      nowAdmins: nowAdmins ?? this.nowAdmins,
      requestState: requestState ?? this.requestState,
      rebuildForTheListner: rebuildForTheListner ?? this.rebuildForTheListner,
    );
  }

  @override
  List<Object?> get props => [
    data,
    error,
    requestState,
    month,
    year,
    rebuildForTheListner,
    nowStars,
    resetTheController,
    nowAdmins
  ];
}

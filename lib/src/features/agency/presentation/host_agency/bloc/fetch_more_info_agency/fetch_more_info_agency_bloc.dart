import 'package:general/src/features/agency/data/model/agency_more_info_model.dart';

import '../../../../../../../reels_viewer/reels_viewer.dart';
import '../../../../agency.dart';
import '../../../../domain/entity/agency_more_info_entity.dart';
import '../../../../domain/use_case/fetch_more_info_agency.dart';

part 'fetch_more_info_agency_event.dart';

part 'fetch_more_info_agency_state.dart';

class FetchMoreInfoAgencyBloc
    extends Bloc<FetchMoreInfoAgencyEvent, FetchMoreInfoAgencyState> {
  final FetchMoreInfoAgencyUC useCase;
  final HostSAgencyDataUC hostSAgencyDataUC;

  FetchMoreInfoAgencyBloc(this.useCase, this.hostSAgencyDataUC)
      : super(FetchMoreInfoAgencyState(
            userTargetScrollCtrl: ScrollController())) {
    on<FetchMoreInfoForMonthEvent>((event, emit) async {
      final result = await useCase(AgencyHistoryParam(
          month: event.month,
          year: event.year,
          agencyId: event.agencyId,
          page: state.userTargetCurrentPage.toString()));
      result.fold((l) {
        _isPaginationLoading = false;
        emit(state.copyWith(
            requestState: RequestState.error,
            message: NetworkExceptions.getErrorMessage(l),
            isPagination: false));
      }, (r) {
        final newUsers = r.data?.usersTarget ?? [];
        final updatedUsers = state.userTargetCurrentPage > 1
            ? [
                ...(state.entity?.usersTarget ?? <UserTargetEntity>[]),
                ...newUsers
              ]
            : newUsers;
        final updatedEntity = state.userTargetCurrentPage > 1
            ? state.entity?.copyWith(usersTarget: updatedUsers)
            : r.data;

        _isPaginationLoading = false;
        emit(state.copyWith(
          requestState: RequestState.loaded,
          entity: updatedEntity,
          userTargetLastPage: r.paginates?.lastPage ?? state.userTargetLastPage,
          isPagination: false,
        ));
      });
    });
    on<HostSAgencyDataUCEvent>((event, emit) async {
      emit(state.copyWith(hostsRequestState: RequestState.loading));

      final result = await hostSAgencyDataUC(AgencyHistoryParam(
        month: event.month,
        year: event.year,
        agencyId: event.agencyId,
      ));

      result.fold(
        (l) {
          emit(state.copyWith(
            hostsRequestState: RequestState.error,
            hostsMessage: NetworkExceptions.getErrorMessage(l),
          ));
        },
        (r) {
          emit(state.copyWith(
            hostsRequestState: RequestState.loaded,
            hostSAgencyDataModel: r.data,
          ));
        },
      );
    });
    on<AddUserTargetScrollListenerEvent>(_onAddUserTargetScrollListener);
    on<RemoveUserTargetScrollListenerEvent>(_onRemoveUserTargetScrollListener);
  }

  bool _isPaginationLoading = false;

  void userTargetScrollListener() {
    handleScrollListener(
      controller: state.userTargetScrollCtrl,
      currentPage: state.userTargetCurrentPage,
      lastPage: state.userTargetLastPage,
      fun: () {
        if (_isPaginationLoading) return;
        _isPaginationLoading = true;

        final nextPage = state.userTargetCurrentPage + 1;
        secondTabAgencyTimeFilter.value =
            "${DateTime.now().year} / ${DateTime.now().month}";
        emit(state.copyWith(
            userTargetCurrentPage: nextPage, isPagination: true));

        add(FetchMoreInfoForMonthEvent(
            month: secondTabAgencyTimeFilter.value.split('/')[1],
            year: secondTabAgencyTimeFilter.value.split('/')[0],
            agencyId:
                (MyDataModel.getInstance().myAgencyModel?.id ?? 0).toString(),
            page: ''));
      },
    );
  }

  void _onAddUserTargetScrollListener(
    AddUserTargetScrollListenerEvent event,
    Emitter<FetchMoreInfoAgencyState> emit,
  ) {
    final scrollCtrl = state.userTargetScrollCtrl
      ..addListener(userTargetScrollListener);
    emit(state.copyWith(userTargetScrollCtrl: scrollCtrl));
  }

  void _onRemoveUserTargetScrollListener(
    RemoveUserTargetScrollListenerEvent event,
    Emitter<FetchMoreInfoAgencyState> emit,
  ) {
    final scrollCtrl = state.userTargetScrollCtrl
      ..removeListener(userTargetScrollListener);
    emit(state.copyWith(userTargetScrollCtrl: scrollCtrl));
  }
}

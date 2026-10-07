import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/loading_dialog_widget.dart';
import 'package:general/src/core/widgets/web_view_preloader.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/domain/entity/form_entity.dart';
import 'package:general/src/features/agency/domain/use_case/fetch_form_uc.dart';

part 'agency_search_event.dart';

part 'agency_search_state.dart';

class AgencySearchBloc extends Bloc<BaseAgencySearchEvent, AgencySearchState> {
  final AgencySearchUC agencySearchUC;
  final FetchFormUc fetchFormUc;
  String _latestQuery = '';

  AgencySearchBloc({required this.agencySearchUC, required this.fetchFormUc})
    : super(AgencySearchState()) {
    on<FetchFixedAgencyEvent>((event, emit) async {
      emit(state.copyWith(state: RequestState.loading));

      final result = await agencySearchUC(AgencySearchParam(id: event.id));
      result.fold(
        (left) {
          emit(
            state.copyWith(
              state: RequestState.error,
              error: NetworkExceptions.getErrorMessage(left),
            ),
          );
        },
        (right) {
          emit(
            state.copyWith(
              state: RequestState.loaded,
              agencySearchModel: right.data,
            ),
          );
        },
      );
    });

    on<FetchFormListEvent>((event, emit) async {
      showCustomLoadingDialog(event.context);
      emit(state.copyWith(formListState: RequestState.loading));

      final result = await fetchFormUc(event.type);

      if (result.isLeft()) {
        result.fold((left) {
          if (event.context.mounted) Navigator.pop(event.context);
          emit(
            state.copyWith(
              formListState: RequestState.error,
              formListError: NetworkExceptions.getErrorMessage(left),
            ),
          );
        }, (_) {});
        return;
      }

      // Handle success case
      final right = result.getOrElse(() => throw Exception());

      if (right.data?.isNotEmpty == true) {
        final FormEntity? formEntity = right.data?.first;

        if (formEntity?.formType == "host_agency") {
          final token = Methods.getUserToken();
          final lang = Methods.getLang();

          final baseUrl = EndPoints.resolveUrl(
            formEntity?.link,
            baseUrl: EndPoints.domainURL,
          );

          final uri = Uri.parse(baseUrl).replace(
            queryParameters: {
              ...Uri.parse(baseUrl).queryParameters,
              'token': token,
              'lang': lang,
            },
          );

          Methods.printLog("final_uri ------> ${uri.toString()}");

          // Preload WebView before navigation
          final preloadedController = await WebViewPreloader.preload(
            uri.toString(),
          );

          // event.context may be stale after the preload await — guard it.
          if (event.context.mounted) {
            Navigator.pop(event.context);
            Navigator.pushNamed(
              event.context,
              Routes.webViewEvents,
              arguments: {
                'url': uri.toString(),
                'type': 'events',
                'needLoading': false,
                'preloadedController': preloadedController,
              },
            );
          }
        } else {
          if (event.context.mounted) Navigator.pop(event.context);
        }
      } else {
        if (event.context.mounted) Navigator.pop(event.context);
      }

      emit(
        state.copyWith(
          formListState: RequestState.loaded,
          formListEntity: right.data,
        ),
      );
    });

    on<FetchRegularAgencyEvent>((event, emit) async {
      final bool isFirstPage = !event.isLoadMore;
      final String currentSearchId = isFirstPage ? event.id : _latestQuery;

      if (isFirstPage) {
        _latestQuery = event.id;
        emit(
          state.copyWith(
            agencyState: RequestState.loading,
            agencyCurrentPage: 1,
            isPaginatingAgency: false,
          ),
        );
      } else {
        if (state.isPaginatingAgency) return;
        emit(
          state.copyWith(
            isPaginatingAgency: true,
            agencyCurrentPage: state.agencyCurrentPage + 1,
          ),
        );
      }

      final int currentPage = state.agencyCurrentPage;
      final result = await agencySearchUC(
        AgencySearchParam(id: currentSearchId, page: '$currentPage'),
      );

      if (_latestQuery != currentSearchId) {
        return;
      }

      result.fold(
        (left) {
          emit(
            state.copyWith(
              agencyState: RequestState.error,
              isPaginatingAgency: false,
              error: NetworkExceptions.getErrorMessage(left),
            ),
          );
        },
        (right) {
          final mergedAgencies = handlePaginationResponse<AgenciesEntity>(
            result: right.data?.agencies,
            currentList: state.agencyModel?.agencies ?? const [],
            currentPage: currentPage,
          );
          final mergedMasters = handlePaginationResponse<AgencyMastersEntity>(
            result: right.data?.agencyMasters,
            currentList: state.agencyModel?.agencyMasters ?? const [],
            currentPage: currentPage,
          );
          emit(
            state.copyWith(
              agencyState: RequestState.loaded,
              agencyModel: AgencySearchModel(
                agencies: mergedAgencies,
                agencyMasters: mergedMasters,
              ),
              agencyLastPage: right.paginates?.lastPage ?? state.agencyLastPage,
              isPaginatingAgency: false,
            ),
          );
        },
      );
    });

    on<AgencySearchAddListenerEvent>((event, emit) {
      state.agencyScrollCtrl.addListener(_listenerAgencySearch);
    });

    on<AgencySearchRemoveListenerEvent>((event, emit) {
      state.agencyScrollCtrl.removeListener(_listenerAgencySearch);
    });

    on<JoinAgencyLocalEvent>((event, emit) {
      final agencyModel = state.agencyModel;
      final searchModel = state.agencySearchModel;

      if (agencyModel == null && searchModel == null) {
        return;
      }

      /// helper to update agency list
      List<AgenciesEntity>? updateAgencies(List<AgenciesEntity>? agencies) {
        if (agencies == null || agencies.isEmpty) return agencies;

        final index = agencies.indexWhere(
          (a) => a.id.toString() == event.agencyId,
        );

        if (index == -1) return agencies;

        final updated = List<AgenciesEntity>.from(agencies);
        updated[index] = updated[index].copyWith(isJoinRequest: true);

        return updated;
      }

      final updatedAgencyModel = agencyModel?.copyWith(
        agencies: updateAgencies(agencyModel.agencies),
      );

      final updatedSearchModel = searchModel?.copyWith(
        agencies: updateAgencies(searchModel.agencies),
      );

      /// 🔥 build NEXT STATE
      final nextState = state.copyWith(
        agencyModel: updatedAgencyModel,
        agencySearchModel: updatedSearchModel,
      );

      /// 🚀 emit NEXT STATE
      emit(nextState);
    });

    on<ResetAgencyEvent>((event, emit) async {
      _latestQuery = '';
      emit(
        state.copyWith(
          agencyModel: AgencySearchModel(),
          agencyState: RequestState.idle,
          agencyCurrentPage: 1,
          agencyLastPage: -1,
          isPaginatingAgency: false,
          error: null,
        ),
      );
    });
  }

  void _listenerAgencySearch() {
    handleScrollListener(
      controller: state.agencyScrollCtrl,
      currentPage: state.agencyCurrentPage,
      lastPage: state.agencyLastPage,
      fun: () {
        add(FetchRegularAgencyEvent(id: _latestQuery, isLoadMore: true));
      },
    );
  }
}

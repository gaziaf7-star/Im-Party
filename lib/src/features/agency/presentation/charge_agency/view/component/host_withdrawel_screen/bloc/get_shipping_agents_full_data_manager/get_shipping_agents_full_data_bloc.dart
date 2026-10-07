
import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'get_shipping_agents_full_data_event.dart';
part 'get_shipping_agents_full_data_state.dart';

class GetShippingAgentsFullDataModelBloc extends Bloc<GetShippingAgentsFullDataModelEvent,
    GetShippingAgentsFullDataModelState> {
  final GetShippingAgentsFullDataUC getShippingAgentsFullDataModel;

  GetShippingAgentsFullDataModelBloc({required this.getShippingAgentsFullDataModel})
      : super(const GetShippingAgentsFullDataModelState()) {
    on<GetAgentsFullData>(
      (event, emit) async {
        if(event.isFirstLoading==true) {
          emit(state.copyWith(status: RequestState.loading));
        }
        final result =
            await getShippingAgentsFullDataModel(FetchShippingAgentsFullDataModelParam(
              countryId: state.selectedCountry?.id,
              paymentId: state.selectedPayment?.id,
              page: 1,
            ));

        result.fold(
          (left) => emit(state.copyWith(
              status: handleErrorResponse(left),
              error: NetworkExceptions.getErrorMessage(left))),
          (right) => emit(
            state.copyWith(
              status: handleLoadedResponse<List<ShippingAgentsFullDataModel>?>(
                  right.data),
              data: right.data ?? [],
              currentPage: right.paginates?.currentPage ?? 1,
              lastPage: right.paginates?.lastPage ?? 1,
            ),
          ),
        );
      },
    );
    on<LoadMoreAgentsFullData>(
      (event, emit) async {
        if (!state.hasMore || state.isPaginating) return;

        emit(state.copyWith(isPaginating: true));

        final nextPage = state.currentPage + 1;
        final result =
            await getShippingAgentsFullDataModel(FetchShippingAgentsFullDataModelParam(
              countryId: state.selectedCountry?.id,
              paymentId: state.selectedPayment?.id,
              page: nextPage,
            ));

        result.fold(
          (left) => emit(state.copyWith(isPaginating: false)),
          (right) => emit(
            state.copyWith(
              data: [...state.data, ...right.data ?? []],
              currentPage: right.paginates?.currentPage ?? nextPage,
              lastPage: right.paginates?.lastPage ?? state.lastPage,
              isPaginating: false,
            ),
          ),
        );
      },
    );
    on<ShowPayments>(
      (event, emit) async {
        if (state.isShowPayment == true) {
          emit(state.copyWith(isShowPayment: false));
        } else {
          emit(state.copyWith(isShowPayment: true));
        }
      },
    );
    on<ShowCountries>(
      (event, emit) async {

        if (state.isShowCountry == true) {
          emit(state.copyWith(isShowCountry: false));
        } else {
          emit(state.copyWith(isShowCountry: true));
        }

      },
    );
    on<SelectPayment>(
      (event, emit) async {
        emit(state.copyWith(selectedPayment: event.paymentMethod));
      },
    );
    on<SelectCountry>(
      (event, emit) async {
        emit(state.copyWith(selectedCountry: event.country));
      },
    );
    on<ClearSelection>(
      (event, emit) async {
        emit(state.copyWith(isNullCountry: true, isNullPayment: true));

      },
    );
  }
}

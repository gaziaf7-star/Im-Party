
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/core/index.dart';

part'get_shipping_countries_event.dart';
part'get_shipping_countries_state.dart';

class GetShippingCountriesBloc
    extends Bloc<GetShippingCountriesEvent, GetShippingCountriesState> {
  GetShippingMoneyCountriesUC getShippingMoneyCountriesUseCase;

  GetShippingCountriesBloc({required this.getShippingMoneyCountriesUseCase})
      : super(const GetShippingCountriesState()) {
    on<GetGetShippingCountries>(
          (event, emit) async {
        emit(state.copyWith(
          status: RequestState.loading
        ));
        final result =
        await getShippingMoneyCountriesUseCase();

        result.fold(
              (left) => emit(
                state.copyWith(
                  status: handleErrorResponse(left),
              error: NetworkExceptions.getErrorMessage(left),
            ),
          ),
              (right) => emit(
                state.copyWith(
                  status: handleLoadedResponse(right.data),

                  data: right.data ?? [],
            ),
          ),
        );
      },
    );
  }
}

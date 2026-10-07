import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

part 'join_to_agency_event.dart';

part 'join_to_agency_state.dart';

class JoinToAgenciesBloc
    extends Bloc<BaseJoinToAgencyEvent, JoinToAgencyState> {
  final JoinToAgencyUC joinToAgencyUC;

  JoinToAgenciesBloc({required this.joinToAgencyUC})
      : super(const JoinToAgencyState()) {
    on<JoinToAgencyEvent>((event, emit) async {
      emit(state.copyWith(state: RequestState.loading));

      final result =
          await joinToAgencyUC(JoinAgencyParam(agencyId: event.agencyId));
      di<AgencySearchBloc>().add(JoinAgencyLocalEvent(event.agencyId));
      di<ShowAgencyBloc>().add(const JoinShowAgencyLocalEvent());

      result.fold((left) {
        emit(
          state.copyWith(
            state: RequestState.error,
            message: NetworkExceptions.getErrorMessage(left),
          ),
        );

        Methods.showToast(event.context,
            message: state.message ?? '', isError: true);
      }, (right) {
        Methods.showToast(
          event.context,
          message: state.message ?? '',
        );

        di<AgencySearchBloc>().add(JoinAgencyLocalEvent(event.agencyId));
        di<ShowAgencyBloc>().add(const JoinShowAgencyLocalEvent());

        emit(
          state.copyWith(
            state: RequestState.loaded,
            message: right.message,
          ),
        );
      });
    });
  }
}

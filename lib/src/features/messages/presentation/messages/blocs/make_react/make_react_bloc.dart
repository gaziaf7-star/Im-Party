import 'package:general/src/core/index.dart';
import 'package:general/src/features/messages/messages.dart';

part 'make_react_event.dart';
part 'make_react_state.dart';

class MakeReactBloc extends Bloc<BaseMakeReactEvent, MakeReactState> {
  final MakeReactUC _makeReactUC;

  MakeReactBloc(this._makeReactUC) : super(const MakeReactState()) {
    on<MakeReactEvent>(
      (event, emit) async {
        final result = await _makeReactUC.call(event.params);
        result.fold(
          (left) => emit(state.copyWith(reqState: RequestState.error)),
          (right) => emit(
            state.copyWith(data: right, reqState: RequestState.loaded),
          ),
        );
      },
    );
  }
}

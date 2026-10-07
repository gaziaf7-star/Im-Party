import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/loading_dialog_widget.dart';
import 'package:general/src/features/room/data/model/room_activity_model.dart';
import 'package:general/src/features/room/domain/use_case/get_room_activity_data.dart';
import 'package:general/src/features/room/domain/use_case/get_room_activity_web_view_link_uc.dart';

part 'get_room_activity_data_event.dart';

part 'get_room_activity_data_state.dart';

class GetRoomActivityDataBloc
    extends Bloc<GetRoomActivityDataEvent, GetRoomActivityDataState> {
  final GetRoomActivityDataUC roomActivityDataUC;
  final GetRoomActivityWebViewLinkUC roomActivityWebViewLinkUC;

  GetRoomActivityDataBloc(
    this.roomActivityDataUC,
    this.roomActivityWebViewLinkUC,
  ) : super(const GetRoomActivityDataState()) {
    on<FetchRoomActivityDataEvent>(_fetchRoomActivityData);
    on<FetchRoomActivityWebViewLinkEvent>(_fetchRoomActivityWebViewLinkEvent);
  }

  Future<void> _fetchRoomActivityData(
    FetchRoomActivityDataEvent event,
    Emitter<GetRoomActivityDataState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await roomActivityDataUC(event.roomId);

    result.fold(
      (failure) {
        final errorMsg = NetworkExceptions.getErrorMessage(failure);
        Methods.printLog(
            '❌ [GetRoomActivityDataBloc] Fetch failed for roomId: ${event.roomId}');
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: errorMsg,
          ),
        );
      },
      (data) {
        Methods.printLog(
            '✅ [GetRoomActivityDataBloc] Fetch success for roomId: ${event.roomId}');
        Methods.printLog(
            '📦 [GetRoomActivityDataBloc] Data received: ${data.data}');
        emit(
          state.copyWith(
            requestState: RequestState.loaded,
            dataModel: data.data,
          ),
        );
      },
    );
  }

  Future<void> _fetchRoomActivityWebViewLinkEvent(
    FetchRoomActivityWebViewLinkEvent event,
    Emitter<GetRoomActivityDataState> emit,
  ) async {
    showCustomLoadingDialog(event.context);

    emit(state.copyWith(requestState: RequestState.loading));

    final result = await roomActivityWebViewLinkUC();

    result.fold(
      (failure) {
        Navigator.pop(event.context);
        final msg = NetworkExceptions.getErrorMessage(failure);
        emit(
          state.copyWith(
            requestState: RequestState.error,
            message: msg,
          ),
        );
      },
      (data) {
        Navigator.pop(event.context);

        Navigator.pushNamed(
          event.context,
          Routes.webViewEvents,
          arguments: {
            'url': data.data,
            'type': 'events',
          },
        );

        emit(
          state.copyWith(
            requestState: RequestState.loaded,
            webViewLink: data.data,
          ),
        );
      },
    );
  }
}

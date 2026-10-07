import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_events.dart';

import '../controller_share_room.dart';
import 'share_room_event.dart';
import 'share_room_state.dart';

class ShareRoomBloc extends Bloc<ShareRoomEvent, ShareRoomState> {
  ShareRoomBloc()
      : super(ShareRoomState(
          scrollController: ScrollController(),
          searchController: TextEditingController(),
        )) {
    on<InitializeShareRoom>((event, emit) {
      final secretKey = event.secretKey;
      emit(state.copyWith(secretKey: secretKey));
    });

    on<ToggleSelectAllRoom>((event, emit) {
      bool newSelectAll = !state.selectAll;
      emit(state.copyWith(
        selectAll: newSelectAll,
        selectedIds: [],
        idsAndBool: {},
      ));
    });

    on<ToggleSelectionRoom>((event, emit) {
      final newIdsAndBool = Map<int, bool>.from(state.idsAndBool);
      final newSelectedIds = List<int>.from(state.selectedIds);
      bool newSelectAll = state.selectAll;

      // Toggle selection
      if (newIdsAndBool.containsKey(event.userId)) {
        newIdsAndBool.remove(event.userId);
        newSelectedIds.remove(event.userId);
      } else {
        newIdsAndBool[event.userId] = true;
        newSelectedIds.add(event.userId);
      }

      // Check if all possible items are selected
      if (newIdsAndBool.isNotEmpty &&
          newIdsAndBool.length == state.idsAndBool.length &&
          newIdsAndBool.values.every((isSelected) => isSelected)) {
        newIdsAndBool.clear();
        newSelectedIds.clear();
        newSelectAll = true;
      } else {
        newSelectAll = false;
      }

      emit(state.copyWith(
        idsAndBool: newIdsAndBool,
        selectedIds: newSelectedIds,
        selectAll: newSelectAll,
      ));
    });

    on<SearchUsersRoom>((event, emit) {
      di<SearchBloc>()
          .add(SearchEvent(keyWord: event.keyword, isFriend: true, page: '1'));
    });

    on<LoadMoreUsersRoom>((event, emit) {
      int newPage = state.page + 1;
      di<SearchBloc>().add(
          SearchEvent(keyWord: "", isFriend: true, page: newPage.toString()));
      emit(state.copyWith(page: newPage));
    });

    on<ShareRoom>((event, emit) {
      ShareRoomController().shareRoomMessageLink(
        state.selectedIds,
        state.selectAll,
        event.context,
        event.roomModel,
        state.secretKey,
      );
    });
  }
}

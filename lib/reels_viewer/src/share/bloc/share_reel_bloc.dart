import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_bloc.dart';
import 'package:general/src/features/home/presentation/search_screen/bloc/search_manager/search_events.dart';

import '../controller_share.dart';
import 'share_reel_event.dart';
import 'share_reel_state.dart';

class ShareReelBloc extends Bloc<ShareReelEvent, ShareReelState> {
  ShareReelBloc()
      : super(ShareReelState(
          scrollController: ScrollController(),
          searchController: TextEditingController(),
        )) {
    on<InitializeShareReel>((event, emit) {
      final secretKey = event.seckretKey;
      emit(state.copyWith(secretKey: secretKey));
    });

    on<ToggleSelectAll>((event, emit) {
      bool newSelectAll = !state.selectAll;
      emit(state.copyWith(
        selectAll: newSelectAll,
        selectedIds: [],
        idsAndBool: {},
      ));
    });

    on<ToggleSelection>((event, emit) {
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

    on<SearchUsers>((event, emit) {
      di<SearchBloc>()
          .add(SearchEvent(keyWord: event.keyword, isFriend: true, page: '1'));
    });

    on<LoadMoreUsers>((event, emit) {
      int newPage = state.page + 1;
      di<SearchBloc>().add(
          SearchEvent(keyWord: "", isFriend: true, page: newPage.toString()));
      emit(state.copyWith(page: newPage));
    });

    on<ShareReel>((event, emit) {
      ShareController().shareReelMessageLink(state.selectedIds, state.selectAll,
          event.context, event.reelModel, state.secretKey);
    });
  }
}

import 'package:general/src/core/index.dart';

class ShareReelState extends Equatable {
  final bool selectAll;
  final Map<int, bool> idsAndBool;
  final List<int> selectedIds;
  final int page;
  final String secretKey;
  final ScrollController scrollController;
  final TextEditingController searchController;

  const ShareReelState({
    this.selectAll = false,
    this.idsAndBool = const {},
    this.selectedIds = const [],
    this.page = 1,
    this.secretKey = '',
   required this.scrollController,
   required this.searchController,

  });

  ShareReelState copyWith({
    bool? selectAll,
    Map<int, bool>? idsAndBool,
    List<int>? selectedIds,
    int? page,
    String? secretKey,

  }) {
    return ShareReelState(
      selectAll: selectAll ?? this.selectAll,
      idsAndBool: idsAndBool ?? this.idsAndBool,
      selectedIds: selectedIds ?? this.selectedIds,
      page: page ?? this.page,
      secretKey: secretKey ?? this.secretKey,
      scrollController: scrollController,
      searchController: searchController
    );
  }

  @override
  List<Object?> get props =>
      [selectAll, idsAndBool, selectedIds, page, secretKey, scrollController, searchController];
}

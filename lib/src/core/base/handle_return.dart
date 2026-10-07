
import 'package:general/src/core/index.dart';

RequestState handleErrorResponse(NetworkExceptions error) {
  return error is NoInternetConnection
      ? RequestState.offline
      : RequestState.error;
}

RequestState handleLoadedResponse<T>(T? result) {
  if (result is List) {
    return result.isEmpty ? RequestState.empty : RequestState.loaded;
  }

  if (result is Map) {
    return result.isEmpty ? RequestState.empty : RequestState.loaded;
  }

  return RequestState.loaded;
}

/* List<T> handlePaginationResponse<T>({
  required List<T>? result,
  required List<T> currentList,
  required int currentPage,
}) {
  if (result == null) return currentList;
  if (currentList.isEmpty || currentPage == 1) {
    return result;
  } else {
    final List<T> res = result.where((_) => !currentList.contains(_)).toList();
    currentList.addAll(res);
    return currentList;
    /*  
    currentList.addAll(result);
    return currentList; 
    */
  }
} */

List<T> handlePaginationResponse<T>({
  required List<T>? result,
  required List<T> currentList,
  required int currentPage,
}) {
  // log('result: $result, currentList: $currentList, currentPage: $currentPage');
  if (result == null) return currentList;

  if (currentList.isEmpty || currentPage == 1) {
    return result;
  } else {
    final Set<T> uniqueItems = Set<T>.from(currentList);
    uniqueItems.addAll(result);
    return uniqueItems.toList();
  }
}


void handleScrollListener({
  required ScrollController controller,
  required Function() fun,
  required int currentPage,
  required int lastPage,
}) async {
  if (controller.positions.length != 1) {
  } else {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      if (lastPage > currentPage) await fun();
    }
  }
}

/// Prefetch-on-scroll for the offline-first chat window (reverse list): fires
/// [fun] once the user scrolls past [threshold] (default 0.7 → ~30 messages
/// remaining of a 50-item page) so the next page is pulled from drift before the
/// top is reached, keeping the scroll smooth. No page math — the guard against
/// re-entry is owned by the caller (e.g. `isLoadingOlder`).
void handlePrefetchScrollListener({
  required ScrollController controller,
  required Function() fun,
  double threshold = 0.7,
}) {
  if (controller.positions.length != 1) return;
  final max = controller.position.maxScrollExtent;
  if (max <= 0) return;
  if (controller.position.pixels >= max * threshold) {
    fun();
  }
}

import 'dart:async';
import 'dart:collection';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/bloc/gift_bloc/gift_bloc.dart';
import 'package:general/src/features/room/presentation/manager/alpha_gift_manager/alpha_gift_manager_bloc.dart';
import 'package:general/src/features/room/presentation/manager/alpha_gift_manager/alpha_gift_manager_event.dart';
import 'package:general/src/features/room/room.dart';

/// Mutable list facade over [GiftQueueManager]'s typed queue.
///
/// Cache widgets (SVGA, VAP, MP4, alpha, image) still access
/// `normalGiftsToShow[0]['pathGift']` and call `removeAt(0)`.
/// This proxy converts GiftQueueItem → Map on read and
/// routes mutations back through the manager.
class GiftQueueListProxy extends ListBase<Map<String, dynamic>> {
  final GiftQueueManager _manager;
  GiftQueueListProxy(this._manager);

  @override
  int get length => _manager._queue.length;

  @override
  set length(int newLength) {
    // Shrink: remove from the end.
    while (_manager._queue.length > newLength) {
      _manager._queue.removeLast();
    }
  }

  @override
  Map<String, dynamic> operator [](int index) =>
      _manager._queue[index].toMap();

  @override
  void operator []=(int index, Map<String, dynamic> value) {
    // Not used by cache widgets — no-op.
  }

  @override
  Map<String, dynamic> removeAt(int index) {
    final removed = _manager._queue.removeAt(index);
    _manager._activeAnimations.remove(removed.uniqueId);
    return removed.toMap();
  }

  @override
  void clear() => _manager.clear();

  @override
  void add(Map<String, dynamic> element) {
    // Legacy path: convert Map back to GiftQueueItem.
    _manager._queue.add(GiftQueueItem(
      uniqueId: element['uniqueId'] as String? ??
          _manager.generateUniqueId(),
      pathGift: element['pathGift'] as String? ?? '',
      isFamousGift: element['isFamousGift'] as bool? ?? false,
      giftType: element['giftType'] as String? ?? 'image',
      wappelData: element['wappel'] as Map<String, dynamic>?,
    ));
  }
}

/// Typed gift queue item replacing Map<String, dynamic> for type safety
/// and eliminating runtime string key lookups.
class GiftQueueItem {
  final String uniqueId;
  final String pathGift;
  final bool isFamousGift;
  final String giftType;
  final String roomGiftsPrice;
  final bool isIntro;
  final bool isShowIntroFullScreen;
  final Map<String, dynamic> wappelData;
  final DateTime enqueueTime;
  DateTime? showTime;

  GiftQueueItem({
    required this.uniqueId,
    required this.pathGift,
    this.isFamousGift = false,
    required this.giftType,
    this.roomGiftsPrice = '',
    this.isIntro = false,
    this.isShowIntroFullScreen = false,
    Map<String, dynamic>? wappelData,
    DateTime? enqueueTime,
    this.showTime,
  })  : wappelData = wappelData ??
            const {
              'user_name_intro': '',
              'user_image_intro': '',
              'wappelImage': '',
              'wappelType': '',
              'wappelKeyName': '',
            },
        enqueueTime = enqueueTime ?? DateTime.now();

  /// Priority score: famous gifts play first.
  int get priority => isFamousGift ? 1 : 0;

  /// Convert to the legacy Map format for backward compatibility with
  /// cache widgets that still read from Map<String, dynamic>.
  Map<String, dynamic> toMap() => {
        'uniqueId': uniqueId,
        'pathGift': pathGift,
        'isShowGift': true,
        'isFamousGift': isFamousGift,
        'giftType': giftType,
        'showTime': showTime?.toIso8601String() ?? '',
        'wappel': wappelData,
      };

  /// Resolved [ShowGiftType] for bloc events.
  ShowGiftType get showGiftType {
    switch (giftType) {
      case 'mp4':
        return ShowGiftType.mp4;
      case 'svga':
      case 'zz':
      case 'zzz':
        return ShowGiftType.svga;
      case 'vap':
        return ShowGiftType.vap;
      case 'alpha':
        return ShowGiftType.alpha;
      default:
        return ShowGiftType.image;
    }
  }
}

/// Manages a priority queue of gift animations with concurrency control.
///
/// Key improvements over the previous approach:
/// - **Max 2 concurrent animations** — prevents GPU/memory pressure from
///   unbounded parallel SVGA/MP4/VAP players.
/// - **Priority ordering** — famous/expensive gifts play before normals.
/// - **Periodic cleanup** — stale items removed every 5 s instead of on
///   every gift arrival (which ran O(n) removeWhere each time).
/// - **Single composite bloc emission** — each gift triggers one
///   [ShowGiftCompositeEvent] instead of 3-4 separate events.
class GiftQueueManager {
  GiftQueueManager._internal() {
    _cleanupTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _periodicCleanup(),
    );
  }

  static final GiftQueueManager _instance = GiftQueueManager._internal();
  factory GiftQueueManager() => _instance;

  /// Maximum number of gift animations playing at once.
  static const int maxConcurrent = 2;

  /// Internal queue sorted by priority then enqueue time.
  final List<GiftQueueItem> _queue = [];

  /// IDs of animations currently playing.
  final Set<String> _activeAnimations = {};

  Timer? _cleanupTimer;

  int _counter = 0;

  // ─── Public API ───────────────────────────────────────────────────────

  /// Generate a unique ID for a new gift.
  String generateUniqueId() {
    _counter++;
    return 'gift_${DateTime.now().millisecondsSinceEpoch}_$_counter';
  }

  /// The number of items in the queue (including active ones).
  int get length => _queue.length;

  /// Whether the queue is empty.
  bool get isEmpty => _queue.isEmpty;

  /// Whether the queue has items.
  bool get isNotEmpty => _queue.isNotEmpty;

  /// The first item in the queue, or null.
  GiftQueueItem? get firstOrNull => _queue.isEmpty ? null : _queue.first;

  /// Backward-compatible mutable view: cache widgets can still call
  /// `normalGiftsToShow[0]['pathGift']`, `.removeAt(0)`, `.clear()`.
  late final GiftQueueListProxy normalGiftsToShow =
      GiftQueueListProxy(this);

  /// Add a gift to the queue and attempt to process it.
  void enqueue(GiftQueueItem item) {
    _queue.add(item);
    _sortQueue();
    _tryProcessNext();
  }

  /// Called by animation widgets when an animation completes.
  /// Removes the completed item and triggers the next one.
  void onAnimationComplete(String uniqueId) {
    _activeAnimations.remove(uniqueId);
    _queue.removeWhere((item) => item.uniqueId == uniqueId);
    _tryProcessNext();
  }

  /// Remove the first item from the queue (legacy compatibility for cache
  /// widgets that call `normalGiftsToShow.removeAt(0)`).
  void removeFirst() {
    if (_queue.isNotEmpty) {
      final removed = _queue.removeAt(0);
      _activeAnimations.remove(removed.uniqueId);
    }
  }

  /// Mark the first item's showTime (legacy compatibility).
  void updateFirstShowTime() {
    if (_queue.isNotEmpty && _queue.first.showTime == null) {
      _queue.first.showTime = DateTime.now();
    }
  }

  /// Number of animations currently playing.
  int get activeCount => _activeAnimations.length;

  /// Whether we can start another animation.
  bool get canStartAnimation => _activeAnimations.length < maxConcurrent;

  /// Clear the entire queue and active set.
  void clear() {
    _queue.clear();
    _activeAnimations.clear();
  }

  /// Dispose timers. Call on room exit.
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    clear();
  }

  /// Reinitialize after dispose (e.g., entering a new room).
  void reinitialize() {
    dispose();
    _cleanupTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _periodicCleanup(),
    );
  }

  // ─── Internal ─────────────────────────────────────────────────────────

  /// Sort queue: items already being shown stay pinned at the head (in show
  /// order); among not-yet-shown items, famous gifts first then FIFO.
  ///
  /// Cache widgets treat index 0 as "the gift currently showing" and call
  /// `removeAt(0)` when its animation finishes. If a freshly-enqueued famous
  /// gift were allowed to sort ahead of the showing gift, `removeAt(0)` would
  /// delete the wrong item (dropping the new famous gift and leaving the shown
  /// gift's id stuck in _activeAnimations). Pinning shown items at the head
  /// keeps index 0 == the showing gift until it actually completes.
  void _sortQueue() {
    _queue.sort((a, b) {
      final aShown = a.showTime != null;
      final bShown = b.showTime != null;
      if (aShown != bShown) return aShown ? -1 : 1;
      if (aShown && bShown) return a.showTime!.compareTo(b.showTime!);
      final priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;
      return a.enqueueTime.compareTo(b.enqueueTime);
    });
  }

  /// Try to start the next queued animation if under the concurrency limit.
  void _tryProcessNext() {
    if (!canStartAnimation) return;

    // Find the first item that isn't already active.
    final nextItem = _queue.cast<GiftQueueItem?>().firstWhere(
          (item) => !_activeAnimations.contains(item!.uniqueId),
          orElse: () => null,
        );
    if (nextItem == null) return;

    _activeAnimations.add(nextItem.uniqueId);
    nextItem.showTime = DateTime.now();

    // If intro, update the intro display data before emitting.
    if (nextItem.isIntro && nextItem.wappelData.isNotEmpty) {
      ShowEntroWidget.showEntro.value = nextItem.wappelData;
    }

    // Alpha gifts route through AlphaGiftManagerBloc instead of GiftBloc.
    if (nextItem.showGiftType == ShowGiftType.alpha) {
      if (nextItem.roomGiftsPrice.isNotEmpty) {
        di<GiftBloc>().add(
          UpdateRoomGiftsPriceEvent(price: nextItem.roomGiftsPrice),
        );
      }
      di<AlphaGiftManagerBloc>().add(
        ShowAlphaGift(
          imgFile: nextItem.pathGift,
          isFamousGift: nextItem.isFamousGift,
          isIntro: nextItem.isIntro,
        ),
      );
      return;
    }

    // All other types: emit a single composite event instead of 3-4 separate.
    di<GiftBloc>().add(
      ShowGiftCompositeEvent(
        pathGift: nextItem.pathGift,
        giftType: nextItem.showGiftType,
        isFamousGift: nextItem.isFamousGift,
        isShowIntroFullScreen: nextItem.isShowIntroFullScreen,
        price: nextItem.roomGiftsPrice,
        showBanner: _queue.length > 1 &&
            (MyDataModel.getInstance().roomEffects?.showBanner != false),
      ),
    );
  }

  /// Remove stale items every 5 seconds instead of on every gift arrival.
  void _periodicCleanup() {
    final now = DateTime.now();
    _queue.removeWhere((item) {
      if (item.showTime != null) {
        // Shown gifts: remove after 20 seconds.
        return now.difference(item.showTime!).inSeconds >= 20;
      }
      // Queued but never shown: remove after 2 minutes.
      return now.difference(item.enqueueTime).inMinutes >= 2;
    });
    // Also prune stale active IDs.
    _activeAnimations.removeWhere(
      (id) => !_queue.any((item) => item.uniqueId == id),
    );
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';
import 'package:general/src/features/mall_bag/presentation/bag/view/widgets/send_bottom_sheet.dart';

import '../../component/custom_model_bottom_sheet.dart';
import '../../component/store_ui.dart';

part '../view/components/bag_tab_bar_view.dart';
part '../view/widgets/bag_product_item.dart';

/// My Items: same look as the Store — the item on the podium, category tabs,
/// a grid of owned items, and Send / Use buttons at the bottom.
class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  /// Tab order on screen, as category indexes (0 bubble, 1 frame, 2 entry,
  /// 3 special ID, 4 profile frame): Frame, Entry, Bubble, Profile frame,
  /// Special ID — same as the Store.
  static const List<int> _tabs = [1, 2, 0, 4, 3];

  final MyBagBloc _bloc = di<MyBagBloc>();
  final StoreWarmer _warmer = StoreWarmer();

  int _category = _tabs.first;
  double? _previewProgress;

  @override
  void initState() {
    super.initState();
    _bloc.add(ChangeAppBarUIEvent(index: _category));
    _ensureLoaded(_category, showLoading: true);
  }

  @override
  void dispose() {
    di<MyBagBloc>().add(const ChangeAppBarUIEvent(index: 0));
    di<MyBagBloc>().add(const SelectBagItemEvent(selectedItem: null));
    super.dispose();
  }

  // ── data ────────────────────────────────────────────────────────────────

  void _ensureLoaded(int category, {bool showLoading = false}) {
    final s = _bloc.state;
    switch (category) {
      case 0:
        if (s.bubbleBagRequest != RequestState.loaded) {
          _bloc.add(GetBubbleBackPackMyBagEvent(isLoading: showLoading));
        }
      case 1:
        if (s.frameBagRequest != RequestState.loaded) {
          _bloc.add(GetFramesMyBagEvent(isLoading: showLoading));
        }
      case 2:
        if (s.carBagRequest != RequestState.loaded) {
          _bloc.add(GetEntrieMyBagEvent(isLoading: showLoading));
        }
      case 3:
        if (s.emojisBagRequest != RequestState.loaded) {
          _bloc.add(GetSpecialIdMyBagEvent(isLoading: showLoading));
        }
      case 4:
        if (s.profileFrameRequest != RequestState.loaded) {
          _bloc.add(GetProfileFrameMyBagEvent(isLoading: showLoading));
        }
    }
  }

  void _reload(int category) {
    switch (category) {
      case 0:
        _bloc.add(const GetBubbleBackPackMyBagEvent());
      case 1:
        _bloc.add(const GetFramesMyBagEvent());
      case 2:
        _bloc.add(const GetEntrieMyBagEvent());
      case 3:
        _bloc.add(const GetSpecialIdMyBagEvent());
      case 4:
        _bloc.add(const GetProfileFrameMyBagEvent());
    }
  }

  List<MyBagEntity> _items(MyBagState s, int c) => switch (c) {
        0 => s.bubblesBag,
        1 => s.framesBag,
        2 => s.carsBag,
        3 => s.emojisBag,
        _ => s.profileFrames,
      };

  RequestState _request(MyBagState s, int c) => switch (c) {
        0 => s.bubbleBagRequest,
        1 => s.frameBagRequest,
        2 => s.carBagRequest,
        3 => s.emojisBagRequest,
        _ => s.profileFrameRequest,
      };

  MyBagEntity? _picked(MyBagState s, int c) => switch (c) {
        0 => s.isBubbleNull == true ? null : s.selectedItemBubble,
        1 => s.isFrameNull == true ? null : s.selectedItemFrame,
        2 => s.isIntroNull == true ? null : s.selectedItemIntro,
        3 => s.isSpecialIdNull == true ? null : s.selectedItemSpecialId,
        _ => s.isProfileFrameNull == true ? null : s.selectedItemProfileFrame,
      };

  MallOrBagType _type(int c) => switch (c) {
        0 => MallOrBagType.bubble,
        1 => MallOrBagType.frame,
        2 => MallOrBagType.intro,
        3 => MallOrBagType.specialId,
        _ => MallOrBagType.profileFrame,
      };

  String _title(int c) => switch (c) {
        0 => StringManager.bubble.tr(),
        1 => StringManager.frames.tr(),
        2 => StringManager.entries.tr(),
        3 => StringManager.specialId.tr(),
        _ => StringManager.profileFrame.tr(),
      };

  /// The item on the podium: the one tapped (or worn), else the one in use,
  /// else the first.
  MyBagEntity? _shown(MyBagState s) {
    final list = _items(s, _category);
    if (list.isEmpty) return null;
    final picked = _picked(s, _category);
    if (picked != null) {
      for (final e in list) {
        if (e.id == picked.id) return e;
      }
    }
    for (final e in list) {
      if (e.isUsed) return e;
    }
    return list.first;
  }

  // ── actions ─────────────────────────────────────────────────────────────

  void _openTab(int category) {
    if (category == _category) return;
    HapticFeedback.selectionClick();
    setState(() => _category = category);
    _bloc.add(ChangeAppBarUIEvent(index: category));
    _ensureLoaded(category, showLoading: true);
  }

  void _select(MyBagEntity item) {
    HapticFeedback.selectionClick();
    _bloc.add(SelectBagItemEvent(selectedItem: item, type: _category));
  }

  Future<void> _preview(MyBagEntity item) async {
    if (_previewProgress != null) return;
    await openStorePreview(
      context,
      StorePreview.bag(item),
      _type(_category),
      onProgress: (p) {
        if (mounted) setState(() => _previewProgress = p);
      },
    );
  }

  void _openMall() {
    Navigator.pushReplacementNamed(context, Routes.mallScreen, arguments: 0);
  }

  // ── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBagBloc, MyBagState>(
      bloc: _bloc,
      builder: (context, state) {
        final items = _items(state, _category);
        final request = _request(state, _category);
        final shown = _shown(state);
        final type = _type(_category);
        if (items.isNotEmpty) {
          _warmer.warm([
            if (shown != null) StorePreview.bag(shown),
            ...items.take(9).map(StorePreview.bag),
          ]);
        }
        return Scaffold(
          backgroundColor: StoreColors.bg,
          extendBodyBehindAppBar: true,
          appBar: AppBarWidget(
            backgroundColor: Colors.transparent,
            shadow: Colors.transparent,
            iconColor: Colors.white,
            title: StringManager.myProps.tr(),
            titleStyle: context.titleLarge.size(20).w600.colorExt(Colors.white),
            actions: [
              IconButton(
                tooltip: StringManager.store.tr(),
                onPressed: _openMall,
                icon: Icon(Icons.storefront_outlined,
                    color: Colors.white, size: 24.sp),
              ),
              6.wBox,
            ],
          ),
          body: Column(
            children: [
              StoreStage(
                item: shown == null ? null : StorePreview.bag(shown),
                type: type,
                progress: _previewProgress,
                onPreview: shown == null ? null : () => _preview(shown),
              ),
              StoreTabBar(
                labels: [for (final c in _tabs) _title(c)],
                selected: _tabs.indexOf(_category),
                onTap: (i) => _openTab(_tabs[i]),
              ),
              10.hBox,
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  child: KeyedSubtree(
                    key: ValueKey('bag_cat_$_category'),
                    child: HandlingDataWidget(
                      title: StringManager.titleEmptyFrame.tr(),
                      subTitle: StringManager.subEmptyFrame.tr(),
                      reqState: request,
                      isNeedLoadingWidget: true,
                      onTap: () => _reload(_category),
                      child: _BagGrid(
                        items: items,
                        shown: shown,
                        onSelect: _select,
                        onRefresh: () async {
                          _reload(_category);
                          await Future<void>.delayed(
                              const Duration(milliseconds: 350));
                        },
                      ),
                    ),
                  ),
                ),
              ),
              _BagBottomBar(item: shown, type: type, category: _category),
            ],
          ),
        );
      },
    );
  }
}

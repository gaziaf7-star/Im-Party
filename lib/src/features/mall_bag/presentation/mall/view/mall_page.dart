import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';
import 'package:general/src/features/mall_bag/presentation/mall/bloc/mall_send_bloc/mall_send_bloc.dart';
import '../../../../profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import '../../bag/view/widgets/send_bottom_sheet.dart';
import '../../component/custom_model_bottom_sheet.dart';
import '../../component/store_ui.dart';

part '../../component/mall_tab_bar_item.dart';
part 'components/mall_tab_bar_view.dart';
part 'widgets/mall_product_item.dart';

/// Store: a podium preview of the selected item on top, category tabs
/// (Frame, Entry, Bubble...), a grid of items, and Send / Purchase at the
/// bottom.
class MallPage extends StatefulWidget {
  /// Category to open: 0 bubble, 1 frame, 2 entry, 3 special ID,
  /// 4 profile frame (same numbering as before).
  final int? index;

  const MallPage({this.index, super.key});

  @override
  State<MallPage> createState() => _MallPageState();
}

class _MallPageState extends State<MallPage> {
  /// Tab order on screen, as category indexes: Frame, Entry, Bubble,
  /// Profile frame, Special ID.
  static const List<int> _tabs = [1, 2, 0, 4, 3];

  final MallBloc _mallBloc = di<MallBloc>();
  final StoreWarmer _warmer = StoreWarmer();

  late int _category;
  double? _previewProgress;

  @override
  void initState() {
    super.initState();
    final requested = widget.index;
    // Always opens on Frames; another tab only when a caller asks for one
    // explicitly (the routes pass 0 by default, which used to land on
    // Bubbles).
    _category = requested != null && requested != 0 && _tabs.contains(requested)
        ? requested
        : _tabs.first;
    _mallBloc.add(ChangeAppBarUIMallEvent(index: _category));
    _ensureLoaded(_category, showLoading: true);
    di<MyStoreBloc>().add(const GetMyStoreEvent(isLoading: false));
  }

  @override
  void dispose() {
    di<MallBloc>().add(const ChangeAppBarUIMallEvent(index: 0));
    super.dispose();
  }

  // ── data ────────────────────────────────────────────────────────────────

  void _ensureLoaded(int category, {bool showLoading = false}) {
    final s = _mallBloc.state;
    switch (category) {
      case 0:
        if (s.bubbleMallRequest != RequestState.loaded) {
          _mallBloc.add(GetBubbleMallEvent(isLoading: showLoading));
        }
      case 1:
        if (s.frameMallRequest != RequestState.loaded) {
          _mallBloc.add(GetFramesMallEvent(isLoading: showLoading));
        }
      case 2:
        if (s.carMallRequest != RequestState.loaded) {
          _mallBloc.add(GetCarMallEvent(isLoading: showLoading));
        }
      case 3:
        if (s.emojisMallRequest != RequestState.loaded) {
          _mallBloc.add(GetSpecialIdMallEvent(isLoading: showLoading));
        }
      case 4:
        if (s.profileFramesMallRequest != RequestState.loaded) {
          _mallBloc.add(GetProfileFramesMallEvent(isLoading: showLoading));
        }
    }
  }

  void _reload(int category) {
    switch (category) {
      case 0:
        _mallBloc.add(const GetBubbleMallEvent());
      case 1:
        _mallBloc.add(const GetFramesMallEvent());
      case 2:
        _mallBloc.add(const GetCarMallEvent());
      case 3:
        _mallBloc.add(const GetSpecialIdMallEvent());
      case 4:
        _mallBloc.add(const GetProfileFramesMallEvent());
    }
  }

  List<MallEntity> _items(GetDataMallStates s, int category) =>
      switch (category) {
        0 => s.bubblesMall,
        1 => s.framesMall,
        2 => s.carsMall,
        3 => s.emojisMall,
        _ => s.profileFramesMall,
      };

  RequestState _request(GetDataMallStates s, int category) =>
      switch (category) {
        0 => s.bubbleMallRequest,
        1 => s.frameMallRequest,
        2 => s.carMallRequest,
        3 => s.emojisMallRequest,
        _ => s.profileFramesMallRequest,
      };

  MallOrBagType _type(int category) => switch (category) {
        0 => MallOrBagType.bubble,
        1 => MallOrBagType.frame,
        2 => MallOrBagType.intro,
        3 => MallOrBagType.specialId,
        _ => MallOrBagType.profileFrame,
      };

  String _title(int category) => switch (category) {
        0 => StringManager.bubble.tr(),
        1 => StringManager.frames.tr(),
        2 => StringManager.entries.tr(),
        3 => StringManager.specialId.tr(),
        _ => StringManager.profileFrame.tr(),
      };

  /// The item shown on the podium: the bloc's pick when it belongs to this
  /// tab, otherwise the tab's first item.
  MallEntity? _selected(GetDataMallStates s) {
    final list = _items(s, _category);
    final picked = s.selectedItem;
    if (picked != null && list.any((e) => e.id == picked.id)) return picked;
    return list.isEmpty ? null : list.first;
  }

  // ── actions ─────────────────────────────────────────────────────────────

  void _openTab(int category) {
    if (category == _category) return;
    HapticFeedback.selectionClick();
    setState(() => _category = category);
    _mallBloc.add(ChangeAppBarUIMallEvent(index: category));
    _ensureLoaded(category, showLoading: true);
    final list = _items(_mallBloc.state, category);
    if (list.isNotEmpty) {
      _mallBloc.add(SelectMallItemEvent(selectedItem: list.first));
    }
  }

  /// Full-screen preview (frame on your avatar, entry over the screen...).
  Future<void> _preview(MallEntity item) async {
    if (_previewProgress != null) return;
    await openStorePreview(
      context,
      StorePreview.mall(item),
      _type(_category),
      onProgress: (p) {
        if (mounted) setState(() => _previewProgress = p);
      },
    );
  }

  // ── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<MallSendBloc, MallSendState>(
      bloc: di<MallSendBloc>(),
      listener: (context, state) {
        if (state is SendSuccessState) {
          Methods.showToast(context, message: state.message);
        } else if (state is SendErrorState) {
          Methods.showToast(context, message: state.message, isError: true);
        } else if (state is SendLoadingState) {
          Methods.showToast(context, isLoading: true);
        }
      },
      child: BlocListener<MallBuyBloc, MallBuyState>(
        bloc: di<MallBuyBloc>(),
        listener: (_, state) {
          if (state is BuySuccessState) {
            Methods.showToast(context, message: state.massage);
            di<MyStoreBloc>().add(const GetMyStoreEvent(isLoading: false));
          } else if (state is BuyErrorState) {
            Methods.showToast(context, message: state.massage, isError: true);
          } else if (state is BuyLoadingState) {
            Methods.showToast(context, isLoading: true);
          }
        },
        child: BlocBuilder<MallBloc, GetDataMallStates>(
          bloc: _mallBloc,
          builder: (context, state) {
            final items = _items(state, _category);
            final request = _request(state, _category);
            final selected = _selected(state);
            final type = _type(_category);
            if (items.isNotEmpty) {
              _warmer.warm([
                if (selected != null) StorePreview.mall(selected),
                ...items.take(9).map(StorePreview.mall),
              ]);
            }
            return Scaffold(
              backgroundColor: StoreColors.bg,
              extendBodyBehindAppBar: true,
              appBar: AppBarWidget(
                backgroundColor: Colors.transparent,
                shadow: Colors.transparent,
                iconColor: Colors.white,
                title: StringManager.store.tr(),
                titleStyle:
                    context.titleLarge.size(20).w600.colorExt(Colors.white),
                actions: [
                  IconButton(
                    tooltip: StringManager.myProps.tr(),
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.bagScreen),
                    icon: Icon(Icons.backpack_outlined,
                        color: Colors.white, size: 24.sp),
                  ),
                  6.wBox,
                ],
              ),
              body: Column(
                children: [
                  StoreStage(
                    item: selected == null ? null : StorePreview.mall(selected),
                    type: type,
                    progress: _previewProgress,
                    onPreview: selected == null ? null : () => _preview(selected),
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
                        key: ValueKey('mall_cat_$_category'),
                        child: HandlingDataWidget(
                          title: StringManager.tittleEmptyFrame.tr(),
                          subTitle: StringManager.subTittleEmptyFrame.tr(),
                          reqState: request,
                          isNeedLoadingWidget: true,
                          onTap: () => _reload(_category),
                          child: _MallTabBarView(
                            mall: items,
                            tabType: type,
                            selected: selected,
                            isLoading: request.isLoading,
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
                  _MallBottomBar(selected: selected, type: type),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

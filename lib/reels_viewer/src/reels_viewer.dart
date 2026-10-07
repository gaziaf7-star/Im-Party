import 'dart:ui' show ImageFilter;

import 'package:general/reels_viewer/reels_viewer.dart';
import 'package:general/src/core/cache/reels_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

part 'components/animated_like.dart';
part 'components/more_options_widget.dart';
part 'components/reel_actions_widget.dart';
part 'components/reels_widget.dart';
part 'components/user_info_widget.dart';
part 'widgets/action_widget.dart';
part 'widgets/count_widget.dart';
part 'widgets/reel_description_widget.dart';

class ReelsViewer extends StatefulWidget {
  final List<ReelsEntity> reelList;
  final Function(ReelsEntity)? onClickCommentIcon;
  final Function(ReelsEntity)? onClickShareIcon;
  final Function(ReelsEntity)? onLike;
  final Function(ReelsEntity)? onUnLike;
  final Function(ReelsEntity)? onClickUserImage;
  final Function(ReelsEntity)? onFollow;
  final Function(ReelsEntity)? onUnFollow;
  final Function(ReelsEntity)? onDelete;
  final bool isSharedReel;
  final ReelsType filter;
  final String? userId;
  final GetReelsBloc getReelsBloc;
  final ReelViewerBloc? reelsViewerBloc;

  const ReelsViewer({
    super.key,
    required this.reelList,
    required this.filter,
    required this.getReelsBloc,
    this.onClickCommentIcon,
    this.onClickShareIcon,
    this.onLike,
    this.onUnLike,
    this.onClickUserImage,
    this.onFollow,
    this.onUnFollow,
    this.onDelete,
    this.userId,
    this.reelsViewerBloc,
    this.isSharedReel = false,
  });

  @override
  State<ReelsViewer> createState() => ReelsViewerState();
}

class ReelsViewerState extends State<ReelsViewer> {
  // Per-session set of reel ids whose view has already been recorded. Static so
  // the dedup survives switching feed tabs / rebuilding this widget within one
  // app run; scrolling back to a reel therefore never double-counts a view.
  static final Set<int> _recordedReelIds = {};

  // Fires POST reals/{id}/view once per session for [reel]. Fire-and-forget:
  // never awaited, never surfaces an error to the UI — a lost view count must
  // not affect playback.
  void _recordReelView(ReelsEntity? reel) {
    final id = reel?.id;
    if (id == null || !_recordedReelIds.add(id)) return;
    DioFactory().post(EndPoints.reelView(id.toString())).ignore();
  }

  List<ReelsEntity> _reelsFor(GetReelsState s) {
    return widget.filter == ReelsType.following
        ? s.followingReelsList
        : widget.filter == ReelsType.myReels
            ? s.myReelsList
            : s.reelsList;
  }

  Map<int, VideoPlayerController> _controllersFor(GetReelsState s) {
    return widget.filter == ReelsType.following
        ? s.followingVideoControllers
        : widget.filter == ReelsType.myReels
            ? s.myReelsVideoControllers
            : s.videoControllers;
  }

  Set<int> _erroredFor(GetReelsState s) {
    return widget.filter == ReelsType.following
        ? s.followingErroredIndices
        : widget.filter == ReelsType.myReels
            ? s.myReelsErroredIndices
            : s.erroredIndices;
  }

ReelsFeedBloc _activeFeed() {
    final bloc = widget.getReelsBloc;
    switch (widget.filter) {
      case ReelsType.following:
        return bloc.followingFeed;
      case ReelsType.myReels:
        return bloc.myReelsFeed;
      case ReelsType.forYou:
        return bloc.forYouFeed;
    }
  }

  bool _controllersChanged(GetReelsState prev, GetReelsState curr) {
    final p = _controllersFor(prev);
    final c = _controllersFor(curr);
    if (p.length != c.length) return true;
    for (final key in c.keys) {
      if (!identical(p[key], c[key])) return true;
    }
    return false;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetReelsBloc, GetReelsState>(
      bloc: widget.getReelsBloc,
      buildWhen: (prev, curr) {
        final prevReels = _reelsFor(prev);
        final currReels = _reelsFor(curr);
        return prevReels.length != currReels.length ||
            _controllersChanged(prev, curr) ||
            !setEquals(_erroredFor(prev), _erroredFor(curr)) ||
            prev.isSeeking != curr.isSeeking ||
            prev.readMore != curr.readMore ||
            prev.height != curr.height;
      },
      builder: (context, state) {
        final reels = _reelsFor(state);
        final controllers = _controllersFor(state);

        final scrollController = widget.filter == ReelsType.following
            ? state.followingScrollCtrl
            : widget.filter == ReelsType.myReels
                ? state.myReelsScrollCtrl
                : state.scrollCtrl;

        return Scaffold(
          backgroundColor: ColorManager.black,
          body: PageView.builder(
            controller: scrollController,
            itemCount: reels.length,
            scrollDirection: Axis.vertical,
            // Snappier paging that still yields the over-scroll at the top to
            // the parent RefreshIndicator (AlwaysScrollable so the pull-to-
            // refresh gesture is recognised even with a single full-screen page).
            physics: const _SnappyPageScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            onPageChanged: (index) {
              widget.reelsViewerBloc
                  ?.add(ChangeActiveReelEvent(index, widget.filter));
              widget.getReelsBloc
                  .add(PageChangedEvent(index, widget.filter, false));
              if (index >= 0 && index < reels.length) {
                _recordReelView(reels[index]);
              }
            },
            itemBuilder: (context, index) {
              // The first reel (index 0) is shown without an onPageChanged
              // event firing, so record its view here. Dedup makes this a
              // no-op on subsequent rebuilds.
              if (index == 0) {
                _recordReelView(reels[index]);
              }
              // Hide broken videos (errored during playback) with an opaque
              // black frame so the user can swipe past without seeing a logo.
              if (_erroredFor(state).contains(index)) {
                return const ColoredBox(color: Colors.black);
              }
              return Stack(
                  alignment: Alignment.center,
                  children: [
                    _ReelsWidget(
                      reelViewerBloc: widget.reelsViewerBloc!,
                      reelData: reels[index],
                      reelIndex: index,
                      reelsType: widget.filter,
                      controller: controllers[index],
                      feed: _activeFeed(),
                      onTogglePlay: () {
                        final viewerBloc = widget.reelsViewerBloc;
                        if (viewerBloc == null) return;
                        viewerBloc.add(
                          viewerBloc.state.isPlaying
                              ? PauseReelEvent()
                              : PlayReelEvent(),
                        );
                      },
                      onDoubleTapLike: () {
                        final reel =
                            _reelsFor(widget.getReelsBloc.state)[index];
                        if (reel.isLiked == false) {
                          widget.onLike?.call(reel);
                        }
                        widget.getReelsBloc
                            .add(AnimateLikeEvent(index, widget.filter));
                      },
                    ),
                    BlocSelector<GetReelsBloc, GetReelsState, bool>(
                      bloc: widget.getReelsBloc,
                      selector: (s) => s.isCommentsOpened,
                      builder: (context, isCommentsOpened) {
                        if (isCommentsOpened) return const SizedBox.shrink();
                        return Stack(
                          children: [
                            ValueListenableBuilder<Duration>(
                              valueListenable: _activeFeed().positionNotifier,
                              builder: (context, pos, _) {
                                return ValueListenableBuilder<Duration>(
                                  valueListenable:
                                      _activeFeed().durationNotifier,
                                  builder: (context, dur, _) {
                                    return BlocBuilder<ReelViewerBloc,
                                        ReelViewerState>(
                                      bloc: widget.reelsViewerBloc,
                                      buildWhen: (prev, curr) =>
                                          prev.isPlaying != curr.isPlaying,
                                      builder: (context, viewerState) {
                                        return _buildSlider(
                                            pos, dur, viewerState, state);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            if (!state.isSeeking) ...[
                              // Per-item selector: only rebuilds this overlay when THIS reel's data changes
                              BlocSelector<GetReelsBloc, GetReelsState,
                                  ReelsEntity?>(
                                bloc: widget.getReelsBloc,
                                selector: (s) {
                                  final list = _reelsFor(s);
                                  return index < list.length
                                      ? list[index]
                                      : null;
                                },
                                builder: (context, reel) {
                                  if (reel == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Stack(
                                    children: [
                                      PositionedDirectional(
                                        bottom: 10,
                                        start: 0,
                                        child: _ReelUserInfo(
                                          height: state.height ?? 0,
                                          readMore: state.readMore,
                                          onTapFollow: () {
                                            widget.getReelsBloc.add(
                                                ToggleFollowEvent(
                                                    index, widget.filter));
                                            widget.onFollow?.call(reel);
                                          },
                                          onUserTap: () => widget
                                              .onClickUserImage
                                              ?.call(reel),
                                          reelsEntity: reel,
                                        ),
                                      ),
                                      PositionedDirectional(
                                        bottom: 10,
                                        end: 0,
                                        child: _ReelActionsWidget(
                                          reelsEntity: reel,
                                          onTapFollow: () {
                                            widget.getReelsBloc.add(
                                                ToggleFollowEvent(
                                                    index, widget.filter));
                                            if (reel.user?.isFollow != true) {
                                              widget.onFollow?.call(reel);
                                            }
                                          },
                                          onUserTap: () => widget
                                              .onClickUserImage
                                              ?.call(reel),
                                          onLike: () {
                                            widget.getReelsBloc.add(
                                                ToggleLikeEvent(
                                                    index, widget.filter));
                                            reel.isLiked == true
                                                ? widget.onLike?.call(reel)
                                                : widget.onUnLike?.call(reel);
                                          },
                                          onClickComment: () => widget
                                              .onClickCommentIcon
                                              ?.call(reel),
                                          onClickShare: () => widget
                                              .onClickShareIcon
                                              ?.call(reel),
                                          onDelete: widget.onDelete == null
                                              ? null
                                              : () =>
                                                  widget.onDelete?.call(reel),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSlider(Duration position, Duration duration,
      ReelViewerState viewerState, GetReelsState state) {
    return Positioned(
      bottom: -15,
      child: Column(
        children: [
          if (state.isSeeking)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  TextWidget(
                    _formatDuration(position),
                    style: context.bodyMedium.bold
                        .size(20)
                        .colorExt(ColorManager.textPrimary),
                  ),
                  TextWidget(" / ",
                      style: context.bodyMedium.bold
                          .size(16)
                          .colorExt(ColorManager.textPrimary)),
                  TextWidget(
                    _formatDuration(duration),
                    style: context.bodyMedium.bold
                        .size(20)
                        .colorExt(ColorManager.greyTextColor),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: ScreenUtil().screenWidth,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: state.isSeeking ? 8 : 2,
                thumbShape: RectangularSliderThumb(
                  thumbWidth: state.isSeeking ? 12 : 8,
                  thumbHeight: state.isSeeking ? 18 : 8,
                ),
                thumbColor: viewerState.isPlaying == false || state.isSeeking
                    ? ColorManager.textPrimary
                    : ColorManager.idGreyColor,
              ),
              child: Slider(
                min: 0,
                max: duration.inMilliseconds.toDouble(),
                value: position.inMilliseconds
                    .clamp(0, duration.inMilliseconds)
                    .toDouble(),
                activeColor: ColorManager.idGreyColor,
                inactiveColor: ColorManager.grayMouce,
                onChanged: (value) {
                  final pos = Duration(milliseconds: value.toInt());
                  widget.getReelsBloc.add(SeekVideoEvent(pos, widget.filter));
                },
                onChangeEnd: (_) =>
                    widget.getReelsBloc.add(const UpdateIsSeekEvent(false)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RectangularSliderThumb extends SliderComponentShape {
  final double thumbWidth;
  final double thumbHeight;

  RectangularSliderThumb({this.thumbWidth = 8, this.thumbHeight = 20});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(thumbWidth, thumbHeight);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final Rect thumbRect = Rect.fromCenter(
      center: center,
      width: thumbWidth.w,
      height: thumbHeight.h,
    );

    final RRect roundedThumb =
        RRect.fromRectAndRadius(thumbRect, Radius.circular(4.w));
    canvas.drawRRect(roundedThumb, paint);
  }
}

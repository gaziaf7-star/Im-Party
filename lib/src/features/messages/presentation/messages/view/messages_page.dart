import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/cupertino.dart';
import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/realtime/in_app_chat_notifier.dart';
import 'package:general/src/core/utils/relative_time.dart';
import 'package:general/src/core/utils/text_sanitizer.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/cp/presentation/cp/view/components/cp_design.dart';
import 'package:general/src/features/cp/presentation/cp_store/bloc/cp_relations/cp_relations_bloc.dart';
import 'package:general/src/features/messages/messages.dart';
import 'package:general/src/features/messages/presentation/messages/blocs/make_react/react_controller.dart';
import 'package:general/src/features/messages/presentation/messages/view/components/messages/deleted_message_body.dart';
import 'package:general/src/features/messages/presentation/messages/view/widgets/pagination_loading_widget.dart';
import 'package:general/src/features/messages/presentation/messages/view/widgets/show_delete_dialog.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/add_or_delete_block/add_or_delete_block_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/add_or_delete_block/add_or_delete_block_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/component/report_dialog_for_users.dart';
import 'package:general/src/features/room/presentation/share/open_shared_room.dart';
import 'package:general/src/features/room/room.dart';
import 'package:reaction_askany/models/emotions.dart';
import 'package:reaction_askany/models/reaction_box_paramenters.dart';
import 'package:reaction_askany/reaction_askany.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../blocs/text_field_bloc/text_field__bloc.dart';

part 'components/app_bar/normal_app_bar_body.dart';

part 'components/app_bar/selected_app_bar_body.dart';

part 'components/messages/attach_dialog_body.dart';

part 'components/messages/card_message_body.dart';

part 'widgets/cp_message.dart';

part 'widgets/emojis_widget.dart';

part 'widgets/message_image_and_text_widget.dart';

part 'widgets/message_image_widget.dart';

part 'widgets/message_text_widget.dart';

part 'widgets/message_video_widget.dart';

part 'widgets/message_voice_widget.dart';

part 'widgets/replay_widget.dart';

part 'widgets/seen_widget.dart';

part 'widgets/select_media_widget.dart';

/// Max characters per text message. The input field enforces this via maxLength
/// so the keyboard stops at the limit instead of erroring after the user sends.
/// Single source of truth lives in [ConstantsManager.maxMessageLength].
const int kMaxMessageLength = ConstantsManager.maxMessageLength;

/// Actions in the 1:1 conversation overflow (⋮) menu.
enum _ChatMenuAction { viewProfile, block, report, delete }

class MessagesPage extends StatefulWidget {
  final MessagesParameter params;

  const MessagesPage({super.key, required this.params});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with RouteAware {
  final FetchMessagesBloc _messagesBloc = di<FetchMessagesBloc>();

  /// Single key for the search-jump target only — lets
  /// [Scrollable.ensureVisible] bring the matched message into view regardless
  /// of variable bubble heights. Allocating one GlobalKey per message grew the
  /// map unbounded with the session; only the jump target needs a key.
  GlobalKey? _jumpKey;

  /// The message id the [_jumpKey] is currently attached to (the jump target).
  int? _jumpTargetId;

  /// Message id currently flashed by the search-jump highlight (null = none).
  int? _highlightId;

  /// One-shot guard, latched ONLY after the jump actually lands. While false a
  /// new loaded window re-attempts the jump, so a target that wasn't in the very
  /// first window (older match, still paging in) is no longer lost.
  bool _didJump = false;

  /// True while a post-frame jump attempt is in flight, so overlapping `data`
  /// emissions don't queue duplicate callbacks for the same target.
  bool _jumpInFlight = false;

  /// Scroll to the [messageId] in the loaded window and flash it for ~500ms.
  /// When the target isn't yet in the rendered window the latch stays OPEN so a
  /// later emission (after more pages load) retries instead of silently failing.
  void _jumpToMessage(int messageId) {
    if (_didJump || _jumpInFlight) return;
    _jumpInFlight = true;
    // Attach the single jump key to the target bubble so the next frame can
    // resolve its context for ensureVisible.
    _jumpTargetId = messageId;
    _jumpKey = GlobalKey();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _jumpInFlight = false;
      final ctx = _jumpKey?.currentContext;
      if (ctx == null) {
        // Target not in the rendered window yet — DON'T latch. The next data
        // emission (more pages loaded) will re-enter and try again.
        return;
      }
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        alignment: 0.5,
      );
      if (!mounted) return;
      // Latch only now that the jump succeeded, so it fires exactly once.
      _didJump = true;
      setState(() => _highlightId = messageId);
      // Clear the jump target in the bloc once we've scrolled to it, so a stream
      // re-render or reopening the chat doesn't re-trigger / stick the jump.
      _messagesBloc.add(const ClearJumpTargetEvent());
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _highlightId = null);
      });
    });
  }

  @override
  void initState() {
    // if (di<ToggleAppBarBloc>().state.isShowRoomCard != true) {
    //   di<ToggleAppBarBloc>().add(const ShowRoomCardEvent(isShowRoomCard: true));
    // }
    // Mark this conversation as on screen so in-app message banners for this
    // peer are suppressed while the user is reading it.
    final activePeer = int.tryParse(widget.params.userId);
    if (activePeer != null) {
      InAppChatNotifier.instance.setActivePeer(activePeer);
    }
    _messagesBloc.add(
      FetchMessagesEvent(
        params: FetchMessagesParamsUC(
          userId: widget.params.userId,
          // Server room id — activates the offline-first realtime path (drift
          // stream + instant open + clear-unread + 50-msg pagination). Without
          // it the bloc falls back to the legacy REST path (empty open, badge
          // never clears). Passed from the chats list / search.
          chatId: widget.params.chatId,
          // Search-jump target (when opened from chats search on a message hit).
          messageIdToMove: widget.params.messageIdToMove,
        ),
        isFirstPage: true,
      ),
    );
    _messagesBloc.add(
      AddListenerEvent(
        params: FetchMessagesParamsUC(
          userId: widget.params.userId,
          // page: '${_messagesBloc.state.currentPage}',
        ),
      ),
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) navigatorObserver.subscribe(this, route);
  }

  @override
  void didPopNext() {
    // A pushed route (e.g. another chat opened from this one) was popped and we
    // are visible again — re-establish OUR active-peer marker, since opening the
    // other chat overwrote it. Without this, returning here would leave no
    // active marker and re-enable banners/sound for the chat on screen.
    final activePeer = int.tryParse(widget.params.userId);
    if (activePeer != null) {
      InAppChatNotifier.instance.setActivePeer(activePeer);
    }
    super.didPopNext();
  }

  @override
  void dispose() {
    navigatorObserver.unsubscribe(this);
    // Targeted clear: only drop the active-peer marker if it still points at
    // THIS conversation, so opening B from A (B's initState set active=B before
    // this dispose runs) does not wipe B's marker (banner/sound race).
    InAppChatNotifier.instance
        .clearActivePeerIfMatches(int.tryParse(widget.params.userId));
    // Tear down any voice controllers still cached for this chat session, in
    // case a bubble's own dispose was skipped (list teardown). Async; fire-and-
    // forget is fine here.
    unawaited(VoicePlayerManager().disposeAll());
    di<ToggleAppBarBloc>().add(const InitAppBarEvent());
    _messagesBloc
      ..add(const CloseMessagesEvent())
      ..add(
        RemoveListenerEvent(
          params: FetchMessagesParamsUC(userId: widget.params.userId),
        ),
      );
    super.dispose();
  }

  void _onChatMenuAction(_ChatMenuAction action) {
    final userId = widget.params.userId;
    switch (action) {
      case _ChatMenuAction.viewProfile:
        Methods().userProfileNavigator(context: context, userId: userId);
      case _ChatMenuAction.block:
        _confirmBlockUser();
      case _ChatMenuAction.report:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDialogForUsers(userId: userId),
          ),
        );
      case _ChatMenuAction.delete:
        _confirmClearChat();
    }
  }

  void _confirmBlockUser() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AnimatedDialog(
        title: StringManager.blockUser.tr(),
        description: StringManager.blockUserConfirm.tr(),
        conText: StringManager.done.tr(),
        dialogBackgroundColor: ColorManager.white,
        titleColor: ColorManager.momentPostTextColor,
        descriptionColor: ColorManager.momentPostTextColor,
        cancelTextColor: ColorManager.momentPostTextColor,
        confirmGradientColors: ColorManager.brandGradientColors,
        onTap: () {
          Navigator.pop(dialogCtx);
          // The block bloc shows its own toast and pops this screen on success.
          di<AddOrRemoveBlock>().add(
            AddBlockListEvent(context, userId: widget.params.userId),
          );
        },
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AnimatedDialog(
        title: StringManager.deleteChatTitle.tr(),
        description: StringManager.deleteChatSubTitle.tr(),
        conText: StringManager.done.tr(),
        dialogBackgroundColor: ColorManager.white,
        titleColor: ColorManager.momentPostTextColor,
        descriptionColor: ColorManager.momentPostTextColor,
        cancelTextColor: ColorManager.momentPostTextColor,
        confirmGradientColors: ColorManager.brandGradientColors,
        onTap: () async {
          Navigator.pop(dialogCtx);
          final peerId = int.tryParse(widget.params.userId) ?? 0;
          if (peerId > 0) {
            di<DeleteChatBloc>().add(DeleteChatEvent(userId: peerId));
            await di<RoomsDao>().deleteRoomByPeer(peerId);
          }
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _chatOptionsMenu() {
    return PopupMenuButton<_ChatMenuAction>(
      // Fixed white icon (was the panel-driven iconColor) — this sits on the
      // brand-gradient app bar now.
      icon: Icon(Icons.more_vert,
          color: ColorManager.onBrandGradient, size: 22.h),
      // Fixed white popup card (was the mutable, panel-overridable
      // surfaceCardColor).
      color: ColorManager.white,
      onSelected: _onChatMenuAction,
      itemBuilder: (_) => [
        _chatMenuItem(_ChatMenuAction.viewProfile, Icons.person_outline,
            StringManager.showProfile.tr()),
        _chatMenuItem(
            _ChatMenuAction.block, Icons.block, StringManager.blockUser.tr()),
        _chatMenuItem(_ChatMenuAction.report, Icons.flag_outlined,
            StringManager.reportUser.tr()),
        _chatMenuItem(_ChatMenuAction.delete, Icons.delete_outline,
            StringManager.clearConversation.tr()),
      ],
    );
  }

  PopupMenuItem<_ChatMenuAction> _chatMenuItem(
      _ChatMenuAction value, IconData icon, String label) {
    return PopupMenuItem<_ChatMenuAction>(
      value: value,
      child: Row(
        children: [
          // Fixed light-black (was the panel-driven iconColor/textPrimary) —
          // this menu's own card is fixed white now.
          Icon(icon, size: 20.h, color: ColorManager.momentPostTextColor),
          10.wBox,
          TextWidget(
            label,
            isTranslate: false,
            style: context.bodyMedium
                .colorExt(ColorManager.momentPostTextColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (di<ToggleAppBarBloc>().state.isToggle == true) {
          di<ToggleAppBarBloc>().add(const ToggleAppBarEvent(isToggle: false));
          return;
        }
      },
      child: BlocBuilder<ToggleAppBarBloc, ToggleAppBarState>(
        bloc: di<ToggleAppBarBloc>(),
        buildWhen: (prev, curr) =>
        prev.isToggle != curr.isToggle ||
            prev.isShowMore != curr.isShowMore ||
            prev.isShowRoomCard != curr.isShowRoomCard,
        builder: (context, __) {
          return Scaffold(
            appBar: AppBarWidget(
              // Fixed brand-gradient app bar (was the panel-driven flat
              // scaffoldBg) — matches the professional look used across the
              // app.
              backgroundGradient: ColorManager.brandGradient,
              isShowBack: false,
              height: 70.h,
              // Left-aligned WhatsApp-style title (back + avatar + name flow
              // together from the leading edge), not centered.
              centerTitle: false,
              titleSpacing: 0,
              title: __.isToggle == true
                  ? _SelectedAppBarBody(bloc: di<ToggleAppBarBloc>())
                  : _NormalAppBarBody(params: widget.params),
              actions: __.isToggle == true ? null : [_chatOptionsMenu()],
            ),
            // Fixed white (was the panel-driven scaffoldBgAlt) — matches the
            // professional white look used across the app.
            backgroundColor: ColorManager.white,
            body: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Column(
                  children: [
                    BlocConsumer<FetchMessagesBloc, FetchMessagesState>(
                        bloc: _messagesBloc,
                        listenWhen: (prev, curr) => prev.data != curr.data,
                        listener: (context, state) {
                          // Search-jump: once the first window is loaded, scroll
                          // to the requested message and flash it.
                          final target = state.messageIdToMove;
                          if (target != null &&
                              state.data.isNotEmpty &&
                              !_didJump) {
                            _jumpToMessage(target);
                          }
                        },
                        buildWhen: (prev, curr) =>
                        prev.reqState != curr.reqState ||
                            prev.data != curr.data ||
                            prev.messageIdToMove != curr.messageIdToMove,
                        builder: (context, state) {
                          return Directionality(
                            textDirection: TextDirection.ltr,
                            child: Expanded(
                              child: HandlingDataWidget(
                                isNeedLoadingWidget: true,
                                reqState: state.reqState == RequestState.empty
                                    ? RequestState.loaded
                                    : state.reqState,
                                title: StringManager.noMessages.tr(),
                                subTitle: StringManager.noMessagesMsg.tr(),
                                // Fixed dark text (was the panel-driven
                                // textPrimary, which can resolve light/near-
                                // white and go invisible on this screen's
                                // white background).
                                titleStyle: context.bodyLarge.w600
                                    .colorExt(ColorManager.momentPostTextColor),
                                subTitleStyle: context.bodyMedium.colorExt(
                                    ColorManager.momentPostTextColor
                                        .withValues(alpha: 0.65)),
                                onTap: () {
                                  _messagesBloc.add(
                                    FetchMessagesEvent(
                                      params: FetchMessagesParamsUC(
                                        userId: widget.params.userId,
                                      ),
                                      isLoading: false,
                                    ),
                                  );
                                },
                                child: Skeletonizer(
                                  enabled:
                                  state.reqState == RequestState.loading,
                                  child: ListView.separated(
                                    // No shrinkWrap: the list lives inside an
                                    // Expanded with a bounded height, so
                                    // shrinkWrap:true only forced a full layout
                                    // of every bubble each frame (jank that grew
                                    // with the message count). Lazy building +
                                    // a small cacheExtent keep scrolling smooth.
                                    reverse: true,
                                    cacheExtent: 600,
                                    padding: context.paddingOnly(bottom: 20),
                                    separatorBuilder: (context, index) =>
                                    20.hBox,
                                    controller: state.scrollController,
                                    itemBuilder: (context, index) {
                                      if (state.reqState ==
                                          RequestState.loading) {
                                        return Container(
                                          margin: context.paddingSymmetric(
                                              vertical: 10),
                                          child: Row(
                                            mainAxisAlignment: index % 2 == 0
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                            children: [
                                              if (index % 2 != 0)
                                                Container(
                                                  width: 40.w,
                                                  height: 40.h,
                                                  decoration: BoxDecoration(
                                                    color: ColorManager
                                                        .surfaceCardColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  margin: context.paddingOnly(
                                                      end: 8),
                                                ),
                                              Container(
                                                width: 200.w,
                                                padding: context.paddingAll(5),
                                                decoration: BoxDecoration(
                                                  color: ColorManager
                                                      .surfaceCardColor,
                                                  borderRadius:
                                                  BorderRadius.circular(5),
                                                ),
                                                child: const Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text("user name"),
                                                    Text("message from user"),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        final currentMessage =
                                        state.data[index];
                                        bool isMe = Methods.isMe(
                                            currentMessage.userId.toString());
                                        final isLastMessage = (index == 0) ||
                                            (state.data[index - 1].userId !=
                                                currentMessage.userId);
                                        final msgId = currentMessage.id;
                                        // Single jump key, attached ONLY to the
                                        // search-jump target so `ensureVisible`
                                        // can scroll to it; the highlight then
                                        // flashes the matched bubble briefly.
                                        final itemKey = (msgId != null &&
                                            msgId == _jumpTargetId)
                                            ? _jumpKey
                                            : null;
                                        final messageWidget = KeyedSubtree(
                                          key: ValueKey(msgId),
                                          child: AnimatedContainer(
                                            key: itemKey,
                                            duration: const Duration(
                                                milliseconds: 250),
                                            color: (msgId != null &&
                                                msgId == _highlightId)
                                                ? ColorManager.primary
                                                .withValues(alpha: 0.15)
                                                : ColorManager.transparent,
                                            child: (currentMessage
                                                .receiverDeleted ==
                                                true &&
                                                currentMessage
                                                    .senderDeleted ==
                                                    true) ||
                                                (currentMessage
                                                    .senderDeleted ==
                                                    true &&
                                                    isMe)
                                                ? TheDeletedMessage(
                                              createdAt:
                                              '${currentMessage.createdAt}',
                                              userId:
                                              '${currentMessage.userId}',
                                              image: widget.params.image,
                                              isLastMessage:
                                              isLastMessage,
                                            )
                                                : _CardMessageBody(
                                              entity: currentMessage,
                                              params: widget.params,
                                              isLastMessage:
                                              isLastMessage,
                                            ),
                                          ),
                                        );

                                        // WhatsApp-style day separators + a
                                        // start-of-chat marker. In a reversed
                                        // list index+1 is the older message, so
                                        // a boundary means this is the first
                                        // (oldest) message of its day.
                                        final isOldest =
                                            index == state.data.length - 1;
                                        final showDay = isOldest ||
                                            !sameLocalDayIso(
                                                currentMessage.createdAt,
                                                state.data[index + 1].createdAt);
                                        final dayLabel = showDay
                                            ? chatDayLabelFromIso(
                                            currentMessage.createdAt)
                                            : null;
                                        // Isolate each row's paint so a
                                        // status/seen/reaction repaint in one
                                        // bubble never dirties its siblings'
                                        // layers (whole-window repaint on every
                                        // drift emission otherwise).
                                        if (!showDay && !isOldest) {
                                          return RepaintBoundary(
                                              child: messageWidget);
                                        }
                                        return RepaintBoundary(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isOldest)
                                                const ChatStartIndicator(),
                                              if (dayLabel != null)
                                                ChatDaySeparator(
                                                    label: dayLabel),
                                              messageWidget,
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    itemCount:
                                    state.reqState == RequestState.loading
                                        ? 5
                                        : state.data.length,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                    15.hBox,
                    BlocBuilder<TextFieldBloc, TextFieldStates>(
                      bloc: di<TextFieldBloc>(),
                      // Only rebuild the send bar on layout-affecting changes,
                      // NOT on every per-second counter tick (the time label
                      // rebuilds itself via its own narrow builder).
                      buildWhen: (prev, curr) =>
                      prev.isRecording != curr.isRecording ||
                          prev.isPaused != curr.isPaused ||
                          prev.isDisplayVoice != curr.isDisplayVoice ||
                          prev.reqState != curr.reqState,
                      builder: (context, state) {
                        return _SendMessageFieldBody(
                          parameter: widget.params,
                          toggleState: __,
                        );
                      },
                    ),
                  ],
                ),
                if (di<ToggleAppBarBloc>().state.isShowMore) ...[
                  Positioned.fill(
                    child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: (_) {
                        if (di<ToggleAppBarBloc>().state.isShowMore) {
                          di<ToggleAppBarBloc>()
                              .add(const ShowAttachBoxEvent(isShowMore: false));
                        }
                      },
                      child: const SizedBox(),
                    ),
                  ),
                  _AttachDialogBody(params: widget.params),
                ],
                if (widget.params.inRoom == true)
                  BlocBuilder<FetchMessagesBloc, FetchMessagesState>(
                    bloc: _messagesBloc,
                    buildWhen: (prev, curr) => prev.room != curr.room,
                    builder: (context, state) {
                      return (state.room?.roomOwnerId != null &&
                          state.room!.roomOwnerId != 0 &&
                          state.room?.room?.id != 0)
                          ? Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: SizedBox(
                          child: Stack(
                            children: [
                              Container(
                                margin: context.paddingSymmetric(
                                    horizontal: 15),
                                padding: context.paddingAll(3),
                                decoration: BoxDecoration(
                                  color: ColorManager.lightGreen,
                                  borderRadius: 10.radius,
                                ),
                                child: Row(
                                  children: [
                                    Stack(
                                      alignment: AlignmentDirectional
                                          .bottomCenter,
                                      children: [
                                        UserImage(
                                          image: widget.params.image,
                                          displayName: widget.params.name,
                                          imageSize: 50,
                                          borderRadius: 10.radius,
                                        ),
                                        Image.asset(
                                          AssetsManager.newSoundWave,
                                          color: ColorManager.white,
                                          height: 20.h,
                                          width: 40.h,
                                        ),
                                      ],
                                    ),
                                    10.wBox,
                                    TextWidget(
                                      StringManager.havingFun.tr(),
                                      style: context.bodyMedium.colorExt(
                                          ColorManager.blackColor),
                                    ),
                                    const Spacer(),
                                    MultiTapCard(
                                      onTap: () async {
                                        // Same room & not minimized: just pop back to room screen
                                        if (di<RoomStateManager>()
                                            .isInRoom &&
                                            !di<RoomStateManager>()
                                                .isMinimized &&
                                            RoomData.instance.room.id ==
                                                state.room?.room?.id) {
                                          context.popUntilRoute(
                                              Routes.roomScreen);
                                          return;
                                        }

                                        final navContext =
                                            SafeNavigator.context;
                                        if (navContext == null) return;

                                        if (di<RoomStateManager>()
                                            .isInRoom &&
                                            !di<RoomStateManager>()
                                                .isMinimized) {
                                          // Pop messages and chat screens back to room
                                          context.popUntilRoute(
                                              Routes.roomScreen);
                                        } else {
                                          // Pop messages and chat screens back to layout
                                          navContext.popUntilRoute(
                                              Routes.layout);
                                        }

                                        // Let RoomStateManager handle the full room transition
                                        // (exit current room if needed, enter new room)
                                        di<RoomStateManager>()
                                            .navigateToRoom(
                                          RoomEntryRequest(
                                            context: navContext,
                                            roomData: RoomEntity(
                                              passwordStatus: state.room
                                                  ?.hasPassword ??
                                                  false,
                                              ownerId: state.room
                                                  ?.roomOwnerId ??
                                                  0,
                                              id: state.room?.room?.id ??
                                                  0,
                                              name: state
                                                  .room?.room?.name ??
                                                  "",
                                              cover: state.room?.room
                                                  ?.image ??
                                                  "",
                                              roomBackground: state
                                                  .room
                                                  ?.room
                                                  ?.roomBackground ??
                                                  "",
                                              mode: state.room?.room?.mode
                                                  .toString() ??
                                                  '',
                                              uuidOwnerRoom: state.room
                                                  ?.owner?.uuid ??
                                                  "",
                                              giftPrice:
                                              state.room?.room?.exp ??
                                                  "",
                                            ),
                                            isLive: false,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 70.w,
                                        height: 28.h,
                                        padding: context.paddingSymmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: ColorManager.orange,
                                          borderRadius: 20.radius,
                                        ),
                                        child: Center(
                                          child: TextWidget(
                                            StringManager.go.tr(),
                                            style: context.bodyMedium.bold
                                                .colorExt(ColorManager
                                                .whiteColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                    10.wBox,
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 10,
                                child: Container(
                                  padding: context.paddingAll(2),
                                  decoration: BoxDecoration(
                                    color: ColorManager.black
                                        .withValues(alpha: (0.15)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      di<ToggleAppBarBloc>().add(
                                        const ShowRoomCardEvent(
                                          isShowRoomCard: false,
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: ColorManager.white,
                                      size: 13.h,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          : const SizedBox();
                    },
                  ),
                Positioned(
                  top: 0,
                  child: BlocBuilder<FetchMessagesBloc, FetchMessagesState>(
                    bloc: _messagesBloc,
                    buildWhen: (prev, curr) =>
                    prev.isPagination != curr.isPagination,
                    builder: (context, state) {
                      return PaginationLoader(
                          isVisible: state.isPagination == true);
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SendMessageFieldBody extends StatefulWidget {
  const _SendMessageFieldBody({
    required this.parameter,
    required this.toggleState,
  });

  final MessagesParameter parameter;
  final ToggleAppBarState toggleState;

  @override
  State<_SendMessageFieldBody> createState() => _SendMessageFieldBodyState();
}

class _SendMessageFieldBodyState extends State<_SendMessageFieldBody> {
  late final TextEditingController messageController;
  final ValueNotifier<bool> isEnglishNotifier = ValueNotifier<bool>(true);
  bool isEnglish = true;

  @override
  void initState() {
    messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  static final RegExp _englishCharRegex = RegExp(r'[a-zA-Z]');

  bool isFirstCharEnglish(String text) {
    if (text.isEmpty) return false;
    final firstChar = text[0];
    return _englishCharRegex.hasMatch(firstChar);
  }

  Future<void> _handleSendAction() async {
    if (di<TextFieldBloc>().state.isRecording) {
      // Capture the voice file + counter BEFORE stopping, because stopRecord
      // nulls state.voice (isVoiceNull) — reading it after the toggle races and
      // can send an empty/0-length voice. Stop is awaited so the file is flushed
      // to disk before we validate it.
      final voiceFile = di<TextFieldBloc>().state.voice;
      final counter = di<TextFieldBloc>().state.counter;
      di<TextFieldBloc>().toggleRecorder();

      if (voiceFile == null) return; // nothing was captured
      // Reject a recording that never produced audible audio (instant tap or a
      // denied-mic phantom): require a non-empty file and at least ~1s.
      final exists = await voiceFile.exists();
      final length = exists ? await voiceFile.length() : 0;
      if (!exists || length <= 0 || counter < 1) {
        if (mounted) {
          Methods.showToast(context,
              isError: true,
              message: StringManager.someThingWentWrong.tr());
        }
        return;
      }
      _voice(voiceFile);
      return;
    }

    // Agency owners can be messaged by anyone at any time, so the non-friend
    // 3-message cap is skipped for them (backend enforces the same exemption).
    if (widget.parameter.isNotFriend == true &&
        widget.parameter.isAgencyOwner != true) {
      final data = di<FetchMessagesBloc>().state.data;
      final myMessageCount = data
          .where((v) =>
      v.userId.toString() == MyDataModel.getInstance().id.toString())
          .length;
      if (data.length >= 6 || myMessageCount >= 3) {
        Methods.showToast(context,
            isError: true,
            message: StringManager.youHaveReachedLimitMessages.tr());
        return;
      }
    }

    // Safety net only — the input field caps length via maxLength so the user
    // never types past the limit (no surprise post-send error).
    if (messageController.text.length > kMaxMessageLength) {
      Methods.showToast(context,
          isError: true,
          message: StringManager.youHaveReachedLimitMessages.tr());
      return;
    }

    if (messageController.text.trim().isEmpty) return;

    if (await Methods.isCheckInternet()) {
      _message(messageController);
      messageController.clear();
    } else {
      Methods.showToast(context,
          isError: true, message: StringManager.internetConnection.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: ColorManager.transparent,
      color: ColorManager.offWhite,
      margin: context.paddingZero(),
      child: Padding(
        padding: context.paddingOnly(top: 10, bottom: 5, end: 7, start: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ReplayBoxBody(
                state: widget.toggleState, name: widget.parameter.name),
            BlocConsumer<SendMessagesBloc, SendMessagesState>(
              listener: (context, state) {
                if (state.reqState.isLoading) {
                  di<ToggleAppBarBloc>().add(const InitAppBarEvent());
                }
              },
              bloc: di<SendMessagesBloc>(),
              builder: (context, state) {
                return ValueListenableBuilder<bool>(
                  valueListenable: isEnglishNotifier,
                  builder: (context, isEnglish, child) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<bool>(
                            valueListenable: isEnglishNotifier,
                            builder: (context, isEnglish, child) {
                              return di<TextFieldBloc>().state.isRecording ==
                                  false
                                  ? TextInputWidget(
                                StringManager.typeSomething.tr(),
                                isTappedOutside: false,
                                // Enter inserts a newline (grows the field)
                                // instead of dismissing the keyboard; user
                                // sends via the send button.
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                minLines: 1,
                                maxLines: 5,
                                // Cap length at the keyboard so the user
                                // can't type past the limit (no post-send
                                // error). No visible counter.
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(
                                      kMaxMessageLength),
                                ],
                                onChanged: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (isFirstCharEnglish(value[0]) &&
                                        value.length == 1) {
                                      isEnglishNotifier.value = true;
                                    } else if (!isFirstCharEnglish(
                                        value[0])) {
                                      isEnglishNotifier.value = false;
                                    }
                                  }
                                },
                                controller: messageController,
                                hintStyle: context.bodyMedium.colorExt(
                                    ColorManager.momentPostTextColor
                                        .withValues(alpha: 0.5)),
                                textColor:
                                ColorManager.momentPostTextColor,
                                cursorColor:
                                ColorManager.brandGradientColors.last,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: 30.radius,
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: context.paddingSymmetric(
                                    horizontal: 15, vertical: 5),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: 30.radius,
                                  borderSide: BorderSide.none,
                                ),
                                // Fixed white (was surfaceCardColor —
                                // panel-driven, could turn dark and hide
                                // the black text on top of it).
                                fillColor: ColorManager.white,
                                suffixIcon: Icons.attach_file,
                                suffixColor: ColorManager.grey,
                                onPressed: () {
                                  if (di<ToggleAppBarBloc>()
                                      .state
                                      .isShowMore ==
                                      true) {
                                    di<ToggleAppBarBloc>().add(
                                        const ShowAttachBoxEvent(
                                            isShowMore: false));
                                  } else {
                                    di<ToggleAppBarBloc>().add(
                                        const ShowAttachBoxEvent(
                                            isShowMore: true));
                                  }
                                },
                              )
                                  : Container(
                                margin: context.paddingOnly(bottom: 7.0),
                                child: Stack(
                                  alignment:
                                  AlignmentDirectional.centerEnd,
                                  children: [
                                    _VoiceBoxBody(
                                      // Route through the validated send
                                      // path (capture file+counter, stop,
                                      // reject empty) instead of sending
                                      // the raw (possibly-nulled) voice.
                                      onTap: () => _handleSendAction(),
                                    ),
                                    GestureDetector(
                                      onTap: () async =>
                                          _handleSendAction(),
                                      child: Container(
                                        padding: context.paddingAll(10),
                                        margin:
                                        context.paddingOnly(end: 5),
                                        // Brand gradient (was the flat
                                        // panel-driven primary).
                                        decoration: const BoxDecoration(
                                            gradient:
                                            ColorManager.brandGradient,
                                            shape: BoxShape.circle),
                                        child: Image.asset(
                                          AssetsManager.send,
                                          height: 20.h,
                                          color:
                                          ColorManager.onBrandGradient,
                                          width: 20.w,
                                          scale: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        if (di<TextFieldBloc>().state.isRecording == false) ...[
                          5.wBox,
                          SizedBox(
                            width: 73.w,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    di<TextFieldBloc>().toggleRecorder();
                                  },
                                  child: Image.asset(
                                    AssetsManager.mic,
                                    height: 20.5.h,
                                    width: 20.5.w,
                                    //color: ColorManager.white,
                                  ),
                                ),
                                5.wBox,
                                GestureDetector(
                                  onTap: () async => _handleSendAction(),
                                  child: Container(
                                    padding: context.paddingAll(10),
                                    margin: context.paddingAll(2),
                                    // Brand gradient (was the flat
                                    // panel-driven primary).
                                    decoration: const BoxDecoration(
                                        gradient: ColorManager.brandGradient,
                                        shape: BoxShape.circle),
                                    child: Transform.rotate(
                                      angle:
                                      Methods.getLang() == 'ar' ? 4.57 : 0,
                                      child: Image.asset(
                                        AssetsManager.send,
                                        height: 18.h,
                                        width: 18.w,
                                        color: ColorManager.onBrandGradient,
                                        scale: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    );
                  },
                );
              },
            ),
            10.hBox,
          ],
        ),
      ),
    );
  }

  Future<void> pickImage({bool camera = true}) async {
    if (!(await Methods.isCheckInternet())) {
      Methods.showToast(context,
          isError: true, message: StringManager.internetConnection.tr());
      return;
    }
    final ImagePicker picker = ImagePicker();
    final result = await Methods.pickImageSafely(
      picker,
      source: camera ? ImageSource.camera : ImageSource.gallery,
    );
    if (result == null) return;
    final String path = result.path;

    Methods.showToast(context, isLoading: true);
    // Image goes through ChatRepository.sendMedia() → optimistic drift row
    // (renders the on-device file) → outbox → MediaUploadWorker. The bubble
    // comes off the drift stream like text, so no separate AddMessageLocalEvent
    // (which would double-render it).
    di<SendMessagesBloc>().add(
      SendMessagesEvent(
        userId: widget.parameter.userId,
        chatId: widget.parameter.chatId,
        isNotFriend: widget.parameter.isNotFriend,
        xFile: File(path),
        type: 'image',
        messageId: di<ToggleAppBarBloc>().state.replay?.messageId,
      ),
    );
  }

  void _message(TextEditingController message) {
    if (message.text.trim().isEmpty) return;
    di<SendMessagesBloc>().add(
      SendMessagesEvent(
        userId: widget.parameter.userId,
        chatId: widget.parameter.chatId,
        isNotFriend: widget.parameter.isNotFriend,
        messageId: di<ToggleAppBarBloc>().state.replay?.messageId,
        message: message.text,
      ),
    );
    // Text sends go through ChatRepository.send() → drift → stream →
    // _onRealtimeUpdated renders the pending bubble. AddMessageLocalEvent is
    // intentionally NOT dispatched here to prevent the double-bubble (#duplication).
  }

  Future<void> _voice(File voiceFile) async {
    if (!(await Methods.isCheckInternet())) {
      Methods.showToast(context,
          isError: true, message: StringManager.internetConnection.tr());
      return;
    }

    // Voice goes through ChatRepository.sendMedia() → optimistic drift row →
    // outbox → MediaUploadWorker, same single path as image/text. The bubble
    // renders off the drift stream, so no separate AddMessageLocalEvent.
    di<SendMessagesBloc>().add(
      SendMessagesEvent(
        userId: widget.parameter.userId,
        chatId: widget.parameter.chatId,
        isNotFriend: widget.parameter.isNotFriend,
        xFile: voiceFile,
        messageId: di<ToggleAppBarBloc>().state.replay?.messageId,
      ),
    );
  }
}

class _VoiceBoxBody extends StatelessWidget {
  const _VoiceBoxBody({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      child: di<TextFieldBloc>().state.isRecording
          ? Container(
        height: 50.h,
        padding: context.paddingAll(3),
        decoration: BoxDecoration(
          color: ColorManager.offWhite,
          borderRadius: 8.radius,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: IconButton(
                onPressed: () {
                  di<TextFieldBloc>().toggleRecorder();
                },
                icon: const Icon(
                  Icons.close_outlined,
                  color: ColorManager.redAccount,
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.topStart,
              child: IconButton(
                onPressed: () {
                  di<TextFieldBloc>().pauseOrResumeRecorder();
                },
                icon: Icon(
                  di<TextFieldBloc>().state.isPaused
                      ? Icons.play_arrow
                      : Icons.pause,
                  color: ColorManager.redAccount,
                ),
              ),
            ),
            10.wBox,
            Expanded(
              flex: 8,
              child: AudioWaveforms(
                enableGesture: true,
                size: Size(MediaQuery.sizeOf(context).width, 45.h),
                recorderController:
                di<TextFieldBloc>().state.recordController,
                waveStyle: const WaveStyle(
                  waveColor: ColorManager.black,
                  extendWaveform: true,
                  showMiddleLine: false,
                ),
              ),
            ),
            10.wBox,
            Expanded(
              flex: 2,
              // Only the time label rebuilds each second — the rest of the
              // send bar no longer ticks (see the narrowed buildWhen above).
              child: BlocBuilder<TextFieldBloc, TextFieldStates>(
                bloc: di<TextFieldBloc>(),
                buildWhen: (prev, curr) => prev.counter != curr.counter,
                builder: (context, state) => TextWidget(
                  Methods.convertSecondsToMinutesAndSeconds(
                    state.counter,
                  ),
                  style: context.bodyMedium
                      .colorExt(ColorManager.momentPostTextColor),
                ),
              ),
            ),
            30.wBox,
          ],
        ),
      )
          : const SizedBox.shrink(),
    );
  }
}

class _ReplayBoxBody extends StatelessWidget {
  const _ReplayBoxBody({required this.state, required this.name});

  final ToggleAppBarState state;
  final String name;

  @override
  Widget build(BuildContext context) {
    // Rebuild reactively when the reply state changes (the previous direct read
    // didn't refresh, so the reply preview only appeared after another rebuild).
    // The builder param is named `state` so all `state.replay` reads below use
    // the live bloc state.
    return BlocBuilder<ToggleAppBarBloc, ToggleAppBarState>(
      bloc: di<ToggleAppBarBloc>(),
      buildWhen: (p, c) =>
      p.isReplying != c.isReplying || p.replay != c.replay,
      builder: (context, state) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 400),
          child: state.isReplying
              ? Container(
            margin: context.paddingSymmetric(horizontal: 0),
            padding: context.paddingAll(7.5),
            color: ColorManager.surfaceCardColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4.w,
                  height: 40.h,
                  color: ColorManager.brandGradientColors.last,
                  margin: context.paddingAll(7.5),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        Methods.isMe('${state.replay?.senderId}')
                            ? StringManager.you.tr()
                            : name,
                        style: context.bodyMedium.w600.colorExt(
                            ColorManager.brandGradientColors.last),
                      ),
                      5.hBox,
                      state.replay?.messageType == "img"
                          ? Row(
                        children: [
                          Icon(
                            CupertinoIcons.photo,
                            size: 14.h,
                            color: ColorManager.grey,
                          ),
                          3.5.wBox,
                          TextWidget(
                            StringManager.photo.tr(),
                            style: context.bodyMedium
                                .size(15)
                                .colorExt(ColorManager.momentPostTextColor),
                          ),
                        ],
                      )
                          : state.replay?.messageType == 'voice'
                          ? Row(
                        children: [
                          Icon(
                            CupertinoIcons.mic_fill,
                            size: 14.h,
                            color: ColorManager.grey,
                          ),
                          3.5.wBox,
                          TextWidget(
                            StringManager.voice.tr(),
                            style: context.bodyMedium
                                .size(15)
                                .colorExt(
                                ColorManager.momentPostTextColor),
                          ),
                        ],
                      )
                          : state.replay?.messageType == 'video'
                          ? Row(
                        children: [
                          Icon(
                            CupertinoIcons.video_camera_solid,
                            size: 14.h,
                            color: ColorManager.grey,
                          ),
                          3.5.wBox,
                          TextWidget(
                            StringManager.video.tr(),
                            style: context.bodyMedium
                                .size(15)
                                .colorExt(
                                ColorManager.momentPostTextColor),
                          ),
                        ],
                      )
                          : TextWidget(
                        '${state.replay?.message}',
                        style: context.bodyMedium.colorExt(
                            ColorManager.momentPostTextColor),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: ColorManager.redAccount,
                  ),
                  onPressed: () => di<ToggleAppBarBloc>()
                    ..add(const ShowReplayBoxEvent(isReplying: false))
                    ..add(const InitAppBarEvent()),
                ),
              ],
            ),
          )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
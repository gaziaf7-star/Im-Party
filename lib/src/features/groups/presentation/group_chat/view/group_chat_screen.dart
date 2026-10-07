import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/realtime/in_app_chat_notifier.dart';
import 'package:general/src/features/chats/presentation/chats/view/widgets/contact_quick_view.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/presentation/group_chat/bloc/group_chat_bloc.dart';
import 'package:general/src/features/groups/presentation/group_chat/view/widgets/group_message_bubble.dart';
import 'package:general/src/features/groups/presentation/group_chat/view/widgets/group_reply_box.dart';
import 'package:general/src/features/groups/presentation/group_chat/view/widgets/group_system_message.dart';
import 'package:general/src/features/groups/presentation/group_chat/view/widgets/mention_picker.dart';

/// Group chat screen on the drift/realtime stack (Plan 7.6, part B).
///
/// Renders the conversation local-first from drift (pending rows on top), sends
/// optimistically through the outbox, and shows system events + read receipts.
/// Lifecycle (open/close realtime subscription) is owned by [GroupChatBloc].
class GroupChatDetailScreen extends StatefulWidget {
  final GroupEntity group;

  const GroupChatDetailScreen({super.key, required this.group});

  @override
  State<GroupChatDetailScreen> createState() => _GroupChatDetailScreenState();
}

class _GroupChatDetailScreenState extends State<GroupChatDetailScreen>
    with RouteAware {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final GroupChatBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di<GroupChatBloc>();
    _bloc.add(OpenGroupChatEvent(widget.group));
    // Track the active group in our OWN lifecycle (like the DM screen) so push
    // suppression + kick/leave auto-pop work regardless of Centrifugo state.
    if (widget.group.chatRoomId > 0) {
      InAppChatNotifier.instance.setActiveGroup(widget.group.chatRoomId);
    }
    _scrollController.addListener(_onScroll);
    // Rebuild on each keystroke so the @-mentions picker tracks the caret/query.
    _controller.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) navigatorObserver.subscribe(this, route);
  }

  @override
  void didPopNext() {
    // A pushed route was popped and this group is visible again — re-establish
    // OUR active-group marker, which opening the other chat overwrote.
    if (widget.group.chatRoomId > 0) {
      InAppChatNotifier.instance.setActiveGroup(widget.group.chatRoomId);
    }
    super.didPopNext();
  }

  @override
  void dispose() {
    navigatorObserver.unsubscribe(this);
    // Targeted clear: only drop the active-group marker if it still points at
    // THIS group, so opening B from A (B's initState set active=B before this
    // dispose runs) does not wipe B's marker (banner/sound race).
    InAppChatNotifier.instance
        .clearActiveGroupIfMatches(widget.group.chatRoomId);
    _bloc.add(const CloseGroupChatEvent());
    _bloc.close();
    _scrollController.removeListener(_onScroll);
    _controller.removeListener(_onTextChanged);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _onScroll() {
    // Reversed list: the top of history is the max scroll extent.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _bloc.add(const LoadOlderGroupMessagesEvent());
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    // Send-time safety net (the field already caps via the formatter), matching
    // the DM composer.
    if (text.length > ConstantsManager.maxMessageLength) {
      Methods.showToast(context,
          isError: true,
          message: StringManager.youHaveReachedLimitMessages.tr());
      return;
    }
    _bloc.add(SendGroupMessageEvent(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupChatBloc, GroupChatState>(
      bloc: _bloc,
      builder: (context, state) {
        return Scaffold(
          // Fixed white + brand-gradient app bar (was the panel-driven
          // scaffoldBg) — matches the redesigned 1:1 message screen.
          backgroundColor: ColorManager.white,
          appBar: _buildAppBar(context, state),
          body: Column(
            children: [
              Expanded(
                child: HandlingDataWidget(
                  reqState: state.reqState,
                  title: StringManager.noMessages.tr(),
                  subTitle: StringManager.noMessagesMsg.tr(),
                  // Fixed dark text (was the panel-driven textPrimary, which
                  // can resolve light/near-white and go invisible on this
                  // screen's white background).
                  titleStyle: context.bodyLarge.w600
                      .colorExt(ColorManager.momentPostTextColor),
                  subTitleStyle: context.bodyMedium.colorExt(
                      ColorManager.momentPostTextColor.withValues(alpha: 0.65)),
                  onTap: () => _bloc.add(OpenGroupChatEvent(state.group)),
                  child: _MessagesList(
                    state: state,
                    controller: _scrollController,
                    bloc: _bloc,
                  ),
                ),
              ),
              GroupReplyBox(
                replyTo: state.replyTo,
                onClear: () => _bloc.add(const SetGroupReplyEvent(null)),
              ),
              // @-mentions: when the word at the caret starts with '@', show a
              // live-filtered member list; picking inserts '@name '.
              Builder(builder: (context) {
                final sel = _controller.selection;
                final cursor =
                sel.isValid ? sel.baseOffset : _controller.text.length;
                final mentionQuery =
                MentionText.activeQuery(_controller.text, cursor);
                if (mentionQuery == null) return const SizedBox.shrink();
                return MentionPicker(
                  members: state.members,
                  query: mentionQuery,
                  onPick: (member) {
                    final c = _controller.selection;
                    final cur =
                    c.isValid ? c.baseOffset : _controller.text.length;
                    final newText = MentionText.applyMention(
                        _controller.text, cur, member.name);
                    _controller.value = TextEditingValue(
                      text: newText,
                      selection: TextSelection.collapsed(
                        offset: cur -
                            mentionQuery.length +
                            member.name.length +
                            1,
                      ),
                    );
                  },
                );
              }),
              _Composer(
                controller: _controller,
                canPost: state.permissions.canPost,
                onSend: _send,
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, GroupChatState state) {
    return AppBarWidget(
      backgroundGradient: ColorManager.brandGradient,
      iconColor: ColorManager.onBrandGradient,
      // Left-aligned WhatsApp-style title (avatar + name right next to the
      // back arrow), not centered. titleSpacing 0 removes the default gap.
      centerTitle: false,
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar opens the group quick-view sheet (mini profile) — mirrors
          // the 1:1 contact quick-view UX. From there a tap opens the full
          // photo, the action opens the read-only info page.
          GestureDetector(
            onTap: () => showGroupQuickView(
              context,
              name: state.group.name,
              image: state.group.avatar,
              membersCount: state.group.membersCount,
              onViewInfo: () => context.pushNamedRoute(
                Routes.groupViewScreen,
                arguments: state.group,
              ),
            ),
            child: ClipOval(
              child: UserImage(
                image: state.group.avatar,
                displayName: state.group.name,
                imageSize: 36,
              ),
            ),
          ),
          10.wBox,
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Tapping the name/subtitle jumps straight to the full info
              // page (skips the quick view since the avatar is right there).
              onTap: () => context.pushNamedRoute(
                Routes.groupViewScreen,
                arguments: state.group,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    state.group.name,
                    isTranslate: false,
                    maxLines: 1,
                    // Fixed white — this sits on the brand-gradient app bar now.
                    style: context.bodyLarge.w600
                        .colorExt(ColorManager.onBrandGradient),
                  ),
                  TextWidget(
                    '${state.group.membersCount} ${StringManager.membersCount.tr()}',
                    isTranslate: false,
                    style: context.bodySmall.colorExt(
                        ColorManager.onBrandGradient.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  final GroupChatState state;
  final ScrollController controller;
  final GroupChatBloc bloc;

  const _MessagesList({required this.state, required this.controller, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final messages = state.messages;
    final itemCount = messages.length + (state.isLoadingOlder ? 1 : 0);

    // Hoist identity once (was read per-item, twice) and find MY newest confirmed
    // message in a single O(n) pass (was a per-item `take(index).any(...)`, i.e.
    // O(n^2) over the whole window on every build).
    final myId = MyDataModel.getInstance().id;
    int? newestOwnIndex;
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (m.senderId == myId && m.serverSeq != null) {
        newestOwnIndex = i; // reversed list: smallest index = newest
        break;
      }
    }

    return ListView.builder(
      controller: controller,
      reverse: true,
      cacheExtent: 600,
      padding: context.paddingSymmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= messages.length) {
          return Padding(
            padding: context.paddingAll(12),
            child: const LoadingWidget(),
          );
        }

        final message = messages[index];

        // WhatsApp-style day separators + a start-of-chat marker. index+1 is the
        // older message in this reversed list, so a day boundary (or the oldest
        // loaded message) earns a date pill above it.
        final ms = message.serverCreatedAt ?? message.createdAtClient;
        final isOldest = index == messages.length - 1;
        final showStart = isOldest && !state.isLoadingOlder;
        final showDay = isOldest ||
            !sameLocalDayMs(
                ms,
                messages[index + 1].serverCreatedAt ??
                    messages[index + 1].createdAtClient);
        final dayLabel = showDay ? chatDayLabelFromMs(ms) : null;

        final Widget body;
        if (message.kind == MessageKind.system) {
          body = GroupSystemMessage(message: message, members: state.members);
        } else {
          final isMe = message.senderId == myId;
          // In a newest-first reversed list, the "previous" visual message
          // (older) is at index+1. Show the sender header when the next-older
          // message is from a different sender (group bubbles need a header).
          final olderIsSameSender = index + 1 < messages.length &&
              messages[index + 1].kind == MessageKind.user &&
              messages[index + 1].senderId == message.senderId;
          final showHeader = !isMe && !olderIsSameSender;

          // Read receipt only on my newest confirmed message (precomputed once).
          final isMyNewest = index == newestOwnIndex;

          // Delete-for-everyone is offered when the message is confirmed (has a
          // server id) and the user may delete it: their OWN message, or anyone's
          // for owner/admin. The server re-checks the same rule (it is the guard).
          final serverMessageId =
              message.serverMessageId; // null for a pending/unsent row
          final canDelete = serverMessageId != null &&
              (isMe || state.permissions.canDeleteOthers);

          body = GroupMessageBubble(
            message: message,
            isMe: isMe,
            showSenderHeader: showHeader,
            members: state.members,
            group: state.group,
            showReadReceipt: isMyNewest,
            onRetry: () => bloc.add(RetryGroupMessageEvent(message.clientUuid)),
            onReply: state.permissions.canPost
                ? () => bloc.add(SetGroupReplyEvent(message))
                : null,
            onDelete: canDelete
                ? () => bloc.add(DeleteGroupMessageEvent(serverMessageId))
                : null,
          );
        }

        // Stable per-message key + paint isolation so one bubble's repaint
        // (receipt/reaction) doesn't dirty its siblings on every emission.
        final keyed = KeyedSubtree(
          key: ValueKey(message.clientUuid),
          child: body,
        );
        if (!showDay && !showStart) return RepaintBoundary(child: keyed);
        return RepaintBoundary(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showStart) const ChatStartIndicator(),
              if (dayLabel != null) ChatDaySeparator(label: dayLabel),
              keyed,
            ],
          ),
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool canPost;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.canPost,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    if (!canPost) {
      return Container(
        width: double.infinity,
        color: ColorManager.offWhite,
        padding: context.paddingSymmetric(vertical: 14, horizontal: 16),
        child: TextWidget(
          StringManager.onlyAdminsPostHint.tr(),
          textAlign: TextAlign.center,
          style: context.bodyMedium.colorExt(ColorManager.momentPostTextColor),
        ),
      );
    }

    return Card(
      color: ColorManager.offWhite,
      elevation: 5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: 10.radiusCircular,
          topLeft: 10.radiusCircular,
        ),
      ),
      child: Padding(
        padding: context.paddingAll(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextInputWidget(
                StringManager.typeMessage.tr(),
                controller: controller,
                isTappedOutside: false,
                // Fixed black text, brand cursor, fixed white field (was
                // textPrimary/primary/surfaceCardColor — all panel-driven,
                // could turn dark/light unpredictably).
                textColor: ColorManager.momentPostTextColor,
                cursorColor: ColorManager.brandGradientColors.last,
                hintStyle: context.bodyMedium.colorExt(
                    ColorManager.momentPostTextColor.withValues(alpha: 0.5)),
                fillColor: ColorManager.white,
                // Enter inserts a newline (grows the field) instead of
                // dismissing the keyboard; send is via the send button.
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 4,
                // Cap length at the keyboard (same mechanism + limit as the DM
                // composer) so the user can't type past the limit.
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                      ConstantsManager.maxMessageLength),
                ],
                enabledBorder: OutlineInputBorder(
                  borderRadius: 30.radius,
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: 30.radius,
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                context.paddingSymmetric(horizontal: 15, vertical: 5),
              ),
            ),
            5.wBox,
            GestureDetector(
              onTap: onSend,
              child: Container(
                padding: context.paddingAll(10),
                // Brand gradient (was the flat panel-driven primary).
                decoration: const BoxDecoration(
                  gradient: ColorManager.brandGradient,
                  shape: BoxShape.circle,
                ),
                child: Transform.rotate(
                  angle: Methods.getLang() == 'en' ? 0 : 3.14 / 0.7,
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
    );
  }
}
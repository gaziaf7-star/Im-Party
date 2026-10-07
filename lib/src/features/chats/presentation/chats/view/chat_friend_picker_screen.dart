import 'package:general/src/features/chats/chats.dart';
import 'package:general/src/features/chats/data/contact_discovery_service.dart';
import 'package:general/src/features/chats/data/contacts_cache.dart';
import 'package:general/src/features/chats/data/invite_share.dart';
import 'package:general/src/features/auth/data/model/user_model.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_bloc.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_event.dart';
import 'package:general/src/features/profile/presentation/f_f_f_v/bloc/bloc_get_f_f_f/get_follower_or_following_state.dart';
import 'widgets/chat_strings.dart';
import 'widgets/chats_search_bar.dart';
import 'widgets/contacts_loading_widget.dart';

/// New-chat picker opened from the chats FAB. Shows the user's IN-APP friends as
/// the primary source: tapping a row opens the chat. A secondary, opt-in section
/// lets the user invite people from their phone book (registered contacts open a
/// chat, unregistered ones fire the native share sheet). Searching filters by
/// name across both sections.
class ChatFriendPickerScreen extends StatefulWidget {
  const ChatFriendPickerScreen({super.key});

  @override
  State<ChatFriendPickerScreen> createState() => _ChatFriendPickerScreenState();
}

class _ChatFriendPickerScreenState extends State<ChatFriendPickerScreen> {
  late final TextEditingController _searchCtrl;
  String _query = '';

  final GetFollowerOrFollowingBloc _friendsBloc =
  di<GetFollowerOrFollowingBloc>();

  // Phone-book discovery is lazy: it only runs once the user opts into the
  // "invite from contacts" section, so the contacts permission prompt never
  // fires just by opening the picker.
  late final ContactsCache _cache;
  bool _contactsRequested = false;
  bool _contactsLoading = false;
  bool _contactsPermissionDenied = false;
  bool _contactsError = false;
  ContactDiscoveryResult? _contactsResult;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _cache = ContactsCache(di<ContactDiscoveryService>());
    if (!_friendsBloc.state.getFriendsRequest.isLoaded) {
      _friendsBloc.add(const GetFriendsEvent(loading: true));
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reloadFriends() async {
    _friendsBloc.add(const GetFriendsEvent(loading: true));
    // #89: pull-to-refresh should also refresh contacts when the user has
    // already opened the contacts section, not just the friends list.
    if (_contactsRequested) {
      await _discoverContacts(forceRefresh: true);
    }
  }

  Future<void> _discoverContacts({bool forceRefresh = false}) async {
    setState(() {
      _contactsRequested = true;
      _contactsPermissionDenied = false;
      _contactsError = false;
    });

    // WhatsApp-style: show cached contacts INSTANTLY (no spinner, no request),
    // then refresh silently only if the cache is stale (>12h). This stops the
    // full "read address book + /contacts/match" sweep from running on every
    // open. Pull-to-refresh passes forceRefresh:true to bypass the cache.
    if (!forceRefresh) {
      final cached = _cache.readCached();
      if (cached != null) {
        setState(() {
          _contactsResult = cached;
          _contactsLoading = false;
        });
        if (!_cache.isStale()) return; // fresh → done, zero network
        try {
          final fresh = await _cache.refresh(); // silent background refresh
          if (!mounted) return;
          setState(() => _contactsResult = fresh);
        } catch (_) {/* keep showing cached results */}
        return;
      }
    }

    // No cache (or forced): full discovery with the loading screen.
    setState(() => _contactsLoading = true);
    try {
      final result = await _cache.refresh();
      if (!mounted) return;
      setState(() {
        _contactsResult = result;
        _contactsLoading = false;
      });
    } on ContactsPermissionDenied {
      if (!mounted) return;
      setState(() {
        _contactsPermissionDenied = true;
        _contactsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _contactsError = true;
        _contactsLoading = false;
      });
    }
  }

  void _openFriendChat(UserModel u) {
    di<FetchUsersChatBloc>().add(
      UpdateTotalMessages(userId: u.uuid.toString(), isIncreased: false),
    );
    Navigator.pushReplacementNamed(
      context,
      Routes.messages,
      arguments: MessagesParameter(
        hasColorName: u.hasColorName ?? false,
        name: u.name ?? '',
        image: u.profile?.image ?? '',
        userId: '${u.id}',
      ),
    );
  }

  void _openFriendProfile(UserModel u) {
    Navigator.pushNamed(
      context,
      Routes.userProfile,
      arguments: UserProfileParameter(userId: '${u.id}'),
    );
  }

  void _openContactChat(DiscoveredContact c) {
    Navigator.pushReplacementNamed(
      context,
      Routes.messages,
      arguments: MessagesParameter(
        hasColorName: false,
        name: c.name,
        image: c.avatar,
        userId: '${c.userId}',
      ),
    );
  }

  Future<void> _invite(UnregisteredContact c) {
    return InviteShare.shareInvite(
      context,
      inviterUserId: '${MyDataModel.getInstance().id ?? ''}',
      contactName: c.name,
    );
  }

  // Case-insensitive substring match on the locally-saved name (registered)
  // or the phone number (unregistered fallback).
  bool _matches(String haystack) {
    if (_query.isEmpty) return true;
    return haystack.toLowerCase().contains(_query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fixed white + brand-gradient app bar (was the panel-driven
      // scaffoldBg/flat app bar) — matches the professional look used
      // across the app.
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        title: ChatStrings.newChat,
        backgroundGradient: ColorManager.brandGradient,
        titleStyle: context.titleLarge.w600
            .size(16)
            .colorExt(ColorManager.onBrandGradient),
        iconColor: ColorManager.onBrandGradient,
      ),
      body: Column(
        children: [
          Padding(
            padding: context.paddingSymmetric(horizontal: 12, vertical: 10),
            child: ChatsSearchBar(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              // This page has a plain white body (not the purple gradient
              // band) — dark text/icons so they're actually visible.
              light: false,
            ),
          ),
          Expanded(
            child: BlocBuilder<GetFollowerOrFollowingBloc,
                GetFollowerOrFollowingState>(
              bloc: _friendsBloc,
              buildWhen: (prev, curr) =>
              prev.getFriends != curr.getFriends ||
                  prev.getFriendsRequest != curr.getFriendsRequest,
              builder: (context, state) => _body(context, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, GetFollowerOrFollowingState state) {
    if (state.getFriends.isEmpty && state.getFriendsRequest.isLoading) {
      return const ContactsLoadingWidget();
    }

    if (state.getFriends.isEmpty && state.getFriendsRequest.isError) {
      return _emptyState(
        icon: Icons.error_outline,
        title: ChatStrings.friendsFetchError,
        actionLabel: ChatStrings.tryAgain,
        onAction: _reloadFriends,
      );
    }

    final friends =
    state.getFriends.where((u) => _matches(u.name ?? '')).toList();

    final registered = (_contactsResult?.registered ?? const [])
        .where((c) => _matches(c.name))
        .toList();
    final unregistered = (_contactsResult?.unregistered ?? const [])
        .where((c) => _matches(c.name) || _matches(c.phone))
        .toList();

    final rows = <_PickerRow>[];

    if (friends.isNotEmpty) {
      rows.add(const _SectionHeaderRow(ChatStrings.friendsOnApp));
      rows.addAll(friends.map(_FriendRow.new));
    } else if (_query.isEmpty) {
      rows.add(const _EmptyFriendsRow());
    }

    // Secondary opt-in: invite from the phone book.
    rows.add(const _ContactsToggleRow());
    // First-time discovery (no cached result yet): show the labelled progress
    // bar instead of a bare spinner so the user knows contacts are loading.
    if (_contactsLoading && _contactsResult == null) {
      rows.add(const _ContactsLoadingRow());
    }
    if (_contactsRequested) {
      if (registered.isNotEmpty) {
        rows.add(const _SectionHeaderRow(ChatStrings.contactsOnApp));
        rows.addAll(registered.map(_RegisteredRow.new));
      }
      if (unregistered.isNotEmpty) {
        rows.add(const _SectionHeaderRow(ChatStrings.inviteFriendsToApp));
        rows.addAll(unregistered.map(_InviteRow.new));
      }
    }

    // #90: suppress the "no match" state while contacts are still loading so the
    // spinner doesn't flash briefly before results arrive.
    if (friends.isEmpty && registered.isEmpty && unregistered.isEmpty &&
        _query.isNotEmpty && !_contactsLoading) {
      return _emptyState(
        icon: Icons.search_off,
        title: ChatStrings.noContactsMatch,
      );
    }

    return RefreshIndicator(
      color: ColorManager.brandGradientColors.last,
      onRefresh: _reloadFriends,
      child: ListView.separated(
        padding: context.paddingSymmetric(vertical: 8),
        itemCount: rows.length,
        separatorBuilder: (_, i) {
          final row = rows[i];
          if (row is _SectionHeaderRow ||
              row is _ContactsToggleRow ||
              row is _EmptyFriendsRow) {
            return const SizedBox.shrink();
          }
          return Divider(
            height: 1,
            color: ColorManager.divider,
            indent: 75.w,
          );
        },
        itemBuilder: (_, i) => _row(rows[i]),
      ),
    );
  }

  Widget _row(_PickerRow row) {
    if (row is _SectionHeaderRow) return _sectionHeader(row.title);
    if (row is _EmptyFriendsRow) return _emptyFriendsInline();
    if (row is _ContactsToggleRow) return _contactsToggle();
    if (row is _ContactsLoadingRow) return _contactsLoadingInline();
    if (row is _FriendRow) return _friendTile(row.user);
    if (row is _RegisteredRow) return _registeredTile(row.contact);
    if (row is _InviteRow) return _inviteTile(row.contact);
    return const SizedBox.shrink();
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: context.paddingOnly(start: 16, top: 14, bottom: 6),
      child: TextWidget(
        title,
        isTranslate: false,
        // Fixed light-black (was textPrimary — panel-driven, can go white and
        // vanish on this white screen).
        style: context.bodyMedium.w600.colorExt(ColorManager.momentPostTextColor),
      ),
    );
  }

  /// Labelled progress bar shown under the contacts toggle while the first-time
  /// phone-book discovery runs (so the user sees "loading contacts" + a bar
  /// instead of a bare spinner).
  Widget _contactsLoadingInline() {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextWidget(
            ChatStrings.loadingContacts,
            isTranslate: false,
            textAlign: TextAlign.center,
            style: context.bodyMedium.colorExt(ColorManager.momentPostTextColor).w500,
          ),
          12.hBox,
          ClipRRect(
            borderRadius: 8.radius,
            child: LinearProgressIndicator(
              minHeight: 4.h,
              backgroundColor: ColorManager.brandGradientColors.last.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(ColorManager.brandGradientColors.last),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyFriendsInline() {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          Icon(Icons.people_outline,
              size: 48.h, color: ColorManager.greyTextColor),
          12.hBox,
          TextWidget(
            ChatStrings.noFriendsYet,
            isTranslate: false,
            textAlign: TextAlign.center,
            // Fixed light-black at reduced opacity (was secondaryText).
            style: context.bodyLarge
                .colorExt(ColorManager.momentPostTextColor.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  // Tap the row -> profile; tap the chat icon -> open chat.
  Widget _friendTile(UserModel u) {
    final name = u.name ?? '';
    return InkWell(
      onTap: () => _openFriendProfile(u),
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            UserImage(
              borderRadius: 50.radius,
              imageSize: 46.h,
              image: (u.profile?.image ?? '').isEmpty
                  ? ''
                  : EndPoints.getImage(u.profile?.image ?? ''),
              displayName: name,
            ),
            12.wBox,
            Expanded(
              child: TextWidget(
                name,
                isTranslate: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                context.bodyLarge.colorExt(ColorManager.momentPostTextColor).w500,
              ),
            ),
            IconButton(
              tooltip: ChatStrings.messageAction,
              onPressed: () => _openFriendChat(u),
              icon: Icon(
                Icons.chat_bubble_outline,
                color: ColorManager.brandGradientColors.last,
                size: 22.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactsToggle() {
    return InkWell(
      onTap: _contactsRequested ? null : _discoverContacts,
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: context.paddingAll(8),
              decoration: BoxDecoration(
                color: ColorManager.brandGradientColors.first
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.contacts_outlined,
                  color: ColorManager.brandGradientColors.last, size: 20.h),
            ),
            12.wBox,
            Expanded(
              child: TextWidget(
                ChatStrings.inviteFromContacts,
                isTranslate: false,
                style:
                context.bodyLarge.colorExt(ColorManager.momentPostTextColor).w500,
              ),
            ),
            if (_contactsLoading)
              SizedBox(
                height: 18.h,
                width: 18.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(ColorManager.brandGradientColors.last),
                ),
              )
            else if (!_contactsRequested)
              Icon(Icons.chevron_right,
                  color: ColorManager.greyTextColor, size: 22.h)
            else if (_contactsPermissionDenied)
                _contactsRetry(ChatStrings.contactsPermissionDenied)
              else if (_contactsError)
                  _contactsRetry(ChatStrings.contactsFetchError),
          ],
        ),
      ),
    );
  }

  Widget _contactsRetry(String label) {
    return InkWell(
      onTap: _discoverContacts,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.refresh, size: 18.h, color: ColorManager.brandGradientColors.last),
          4.wBox,
          TextWidget(
            ChatStrings.tryAgain,
            isTranslate: false,
            style: context.bodySmall.colorExt(ColorManager.brandGradientColors.last).w600,
          ),
        ],
      ),
    );
  }

  // Tap -> open chat (these are phone-book contacts already on the app).
  Widget _registeredTile(DiscoveredContact c) {
    return InkWell(
      onTap: () => _openContactChat(c),
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            UserImage(
              borderRadius: 50.radius,
              imageSize: 46.h,
              image: c.avatar.isEmpty ? '' : EndPoints.getImage(c.avatar),
              displayName: c.name,
            ),
            12.wBox,
            Expanded(
              child: TextWidget(
                c.name,
                isTranslate: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                context.bodyLarge.colorExt(ColorManager.momentPostTextColor).w500,
              ),
            ),
            IconButton(
              tooltip: ChatStrings.messageAction,
              onPressed: () => _openContactChat(c),
              icon: Icon(
                Icons.chat_bubble_outline,
                color: ColorManager.brandGradientColors.last,
                size: 22.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inviteTile(UnregisteredContact c) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Initials placeholder (these aren't app users, no avatar).
          SizedBox(
            width: 46.h,
            height: 46.h,
            child: InitialsAvatar(name: c.name, size: 46.h),
          ),
          12.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  c.name,
                  isTranslate: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyLarge
                      .colorExt(ColorManager.momentPostTextColor)
                      .w500,
                ),
                if (c.phone.isNotEmpty)
                  TextWidget(
                    c.phone,
                    isTranslate: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodySmall.colorExt(
                        ColorManager.momentPostTextColor.withValues(alpha: 0.6)),
                  ),
              ],
            ),
          ),
          8.wBox,
          InkWell(
            onTap: () => _invite(c),
            borderRadius: 20.radius,
            child: Container(
              padding: context.paddingSymmetric(horizontal: 16, vertical: 7),
              decoration: const BoxDecoration(
                gradient: ColorManager.brandGradient,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1,
                      size: 16.h, color: ColorManager.onBrandGradient),
                  6.wBox,
                  TextWidget(
                    ChatStrings.invite,
                    isTranslate: false,
                    style: context.bodyMedium
                        .colorExt(ColorManager.onBrandGradient)
                        .w600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56.h, color: ColorManager.greyTextColor),
            14.hBox,
            TextWidget(
              title,
              isTranslate: false,
              textAlign: TextAlign.center,
              // Fixed light-black at reduced opacity (was secondaryText).
              style: context.bodyLarge
                  .colorExt(ColorManager.momentPostTextColor.withValues(alpha: 0.6)),
            ),
            if (actionLabel != null && onAction != null) ...[
              14.hBox,
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.brandGradientColors.last,
                  foregroundColor: ColorManager.onBrandGradient,
                  shape: RoundedRectangleBorder(borderRadius: 8.radius),
                ),
                child: TextWidget(
                  actionLabel,
                  isTranslate: false,
                  style: context.bodyMedium
                      .colorExt(ColorManager.onBrandGradient)
                      .w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Render-list items (built once, rendered lazily by ListView.builder so large
// friend/contact lists scroll without jank).
// ---------------------------------------------------------------------------
sealed class _PickerRow {
  const _PickerRow();
}

class _SectionHeaderRow extends _PickerRow {
  const _SectionHeaderRow(this.title);
  final String title;
}

class _EmptyFriendsRow extends _PickerRow {
  const _EmptyFriendsRow();
}

class _ContactsToggleRow extends _PickerRow {
  const _ContactsToggleRow();
}

class _ContactsLoadingRow extends _PickerRow {
  const _ContactsLoadingRow();
}

class _FriendRow extends _PickerRow {
  const _FriendRow(this.user);
  final UserModel user;
}

class _RegisteredRow extends _PickerRow {
  const _RegisteredRow(this.contact);
  final DiscoveredContact contact;
}

class _InviteRow extends _PickerRow {
  const _InviteRow(this.contact);
  final UnregisteredContact contact;
}
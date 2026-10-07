import 'package:general/src/core/database/daos/rooms_dao.dart';
import 'package:general/src/core/database/tables/chat_tables.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/chats/presentation/chats/view/widgets/room_to_conversation_mapper.dart';

/// Inline chats search (offline, from the local drift cache). Replaces the old
/// home-screen SearchScreen for the chats tab: it searches the user's own
/// conversations by name AND the content of every cached message, showing the
/// matched text highlighted in yellow (WhatsApp-style). Works with no network.
class ChatsSearchScreen extends StatefulWidget {
  const ChatsSearchScreen({super.key});

  @override
  State<ChatsSearchScreen> createState() => _ChatsSearchScreenState();
}

class _ChatsSearchScreenState extends State<ChatsSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final RoomsDao _roomsDao = di<RoomsDao>();

  /// Monotonic token so a slow query can't overwrite a newer one's results.
  int _queryToken = 0;
  String _query = '';
  List<RoomWithLast> _rooms = const [];
  List<MessageHit> _messages = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onChanged(String raw) async {
    final q = raw.trim();
    final token = ++_queryToken;
    if (q.isEmpty) {
      setState(() {
        _query = '';
        _rooms = const [];
        _messages = const [];
      });
      return;
    }
    final results = await Future.wait([
      _roomsDao.searchRooms(q),
      _roomsDao.searchMessages(q),
    ]);
    if (!mounted || token != _queryToken) return;
    setState(() {
      _query = q;
      _rooms = results[0] as List<RoomWithLast>;
      _messages = results[1] as List<MessageHit>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImgWidget(
      child: Scaffold(
        backgroundColor: ColorManager.transparent,
        appBar: AppBar(
          backgroundColor: ColorManager.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: ColorManager.textPrimary),
          title: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: _onChanged,
            style: context.bodyLarge.colorExt(ColorManager.textPrimary),
            cursorColor: ColorManager.primary,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: StringManager.search.tr(),
              hintStyle: context.bodyLarge
                  .colorExt(ColorManager.textPrimary.withValues(alpha: 0.5)),
            ),
          ),
        ),
        body: SafeArea(child: _body(context)),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_query.isEmpty) {
      return _hint(context, StringManager.searchByNameOrMessage.tr());
    }
    if (_rooms.isEmpty && _messages.isEmpty) {
      return _hint(context, StringManager.noResults.tr());
    }
    return ListView(
      padding: context.paddingSymmetric(vertical: 8),
      children: [
        if (_rooms.isNotEmpty) ...[
          _sectionHeader(context, StringManager.chatsSection.tr()),
          ..._rooms.map(_roomTile),
        ],
        if (_messages.isNotEmpty) ...[
          _sectionHeader(context, StringManager.messages.tr()),
          ..._messages.map(_messageTile),
        ],
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String text) => Padding(
        padding: context.paddingSymmetric(horizontal: 16, vertical: 8),
        child: TextWidget(
          text,
          isTranslate: false,
          style: context.bodyMedium.w600.colorExt(ColorManager.primary),
        ),
      );

  Widget _roomTile(RoomWithLast row) {
    final isGroup = row.room.type == RoomType.group;
    final title = row.room.title ?? '';
    return ListTile(
      leading: _avatar(row.room.avatarUrl, isGroup, title),
      title: _highlighted(context, title, _query),
      onTap: () => _openRoom(row),
    );
  }

  Widget _messageTile(MessageHit hit) {
    final isGroup = hit.room.type == RoomType.group;
    final title = hit.room.title ?? '';
    return ListTile(
      leading: _avatar(hit.room.avatarUrl, isGroup, title),
      title: TextWidget(
        title,
        isTranslate: false,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.bodyLarge.w600.colorExt(ColorManager.textPrimary),
      ),
      subtitle: _highlighted(context, hit.message.body ?? '', _query),
      trailing: TextWidget(
        RoomToConversationMapper.timeLabel(
          RoomWithLast(room: hit.room, last: hit.message),
        ),
        isTranslate: false,
        style: context.bodyMedium
            .size(11)
            .colorExt(ColorManager.secondaryText),
      ),
      onTap: () => _openRoom(
        RoomWithLast(room: hit.room, last: hit.message),
        // Jump to the matched message: prefer its server id, fall back to the
        // local id for not-yet-synced rows.
        messageIdToMove: hit.message.serverMessageId ?? hit.message.localId,
      ),
    );
  }

  Widget _avatar(String? url, bool isGroup, String name) => UserImage(
        image: (url == null || url.isEmpty) ? '' : EndPoints.getImage(url),
        displayName: name,
        imageSize: 46.w,
      );

  void _openRoom(RoomWithLast row, {int? messageIdToMove}) {
    if (row.room.type == RoomType.group) {
      final group = RoomToConversationMapper.toGroup(row);
      context.pushNamedRoute(Routes.groupChatDetailScreen, arguments: group);
      return;
    }
    final chat = RoomToConversationMapper.toUserChat(row);
    Navigator.pushNamed(
      context,
      Routes.messages,
      arguments: MessagesParameter(
        inRoom: chat.inRoom,
        hasColorName: chat.hasColorName,
        name: chat.name,
        image: chat.image,
        userId: '${chat.userId}',
        messageIdToMove: messageIdToMove,
      ),
    );
  }

  Widget _hint(BuildContext context, String text) => Center(
        child: TextWidget(
          text,
          isTranslate: false,
          style: context.bodyMedium.colorExt(ColorManager.secondaryText),
        ),
      );

  /// Renders [text] with every (case-insensitive) occurrence of [query]
  /// highlighted on a yellow background — the WhatsApp search look.
  Widget _highlighted(BuildContext context, String text, String query) {
    final base = context.bodyMedium.colorExt(ColorManager.textPrimary);
    if (query.isEmpty) {
      return Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: base);
    }
    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    var start = 0;
    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx < 0) {
        spans.add(TextSpan(text: text.substring(start), style: base));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: base));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: base.copyWith(
          backgroundColor: ColorManager.lightYellow,
          color: ColorManager.textPrimary,
        ),
      ));
      start = idx + query.length;
    }
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }
}

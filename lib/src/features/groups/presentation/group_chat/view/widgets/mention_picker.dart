import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_enums.dart';
import 'package:general/src/features/groups/domain/entities/group_member_entity.dart';

/// @-mentions picker shown above the group composer.
///
/// Driven by the active mention [query] computed from the composer's
/// controller (see [MentionText.activeQuery]). Filters [members] by name
/// (case-insensitive, substring) and renders a compact, height-capped,
/// scrollable list of tappable rows. Picking a member calls [onPick]; the
/// composer is responsible for rewriting its text via [MentionText.applyMention].
///
/// Renders nothing (an empty box) when the query matches no members, so the
/// composer can place this directly above the input without reserving space.
class MentionPicker extends StatelessWidget {
  final List<GroupMemberEntity> members;
  final String query;
  final void Function(GroupMemberEntity) onPick;

  const MentionPicker({
    super.key,
    required this.members,
    required this.query,
    required this.onPick,
  });

  List<GroupMemberEntity> get _matches {
    final q = query.trim().toLowerCase();
    final list = q.isEmpty
        ? members
        : members
        .where((m) => m.name.toLowerCase().contains(q))
        .toList(growable: false);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matches;
    if (matches.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.3,
      ),
      decoration: BoxDecoration(
        // Fixed white (was surfaceCardColor — panel-driven).
        color: ColorManager.white,
        borderRadius: BorderRadius.only(
          topRight: 10.radiusCircular,
          topLeft: 10.radiusCircular,
        ),
        border: Border.all(color: ColorManager.divider),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: context.paddingSymmetric(vertical: 4),
        itemCount: matches.length,
        separatorBuilder: (_, __) => Divider(
          height: 1.h,
          thickness: 1.h,
          color: ColorManager.divider,
        ),
        itemBuilder: (context, index) {
          final member = matches[index];
          return _MentionRow(member: member, onTap: () => onPick(member));
        },
      ),
    );
  }
}

class _MentionRow extends StatelessWidget {
  final GroupMemberEntity member;
  final VoidCallback onTap;

  const _MentionRow({required this.member, required this.onTap});

  String? get _roleLabel {
    switch (member.role) {
      case GroupRole.owner:
        return StringManager.owner.tr();
      case GroupRole.admin:
        return StringManager.admin.tr();
      case GroupRole.member:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _roleLabel;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: context.paddingSymmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            ImageViewWidget(
              url: member.avatar,
              displayName: member.name,
              height: 36,
              width: 36,
              radius: 18,
            ),
            10.wBox,
            Expanded(
              child: GradientName(child: TextWidget(
                member.name,
                isTranslate: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyMedium.w600
                    .colorExt(ColorManager.momentPostTextColor),
              )),
            ),
            if (role != null) ...[
              8.wBox,
              TextWidget(
                role,
                isTranslate: false,
                style: context.bodySmall.colorExt(
                    ColorManager.momentPostTextColor.withValues(alpha: 0.6)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pure, unit-testable helpers for the @-mention token in a text field.
///
/// All offsets are character indices into [text]; [cursor] is the caret
/// position (e.g. `controller.selection.baseOffset`). Methods never touch the
/// UI and have no Flutter dependencies, so they can be exercised directly in
/// tests.
abstract final class MentionText {
  const MentionText._();

  /// Returns the active mention query (the text after the most recent '@' in
  /// the word immediately before [cursor]), or null when there is no active
  /// mention.
  ///
  /// A mention is "active" when the token ending at the cursor begins with '@'
  /// and contains no whitespace after it — e.g. cursor at the end of `hi @al`
  /// yields `al`, while `hi @ali bye|` (cursor after a space) yields null.
  /// The query itself may be empty (the user just typed '@').
  static String? activeQuery(String text, int cursor) {
    if (cursor < 0 || cursor > text.length) return null;

    // Walk left from the cursor to the start of the current token.
    var start = cursor;
    while (start > 0) {
      final ch = text[start - 1];
      if (ch == '@') {
        // Found the trigger. Valid only if it starts the token, i.e. the char
        // before '@' is whitespace or the very beginning of the text.
        final beforeAt = start - 2;
        if (beforeAt < 0 || _isWhitespace(text[beforeAt])) {
          return text.substring(start, cursor);
        }
        return null;
      }
      if (_isWhitespace(ch)) return null;
      start--;
    }
    return null;
  }

  /// Replaces the active '@query' token ending at [cursor] with '@name ' and
  /// returns the rewritten text. When there is no active mention the original
  /// [text] is returned unchanged.
  static String applyMention(String text, int cursor, String name) {
    final query = activeQuery(text, cursor);
    if (query == null) return text;

    // The token spans from the '@' up to the cursor. '@' sits just before the
    // query, so its index is cursor - query.length - 1.
    final atIndex = cursor - query.length - 1;
    final before = text.substring(0, atIndex);
    final after = text.substring(cursor);
    return '$before@$name $after';
  }

  static bool _isWhitespace(String ch) => ch.trim().isEmpty;
}
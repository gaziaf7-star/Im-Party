import 'package:general/src/core/index.dart';

/// WhatsApp-style day label for a chat date separator.
///
/// `today`, `yesterday`, within the last week the weekday name, otherwise a
/// `day month year` date.
///
/// These were Arabic string literals with no other branch, so they showed in
/// Arabic no matter what language the app was in.
String chatDayLabel(DateTime when) {
  final local = when.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(local.year, local.month, local.day);
  final diff = today.difference(that).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff >= 2 && diff <= 6) return _weekdayName(that.weekday);
  return '${that.day} ${_monthName(that.month)} ${that.year}';
}

/// Day label from an epoch-ms instant (group drift messages carry ms).
String chatDayLabelFromMs(int ms) =>
    chatDayLabel(DateTime.fromMillisecondsSinceEpoch(ms));

/// Day label from an ISO timestamp (the 1:1 entity carries an ISO string).
/// Returns null when the value is missing or unparseable.
String? chatDayLabelFromIso(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  final dt = DateTime.tryParse(iso);
  if (dt == null) return null;
  return chatDayLabel(dt);
}

/// Whether two epoch-ms instants fall on the same local calendar day.
bool sameLocalDayMs(int a, int b) {
  final da = DateTime.fromMillisecondsSinceEpoch(a).toLocal();
  final dbb = DateTime.fromMillisecondsSinceEpoch(b).toLocal();
  return da.year == dbb.year && da.month == dbb.month && da.day == dbb.day;
}

/// Whether two ISO timestamps fall on the same local calendar day. Returns true
/// when either side is unparseable, so an unknown timestamp never injects a
/// spurious separator.
bool sameLocalDayIso(String? a, String? b) {
  final da = a == null ? null : DateTime.tryParse(a);
  final dbb = b == null ? null : DateTime.tryParse(b);
  if (da == null || dbb == null) return true;
  final la = da.toLocal();
  final lb = dbb.toLocal();
  return la.year == lb.year && la.month == lb.month && la.day == lb.day;
}

String _weekdayName(int weekday) {
  switch (weekday) {
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
  }
  return '';
}

String _monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[(month - 1).clamp(0, 11)];
}

/// Centered date pill shown above the first (oldest) message of each day.
class ChatDaySeparator extends StatelessWidget {
  const ChatDaySeparator({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: context.paddingSymmetric(vertical: 8),
        padding: context.paddingSymmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          color: ColorManager.surfaceCardColor,
          borderRadius: 12.radius,
        ),
        child: TextWidget(
          label,
          isTranslate: false,
          style: context.bodySmall.colorExt(ColorManager.secondaryText),
        ),
      ),
    );
  }
}

/// Shown above the oldest loaded message — marks the start of the conversation
/// (there are no older messages to load).
class ChatStartIndicator extends StatelessWidget {
  const ChatStartIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.paddingSymmetric(vertical: 12),
        child: TextWidget(
          'No older messages',
          isTranslate: false,
          style: context.bodySmall.colorExt(ColorManager.secondaryText),
        ),
      ),
    );
  }
}

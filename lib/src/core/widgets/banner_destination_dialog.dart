import 'package:general/src/core/index.dart';

/// Confirmation dialog for top-banner taps (special message, lucky-win,
/// lucky box). Built on [AnimatedDialog] because its text colors are
/// explicit — when the dark body theme is enabled, the inherited textTheme
/// is painted white (app.dart _MainLayout), which made the old plain
/// [AlertDialog] title/content invisible on the white dialog card.
Future<void> showBannerDestinationDialog({
  required BuildContext context,
  required String? destinationName,
  required bool isLive,
  required VoidCallback onConfirm,
}) {
  final name = (destinationName ?? '').trim();
  final title = name.isNotEmpty
      ? name
      : (isLive ? StringManager.liveBroadcast.tr() : StringManager.room.tr());
  final String question;
  if (isLive) {
    question = name.isEmpty
        ? StringManager.goToLiveQuestionNoName.tr()
        : StringManager.goToLiveQuestion.tr(namedArgs: {'name': name});
  } else {
    question = name.isEmpty
        ? StringManager.goToRoomQuestionNoName.tr()
        : StringManager.goToRoomQuestion.tr(namedArgs: {'name': name});
  }

  return showDialog(
    context: context,
    builder: (ctx) => AnimatedDialog(
      title: title,
      description: question,
      conText: StringManager.yes.tr(),
      cancelText: StringManager.no.tr(),
      onTapCancel: () => Navigator.of(ctx).pop(),
      onTap: () {
        Navigator.of(ctx).pop();
        onConfirm();
      },
    ),
  );
}

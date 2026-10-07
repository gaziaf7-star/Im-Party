import 'package:general/src/core/index.dart';

/// Reusable centered "no data" state for loaded-but-empty lists.
///
/// Drop-in guard for places that render row/frame placeholders even when the
/// source list is empty (e.g. leaderboard top-three slots). Wraps the existing
/// [ErrorOrEmptyWidget] so the empty icon + message stay consistent app-wide.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.onTap,
    this.iconSize,
    this.titleStyle,
    this.subTitleStyle,
  });

  /// Localization key for the title. Defaults to [StringManager.noDataYet].
  final String? title;

  /// Localization key for the subtitle/message. Hidden when null/empty.
  final String? message;

  /// Optional refresh callback; shows the refresh button when provided.
  final VoidCallback? onTap;

  final double? iconSize;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;

  @override
  Widget build(BuildContext context) {
    return ErrorOrEmptyWidget(
      image: AssetsManager.empty,
      title: tr(title ?? StringManager.noDataYet),
      message: message == null ? '' : tr(message!),
      onTap: onTap,
      size: iconSize,
      titleStyle: titleStyle,
      subTitleStyle: subTitleStyle,
    );
  }
}

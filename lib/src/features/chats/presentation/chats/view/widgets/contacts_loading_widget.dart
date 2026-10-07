import 'package:general/src/core/index.dart';

import '../../../../../../core/widgets/GradientLoader.dart';

/// Loading state for the new-chat friend picker: just the app's single
/// standard spinner, no caption and no linear bar (on request, every loading
/// state in the app shows only the spinner — no accompanying text).
class ContactsLoadingWidget extends StatelessWidget {
  const ContactsLoadingWidget({super.key, this.message});

  /// Kept for call-site compatibility; no longer rendered (loading states
  /// show only the spinner now).
  final String? message;

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: GradientLoader(size: 40, strokeWidth: 2.5),
    );
  }
}
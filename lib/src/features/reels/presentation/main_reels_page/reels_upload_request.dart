import 'package:flutter/foundation.dart';

/// Bumped by the bottom nav's PLUS item (it replaces the Reels icon while the
/// user is already ON the Reels tab — TikTok style); the reels screen listens
/// and opens the pick-and-edit video flow. The old in-screen top "+" button
/// was removed in favour of this.
final ValueNotifier<int> reelsUploadRequest = ValueNotifier<int>(0);

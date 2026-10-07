
class BadWordsManager {
  BadWordsManager._();
  static final BadWordsManager _instance = BadWordsManager._();
  static BadWordsManager get instance => _instance;

  /// The list of raw bad word strings/patterns fetched from server.
  List<String> _badWords = [];

  /// Compiled regex patterns from the server response.
  List<RegExp> _compiledPatterns = [];

  /// Whether the bad words have been loaded.
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<String> get badWords => _badWords;

  /// Sets the bad words list (called after fetching from server via use case).
  void setBadWords(List<String> words) {
    _badWords = words;
    _compilePatterns();
    _isLoaded = true;
  }

  /// Compiles the bad words list into regex patterns.
  /// If a word is a valid regex pattern from the server, it's used as-is.
  /// If it's a plain word, it's wrapped with Unicode-aware word boundaries
  /// so Arabic text (RTL) is handled correctly.
  void _compilePatterns() {
    _compiledPatterns = [];
    for (final word in _badWords) {
      if (word.isEmpty) continue;
      try {
        if (_looksLikeRegex(word)) {
          // Server sent a regex pattern → use as-is
          _compiledPatterns.add(RegExp(word, caseSensitive: false, unicode: true));
        } else {
          // Plain word → wrap with Unicode word boundaries
          _compiledPatterns.add(_buildWholeWordRegex(word));
        }
      } catch (_) {
        // If regex compilation fails, treat as plain word
        try {
          _compiledPatterns.add(_buildWholeWordRegex(word));
        } catch (_) {
          // Skip invalid patterns entirely
        }
      }
    }
  }

  /// Checks if a string looks like it contains regex metacharacters
  /// (beyond what a normal word would have).
  bool _looksLikeRegex(String pattern) {
    return RegExp(r'[\\.*+?\[\](){}|^$]').hasMatch(pattern);
  }


  ///
  /// Uses \p{L} (any letter) and \p{N} (any digit) for Unicode support
  /// so Arabic, English, and other scripts all work correctly.
  RegExp _buildWholeWordRegex(String word) {
    final escaped = RegExp.escape(word);
    // Lookbehind: must NOT be preceded by a letter or digit
    // Lookahead: must NOT be followed by a letter or digit
    return RegExp(
      '(?<![\\p{L}\\p{N}])$escaped(?![\\p{L}\\p{N}])',
      caseSensitive: false,
      unicode: true,
    );
  }

  /// Filters bad words in a message, replacing them with '****'.
  String filterMessage(String message) {
    if (_compiledPatterns.isEmpty) return message;

    for (final pattern in _compiledPatterns) {
      message = message.replaceAll(pattern, '****');
    }
    return message;
  }

  /// Resets the manager state (e.g., on logout).
  void reset() {
    _badWords = [];
    _compiledPatterns = [];
    _isLoaded = false;
  }
}

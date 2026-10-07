/// Works out WHICH file a store / backpack item should preview and HOW to play
/// it, without trusting the `image_type` column on its own.
///
/// The panel stores the animation kind in a text column that content imports
/// routinely get wrong: entrance wares 829 and 833 shipped as `image_type =
/// 'alpha'` while the file on disk is `.svga`, and every frame ware claims
/// `'svga'` while carrying no animated file at all. Both cases used to end the
/// same way — the player for the declared kind refused the bytes, the widget
/// returned an empty box, and the user got a dimmed screen with nothing on it.
///
/// The container extension is the only trustworthy signal, so it wins. The one
/// genuine ambiguity is `.mp4`, which is the container for plain video, VAP and
/// alpha-channel video alike; there the declared type is the only thing that
/// can tell them apart, so it is honoured.
library;

enum AssetPreviewKind {
  svga,
  vap,
  alpha,
  mp4,

  /// A still image (png / webp / …) — no player, just draw it.
  still,

  /// Nothing to show: the item has no usable file on either field.
  none,
}

class AssetPreviewSource {
  const AssetPreviewSource({required this.url, required this.kind});

  /// Relative or absolute path of the file to play. Empty when [kind] is
  /// [AssetPreviewKind.none].
  final String url;

  final AssetPreviewKind kind;

  bool get isAnimated =>
      kind != AssetPreviewKind.still && kind != AssetPreviewKind.none;

  bool get isPlayable => kind != AssetPreviewKind.none;

  static const _stillExtensions = <String>{
    '.png',
    '.jpg',
    '.jpeg',
    '.webp',
    '.gif',
    '.bmp',
    '.svg',
  };

  static const _svgaExtensions = <String>['.svga', '.zzz', '.zz'];

  /// [animated] is the ware's `svg` field (`img2` on the panel), [still] its
  /// `image` field. The animated file is preferred; an item that only ships a
  /// still — every frame ware today — previews as that still rather than as a
  /// blank dialog.
  static AssetPreviewSource resolve({
    String? animated,
    String? still,
    String? declaredType,
  }) {
    final animatedUrl = animated?.trim() ?? '';
    final stillUrl = still?.trim() ?? '';
    final url = animatedUrl.isNotEmpty ? animatedUrl : stillUrl;

    if (url.isEmpty) {
      return const AssetPreviewSource(url: '', kind: AssetPreviewKind.none);
    }

    return AssetPreviewSource(url: url, kind: _kindOf(url, declaredType));
  }

  static AssetPreviewKind _kindOf(String url, String? declaredType) {
    final lower = url.toLowerCase();
    final declared = declaredType?.trim().toLowerCase() ?? '';

    // Strip a query string before looking at the extension: presigned URLs
    // carry `?X-Amz-…` and would otherwise never match.
    final path = lower.split('?').first;

    for (final ext in _svgaExtensions) {
      if (path.endsWith(ext)) return AssetPreviewKind.svga;
    }

    // One container, three renderers — only the column knows which.
    if (path.endsWith('.mp4') || path.endsWith('.mov')) {
      if (declared == 'vap') return AssetPreviewKind.vap;
      if (declared == 'alpha') return AssetPreviewKind.alpha;
      return AssetPreviewKind.mp4;
    }

    final dot = path.lastIndexOf('.');
    final ext = dot == -1 ? '' : path.substring(dot);
    if (_stillExtensions.contains(ext)) return AssetPreviewKind.still;

    // Extensionless key (some imports store a bare object name): the column is
    // all that is left, so fall back to it.
    switch (declared) {
      case 'svga':
        return AssetPreviewKind.svga;
      case 'vap':
        return AssetPreviewKind.vap;
      case 'alpha':
        return AssetPreviewKind.alpha;
      case 'mp4':
        return AssetPreviewKind.mp4;
      default:
        return AssetPreviewKind.still;
    }
  }
}

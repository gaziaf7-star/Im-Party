import 'dart:convert';

/// Reads the `videoEffects` entitlement claim from a LiveKit access-token JWT.
///
/// The engine resolves the per-platform Video Effects entitlement against the
/// requesting client's `os` at mint and stamps a single boolean into the token's
/// signed `metadata` claim. We decode it here WITHOUT verifying the signature —
/// the SFU verifies the token on join; this client-side read only chooses whether
/// to build the effects processor in entitled mode. The authoritative gate is the
/// processor itself (it forces native passthrough when `entitled: false`).
///
/// Backward-compatible / fail-open: returns `true` unless the claim is explicitly
/// `false`. A token minted by an older engine (no claim) keeps effects working;
/// only a new engine that has computed "not entitled" emits `videoEffects: false`.
bool videoEffectsEntitledFromToken(String? token) {
  if (token == null || token.isEmpty) return true;
  try {
    final parts = token.split('.');
    if (parts.length < 2) return true;
    final payload = jsonDecode(_decodeSegment(parts[1])) as Map<String, dynamic>;
    final metaRaw = payload['metadata'];
    if (metaRaw is! String || metaRaw.isEmpty) return true;
    final meta = jsonDecode(metaRaw) as Map<String, dynamic>;
    final v = meta['videoEffects'];
    return v is bool ? v : true;
  } catch (_) {
    return true;
  }
}

/// Base64url-decodes a JWT segment (handles missing padding) to a UTF-8 string.
String _decodeSegment(String seg) {
  var s = seg.replaceAll('-', '+').replaceAll('_', '/');
  switch (s.length % 4) {
    case 2:
      s += '==';
      break;
    case 3:
      s += '=';
      break;
  }
  return utf8.decode(base64.decode(s));
}

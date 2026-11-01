import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_api/youtube_api.dart';
import 'get_youtube_videos_event.dart';
import 'get_youtube_videos_state.dart';

class GetYoutubeVideosBloc extends Bloc<GetYoutubeEvent, GetYoutubeState> {
  List<YouTubeVideo> results = [];

  GetYoutubeVideosBloc() : super(GetYoutubeStateInitial()) {
    on<GetYoutubeVideoEvent>((event, emit) async {
      emit(GetYoutubeStateLoading());

      final query = event.search.trim();
      final cached = _cache[query.toLowerCase()];
      if (cached != null) {
        results = cached;
        emit(GetVideosYoutubeSuccessState(results));
        return;
      }

      try {
        // The API key has a small daily quota (a search costs 100 of 10,000
        // units). Once it is used up -- or the key is missing -- search the
        // YouTube page directly instead, so search keeps working.
        if (_apiUsable) {
          try {
            results = query.isEmpty
                ? await _trending(event.regionCode)
                : await _search(query);
          } catch (e) {
            log('YouTube API failed, using keyless search: $e');
            if (e.toString().toLowerCase().contains('quota')) {
              _apiOffUntil = DateTime.now().add(const Duration(hours: 6));
            }
            results = await _keylessSearch(
                query.isEmpty ? 'trending music videos' : query);
          }
        } else {
          results = await _keylessSearch(
              query.isEmpty ? 'trending music videos' : query);
        }
        if (results.isNotEmpty) _cache[query.toLowerCase()] = results;
        emit(GetVideosYoutubeSuccessState(results));
      } catch (e, st) {
        log('Error fetching youtube videos: $e\n$st');
        emit(GetYoutubeStateError(e.toString()));
      }
    });
  }

  /// Trending videos, fetched directly (1 quota unit). youtube_api's own
  /// getTrends crashed with "RangeError ... 0..48: 49": it reads as many items
  /// as `resultsPerPage` says (50) even when YouTube returns fewer (49).
  /// Here we only ever read the items that actually arrived.
  Future<List<YouTubeVideo>> _trending(String? regionCode) async {
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
      'part': 'snippet,contentDetails',
      'chart': 'mostPopular',
      'maxResults': '50',
      'key': youtubeApiKey,
      if (regionCode != null && regionCode.isNotEmpty) 'regionCode': regionCode,
    });
    final res = await http.get(uri);
    final data = jsonDecode(res.body);
    if (data is! Map) return const [];
    if (data['error'] != null) {
      throw (data['error']['message'] ?? 'YouTube error').toString();
    }
    final items = data['items'];
    if (items is! List) return const [];
    final videos = <YouTubeVideo>[];
    for (final item in items) {
      if (item is! Map) continue;
      try {
        final video = YouTubeVideo(item, getTrendingVideo: true);
        final iso = item['contentDetails']?['duration']?.toString();
        video.duration = _duration(iso);
        videos.add(video);
      } catch (_) {
        // Skip a malformed entry instead of losing the whole list.
      }
    }
    return videos;
  }

  /// Search (100 quota units), with the same "only read what arrived" guard
  /// as [_trending]; durations come from one extra videos call (1 unit).
  Future<List<YouTubeVideo>> _search(String query) async {
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/search', {
      'part': 'snippet',
      'q': query,
      'type': 'video',
      'maxResults': '50',
      'key': youtubeApiKey,
    });
    final res = await http.get(uri);
    final data = jsonDecode(res.body);
    if (data is! Map) return const [];
    if (data['error'] != null) {
      throw (data['error']['message'] ?? 'YouTube error').toString();
    }
    final items = data['items'];
    if (items is! List) return const [];
    final videos = <YouTubeVideo>[];
    for (final item in items) {
      if (item is! Map || item['id'] is! Map) continue;
      try {
        videos.add(YouTubeVideo(item));
      } catch (_) {}
    }
    if (videos.isEmpty) return videos;
    try {
      final durUri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
        'part': 'contentDetails',
        'id': videos.map((v) => v.id).whereType<String>().join(','),
        'key': youtubeApiKey,
      });
      final durData = jsonDecode((await http.get(durUri)).body);
      final durItems = durData is Map ? durData['items'] : null;
      if (durItems is List) {
        final byId = {
          for (final d in durItems)
            if (d is Map) '${d['id']}': _duration(
                d['contentDetails']?['duration']?.toString()),
        };
        for (final v in videos) {
          v.duration = byId[v.id] ?? '';
        }
      }
    } catch (_) {
      // Durations are a nicety; the list is still usable without them.
    }
    return videos;
  }

  /// Results of this app session, so repeating a search costs nothing.
  static final Map<String, List<YouTubeVideo>> _cache = {};

  /// Set when the API key's daily quota ran out; the API is skipped until then.
  static DateTime? _apiOffUntil;

  bool get _apiUsable =>
      youtubeApiKey.trim().isNotEmpty &&
      (_apiOffUntil == null || DateTime.now().isAfter(_apiOffUntil!));

  /// Search without the API key: the YouTube results page carries its data
  /// as `ytInitialData` JSON. Parsed on a background isolate (it is large).
  Future<List<YouTubeVideo>> _keylessSearch(String query) async {
    final uri = Uri.https('www.youtube.com', '/results', {
      'search_query': query,
      'hl': 'en',
    });
    final res = await http.get(uri, headers: const {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
          'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36',
      'Accept-Language': 'en-US,en;q=0.9',
      'Cookie': 'CONSENT=YES+1',
    }).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw 'YouTube search failed (${res.statusCode})';
    }
    final items = await compute(_parseResultsPage, res.body);
    final videos = <YouTubeVideo>[];
    for (final item in items) {
      try {
        final video = YouTubeVideo(item);
        video.duration = '${item['duration'] ?? ''}';
        videos.add(video);
      } catch (_) {}
    }
    return videos;
  }

  /// "PT1H2M3S" -> "1:02:03", "PT4M13S" -> "4:13".
  static String _duration(String? iso) {
    if (iso == null) return '';
    final m = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?').firstMatch(iso);
    if (m == null) return '';
    final h = int.tryParse(m.group(1) ?? '') ?? 0;
    final min = int.tryParse(m.group(2) ?? '') ?? 0;
    final s = int.tryParse(m.group(3) ?? '') ?? 0;
    String two(int v) => v.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(min)}:${two(s)}' : '$min:${two(s)}';
  }
}

/// Pulls every `videoRenderer` out of a YouTube results page and shapes it
/// like an API search item, so [YouTubeVideo] can read it unchanged.
List<Map<String, dynamic>> _parseResultsPage(String html) {
  const marker = 'ytInitialData';
  var at = html.indexOf('var $marker');
  if (at < 0) at = html.indexOf('window["$marker"]');
  if (at < 0) return const [];
  final start = html.indexOf('{', at);
  if (start < 0) return const [];

  // Find the matching closing brace, skipping braces inside strings.
  var depth = 0;
  var inString = false;
  var escaped = false;
  var end = -1;
  for (var i = start; i < html.length; i++) {
    final c = html.codeUnitAt(i);
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (c == 0x5C) {
        escaped = true;
      } else if (c == 0x22) {
        inString = false;
      }
      continue;
    }
    if (c == 0x22) {
      inString = true;
    } else if (c == 0x7B) {
      depth++;
    } else if (c == 0x7D) {
      depth--;
      if (depth == 0) {
        end = i;
        break;
      }
    }
  }
  if (end < 0) return const [];

  final Object? data;
  try {
    data = jsonDecode(html.substring(start, end + 1));
  } catch (_) {
    return const [];
  }

  String text(Object? node) {
    if (node is! Map) return '';
    if (node['simpleText'] != null) return '${node['simpleText']}';
    final runs = node['runs'];
    if (runs is List) {
      return runs.map((r) => r is Map ? '${r['text'] ?? ''}' : '').join();
    }
    return '';
  }

  final out = <Map<String, dynamic>>[];
  final seen = <String>{};
  void walk(Object? node) {
    if (out.length >= 40) return;
    if (node is Map) {
      final v = node['videoRenderer'];
      if (v is Map && v['videoId'] is String) {
        final id = v['videoId'] as String;
        if (seen.add(id)) {
          final owner = v['ownerText'];
          String channelId = '';
          if (owner is Map && owner['runs'] is List && (owner['runs'] as List).isNotEmpty) {
            final run = (owner['runs'] as List).first;
            if (run is Map) {
              channelId = '${run['navigationEndpoint']?['browseEndpoint']?['browseId'] ?? ''}';
            }
          }
          Map<String, dynamic> thumb(String name, int w, int h) =>
              {'url': 'https://i.ytimg.com/vi/$id/$name.jpg', 'width': w, 'height': h};
          out.add({
            'kind': 'youtube#searchResult',
            'id': {'kind': 'youtube#video', 'videoId': id},
            'snippet': {
              'publishedAt': text(v['publishedTimeText']),
              'channelId': channelId,
              'title': text(v['title']),
              'description': text(v['descriptionSnippet']),
              'channelTitle': text(owner),
              'thumbnails': {
                'default': thumb('default', 120, 90),
                'medium': thumb('mqdefault', 320, 180),
                'high': thumb('hqdefault', 480, 360),
              },
            },
            'duration': text(v['lengthText']),
          });
        }
        return;
      }
      for (final value in node.values) {
        walk(value);
      }
    } else if (node is List) {
      for (final value in node) {
        walk(value);
      }
    }
  }

  walk(data);
  return out;
}

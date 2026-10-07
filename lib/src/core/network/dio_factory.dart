import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/network/file_cache_store.dart';
import 'package:general/src/core/realtime/realtime_client.dart';
import 'package:general/src/core/services/auth_service.dart';
import 'package:platform_device_id_plus/platform_device_id.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioFactory {
  static final DioFactory _instance = DioFactory._internal();

  factory DioFactory() => _instance;

  static String? _cachedDeviceId;

  static final Random _requestIdRandom = Random();

  /// Persistent HTTP response cache, backed by a file-per-entry store under the
  /// app-support dir. Pure-Dart (dart:io + path_provider), no native code path
  /// that breaks Shorebird and no Hive dependency — so it keeps the original
  /// Shorebird-safe / no classic-Hive-vs-hive_ce constraint while ADDING
  /// survival across app restarts. On weak devices this lets opted-in catalog
  /// GETs and the /bootstrap aggregate serve instantly from disk on cold start
  /// instead of re-hitting the network. Caching is still strictly opt-in (the
  /// interceptor default below is [CachePolicy.noCache]), so writes and untagged
  /// GETs are never persisted.
  static final CacheStore _cacheStore = FileCacheStore();

  /// Wipes every persisted HTTP response from [_cacheStore].
  ///
  /// dio_cache_interceptor keys entries by URL only — the Authorization header
  /// is NOT part of the cache key — so a cached GET written under one signed-in
  /// user would otherwise be served to the next user on the same device (and,
  /// now that the store is persistent, across restarts). Calling this on every
  /// auth-scope change (logout / 401 / 505 teardown) guarantees one user's
  /// cached entries never leak into another user's session. Best-effort: a
  /// failed clean degrades to stale cache, never blocks the logout flow.
  static Future<void> clearHttpCache() async {
    try {
      // priorityOrBelow: CachePriority.high (the default) removes ALL keys.
      await _cacheStore.clean(priorityOrBelow: CachePriority.high);
    } catch (_) {}
  }

  /// Stable per-user scope folded into every cache key (FIX A: defense by
  /// construction). dio_cache_interceptor keys entries by URL only — the
  /// Authorization header is NOT part of the default key — so without this a
  /// cached GET written under user A's token could be served under user B's
  /// token on the same device, regardless of which logout path ran or whether a
  /// purge fired. By prefixing the key with a hash of the CURRENT bearer token,
  /// an entry written under A's scope can NEVER be looked up under B's scope:
  /// the keys simply differ.
  ///
  /// The token is read via [Methods.getUserToken] — the EXACT same source the
  /// request interceptor uses to inject the Authorization header
  /// ([_addAuthorizationHeader]) — so the cache scope always matches the auth
  /// the request actually carried. Logged out (empty token) => fixed 'anon'
  /// scope. Hashing (sha256, crypto is a direct dep) keeps the raw token out of
  /// file names on disk; only the first 16 hex chars are used (collision-safe
  /// for scoping) to keep keys short.
  static String _authScope() {
    final token = Methods.getUserToken();
    if (token.isEmpty) return 'anon';
    final digest = sha256.convert(utf8.encode(token));
    return digest.toString().substring(0, 16);
  }

  /// Cache-key builder shared by BOTH the global interceptor options and every
  /// per-request [CacheOptions] (zero duplication). Computes the package's
  /// default URL-based key, then prefixes it with the current auth scope so
  /// entries are partitioned per signed-in user.
  ///
  /// Signature matches [CacheKeyBuilder] (http_cache_core): named {url, headers,
  /// body}. The default builder keys by url only; we prepend the per-user scope.
  static String _scopedCacheKey({
    required Uri url,
    Map<String, String>? headers,
    Object? body,
  }) {
    final base = CacheOptions.defaultCacheKeyBuilder(
      url: url,
      headers: headers,
      body: body,
    );
    return '${_authScope()}|$base';
  }

  /// Methods that are safe to retry automatically. Retrying a write (POST/PUT/
  /// PATCH/DELETE) whose response was lost can double-apply the operation —
  /// e.g. a double gift-send / double coin charge — because dio_smart_retry
  /// re-sends the body. So retries are restricted to idempotent reads.
  static const _idempotentMethods = {'GET', 'HEAD', 'OPTIONS'};

  /// Retry decision used by every [RetryInterceptor] in this factory.
  /// Never retries non-idempotent methods; for idempotent reads it falls back
  /// to the package's default (timeouts, connection errors, retryable 5xx/429).
  static FutureOr<bool> _retryEvaluator(DioException error, int attempt) {
    final method = error.requestOptions.method.toUpperCase();
    if (!_idempotentMethods.contains(method)) {
      return false;
    }
    return RetryInterceptor.defaultRetryEvaluator(error, attempt);
  }

  /// Generates a locally-unique correlation id for a single request, sent as
  /// the 'X-Request-Id' header and mirrored to Crashlytics ('request_id') so a
  /// crash can be tied back to the exact server request. No package required.
  static String _generateRequestId() {
    final micros = DateTime.now().microsecondsSinceEpoch;
    final rand = _requestIdRandom.nextInt(0xFFFFFF);
    return '$micros-$rand';
  }

  /// Markers ensureDeviceId() will treat as "still need to retry".
  /// Never stored in [_cachedDeviceId] — only ever returned as a last
  /// resort by [ensureDeviceId] when every retry has been exhausted
  /// for that call. Keeping them out of the cache means the very next
  /// call will try again instead of being stuck on the marker forever.
  static const _deviceIdMarkers = {
    'failed_to_get_deviceId',
    'null_device_id',
  };

  static bool _isReliableDeviceId(String? id) =>
      id != null && id.isNotEmpty && !_deviceIdMarkers.contains(id);

  /// Boot-time best-effort fetch. Stores the real id on success;
  /// leaves [_cachedDeviceId] null on failure so [ensureDeviceId]
  /// can retry later.
  static Future<void> initDeviceId() async {
    try {
      final id = await PlatformDeviceId.getDeviceId;
      if (id != null && id.isNotEmpty) {
        _cachedDeviceId = id;
      }
    } on PlatformException {
      // leave _cachedDeviceId null; ensureDeviceId will retry on demand
    }
  }

  /// Returns a non-null, non-empty device id string for use in requests.
  ///
  /// If [_cachedDeviceId] already holds a real id, returns it
  /// immediately. Otherwise tries [PlatformDeviceId.getDeviceId] up to
  /// [attemptsPerCall] times with a small backoff, caching the first
  /// real id it gets so future calls are O(1).
  ///
  /// If every attempt fails, returns a marker string ('failed_to_get_deviceId')
  /// **without caching it** — so the next call to ensureDeviceId will
  /// retry from scratch. This is deliberate: device id can become
  /// available later (permissions granted, platform initialised),
  /// and we don't want to be permanently stuck on a marker.
  Future<String> ensureDeviceId({int attemptsPerCall = 3}) async {
    if (_isReliableDeviceId(_cachedDeviceId)) return _cachedDeviceId!;

    for (var attempt = 1; attempt <= attemptsPerCall; attempt++) {
      try {
        final fresh = await PlatformDeviceId.getDeviceId;
        if (fresh != null && fresh.isNotEmpty) {
          _cachedDeviceId = fresh;
          return fresh;
        }
      } on PlatformException {
        // fall through to backoff + retry
      }
      if (attempt < attemptsPerCall) {
        await Future.delayed(Duration(milliseconds: 100 * attempt));
      }
    }

    // All attempts in this call failed. Return marker for the request
    // but DON'T cache it, so the next request will retry from scratch.
    return 'failed_to_get_deviceId';
  }

  late Dio dio;
  CancelToken cancelToken = CancelToken();

  DioFactory._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: EndPoints.baseURL,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        // NOT `br`. dart:io decodes gzip and deflate transparently but has no
        // brotli decoder, so advertising it is a promise the client cannot keep:
        // a CDN that honours it (Cloudflare does, for any response big enough to
        // be worth compressing) sends brotli bytes, and every one of them lands
        // in jsonDecode as "FormatException: Unexpected character (at offset 0)".
        'Accept-Encoding': 'gzip, deflate',
        'Content-Type': 'application/json; charset=utf-8',
        'X-localization': HiveManager().getData<String>(
                KeysManager.USER_BOX, KeysManager.LANG_CODE_KEY) ??
            "en",
        'tz': DateTime.now().timeZoneName.toString(),
        'long': ConstantsManager.long.value,
        'lat': ConstantsManager.lat.value,
        'iso': ConstantsManager.iso.value,
      },
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print,
        retries: 1,
        retryEvaluator: _retryEvaluator,
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
          // High-frequency / huge payloads would flood the console and block
          // the UI thread in debug builds.
          filter: (options, args) =>
              !options.path.contains('/aim') &&
              !options.path.contains('/rocket/'),
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers["X-Device-Token"] =
              _cachedDeviceId ?? 'failed_to_get_deviceId';
          final requestId = _generateRequestId();
          options.headers['X-Request-Id'] = requestId;
          try {
            FirebaseCrashlytics.instance.setCustomKey('request_id', requestId);
          } catch (_) {}
          _addAuthorizationHeader(options);
          return handler.next(options);
        },
        onError: (DioException dioError, handler) async {
          final statusCode = dioError.response?.statusCode;
          if (statusCode == 401 &&
              NavObserver.currentRoute.value != Routes.intro) {
            final authMessage = _extractMessage(dioError.response?.data);
            debugPrint(
              '[AUTH_REDIRECT] source=DioFactory '
              'endpoint=${dioError.requestOptions.path} status=$statusCode '
              'message=${authMessage ?? dioError.message}',
            );
            debugPrint(
              '[LOGIN_REDIRECT] source=DioFactory status=$statusCode '
              'reason=${authMessage ?? 'HTTP 401'}',
            );
            await _handleAuthFailure(
              message: authMessage,
            );
            return handler.reject(dioError);
          }
          _logWithdrawError(dioError);
          _recordApiError(dioError);
          return handler.next(dioError);
        },
      ),
    );

    // Opt-in HTTP response cache. Added LAST so the cache key/entry reflects the
    // final request (Authorization + localization headers already injected by
    // the wrapper above). The global default policy is [CachePolicy.noCache]:
    // a request is cached ONLY when it explicitly opts in by carrying a
    // per-request CacheOptions in its extra (see [_handleRequest]). This keeps
    // every write and every untagged GET uncached by construction.
    dio.interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
          store: _cacheStore,
          policy: CachePolicy.noCache,
          keyBuilder: _scopedCacheKey,
        ),
      ),
    );
  }

  /// Null-safe extraction of the server 'message' field. Concurrent 401/505
  /// responses can arrive with a null or non-Map body (HTML error page, empty
  /// body, plain string); reading data['message'] on those throws and used to
  /// crash the onError handler. Returns null when no usable message is present.
  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      final message = data['message'];
      return message is String ? message : null;
    }
    return null;
  }

  static void _logWithdrawError(DioException error) {
    final path = error.requestOptions.path;
    final isWithdrawRequest = path.contains('withdraw') ||
        path.contains('widthraw') ||
        path.contains('withdrow') ||
        path.contains('PaymentMethod') ||
        path.contains('reseller_list');
    if (!isWithdrawRequest) return;
    debugPrint(
      '[WITHDRAW_ERROR] endpoint=$path '
      'status=${error.response?.statusCode} '
      'message=${_extractMessage(error.response?.data) ?? error.message}',
    );
  }

  /// Guards against concurrent logouts. Several in-flight requests can each
  /// return 401 at once; without this flag every one of them would tear
  /// down Centrifugo, sign out of Google/Firebase and re-navigate to intro,
  /// firing the heavy teardown N times and stacking navigations. The first
  /// failure wins; the rest are ignored until the user is back on intro.
  static bool _isHandlingAuthFailure = false;

  static Future<void> _handleAuthFailure({String? message}) async {
    if (_isHandlingAuthFailure) return;
    _isHandlingAuthFailure = true;
    try {
      // Tear down the Centrifugo realtime socket on auth failure (replaces the
      // old realtime disconnect). Guarded + best-effort: never block the logout flow.
      if (di.isRegistered<RealtimeClient>()) {
        await di<RealtimeClient>().stop();
      }
      AuthService().clearToken();
      final google = GoogleSignIn();
      try {
        await google.signOut();
        google.disconnect();
      } catch (_) {
        // google_sign_in pigeon channel can be unavailable
        // (channel-error / MissingPluginException). Sign-out is best-effort:
        // never let it abort the logout flow below.
      }
      const MyDataModel().clearInstance();
      await FirebaseAuth.instance.signOut();
      navKey.currentContext?.pushNamedAndRemoveUntil(
        Routes.intro,
        arguments: message,
      );
    } finally {
      _isHandlingAuthFailure = false;
    }
  }

  /// Count of network timeouts since launch — kept internally (and as a
  /// Crashlytics custom key) instead of one recordError per timeout.
  static int _timeoutCount = 0;

  /// Reports non-auth network/API failures to Crashlytics as non-fatal so they
  /// don't block the user but are visible for diagnosis. Covers connection
  /// errors, 5xx, parse/unknown and any non-redirect status codes.
  /// Only the endpoint path, HTTP method and status code are attached — never
  /// tokens or request/response bodies.
  ///
  /// Plain timeouts (connect/receive/send) are NOT recorded as events: they
  /// fire by the tens of thousands on slow networks (35K+ events) and drown
  /// the dashboard. They are counted + breadcrumbed instead, so they still
  /// show up attached to any real crash report.
  static void _recordApiError(DioException dioError) {
    try {
      final requestOptions = dioError.requestOptions;
      final statusCode = dioError.response?.statusCode;
      final crashlytics = FirebaseCrashlytics.instance;

      final isTimeout = dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.sendTimeout;
      if (isTimeout) {
        _timeoutCount++;
        Methods.printLog(
            '⏱️ Dio ${dioError.type.name} #$_timeoutCount on ${requestOptions.method} ${requestOptions.path}');
        crashlytics.setCustomKey('api_timeout_count', _timeoutCount);
        crashlytics.log(
            'dio ${dioError.type.name}: ${requestOptions.method} ${requestOptions.path}');
        return;
      }

      crashlytics.setCustomKey('api_endpoint', requestOptions.path);
      crashlytics.setCustomKey('api_method', requestOptions.method);
      crashlytics.setCustomKey('api_status', statusCode?.toString() ?? 'none');
      crashlytics.recordError(
        dioError,
        dioError.stackTrace,
        fatal: false,
      );
    } catch (_) {}
  }

  /// Adds Authorization headers to the request if token is present
  void _addAuthorizationHeader(RequestOptions options) {
    final token = Methods.getUserToken();
    Methods.printLog("TOKEN -----> $token");
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
  }

  void updateLanguageHeader(String languageCode) {
    dio.options.headers["X-localization"] = languageCode == "ar" ? "ar" : "en";
  }

  String? getDeviceId() => _cachedDeviceId;

  static Dio createDownloadDio() {
    // Image/asset download client (isolated: no baseUrl, no auth header). On
    // very slow networks (single-digit KB/s) a full-size avatar/cover can take
    // a long time; these timeouts are generous so the download succeeds instead
    // of aborting to a placeholder. This never blocks the UI — downloads run
    // async and CacheImageWidget renders a shimmer meanwhile.
    final downloadDio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.bytes,
    ));
    downloadDio.interceptors.add(
      RetryInterceptor(
        dio: downloadDio,
        logPrint: print,
        retries: 2,
        retryEvaluator: _retryEvaluator,
      ),
    );
    return downloadDio;
  }

  /// Common get request handler.
  ///
  /// Caching is OPT-IN: a response is cached only when [cacheDuration] is
  /// explicitly provided (non-null). With no [cacheDuration] the request is
  /// never cached. [forceRefresh] bypasses any cached value, fetches from the
  /// network and refreshes the cache entry. Both apply to GET only.
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? headers,
    bool forceRefresh = false,
    Duration? cacheDuration,
    bool serveCacheOn5xx = true,
    ProgressCallback? onSendProgress,
  }) async {
    return _handleRequest(
      path,
      options: options,
      headers: headers,
      queryParameters: queryParameters,
      method: 'GET',
      forceRefresh: forceRefresh,
      cacheDuration: cacheDuration,
      serveCacheOn5xx: serveCacheOn5xx,
      onSendProgress: onSendProgress,
    );
  }

  /// Common post request handler
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
  }) async {
    final response = await _handleRequest(
      path,
      options: options,
      headers: headers,
      queryParameters: queryParameters,
      data: data,
      method: 'POST',
      onSendProgress: onSendProgress,
    );
    return response;
  }

  /// Common put request handler
  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
  }) async {
    final response = await _handleRequest(
      path,
      options: options,
      headers: headers,
      queryParameters: queryParameters,
      data: data,
      method: 'PUT',
      onSendProgress: onSendProgress,
    );
    return response;
  }

  /// Common delete request handler
  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
  }) async {
    final response = await _handleRequest(
      path,
      options: options,
      headers: headers,
      queryParameters: queryParameters,
      data: data,
      method: 'DELETE',
      onSendProgress: onSendProgress,
    );
    return response;
  }

  Future<Response<dynamic>> _handleRequest(
    String path, {
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? headers,
    bool forceRefresh = false,
    Duration? cacheDuration,
    bool serveCacheOn5xx = true,
    ProgressCallback? onSendProgress,
  }) async {
    // Global guard: never issue a request with an empty/blank URL. An empty path
    // reaches Dio from null image URLs (getImage() -> '') or a missing signed
    // upload URL, and Dio.request/download throws an opaque error on it. Reject
    // early with a DioException so the normal Either/execute error paths handle
    // it as a failure instead of crashing the caller.
    if (path.trim().isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'Empty request URL',
      );
    }
    if (AuthService().canMakeRequest(path)) {
      Options requestOptions = options ?? Options(method: method);
      requestOptions.headers = requestOptions.headers ?? {};

      if (headers != null) {
        requestOptions.headers?.addAll(headers);
      }

      // Opt-in caching: only GET requests that explicitly pass a cacheDuration
      // attach a per-request CacheOptions. Everything else (writes, untagged
      // GETs) carries no cache extra and falls to the global noCache default,
      // so it is never stored — financial/dynamic endpoints are uncacheable by
      // construction. forceCache stores the response even when the server sends
      // no cache directives; maxStale bounds its lifetime to [cacheDuration].
      if (method == 'GET' && cacheDuration != null) {
        final cacheOptions = CacheOptions(
          store: _cacheStore,
          // FIX A: partition entries per signed-in user (see [_scopedCacheKey]).
          keyBuilder: _scopedCacheKey,
          policy: forceRefresh
              ? CachePolicy.refreshForceCache
              : CachePolicy.forceCache,
          maxStale: cacheDuration,
          // FIX B: financial endpoints (e.g. /bootstrap → my_store wallet/coins/
          // diamonds) pass serveCacheOn5xx:false so a server 5xx is NEVER masked
          // with a stale cached balance — only a genuine offline failure
          // (hitCacheOnNetworkFailure) may serve the last snapshot. Non-financial
          // catalog GETs keep the previous behaviour of riding out a transient
          // 5xx with cache.
          hitCacheOnErrorCodes:
              serveCacheOn5xx ? const [500, 502, 503, 504] : const [],
          hitCacheOnNetworkFailure: true,
        );
        requestOptions.extra = {
          ...?requestOptions.extra,
          ...cacheOptions.toExtra(),
        };
      }

      Response<dynamic> response = await dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );

      return response;
    } else {
      return Response<String>(
        data: null,
        requestOptions: RequestOptions(path: path),
        statusCode: 401,
        statusMessage: 'Unauthorized or Not Authenticated',
      );
    }
  }

  void refreshHeaders() {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'X-localization': HiveManager().getData<String>(
            KeysManager.USER_BOX,
            KeysManager.LANG_CODE_KEY,
          ) ??
          "en",
      'tz': DateTime.now().timeZoneName.toString(),
      'long': ConstantsManager.long.value,
      'lat': ConstantsManager.lat.value,
      'iso': ConstantsManager.iso.value,
    };

    dio.options.headers.addAll(headers);

    Methods.printLog(
      "[DioFactory] 🔁 Headers refreshed with new location:\n"
      "lat: ${ConstantsManager.lat.value}, "
      "long: ${ConstantsManager.long.value}, "
      "iso: ${ConstantsManager.iso.value}, "
      "tz: ${DateTime.now().timeZoneName}",
    );
  }
}

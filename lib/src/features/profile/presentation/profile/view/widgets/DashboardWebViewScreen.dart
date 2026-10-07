import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:general/src/core/index.dart';

/// Professional in-app browser for Agency / Manager / BD / Admin /
/// Super Admin dashboards.
///
/// Why this is more reliable than the old WebView:
/// - sends the app Bearer token on the first request
/// - enables JavaScript + DOM storage + database storage
/// - accepts third-party cookies
/// - allows mixed content used by some dashboard assets
/// - handles redirects and target="_blank" / window.open links
/// - uses a normal mobile-browser User-Agent
/// - has progress, retry, reload and WebView-back handling
class DashboardWebViewScreen extends StatefulWidget {
  const DashboardWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  final String url;
  final String title;

  @override
  State<DashboardWebViewScreen> createState() =>
      _DashboardWebViewScreenState();
}

class _DashboardWebViewScreenState
    extends State<DashboardWebViewScreen> {
  static const Color _pageBg = Color(0xFFF7F7F8);
  static const Color _black = Color(0xFF111111);
  static const Color _purple = Color(0xFF6C35F5);

  InAppWebViewController? _webViewController;

  bool _isLoading = true;
  double _progress = 0;
  String? _mainFrameError;
  int? _mainFrameStatusCode;
  String _currentUrl = '';

  late final Uri _initialUri;

  Map<String, String> get _requestHeaders {
    final headers = <String, String>{
      'Accept-Language': 'en-US,en;q=0.9',
    };

    final token = Methods.getUserToken();
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  @override
  void initState() {
    super.initState();

    _initialUri = Uri.tryParse(widget.url) ?? Uri();

    Methods.printLog(
      '🌐 [DashboardWebView] OPEN title=${widget.title} url=${widget.url}',
    );
    Methods.printLog(
      '🌐 [DashboardWebView] token_present=${Methods.getUserToken().isNotEmpty}',
    );
  }

  bool get _hasValidUrl =>
      _initialUri.hasScheme &&
          (_initialUri.scheme == 'https' || _initialUri.scheme == 'http') &&
          _initialUri.host.isNotEmpty;

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => _isLoading = value);
  }

  void _clearError() {
    if (!mounted) return;
    setState(() {
      _mainFrameError = null;
      _mainFrameStatusCode = null;
    });
  }

  Future<void> _reload() async {
    final controller = _webViewController;
    if (controller == null) return;

    _clearError();
    _setLoading(true);

    try {
      await controller.reload();
    } catch (e) {
      Methods.printLog(
        '🚨 [DashboardWebView] reload error => $e',
      );
    }
  }

  Future<void> _reloadInitialUrl() async {
    final controller = _webViewController;
    if (controller == null || !_hasValidUrl) return;

    _clearError();
    _setLoading(true);

    try {
      await controller.loadUrl(
        urlRequest: URLRequest(
          url: WebUri.uri(_initialUri),
          headers: _requestHeaders,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _mainFrameError = e.toString();
      });
    }
  }

  Future<void> _handleBack() async {
    final controller = _webViewController;

    if (controller != null) {
      try {
        if (await controller.canGoBack()) {
          await controller.goBack();
          return;
        }
      } catch (_) {}
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<bool> _handleNewWindow(
      InAppWebViewController controller,
      CreateWindowAction action,
      ) async {
    final popupUrl = action.request.url;

    if (popupUrl == null) return false;

    Methods.printLog(
      '🌐 [DashboardWebView] popup -> same WebView => $popupUrl',
    );

    try {
      await controller.loadUrl(
        urlRequest: URLRequest(
          url: popupUrl,
          headers: _requestHeaders,
        ),
      );
    } catch (e) {
      Methods.printLog(
        '🚨 [DashboardWebView] popup load error => $e',
      );
    }

    // We loaded the popup URL in the current WebView instead of creating
    // a second native window.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            onPressed: _handleBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _black,
              size: 20,
            ),
          ),
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Reload',
              onPressed: _reload,
              icon: const Icon(
                Icons.refresh_rounded,
                color: _black,
                size: 23,
              ),
            ),
            SizedBox(width: 4.w),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
              _isLoading ? 3.h : 0,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: _isLoading ? 3.h : 0,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: _isLoading
                  ? LinearProgressIndicator(
                value: _progress > 0 && _progress < 1
                    ? _progress
                    : null,
                minHeight: 3.h,
                backgroundColor:
                _purple.withValues(alpha: 0.10),
                valueColor:
                const AlwaysStoppedAnimation<Color>(
                  _purple,
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        body: !_hasValidUrl
            ? _DashboardErrorView(
          title: 'Invalid dashboard link',
          message: widget.url,
          statusCode: null,
          onRetry: () => Navigator.pop(context),
          retryText: 'Go back',
        )
            : Stack(
          children: [
            Positioned.fill(
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri.uri(_initialUri),
                  headers: _requestHeaders,
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  supportMultipleWindows: true,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  cacheEnabled: true,
                  thirdPartyCookiesEnabled: true,
                  mixedContentMode:
                  MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  useHybridComposition: true,
                  supportZoom: false,
                  verticalScrollBarEnabled: true,
                  horizontalScrollBarEnabled: false,
                  useShouldOverrideUrlLoading: true,

                  // A normal Chrome-like UA avoids sites/CDNs that
                  // return a reduced/blocked page to Android WebView's
                  // default "wv" User-Agent.
                  userAgent:
                  'Mozilla/5.0 (Linux; Android 13; Mobile) '
                      'AppleWebKit/537.36 (KHTML, like Gecko) '
                      'Chrome/152.0.0.0 Mobile Safari/537.36',
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  if (!mounted) return;

                  setState(() {
                    _isLoading = true;
                    _progress = 0;
                    _mainFrameError = null;
                    _mainFrameStatusCode = null;
                    _currentUrl = url?.toString() ?? '';
                  });

                  Methods.printLog(
                    '🌐 [DashboardWebView] START => $url',
                  );
                },
                onLoadStop: (controller, url) async {
                  if (!mounted) return;

                  setState(() {
                    _isLoading = false;
                    _progress = 1;
                    _currentUrl = url?.toString() ?? _currentUrl;
                  });

                  Methods.printLog(
                    '✅ [DashboardWebView] FINISH => $url',
                  );
                },
                onProgressChanged: (controller, progress) {
                  if (!mounted) return;

                  setState(() {
                    _progress =
                        progress.clamp(0, 100) / 100.0;
                    if (progress >= 100) {
                      _isLoading = false;
                    }
                  });
                },
                shouldOverrideUrlLoading:
                    (controller, navigationAction) async {
                  final url =
                      navigationAction.request.url;

                  if (url != null) {
                    Methods.printLog(
                      '🌐 [DashboardWebView] NAV => $url',
                    );
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onCreateWindow: _handleNewWindow,
                onUpdateVisitedHistory:
                    (controller, url, isReload) {
                  if (!mounted) return;

                  setState(() {
                    _currentUrl =
                        url?.toString() ?? _currentUrl;
                  });
                },
                onReceivedError:
                    (controller, request, error) {
                  Methods.printLog(
                    '🚨 [DashboardWebView] '
                        'ERROR type=${error.type} '
                        'main=${request.isForMainFrame} '
                        'url=${request.url} '
                        'description=${error.description}',
                  );

                  if (request.isForMainFrame == true &&
                      mounted) {
                    setState(() {
                      _isLoading = false;
                      _mainFrameError =
                          error.description;
                    });
                  }
                },
                onReceivedHttpError:
                    (controller, request, response) {
                  Methods.printLog(
                    '🚨 [DashboardWebView] '
                        'HTTP ${response.statusCode} '
                        'main=${request.isForMainFrame} '
                        'url=${request.url}',
                  );

                  if (request.isForMainFrame == true &&
                      (response.statusCode ?? 0) >= 400 &&
                      mounted) {
                    setState(() {
                      _isLoading = false;
                      _mainFrameStatusCode =
                          response.statusCode;
                      _mainFrameError =
                      'The dashboard server returned '
                          'HTTP ${response.statusCode}.';
                    });
                  }
                },
                onConsoleMessage:
                    (controller, consoleMessage) {
                  Methods.printLog(
                    '🧩 [DashboardWebView][JS] '
                        '${consoleMessage.message}',
                  );
                },
              ),
            ),

            if (_mainFrameError != null)
              Positioned.fill(
                child: _DashboardErrorView(
                  title: _mainFrameStatusCode == 401 ||
                      _mainFrameStatusCode == 403
                      ? 'Dashboard access needs authentication'
                      : 'Could not load dashboard',
                  message: _mainFrameStatusCode == 401 ||
                      _mainFrameStatusCode == 403
                      ? 'The web dashboard did not accept the '
                      'current app session. Tap Retry. If it '
                      'still returns ${_mainFrameStatusCode ?? ''}, '
                      'the backend dashboard route needs to accept '
                      'the app Bearer token or create an SSO session.'
                      : (_mainFrameError ??
                      'Please try again.'),
                  statusCode: _mainFrameStatusCode,
                  onRetry: _reloadInitialUrl,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardErrorView extends StatelessWidget {
  const _DashboardErrorView({
    required this.title,
    required this.message,
    required this.statusCode,
    required this.onRetry,
    this.retryText = 'Retry',
  });

  final String title;
  final String message;
  final int? statusCode;
  final VoidCallback onRetry;
  final String retryText;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7F7F8),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 26.w,
            vertical: 24.h,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20.w,
              24.h,
              20.w,
              20.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: const Color(0xFFE7E7EA),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20.r,
                  offset: Offset(0, 7.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C35F5)
                        .withValues(alpha: 0.09),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    color: const Color(0xFF6C35F5),
                    size: 29.h,
                  ),
                ),
                16.hBox,
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF111111),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (statusCode != null) ...[
                  7.hBox,
                  Text(
                    'HTTP $statusCode',
                    style: TextStyle(
                      color: const Color(0xFFE5484D),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                9.hBox,
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF6C6C72),
                    fontSize: 12.5.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                20.hBox,
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onRetry,
                      borderRadius:
                      BorderRadius.circular(24.r),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius:
                          BorderRadius.circular(24.r),
                        ),
                        child: Center(
                          child: Text(
                            retryText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

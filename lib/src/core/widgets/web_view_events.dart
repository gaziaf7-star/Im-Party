import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/opening_link_page.dart';
import 'package:general/src/core/widgets/payment_loading_page.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/presentation/search_agency_screen/view/show_hosts_agency.dart';
import 'package:general/src/features/agency/presentation/search_agency_screen/view/show_shipping_agency.dart';
import 'package:general/src/features/profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewEvents extends StatefulWidget {
  final String url;
  final String type;
  final bool needLoading;
  final WebViewController? preloadedController;

  const WebViewEvents({
    required this.url,
    super.key,
    this.type = "events",
    this.needLoading = true,
    this.preloadedController,
  });

  @override
  WebViewEventsState createState() => WebViewEventsState();
}

class WebViewEventsState extends State<WebViewEvents>
    with AutomaticKeepAliveClientMixin {
  WebViewController? _controller;
  bool isShowWebView = false;
  Timer? _hideLoadingTimer;
  static const platform = MethodChannel('file_picker_channel');

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedController != null) {
      _controller = widget.preloadedController;
      _setupPreloadedController();
    } else {
      _initWebView();
    }
  }

  void _setupPreloadedController() {
    // Set up the preloaded controller with additional handlers
    _controller?.clearCache();
    _controller
      ?..addJavaScriptChannel(
        'AppChannel',
        onMessageReceived: (message) {
          final data = message.message;
          Methods.printLog('📩 Received from web: $data');

          if (data.startsWith('open_profile:')) {
            final userId = data.split(':').last.trim();
            _openUserProfile(userId);
          } else if (data.startsWith('host_agency:')) {
            final agencyId = data.split(':').last.trim();
            _openHostsAgency(agencyId);
          } else if (data.startsWith('shipping_agency:')) {
            final agencyId = data.split(':').last.trim();
            _openShippingAgency(agencyId);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isShowWebView = false;
            });
            _hideLoadingTimer?.cancel();
          },
          onPageFinished: (String url) async {
            _content();

            _controller?.runJavaScript("""
                if (!window._flutterListenerAdded) {
                  window._flutterListenerAdded = true;
                  window.addEventListener('message', (event) => {
                    if (event.data) {
                      const msg = event.data.toString();
                      if (msg.startsWith('open_profile:') || msg.startsWith('host_agency:') || msg.startsWith('shipping_agency:')) {
                        AppChannel.postMessage(msg);
                      }
                    }
                  });
                  console.log("✅ JS listener injected only once");
                }
              """);

            await _controller?.runJavaScript('''
            const link = document.createElement('link');
            link.href = "https://fonts.googleapis.com/css2?family=Tajawal&display=swap";
            link.rel = "stylesheet";
            document.head.appendChild(link);
          ''');

            await _controller?.runJavaScript('''
            const style = document.createElement('style');
            style.innerHTML = '* { font-family: "Tajawal", sans-serif !important; }';
            document.head.appendChild(style);

            const observer = new MutationObserver(function(mutations) {
              document.querySelectorAll('*').forEach(el => {
                el.style.fontFamily = "Tajawal, sans-serif !important";
              });
            });

            observer.observe(document.body, { childList: true, subtree: true });
          ''');

            if (url.contains(EndPoints.domainURL)) {
              _controller
                  ?.runJavaScriptReturningResult('document.body.innerHTML')
                  .then((element) {
                final dynamic result = element;
                if (result == null) return;
                final html = result.toString().toLowerCase();

                if (!mounted) return;
                if (url.contains('${EndPoints.domainURL}/forms')) {
                  _handleCreateAgencyResult(context, html);
                } else {
                  _handleTrxValue(context, html);
                }
              });
              return;
            }
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains(EndPoints.domainURL)) {
              _controller
                  ?.runJavaScriptReturningResult('document.body.innerHTML')
                  .then((element) {
                final dynamic result = element;
                if (result == null) return;
                final html = result.toString().toLowerCase();

                if (!mounted) return;
                if (request.url.contains('${EndPoints.domainURL}/forms')) {
                  _handleCreateAgencyResult(context, html);
                } else {
                  _handleTrxValue(context, html);
                }
              });
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // Setup Android-specific features (file picker for upload)
    if (_controller?.platform is AndroidWebViewController) {
      _setupAndroidWebView(_controller?.platform as AndroidWebViewController);
    }

    // Mark as ready since it was preloaded
    setState(() => isShowWebView = true);
  }

  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    _controller = WebViewController()
      ..clearCache()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'AppChannel',
        onMessageReceived: (message) {
          final data = message.message;
          Methods.printLog('📩 Received from web: $data');

          if (data.startsWith('open_profile:')) {
            final userId = data.split(':').last.trim();
            _openUserProfile(userId);
          } else if (data.startsWith('host_agency:')) {
            final agencyId = data.split(':').last.trim();
            _openHostsAgency(agencyId);
          } else if (data.startsWith('shipping_agency:')) {
            final agencyId = data.split(':').last.trim();
            _openShippingAgency(agencyId);
          }
        },
      )
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isShowWebView = false;
            });
            _hideLoadingTimer?.cancel();
          },
          onPageFinished: (String url) async {
            _content();

            _controller?.runJavaScript("""
                if (!window._flutterListenerAdded) {
                  window._flutterListenerAdded = true;
                  window.addEventListener('message', (event) => {
                    if (event.data) {
                      const msg = event.data.toString();
                      if (msg.startsWith('open_profile:') || msg.startsWith('host_agency:') || msg.startsWith('shipping_agency:')) {
                        AppChannel.postMessage(msg);
                      }
                    }
                  });
                  console.log("✅ JS listener injected only once");
                }
              """);

            await _controller?.runJavaScript('''
            const link = document.createElement('link');
            link.href = "https://fonts.googleapis.com/css2?family=Tajawal&display=swap";
            link.rel = "stylesheet";
            document.head.appendChild(link);
          ''');

            await _controller?.runJavaScript('''
            const style = document.createElement('style');
            style.innerHTML = '* { font-family: "Tajawal", sans-serif !important; }';
            document.head.appendChild(style);

            const observer = new MutationObserver(function(mutations) {
              document.querySelectorAll('*').forEach(el => {
                el.style.fontFamily = "Tajawal, sans-serif !important";
              });
            });

            observer.observe(document.body, { childList: true, subtree: true });
          ''');

            if (url.contains(EndPoints.domainURL)) {
              _controller
                  ?.runJavaScriptReturningResult('document.body.innerHTML')
                  .then((element) {
                final dynamic result = element;
                if (result == null) return;
                final html = result.toString().toLowerCase();

                if (!mounted) return;
                if (url.contains('${EndPoints.domainURL}/forms')) {
                  _handleCreateAgencyResult(context, html);
                } else {
                  _handleTrxValue(context, html);
                }
              });
              return;
            }
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains(EndPoints.domainURL)) {
              _controller
                  ?.runJavaScriptReturningResult('document.body.innerHTML')
                  .then((element) {
                final dynamic result = element;
                if (result == null) return;
                final html = result.toString().toLowerCase();

                if (!mounted) return;
                if (request.url.contains('${EndPoints.domainURL}/forms')) {
                  _handleCreateAgencyResult(context, html);
                } else {
                  _handleTrxValue(context, html);
                }
              });
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    if (_controller?.platform is AndroidWebViewController) {
      _setupAndroidWebView(_controller?.platform as AndroidWebViewController);
    }
  }

  void _content() async {
    try {
      final result = await _controller?.runJavaScriptReturningResult('''
      (function() {
        try {
          var visibleElements = document.querySelectorAll('*:not(script):not(style)').length;
          return { visibleElements: visibleElements };
        } catch(e) {
          return { visibleElements: 27.5, error: e.toString() };
        }
      })();
    ''');

      if (result != null) {
        final data = json.decode(result.toString());
        final visibleElements = (data['visibleElements'] ?? 0).toDouble();

        Methods.printLog("   visibleElements: $visibleElements");

        if (visibleElements > 22.5) {
          if (!isShowWebView && mounted) {
            setState(() => isShowWebView = true);
            Methods.printLog("🎉 WebView is now visible based on content!");
          }
          return;
        } else {
          Methods.printLog("⏳ Content not ready yet, retrying...");
          _hideLoadingTimer?.cancel();
          _hideLoadingTimer = Timer(const Duration(milliseconds: 800), () {
            if (mounted && !isShowWebView) {
              _content();
            }
          });
        }
      } else {
        Methods.printLog("⚠️ No result from JavaScript, fallback to show");
        if (!isShowWebView && mounted) {
          setState(() => isShowWebView = true);
        }
      }
    } catch (e) {
      Methods.printLog("❌ Error checking page content: $e");
      if (!isShowWebView && mounted) {
        setState(() => isShowWebView = true);
      }
    }

    _hideLoadingTimer?.cancel();
    _hideLoadingTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && !isShowWebView) {
        Methods.printLog("⏰ Timeout reached, forcing WebView display");
        setState(() => isShowWebView = true);
      }
    });
  }

  void _setupAndroidWebView(AndroidWebViewController androidController) {
    androidController.setMediaPlaybackRequiresUserGesture(false);
    androidController.setOnShowFileSelector(_androidFilePicker);
  }

  Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
    try {
      final String? contentUri = await platform.invokeMethod('pickFile');

      if (contentUri != null && contentUri.isNotEmpty) {
        debugPrint('Content URI from native: $contentUri');
        return [contentUri];
      }

      return [];
    } catch (e) {
      debugPrint('Error picking file: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _hideLoadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBgAlt,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller!),
            if (!isShowWebView && widget.needLoading) ...{
              if (widget.type == "events") ...{
                const OpeningLinkPage(),
              } else if (widget.type == "payment") ...{
                const PaymentLoadingPage(),
              },
            }
          ],
        ),
      ),
    );
  }
}

void _openUserProfile(String userId) {
  final context = SafeNavigator.context;
  if (context == null) return;
  Methods().userProfileNavigator(
    context: context,
    userId: userId,
  );
}

void _openHostsAgency(String agencyId) {
  di<ShowAgencyBloc>().add(
    ShowAgencyEvent(
      agencyId: int.parse(agencyId),
      isFirstLoading: true,
    ),
  );
  final context = SafeNavigator.context;
  if (context == null) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return const ShowHostsAgency(
          agencyData: null,
          isProfile: true,
        );
      },
    ),
  );
}

void _openShippingAgency(String agencyId) {
  di<GetChargeAgencyBloc>().add(
    GetChargeAgencyEvent(agencyId: int.parse(agencyId), isFirstLoading: true),
  );
  final context = SafeNavigator.context;
  if (context == null) return;
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return ShowShippingAgency(
        agencyData: null,
        isProfile: true,
        id: int.parse(agencyId),
      );
    },
  ));
}

/// Top-level function for compute() — parses HTML content and extracts
/// the JSON payload from a <pre> block, off the main isolate.
Map<String, dynamic>? _parsePreBlockJson(String htmlContent) {
  final decoded = json.decode(htmlContent);
  final regex = RegExp(r'<pre[^>]*>(.*?)<\/pre>', dotAll: true);
  final match = regex.firstMatch(decoded);
  if (match == null) return null;
  return json.decode(match.group(1)!) as Map<String, dynamic>;
}

void _handleTrxValue(BuildContext context, String htmlContent) async {
  final data = await compute(_parsePreBlockJson, htmlContent);

  if (data != null) {
    Methods.printLog("DATA ===> $data");
    final status = data['status'] as bool?;
    final trx = data['trx'] as String?;
    final pending = data['pending'] as bool?;

    try {
      if (status != null && status == false) {
        context.popRoute();
        Methods.printLog("❌ STATUS FOUND ===> $status");
        Methods.printLog("❌ TRX FOUND ===> $trx");
        // Failed
        final dialogContext = SafeNavigator.context;
        if (dialogContext == null) return;
        showDialog(
          context: dialogContext,
          builder: (context) => AnimatedDialog(
            title: '',
            titleDivider: false,
            cancelText: StringManager.ok.tr(),
            isHideConfirm: true,
            isUpdateDialog: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: context.paddingAll(10),
                  decoration: BoxDecoration(
                    color: ColorManager.redAccount,
                    borderRadius: 60.radius,
                  ),
                  child: Icon(
                    Icons.close,
                    color: ColorManager.white,
                    size: 40.h,
                  ),
                ),
                10.hBox,
                TextWidget(
                  StringManager.operationFailed.tr(),
                  style: context.bodyMedium
                      .size(16)
                      .w600
                      .colorExt(ColorManager.textPrimary),
                  textAlign: TextAlign.center,
                ),
                5.hBox,
                TextWidget(
                  '${StringManager.operationNumber.tr()}: $trx',
                  style:
                      context.bodyMedium.size(14).colorExt(ColorManager.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
        return;
      }
      if (status != null && status == true) {
        context.popRoute();
        if (pending != null && pending == true) {
          Methods.printLog("⏳ PAYMENT PENDING ===> $status");
          Methods.printLog("⏳ TRX FOUND ===> $trx");
          // Pending
          final dialogContext = SafeNavigator.context;
          if (dialogContext == null) return;
          showDialog(
            context: dialogContext,
            builder: (context) => AnimatedDialog(
              title: '',
              titleDivider: false,
              cancelText: StringManager.ok.tr(),
              isHideConfirm: true,
              isUpdateDialog: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: context.paddingAll(10),
                    decoration: BoxDecoration(
                      color: ColorManager.primary,
                      borderRadius: 60.radius,
                    ),
                    child: Icon(
                      CupertinoIcons.hourglass,
                      color: ColorManager.white,
                      size: 40.h,
                    ),
                  ),
                  10.hBox,
                  TextWidget(
                    StringManager.paymentPending,
                    style: context.bodyMedium
                        .size(16)
                        .w600
                        .colorExt(ColorManager.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  5.hBox,
                  TextWidget(
                    '${StringManager.operationNumber.tr()}: $trx',
                    style: context.bodyMedium
                        .size(14)
                        .colorExt(ColorManager.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
          return;
        }

        // Success
        if (trx != null && trx.isNotEmpty) {
          Methods.printLog("✅ STATUS FOUND ===> $status");
          Methods.printLog("✅ TRX FOUND ===> $trx");

          di<MyStoreBloc>().add(const GetMyStoreEvent(isLoading: false));
          final dialogContext = SafeNavigator.context;
          if (dialogContext == null) return;
          showDialog(
            context: dialogContext,
            builder: (context) => AnimatedDialog(
              title: '',
              titleDivider: false,
              cancelText: StringManager.ok.tr(),
              isHideConfirm: true,
              isUpdateDialog: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: context.paddingAll(10),
                    decoration: BoxDecoration(
                      color: ColorManager.primary,
                      borderRadius: 60.radius,
                    ),
                    child: Icon(
                      Icons.check,
                      color: ColorManager.white,
                      size: 40.h,
                    ),
                  ),
                  10.hBox,
                  TextWidget(
                    StringManager.success.tr(),
                    style: context.bodyMedium
                        .size(16)
                        .w600
                        .colorExt(ColorManager.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  5.hBox,
                  TextWidget(
                    '${StringManager.operationNumber.tr()}: $trx',
                    style: context.bodyMedium
                        .size(14)
                        .colorExt(ColorManager.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return;
      }
    } catch (error) {
      Methods.printLog("❌ JSON decode error: $error");
    }
  } else {
    Methods.printLog("❌ No <pre> block found.");
  }
}

void _handleCreateAgencyResult(BuildContext context, String htmlContent) async {
  final data = await compute(_parsePreBlockJson, htmlContent);

  if (data != null) {
    Methods.printLog("data from create_agency ===> $data");

    final bool success = data['success'] ?? false;
    final String message = data['message'] ?? '';
    final dynamic orderId = data['data']?['order_id'];
    try {
      // Close any existing dialogs
      context.popRoute();

      if (!success) {
        // ❌ FAILED
        Methods.printLog("❌ CREATE AGENCY FAILED");
        final dialogContext = SafeNavigator.context;
        if (dialogContext == null) return;
        showDialog(
          context: dialogContext,
          builder: (context) => AnimatedDialog(
            title: '',
            titleDivider: false,
            cancelText: StringManager.ok.tr(),
            isHideConfirm: true,
            isUpdateDialog: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: context.paddingAll(10),
                  decoration: BoxDecoration(
                    color: ColorManager.redAccount,
                    borderRadius: 60.radius,
                  ),
                  child:
                      Icon(Icons.close, color: ColorManager.white, size: 40.h),
                ),
                10.hBox,
                TextWidget(
                  message.isNotEmpty
                      ? message
                      : StringManager.operationFailed.tr(),
                  style: context.bodyMedium
                      .size(16)
                      .w600
                      .colorExt(ColorManager.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
        return;
      }

      // ✅ SUCCESS
      Methods.printLog("✅ CREATE AGENCY SUCCESS — ORDER ID: $orderId");

      final dialogContext = SafeNavigator.context;
      if (dialogContext == null) return;
      showDialog(
        context: dialogContext,
        builder: (context) => AnimatedDialog(
          title: '',
          titleDivider: false,
          cancelText: StringManager.ok.tr(),
          isHideConfirm: true,
          isUpdateDialog: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: context.paddingAll(10),
                decoration: BoxDecoration(
                  color: ColorManager.primary,
                  borderRadius: 60.radius,
                ),
                child: Icon(CupertinoIcons.hourglass,
                    color: ColorManager.white, size: 40.h),
              ),
              10.hBox,
              TextWidget(
                message,
                style: context.bodyMedium
                    .size(16)
                    .w600
                    .colorExt(ColorManager.textPrimary),
                textAlign: TextAlign.center,
              ),
              if (orderId != null) ...[
                5.hBox,
                TextWidget(
                  "Order ID: $orderId",
                  style:
                      context.bodyMedium.size(14).colorExt(ColorManager.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    } catch (error) {
      Methods.printLog("❌ JSON Parse Error: $error");
    }
  }
}

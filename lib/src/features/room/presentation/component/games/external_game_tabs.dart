import 'dart:async';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// Top tab row shown above the games grid inside [GamesView]'s bottom sheet,
/// offering the two external WebView-based games (Teen Patti, Greedy Lion).
class ExternalGameTabs extends StatelessWidget {
  const ExternalGameTabs({super.key});

  String get _userId => MyDataModel.getInstance().id.toString();

  String get _streamId => RoomData.instance.room.id.toString();

  void _openTeenPatti(BuildContext context) {
    showExternalGameBottomSheet(
      context: context,
      gameName: 'Teen Patti',
      heightFactor: 0.64,
      replaceCurrentSheet: true,
      url: 'https://teenpatti.linlive.fr/game?uid=$_userId&stream=$_streamId&embed=1',
    );
  }

  void _openGreedyLion(BuildContext context) {
    showExternalGameBottomSheet(
      context: context,
      gameName: 'Greedy Lion',
      replaceCurrentSheet: true,
      url: 'https://greedylion.linlive.fr/$_userId',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingOnly(start: 15, end: 15, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: _ExternalGameTile(
              icon: AssetsManager.teenPattiIcon,
              label: 'Teen Patti',
              onTap: () => _openTeenPatti(context),
            ),
          ),
          10.wBox,
          Expanded(
            child: _ExternalGameTile(
              icon: AssetsManager.greedyLionIcon,
              label: 'Greedy Lion',
              onTap: () => _openGreedyLion(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExternalGameTile extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _ExternalGameTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: context.paddingSymmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: ColorManager.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(icon, width: 32.w, height: 32.w, fit: BoxFit.cover),
            ),
            8.wBox,
            Flexible(
              child: TextWidget(
                label,
                style: context.bodyMedium.colorExt(ColorManager.white).w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shared by the Live Games grid and the legacy external-game row. Keep the
// lock until the game route has finished closing, including its animation.
bool _externalGameActive = false;

/// Opens a game above the room. When launched from the game picker, dismiss
/// that popup completely before presenting the WebView on the root navigator.
Future<void> showExternalGameBottomSheet({
  required BuildContext context,
  required String url,
  required String gameName,
  double heightFactor = 0.80,
  double closeButtonTop = 64.0,
  Color backgroundColor = Colors.black,
  bool replaceCurrentSheet = false,
}) async {
  if (!context.mounted || _externalGameActive) return;

  // Capture both navigators while the picker context is still valid. The
  // picker uses a RawDialogRoute, so don't assume it is a ModalBottomSheetRoute.
  final rootNavigator = Navigator.of(context, rootNavigator: true);
  final pickerRoute = ModalRoute.of(context);
  final pickerNavigator = pickerRoute?.navigator;
  if (replaceCurrentSheet &&
      (pickerRoute is! PopupRoute ||
          !pickerRoute.isCurrent ||
          pickerNavigator == null)) {
    return; // Never pop the audio-room page to open a game.
  }

  _externalGameActive = true;
  ModalRoute<void>? gameRoute;
  bool gameStateSet = false;
  try {
    if (replaceCurrentSheet && pickerRoute is PopupRoute) {
      pickerNavigator!.pop();
      // Unlike `popped`, `completed` also waits for overlay removal. No
      // arbitrary delay and no use of the disposed game-picker context.
      await pickerRoute.completed;
    }
    if (!rootNavigator.mounted) return;

    ForegroundWidget.openGames.value = true;
    gameStateSet = true;
    await showModalBottomSheet<void>(
      context: rootNavigator.context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      clipBehavior: Clip.hardEdge,
      barrierColor: Colors.transparent,
      builder: (sheetContext) {
        gameRoute = ModalRoute.of<void>(sheetContext);
        final mq = MediaQuery.of(sheetContext);
        return ColoredBox(
          color: backgroundColor,
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: mq.size.height * heightFactor,
              child: _ExternalGameWebView(
                url: url,
                gameName: gameName,
                backgroundColor: backgroundColor,
                closeButtonTop: closeButtonTop,
              ),
            ),
          ),
        );
      },
    );
    final route = gameRoute;
    if (route != null) await route.completed;
  } finally {
    if (gameStateSet) ForegroundWidget.openGames.value = false;
    _externalGameActive = false;
  }
}

class _ExternalGameWebView extends StatefulWidget {
  final String url;
  final String gameName;
  final Color backgroundColor;
  final double closeButtonTop;

  const _ExternalGameWebView({
    required this.url,
    required this.gameName,
    required this.backgroundColor,
    required this.closeButtonTop,
  });

  @override
  State<_ExternalGameWebView> createState() => _ExternalGameWebViewState();
}

class _ExternalGameWebViewState extends State<_ExternalGameWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _progress = 0;
  String? _errorText;
  bool _closing = false;
  Future<void>? _pageCleanup;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.backgroundColor)
      ..addJavaScriptChannel(
        'FlutterNativeApp',
        onMessageReceived: (JavaScriptMessage message) {
          final String command = message.message.trim();
          if (command == 'CLOSE_GAME') {
            _close();
          } else if (command == 'RELOAD_USER') {
            Methods.printLog('🎮 EXTERNAL GAME => reload user requested');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted || _closing) return;
            setState(() => _progress = progress);
          },
          onPageStarted: (_) {
            if (!mounted || _closing) return;
            setState(() {
              _isLoading = true;
              _errorText = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted || _closing) return;
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (!mounted || _closing || error.isForMainFrame == false) return;
            setState(() {
              _isLoading = false;
              _errorText = error.description;
            });
          },
          onNavigationRequest: (request) => _closing && request.url != 'about:blank'
              ? NavigationDecision.prevent
              : NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    if (_controller.platform is AndroidWebViewController) {
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  Future<void> _clearGamePage() => _pageCleanup ??= _loadBlankPage();

  Future<void> _loadBlankPage() async {
    try {
      // Unload the game document, including its audio, timers and sockets.
      // A stalled platform call must never block the close button.
      await _controller
          .loadRequest(Uri.parse('about:blank'))
          .timeout(const Duration(milliseconds: 500));
    } catch (_) {
      // The native view may already be gone during external route teardown.
    }
  }

  Future<void> _close() async {
    if (!mounted || _closing) return;
    final route = ModalRoute.of(context);
    final navigator = route?.navigator;

    // Detach the platform view before starting the route's pop animation.
    setState(() => _closing = true);
    final cleanup = _clearGamePage();
    await WidgetsBinding.instance.endOfFrame;
    await cleanup;
    if (!mounted || navigator == null || !navigator.mounted || route == null) {
      return;
    }
    if (route.isCurrent) {
      // Direct pop bypasses the PopScope veto used to intercept system Back.
      // maybePop() would ask the same veto again and leave the game stuck.
      navigator.pop<void>();
    } else if (route.isActive) {
      // If another overlay appeared while cleaning up, remove only this game.
      navigator.removeRoute(route);
    }
  }

  @override
  void dispose() {
    _closing = true;
    unawaited(_clearGamePage());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: ColoredBox(
          color: widget.backgroundColor,
          child: Stack(
            children: [
              if (!_closing)
                Positioned.fill(child: WebViewWidget(controller: _controller)),
              if (_isLoading && !_closing)
                Positioned.fill(
                  child: ColoredBox(
                    color: widget.backgroundColor,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          12.hBox,
                          TextWidget(
                            '${widget.gameName}... $_progress%',
                            style: context.bodyMedium.colorExt(ColorManager.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_errorText != null && !_closing)
                Positioned.fill(
                  child: ColoredBox(
                    color: widget.backgroundColor,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 40),
                          12.hBox,
                          Padding(
                            padding: context.paddingSymmetric(horizontal: 24),
                            child: TextWidget(
                              _errorText!,
                              textAlign: TextAlign.center,
                              style: context.bodyMedium.colorExt(ColorManager.white),
                            ),
                          ),
                          16.hBox,
                          TextButton(
                            onPressed: _closing
                                ? null
                                : () => _controller.loadRequest(Uri.parse(widget.url)),
                            child: const TextWidget('Reload', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: widget.closeButtonTop.h,
                right: 10.w,
                child: _Close3dButton(
                  onTap: _closing ? null : _close,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glossy 3D close button: gradient face, light rim, darker "thickness" under
/// it and a soft shadow; it sinks slightly while pressed.
class _Close3dButton extends StatefulWidget {
  final VoidCallback? onTap;

  const _Close3dButton({required this.onTap});

  @override
  State<_Close3dButton> createState() => _Close3dButtonState();
}

class _Close3dButtonState extends State<_Close3dButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final depth = _down ? 1.5 : 5.0;
    return Semantics(
      button: true,
      label: 'Close game',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 70),
              margin: EdgeInsets.only(top: 5 - depth + 1.5),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF6B6B), Color(0xFFD7263D)],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.75),
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7A0F1C),
                    offset: Offset(0, depth),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    offset: Offset(0, depth + 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 24,
                shadows: [Shadow(color: Color(0x88000000), offset: Offset(0, 1.5), blurRadius: 2)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

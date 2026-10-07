import 'package:general/src/core/services/room_state_manager.dart';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/room/presentation/component/games/game_loading_screen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LeaderCCGameWebViewScreen extends StatefulWidget {
  final String gameUrl;
  final String screenMode; // 'full', 'hd', 'half'

  const LeaderCCGameWebViewScreen({
    super.key,
    required this.gameUrl,
    required this.screenMode,
  });

  @override
  State<LeaderCCGameWebViewScreen> createState() =>
      _LeaderCCGameWebViewScreenState();
}

class _LeaderCCGameWebViewScreenState extends State<LeaderCCGameWebViewScreen> {
  WebViewController? _controller;
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  String? _initializationError;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  @override
  void dispose() {
    _closing = true;
    _isLoading.dispose();
    di<ExploreBloc>().add(const StopGameEvent());

    final WebViewController? controller = _controller;
    if (controller != null) {
      controller.loadRequest(Uri.parse('about:blank'));
      controller.clearCache();
    }

    // Keep the screen awake if we're still inside a room after closing the game.
    if (!di<RoomStateManager>().isInRoom) {
      WakelockPlus.disable();
    }
    super.dispose();
  }

  Future<void> _initializeWebViewController() async {
    try {
      final Uri? uri = Uri.tryParse(widget.gameUrl);

      // ✅ FIX: Don't use project custom FormatException
      if (uri == null ||
          !(uri.scheme.toLowerCase() == 'http' ||
              uri.scheme.toLowerCase() == 'https')) {
        Methods.printLog(
          '❌ Invalid game URL => ${widget.gameUrl}',
        );

        _initializationError =
        'Invalid game URL: ${widget.gameUrl}';

        if (!_closing) {
          _isLoading.value = false;

          if (mounted) {
            setState(() {});
          }
        }

        return;
      }

      Methods.printLog('🎮 Opening game URL => $uri');
      Methods.printLog('🎮 Screen mode => ${widget.screenMode}');

      final WebViewController controller = WebViewController();

      // ✅ Assign before loading
      _controller = controller;

      await controller.setJavaScriptMode(
        JavaScriptMode.unrestricted,
      );

      await controller.setBackgroundColor(
        ColorManager.transparent,
      );

      await controller.addJavaScriptChannel(
        'pay',
        onMessageReceived: (message) {
          Methods.printLog(
            '💰 pay callback: ${message.message}',
          );
        },
      );

      await controller.addJavaScriptChannel(
        'closeGame',
        onMessageReceived: (message) {
          Methods.printLog('🕹️ closeGame callback');
          _closeGame();
        },
      );

      await controller.addJavaScriptChannel(
        'loadComplete',
        onMessageReceived: (message) {
          Methods.printLog('✅ game load complete');

          if (!_closing) {
            _isLoading.value = false;
          }
        },
      );

      await controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            Methods.printLog(
              '🎮 Game loading => $progress%',
            );
          },

          onPageStarted: (String url) {
            Methods.printLog(
              '🌍 Game page started: $url',
            );

            if (!_closing) {
              _isLoading.value = true;
            }
          },

          onPageFinished: (String url) async {
            Methods.printLog(
              '✅ Game page finished: $url',
            );

            try {
              await controller.runJavaScript('''
              console.log = function(){};
              console.error = function(){};
              console.warn = function(){};
            ''');
            } catch (e) {
              Methods.printLog(
                '⚠️ game console override failed: $e',
              );
            }

            if (!_closing) {
              _isLoading.value = false;
            }
          },

          onWebResourceError: (WebResourceError error) {
            Methods.printLog(
              '🚨 Game WebView error => '
                  'code=${error.errorCode} '
                  'description=${error.description} '
                  'mainFrame=${error.isForMainFrame}',
            );

            if (error.isForMainFrame == true && !_closing) {
              _isLoading.value = false;
            }
          },

          onNavigationRequest: (
              NavigationRequest request,
              ) {
            Methods.printLog(
              '➡️ Game navigation => ${request.url}',
            );

            return NavigationDecision.navigate;
          },
        ),
      );

      await WakelockPlus.enable();

      if (_closing) return;

      Methods.printLog(
        '🚀 Loading LeaderCC game...',
      );

      await controller.loadRequest(uri);
    } catch (e, s) {
      Methods.printLog(
        '❌ _initializeWebViewController error: $e\n$s',
      );

      _initializationError = e.toString();

      if (!_closing) {
        _isLoading.value = false;

        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  void _closeGame() {
    if (_closing || !mounted) return;
    _closing = true;
    Navigator.of(context).maybePop();
  }

  /// call updateCoin
  void updateCoin() {
    final WebViewController? controller = _controller;
    if (controller == null) return;
    try {
      controller.runJavaScript('updateCoin();');
      Methods.printLog('💰 updateCoin called');
    } catch (e, s) {
      Methods.printLog('❌ updateCoin error: $e\n$s');
    }
  }

  double _getHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;

    switch (widget.screenMode) {
      case 'full':
        return size.height;

      case 'hd':
        return (size.width * 1044.0 / 750.0)
            .clamp(size.width, size.height)
            .toDouble();

      case 'half':
      default:
        return size.width;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = _getHeight(context);
    final bool isFullScreen = widget.screenMode == 'full';
    final WebViewController? controller = _controller;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _closing = true;
      },
      child: Scaffold(
        backgroundColor: ColorManager.transparent,
        body: Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: SizedBox(
            width: double.infinity,
            height: isFullScreen ? null : height,
            child: Stack(
              children: [
                if (controller != null)
                  Positioned.fill(
                    child: WebViewWidget(controller: controller),
                  )
                else
                  const Positioned.fill(
                    child: ColoredBox(color: Colors.black),
                  ),

                if (_initializationError == null)
                  ValueListenableBuilder<bool>(
                    valueListenable: _isLoading,
                    builder: (_, value, __) {
                      return value
                          ? const GameLoadingScreen()
                          : const SizedBox.shrink();
                    },
                  )
                else
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black,
                      child: SafeArea(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.white,
                                  size: 44,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Game could not be opened',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: _closeGame,
                                  child: const Text('Close'),
                                ),
                              ],
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

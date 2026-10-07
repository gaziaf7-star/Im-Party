import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:general/src/features/games/domain/entities/game_entity.dart';
import 'package:general/src/features/games/games.dart';
import 'package:general/src/features/room/presentation/manager/open_game_manager/open_game_bloc.dart';
import 'package:general/src/features/room/presentation/manager/open_game_manager/open_game_event.dart';
import 'package:general/src/features/room/room.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'external_game_tabs.dart';
import 'game_view_item.dart';

class GamesView extends StatefulWidget {
  final String roomId;
  final bool? isFull;

  const GamesView({
    super.key,
    this.isFull = false,
    required this.roomId,
  });

  @override
  State<GamesView> createState() => _GamesViewState();
}

class _GamesViewState extends State<GamesView>
    with SingleTickerProviderStateMixin {
  int _openingGameId = 0;
  List<Map<String, dynamic>>? _baishunGamesCache;

  // Two tabs, per request: the existing provider game grid, and a second
  // tab of external web games (Teen Patti / Greedy Lion), matching the
  // sibling OriVex Party codebase -- was a fixed row of tiles shown above
  // the grid at all times.
  late final TabController _tabController =
  TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();

    final ExploreBloc bloc = di<ExploreBloc>();

    // Keep the SAME game list that is already showing correctly in the app.
    if (!bloc.state.outerReqStateGames.isLoaded) {
      bloc.add(const FetchGamesEvent(type: 'outer'));
    }
    if (!bloc.state.innerReqStateGames.isLoaded) {
      bloc.add(const FetchGamesEvent(type: 'inner'));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorManager.black,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15.r),
          topLeft: Radius.circular(15.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.hBox,
          Padding(
            padding: context.paddingOnly(top: 8, start: 15, bottom: 15),
            child: TextWidget(
              StringManager.entertainment,
              style: context.bodyLarge.colorExt(ColorManager.white).w600,
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: ColorManager.primary,
            labelColor: ColorManager.white,
            unselectedLabelColor:
            ColorManager.white.withValues(alpha: 0.55),
            labelStyle: context.bodyMedium.w600,
            tabs: [
              Tab(text: StringManager.games.tr()),
              // Literal label (no StringManager key yet), matching the
              // sibling OriVex Party codebase's own pattern of a
              // plain-text fallback ('No games available' below).
              const Tab(text: 'Live Games'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProviderGamesTab(),
                _buildLiveGamesGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderGamesTab() {
    return BlocBuilder<ExploreBloc, ExploreState>(
      bloc: di<ExploreBloc>(),
      buildWhen: (prev, curr) =>
      prev.outerReqStateGames != curr.outerReqStateGames ||
          prev.innerReqStateGames != curr.innerReqStateGames ||
          prev.outerGames != curr.outerGames ||
          prev.innerGames != curr.innerGames,
      builder: (context, state) {
        // IMPORTANT: profile/full list first. If unavailable, keep the old
        // inner/mini list only as a fallback.
        final List<GameDataEntity> profileGames = [
          ...state.outerGames?.fullGames ?? <GameDataEntity>[],
        ];
        final List<GameDataEntity> innerGames = [
          ...state.innerGames?.miniGames ?? <GameDataEntity>[],
        ];
        final List<GameDataEntity> games =
        profileGames.isNotEmpty ? profileGames : innerGames;

        Methods.printLog(
          '🎮 LIVE GAME LIST => profile=${profileGames.length} '
              'inner=${innerGames.length} show=${games.length}',
        );

        if (games.isNotEmpty) {
          return _buildGamesGrid(games);
        }

        final bool isLoading =
            state.outerReqStateGames == RequestState.loading ||
                state.innerReqStateGames == RequestState.loading;

        if (isLoading) {
          return const Center(
            child: LoadingView(isLoadingCenter: true),
          );
        }

        final bool hasError =
            state.outerReqStateGames == RequestState.error ||
                state.innerReqStateGames == RequestState.error;

        if (hasError) {
          return ErrorView(
            onTap: () {
              final ExploreBloc bloc = di<ExploreBloc>();
              bloc.add(const FetchGamesEvent(type: 'outer'));
              bloc.add(const FetchGamesEvent(type: 'inner'));
            },
          );
        }

        return Center(
          child: TextWidget(
            'No games available',
            style: context.bodyMedium.colorExt(ColorManager.white),
          ),
        );
      },
    );
  }

  /// External games replace the picker with one WebView sheet above the room.
  Widget _buildLiveGamesGrid() {
    final userId = MyDataModel.getInstance().id?.toString() ?? '';
    final streamId = RoomData.instance.room.id?.toString() ?? '';
    final liveGames = <_LiveGameEntry>[
      _LiveGameEntry(
        title: 'Greedy Lion',
        image: AssetsManager.greedyLionIcon,
        url: 'https://greedylion.linlive.fr/$userId',
      ),
      _LiveGameEntry(
        title: 'Teen Patti',
        heightFactor: 0.64,
        image: AssetsManager.teenPattiIcon,
        url:
        'https://teenpatti.linlive.fr/game?uid=$userId&stream=$streamId&embed=1',
      ),
      _LiveGameEntry(
        title: 'Greedy Baby',
        image: AssetsManager.greedyBabyIcon,
        url: 'https://greedybaby.linlive.fr/?id=$userId',
      ),
      _LiveGameEntry(
        title: 'Roulette',
        image: AssetsManager.rouletteIcon,
        url: 'https://roulettecasino.linlive.fr/',
        heightFactor: 0.70,
        closeButtonTop: 92.0,
        backgroundColor: const Color(0xFF07723A),
      ),
      _LiveGameEntry(
        title: 'Ferry Wheel',
        image: AssetsManager.ferryWheelIcon,
        url: 'https://ferrywheel.linlive.fr/?id=$userId',
        heightFactor: 0.68,
        closeButtonTop: 80.0,
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      _LiveGameEntry(
        title: 'Lucky 77',
        image: AssetsManager.lucky77Icon,
        url: 'https://lucky77.linlive.fr/game/$userId',
        heightFactor: 0.60,
        closeButtonTop: 90.0,
        backgroundColor: const Color(0xFF0F0C20),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      padding: context.paddingOnly(top: 20, start: 10, end: 10),
      itemCount: liveGames.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.80,
      ),
      itemBuilder: (context, index) {
        final entry = liveGames[index];
        return InkWell(
          onTap: () => showExternalGameBottomSheet(
            context: context,
            gameName: entry.title,
            url: entry.url,
            heightFactor: entry.heightFactor,
            closeButtonTop: entry.closeButtonTop,
            backgroundColor: entry.backgroundColor,
            replaceCurrentSheet: true,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry.image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(entry.image,
                      height: 72.h, width: 72.h, fit: BoxFit.contain),
                )
              else
                Container(
                  height: 72.h,
                  width: 72.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9A3C), Color(0xFFE8337A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text('🎮', style: TextStyle(fontSize: 36.sp)),
                ),
              6.hBox,
              TextWidget(
                entry.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodySmall.size(11).colorExt(ColorManager.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGamesGrid(List<GameDataEntity> games) {
    // No Expanded here -- this is now a direct TabBarView child (which
    // already hands it a bounded size), not a Column child.
    return GridView.builder(
      shrinkWrap: true,
      padding: context.paddingOnly(top: 20, start: 10, end: 10),
      itemCount: games.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.70,
      ),
      itemBuilder: (context, index) {
        final GameDataEntity game = games[index];
        final bool opening = _openingGameId == (game.id ?? 0);
        final bool blocked = _openingGameId != 0 && !opening;

        return IgnorePointer(
          ignoring: blocked || opening,
          child: InkWell(
            onTap: () => _openGameWithSameBaishunData(game),
            child: Stack(
              children: [
                Positioned.fill(
                  child: GamesViewItem(
                    img: (game.isStatic ?? false)
                        ? (game.image ?? '')
                        : EndPoints.getImage(game.image),
                    title: game.name ?? '',
                    isHot: game.isHot ?? 0,
                    isAsset: game.isStatic ?? false,
                  ),
                ),
                if (opening)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.28),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openGameWithSameBaishunData(GameDataEntity game) async {
    final int gameId = game.id ?? 0;
    if (gameId <= 0 || _openingGameId != 0) return;

    final String activeRoomId = widget.roomId.trim().isNotEmpty
        ? widget.roomId.trim()
        : '${RoomData.instance.room.id}';

    final String token = Methods.getUserToken().trim();
    if (token.isEmpty) {
      Methods.showToast(
        context,
        message: 'Login session not found. Please login again.',
        isError: true,
      );
      return;
    }

    // Capture root context before the game-list bottom sheet closes.
    final NavigatorState rootNavigator = Navigator.of(
      context,
      rootNavigator: true,
    );
    final BuildContext rootContext = rootNavigator.context;

    setState(() => _openingGameId = gameId);

    Methods.printLog(
      '🎮 LIVE GAME TAP => id=$gameId room=$activeRoomId '
          'source=current-list play=baishun-session',
    );

    // Keep the app's existing update-game call too. This is only the existing
    // tracking/open event; the actual H5 launch data comes from /baishun/sessions.
    di<OpenGameBloc>().add(OpenGameEvent(id: gameId));

    try {
      // The visible /all-games1 list uses its own local `id`. Baishun's
      // /baishun/sessions endpoint expects the merchant-enabled `game_id`
      // returned by /baishun/games. Resolve the selected visible game to that
      // exact Baishun record first, then create the session with its game_id.
      final Map<String, dynamic>? baishunGame =
      await _resolveBaishunGameForVisibleGame(
        game: game,
        token: token,
      );

      if (!mounted) return;

      if (baishunGame == null) {
        Methods.printLog(
          '❌ BAISHUN GAME MATCH FAILED => localId=$gameId name=${game.name}',
        );
        Methods.showToast(
          context,
          message: 'This game is not enabled for the game provider.',
          isError: true,
        );
        setState(() => _openingGameId = 0);
        return;
      }

      final int baishunGameId =
          int.tryParse(baishunGame['game_id']?.toString() ?? '') ?? 0;

      if (baishunGameId <= 0) {
        Methods.showToast(
          context,
          message: 'Game provider ID is missing.',
          isError: true,
        );
        setState(() => _openingGameId = 0);
        return;
      }

      Methods.printLog(
        '✅ BAISHUN GAME MATCH => localId=$gameId '
            'name=${game.name} baishunGameId=$baishunGameId',
      );

      final Map<String, dynamic>? session = await _createBaishunSession(
        gameId: baishunGameId,
        roomId: activeRoomId,
        token: token,
      );

      if (!mounted) return;

      if (session == null) {
        setState(() => _openingGameId = 0);
        return;
      }

      final String launchUrl =
          session['launch_url']?.toString().trim() ?? '';
      final Map<String, dynamic> getConfig = _asMap(session['get_config']);

      if (launchUrl.isEmpty || getConfig.isEmpty) {
        Methods.showToast(
          context,
          message: 'Game session data is incomplete.',
          isError: true,
        );
        setState(() => _openingGameId = 0);
        return;
      }

      Methods.printLog(
        '✅ BAISHUN SESSION READY => localId=$gameId providerId=$baishunGameId '
            'launch=$launchUrl configKeys=${getConfig.keys.toList()}',
      );

      // Close only the game-list sheet.
      final NavigatorState listNavigator = Navigator.of(context);
      if (listNavigator.canPop()) {
        listNavigator.pop();
      }

      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (!rootContext.mounted) return;

      ForegroundWidget.openGames.value = true;

      try {
        await _showSameBaishunHalfScreen(
          context: rootContext,
          launchUrl: launchUrl,
          getConfig: getConfig,
          gameName: game.name ?? 'Game',
        );
      } finally {
        ForegroundWidget.openGames.value = false;
      }
    } on DioException catch (e, s) {
      Methods.printLog('❌ BAISHUN SESSION DIO ERROR => $e\n$s');
      if (mounted) {
        Methods.showToast(
          context,
          message: _dioMessage(e),
          isError: true,
        );
      }
    } catch (e, s) {
      Methods.printLog('❌ BAISHUN SESSION ERROR => $e\n$s');
      if (mounted) {
        Methods.showToast(
          context,
          message: 'Failed to start the game. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _openingGameId = 0);
      }
    }
  }

  Future<Map<String, dynamic>?> _resolveBaishunGameForVisibleGame({
    required GameDataEntity game,
    required String token,
  }) async {
    List<Map<String, dynamic>> games =
        _baishunGamesCache ?? const <Map<String, dynamic>>[];

    if (games.isEmpty) {
      final Dio dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 25),
          sendTimeout: const Duration(seconds: 20),
          headers: const <String, dynamic>{
            'Accept': 'application/json',
          },
        ),
      );

      final String url = '${EndPoints.baseURL}/baishun/games';
      Methods.printLog('🎮 BAISHUN GAME MAP REQUEST => $url');

      final Response<dynamic> response = await dio.get<dynamic>(
        url,
        options: Options(
          headers: <String, dynamic>{
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final Map<String, dynamic> body = _asMap(response.data);
      if (body['success'] != true) {
        final String message = _firstNonEmpty(<dynamic>[
          body['message'],
          body['error'],
          'Unable to load provider games.',
        ]);
        throw Exception(message);
      }

      final List<dynamic> raw = body['data'] is List<dynamic>
          ? body['data'] as List<dynamic>
          : const <dynamic>[];

      games = raw
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) =>
      Map<String, dynamic>.from(item))
          .where((Map<String, dynamic> item) {
        final dynamic ready = item['ready'];
        return ready == true || ready?.toString() == '1';
      })
          .toList(growable: false);

      _baishunGamesCache = games;
      Methods.printLog(
        '✅ BAISHUN GAME MAP LOADED => count=${games.length}',
      );
    }

    if (games.isEmpty) return null;

    final String visibleName = _normalizeGameKey(game.name ?? '');
    final String visibleUrl = (game.url ?? '').trim().toLowerCase();

    Map<String, dynamic>? byName;
    for (final Map<String, dynamic> item in games) {
      final String providerName =
      _normalizeGameKey(item['name']?.toString() ?? '');
      if (visibleName.isNotEmpty && providerName == visibleName) {
        byName = item;
        break;
      }
    }
    if (byName != null) return byName;

    // Secondary URL/slug match for cases where the display name changed
    // slightly but both APIs still point to the same H5 package.
    final String visibleSlug = _gameUrlSlug(visibleUrl);
    if (visibleSlug.isNotEmpty) {
      for (final Map<String, dynamic> item in games) {
        final List<String> candidates = <String>[
          item['download_url']?.toString() ?? '',
          item['preview_url']?.toString() ?? '',
          item['launch_url']?.toString() ?? '',
        ];
        for (final String candidate in candidates) {
          if (_gameUrlSlug(candidate.toLowerCase()) == visibleSlug) {
            return item;
          }
        }
      }
    }

    // Conservative fuzzy fallback: only accept one unique containment match.
    final List<Map<String, dynamic>> fuzzy = games.where((item) {
      final String providerName =
      _normalizeGameKey(item['name']?.toString() ?? '');
      if (visibleName.isEmpty || providerName.isEmpty) return false;
      return providerName.contains(visibleName) ||
          visibleName.contains(providerName);
    }).toList(growable: false);

    return fuzzy.length == 1 ? fuzzy.first : null;
  }

  static String _normalizeGameKey(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static String _gameUrlSlug(String value) {
    if (value.trim().isEmpty) return '';
    final Uri? uri = Uri.tryParse(value.trim());
    if (uri == null) return '';
    final List<String> segments = uri.pathSegments;
    final int packageIndex = segments.indexOf('common-web');
    if (packageIndex >= 0 && packageIndex + 1 < segments.length) {
      return _normalizeGameKey(segments[packageIndex + 1]);
    }
    return '';
  }

  Future<Map<String, dynamic>?> _createBaishunSession({
    required int gameId,
    required String roomId,
    required String token,
  }) async {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 25),
        sendTimeout: const Duration(seconds: 20),
        headers: const <String, dynamic>{
          'Accept': 'application/json',
        },
      ),
    );

    final String url = '${EndPoints.baseURL}/baishun/sessions';

    Methods.printLog(
      '🎮 BAISHUN SESSION REQUEST => game=$gameId room=$roomId mode=2 url=$url',
    );

    final Response<dynamic> response = await dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        'game_id': gameId,
        'room_id': roomId,
        // Live-room player is a bottom-sheet player, so create the provider
        // session itself in Baishun showroom/half-screen mode.
        'game_mode': '2',
        'language': '2',
        'scene_mode': 0,
      },
      options: Options(
        headers: <String, dynamic>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    final Map<String, dynamic> body = _asMap(response.data);
    if (body['success'] != true) {
      final String message = _firstNonEmpty(<dynamic>[
        body['message'],
        body['error'],
        'Unable to start the game.',
      ]);
      throw Exception(message);
    }

    return _asMap(body['data']);
  }

  String _dioMessage(DioException error) {
    final Map<String, dynamic> body = _asMap(error.response?.data);
    final String server = _firstNonEmpty(<dynamic>[
      body['message'],
      body['error'],
    ]);
    if (server.isNotEmpty) return server;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'Connection timeout. Please try again.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please try again.';

      case DioExceptionType.badResponse:
        return error.response?.statusCode == 401
            ? 'Login expired. Please login again.'
            : 'Server error. Please try again.';

      case DioExceptionType.badCertificate:
        return 'Secure connection failed.';

      case DioExceptionType.cancel:
        return 'Request cancelled.';

      case DioExceptionType.unknown:
        return 'Failed to connect to the game server.';
    }
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map<dynamic, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final dynamic value in values) {
      final String text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}

// -----------------------------------------------------------------------------
// SAME bottom-sheet sizing contract as the original working Baishun V1 file.
// -----------------------------------------------------------------------------
double _calculateSameBaishunHalfScreenHeight(MediaQueryData mediaQuery) {
  final Size screenSize = mediaQuery.size;

  final double usableHeight = (screenSize.height -
      mediaQuery.padding.top -
      mediaQuery.padding.bottom)
      .clamp(0.0, screenSize.height)
      .toDouble();

  if (screenSize.width <= 0 || usableHeight <= 0) {
    return screenSize.height * 0.6;
  }

  final double desiredHeight = usableHeight * 0.56;
  final double widthBasedMaximum = screenSize.width * 1.45;
  final double screenBasedMaximum = usableHeight * 0.62;
  final double screenBasedMinimum = usableHeight * 0.44;

  double gameHeight = desiredHeight;

  if (gameHeight > widthBasedMaximum) {
    gameHeight = widthBasedMaximum;
  }
  if (gameHeight > screenBasedMaximum) {
    gameHeight = screenBasedMaximum;
  }
  if (gameHeight < screenBasedMinimum &&
      screenBasedMinimum <= widthBasedMaximum) {
    gameHeight = screenBasedMinimum;
  }

  if (usableHeight < 240.0) return usableHeight;

  gameHeight = gameHeight.clamp(240.0, usableHeight).toDouble();

  // Baishun half-screen mode requires height > width.
  final double minRequiredHeight = screenSize.width + 24.0;
  if (gameHeight <= screenSize.width) {
    gameHeight = minRequiredHeight.clamp(240.0, usableHeight).toDouble();
  }

  return gameHeight;
}

Future<void> _showSameBaishunHalfScreen({
  required BuildContext context,
  required String launchUrl,
  required Map<String, dynamic> getConfig,
  required String gameName,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      final MediaQueryData mediaQuery = MediaQuery.of(sheetContext);
      final double gameHeight =
      _calculateSameBaishunHalfScreenHeight(mediaQuery);
      final double bottomSafeArea = mediaQuery.padding.bottom;

      Methods.printLog(
        '🎮 BAISHUN HALF SCREEN => height=$gameHeight '
            'width=${mediaQuery.size.width}',
      );

      return Padding(
        padding: EdgeInsets.only(bottom: bottomSafeArea),
        child: SizedBox(
          width: double.infinity,
          height: gameHeight,
          child: _SameBaishunBottomGameWebView(
            launchUrl: launchUrl,
            getConfig: getConfig,
            gameName: gameName,
          ),
        ),
      );
    },
  );
}

class _SameBaishunBottomGameWebView extends StatefulWidget {
  const _SameBaishunBottomGameWebView({
    required this.launchUrl,
    required this.getConfig,
    required this.gameName,
  });

  final String launchUrl;
  final Map<String, dynamic> getConfig;
  final String gameName;

  @override
  State<_SameBaishunBottomGameWebView> createState() =>
      _SameBaishunBottomGameWebViewState();
}

class _SameBaishunBottomGameWebViewState
    extends State<_SameBaishunBottomGameWebView> {
  static const String _androidBridgeChannel = '_LinLiveBaishunBridge';

  late final WebViewController _webViewController;
  Timer? _loadTimeout;

  bool _isLoading = true;
  bool _isClosing = false;
  int _progress = 0;
  String? _errorText;

  // Chromium/CloudFront can occasionally reset the first TLS socket on some
  // Android/MIUI devices. Retry only the main-frame connection reset; do not
  // loop forever or hide real provider errors.
  static const int _maxConnectionResetRetries = 3;
  int _connectionResetRetryCount = 0;
  Timer? _connectionRetryTimer;

  @override
  void initState() {
    super.initState();
    _createWebView();
    _startLoadTimeout();
  }

  void _createWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..addJavaScriptChannel(
        _androidBridgeChannel,
        onMessageReceived: _handleAndroidBridgeMessage,
      )
      ..addJavaScriptChannel(
        'getConfig',
        onMessageReceived: (JavaScriptMessage message) {
          _handleBridgeMethod('getConfig', message.message);
        },
      )
      ..addJavaScriptChannel(
        'destroy',
        onMessageReceived: (JavaScriptMessage message) {
          _handleBridgeMethod('destroy', message.message);
        },
      )
      ..addJavaScriptChannel(
        'gameRecharge',
        onMessageReceived: (JavaScriptMessage message) {
          _handleBridgeMethod('gameRecharge', message.message);
        },
      )
      ..addJavaScriptChannel(
        'gameLoaded',
        onMessageReceived: (JavaScriptMessage message) {
          _handleBridgeMethod('gameLoaded', message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
          onPageStarted: (String url) {
            Methods.printLog(
              '🌍 BAISHUN PAGE STARTED => $url '
                  '(retry=$_connectionResetRetryCount)',
            );
            if (mounted) {
              setState(() {
                _isLoading = true;
                _errorText = null;
                _progress = 0;
              });
            }
            _injectNativeBridgeRepeatedly();
          },
          onPageFinished: (String url) {
            Methods.printLog('✅ BAISHUN PAGE FINISHED => $url');
            _injectNativeBridgeRepeatedly();
          },
          onWebResourceError: (WebResourceError error) {
            Methods.printLog(
              '🚨 BAISHUN WEB ERROR => ${error.errorCode} | '
                  '${error.errorType} | ${error.description}',
            );

            if (!mounted || error.isForMainFrame != true) return;

            final String description = error.description.toLowerCase();
            final bool isConnectionReset =
                error.errorCode == -6 ||
                    description.contains('err_connection_reset') ||
                    description.contains('connection reset');

            if (isConnectionReset &&
                _connectionResetRetryCount < _maxConnectionResetRetries) {
              _retryAfterConnectionReset();
              return;
            }

            _loadTimeout?.cancel();
            _connectionRetryTimer?.cancel();
            setState(() {
              _isLoading = false;
              _errorText = error.description.trim().isNotEmpty
                  ? error.description
                  : 'Failed to load game';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            Methods.printLog('➡️ BAISHUN NAVIGATION => ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.launchUrl));
  }

  void _retryAfterConnectionReset() {
    if (!mounted || _isClosing) return;

    _connectionRetryTimer?.cancel();
    _connectionResetRetryCount += 1;

    final int waitMs = switch (_connectionResetRetryCount) {
      1 => 500,
      2 => 1200,
      _ => 2200,
    };

    Methods.printLog(
      '🔄 BAISHUN CONNECTION RESET => auto retry '
          '$_connectionResetRetryCount/$_maxConnectionResetRetries '
          'after ${waitMs}ms',
    );

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorText = null;
        _progress = 0;
      });
    }

    _connectionRetryTimer = Timer(Duration(milliseconds: waitMs), () async {
      if (!mounted || _isClosing) return;

      try {
        // Stop the failed main-frame load before creating a fresh request.
        await _webViewController.runJavaScript('window.stop();');
      } catch (_) {}

      if (!mounted || _isClosing) return;

      try {
        final Uri original = Uri.parse(widget.launchUrl);
        final Map<String, String> query = <String, String>{
          ...original.queryParameters,
          '_lin_retry': '$_connectionResetRetryCount',
        };
        final Uri retryUri = original.replace(queryParameters: query);

        Methods.printLog('🚀 BAISHUN RETRY LOAD => $retryUri');
        _startLoadTimeout();
        await _webViewController.loadRequest(retryUri);
      } catch (e, st) {
        Methods.printLog('❌ BAISHUN RETRY LOAD FAILED => $e\n$st');
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorText = 'Failed to connect to the game server.';
        });
      }
    });
  }

  void _startLoadTimeout() {
    _loadTimeout?.cancel();
    _loadTimeout = Timer(const Duration(seconds: 45), () {
      if (!mounted || !_isLoading) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Game loading timed out. Please reload.';
      });
    });
  }

  Future<void> _injectNativeBridgeRepeatedly() async {
    const List<Duration> delays = <Duration>[
      Duration.zero,
      Duration(milliseconds: 25),
      Duration(milliseconds: 100),
      Duration(milliseconds: 300),
      Duration(milliseconds: 700),
      Duration(milliseconds: 1400),
    ];

    for (final Duration delay in delays) {
      if (delay != Duration.zero) {
        await Future<void>.delayed(delay);
      }
      if (!mounted || _isClosing) return;
      await _injectNativeBridge();
    }
  }

  Future<void> _injectNativeBridge() async {
    const String script = r'''
(function () {
  try {
    if (window.NativeBridge && window.NativeBridge.__linLiveBaishunBridge === true) {
      return;
    }

    const sendToFlutter = function (method, payload) {
      const normalizedPayload = typeof payload === 'string'
        ? payload
        : JSON.stringify(payload || {});

      window._LinLiveBaishunBridge.postMessage(JSON.stringify({
        method: method,
        payload: normalizedPayload
      }));
    };

    const bridge = window.NativeBridge || {};
    bridge.__linLiveBaishunBridge = true;
    bridge.getConfig = function (payload) {
      sendToFlutter('getConfig', payload);
    };
    bridge.destroy = function (payload) {
      sendToFlutter('destroy', payload);
    };
    bridge.gameRecharge = function (payload) {
      sendToFlutter('gameRecharge', payload);
    };
    bridge.gameLoaded = function (payload) {
      sendToFlutter('gameLoaded', payload);
    };

    window.NativeBridge = bridge;
    window.__LIN_LIVE_BAISHUN_BRIDGE_READY__ = true;
  } catch (error) {
    console.error('NativeBridge injection failed', error);
  }
})();
''';

    try {
      await _webViewController.runJavaScript(script);
    } catch (e) {
      Methods.printLog('⚠️ BAISHUN BRIDGE INJECT ERROR => $e');
    }
  }

  void _handleAndroidBridgeMessage(JavaScriptMessage message) {
    try {
      final dynamic decoded = jsonDecode(message.message);
      if (decoded is! Map<dynamic, dynamic>) return;

      final Map<String, dynamic> payload =
      Map<String, dynamic>.from(decoded);
      final String method = payload['method']?.toString().trim() ?? '';
      final String rawPayload = payload['payload']?.toString() ?? '{}';

      _handleBridgeMethod(method, rawPayload);
    } catch (e, s) {
      Methods.printLog('❌ BAISHUN BRIDGE MESSAGE ERROR => $e\n$s');
    }
  }

  Future<void> _handleBridgeMethod(String method, String rawPayload) async {
    Methods.printLog('🎮 BAISHUN BRIDGE => $method | $rawPayload');

    switch (method) {
      case 'getConfig':
        await _sendConfigToGame(rawPayload);
        break;
      case 'gameLoaded':
        _loadTimeout?.cancel();
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorText = null;
          _progress = 100;
        });
        break;
      case 'gameRecharge':
        if (mounted) {
          Methods.showToast(
            context,
            message: 'Your balance is insufficient. Please recharge.',
            isError: true,
          );
        }
        break;
      case 'destroy':
        await _closeGame();
        break;
      default:
        Methods.printLog('⚠️ BAISHUN UNKNOWN BRIDGE METHOD => $method');
    }
  }

  Future<void> _sendConfigToGame(String rawPayload) async {
    final Map<String, dynamic> request = _decodePayload(rawPayload);
    final String callback = request['jsCallback']?.toString().trim() ?? '';

    if (callback.isEmpty) {
      Methods.printLog('⚠️ BAISHUN getConfig callback is empty');
      return;
    }

    final RegExp safeCallback = RegExp(
      r'^[A-Za-z_$][A-Za-z0-9_$]*(\.[A-Za-z_$][A-Za-z0-9_$]*)*$',
    );

    if (!safeCallback.hasMatch(callback)) {
      Methods.printLog('⚠️ BAISHUN unsafe callback rejected => $callback');
      return;
    }

    final Map<String, dynamic> safeConfig =
    Map<String, dynamic>.from(widget.getConfig);

    // SAME as V1 bottom-sheet mode.
    safeConfig['gameMode'] = '2';

    final String configJson = jsonEncode(safeConfig);
    final String javascript = '''
try {
  $callback($configJson);
} catch (error) {
  console.error('getConfig callback failed', error);
}
''';

    try {
      await _webViewController.runJavaScript(javascript);
      Methods.printLog(
        '✅ BAISHUN CONFIG SENT => mode=2 configKeys=${safeConfig.keys.toList()}',
      );
    } catch (e, s) {
      Methods.printLog('❌ BAISHUN CONFIG SEND ERROR => $e\n$s');
    }
  }

  Map<String, dynamic> _decodePayload(String rawPayload) {
    dynamic value = rawPayload;

    for (int i = 0; i < 2; i++) {
      if (value is String) {
        final String text = value.trim();
        if (text.isEmpty) return <String, dynamic>{};
        try {
          value = jsonDecode(text);
          continue;
        } catch (_) {
          return <String, dynamic>{};
        }
      }
      break;
    }

    if (value is Map<String, dynamic>) return value;
    if (value is Map<dynamic, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  Future<void> _reloadGame() async {
    if (!mounted || _isClosing) return;

    _connectionRetryTimer?.cancel();
    _connectionResetRetryCount = 0;

    setState(() {
      _isLoading = true;
      _errorText = null;
      _progress = 0;
    });

    _startLoadTimeout();
    await _webViewController.loadRequest(Uri.parse(widget.launchUrl));
  }

  Future<void> _closeGame() async {
    if (_isClosing) return;
    _isClosing = true;
    _loadTimeout?.cancel();
    _connectionRetryTimer?.cancel();

    try {
      await _webViewController.runJavaScript('window.stop();');
    } catch (_) {}

    try {
      await _webViewController.loadRequest(Uri.parse('about:blank'));
    } catch (_) {}

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop<void>();
    }
  }

  @override
  void dispose() {
    _loadTimeout?.cancel();
    _connectionRetryTimer?.cancel();
    _isClosing = true;
    _webViewController.loadRequest(Uri.parse('about:blank'));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _closeGame();
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        child: ColoredBox(
          color: Colors.white,
          child: Stack(
            children: [
              Positioned.fill(
                child: WebViewWidget(controller: _webViewController),
              ),
              if (_isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 34,
                            height: 34,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.gameName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Loading game... $_progress%',
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_errorText != null)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.redAccent,
                              size: 44,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _errorText!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: _closeGame,
                                  child: const Text('Close'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _reloadGame,
                                  child: const Text('Reload'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveGameEntry {
  final String title;
  final String image;
  final String url;
  final double heightFactor;
  final double closeButtonTop;
  final Color backgroundColor;

  const _LiveGameEntry({
    required this.title,
    required this.image,
    required this.url,
    this.heightFactor = 0.80,
    this.closeButtonTop = 64.0,
    this.backgroundColor = Colors.black,
  });
}

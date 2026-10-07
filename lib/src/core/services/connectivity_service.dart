import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/music/bloc/music_room_bloc.dart';

class ConnectivityService {
  // Singleton instance
  ConnectivityService._internal();
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  late final Connectivity _connectivity = Connectivity();

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Stream<bool> get connectionStream => _connectionController.stream;

  bool isConnected = true;

  /// Track previous state so we only emit on actual changes.
  bool _previousConnected = true;

  /// Debounce timer to avoid rapid state oscillation.
  Timer? _debounceTimer;

  Future<void> init() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _applyConnectionStatus(result);
    } on PlatformException {
      _applyConnectionStatus([ConnectivityResult.none]);
    }

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  /// Debounce connectivity changes by 500ms to avoid rapid oscillation.
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _applyConnectionStatus(result);
    });
  }

  /// Apply the connectivity result, only emitting when the state changes.
  void _applyConnectionStatus(List<ConnectivityResult> result) {
    final newConnected = !result.contains(ConnectivityResult.none);
    if (newConnected == _previousConnected) return;

    _previousConnected = newConnected;
    isConnected = newConnected;
    _connectionController.add(isConnected);
    HomePage.isConnectToInternet = isConnected;

    if (!isConnected) {
      if (di<MusicRoomBloc>().state.isSongPlaying) {
        try {
          di<MusicRoomBloc>().state.audioPlayer.pause();
        } catch (_) {}
        di<MusicRoomBloc>().add(const ControlPlayingMusicRoomEvent());
      }
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    if (!_connectionController.isClosed) {
      _connectionController.close();
    }
  }
}

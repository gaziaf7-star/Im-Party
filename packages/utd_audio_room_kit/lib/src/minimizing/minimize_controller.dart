import 'dart:developer';

import 'package:flutter/material.dart';

import '../controller/utd_room_controller.dart';
import '../models/minimize_config.dart';
import 'mini_overlay_data.dart';
import 'mini_overlay_machine.dart';

class UTDMinimizeController {
  final UTDRoomController _controller;

  UTDMinimizeController(this._controller);

  UTDMiniOverlayMachine get _machine => UTDMiniOverlayMachine.instance;

  bool get isMinimizing => _machine.isMinimizing;

  ValueNotifier<UTDMiniOverlayState> get stateNotifier =>
      _machine.stateNotifier;

  UTDMinimizeConfig? _config;
  UTDMinimizeConfig? get config => _config;

  void configure(UTDMinimizeConfig config) {
    _config = config;
  }

  UTDMinimizeData? _data;
  UTDMinimizeData? get data => _data;

  NavigatorState? _navigator;

  /// [routeNameOverride]: when the caller's context isn't actually inside the
  /// room screen's own route (e.g. a dialog/side-panel shown ON TOP of the
  /// room, like the exit panel), `ModalRoute.of(context)` resolves to that
  /// dialog's OWN route instead — which is usually unnamed, so `routeName`
  /// came back null and restore-after-minimize silently did nothing. A
  /// caller that knows the room's real route name (it pushed it) can pass it
  /// here directly instead of relying on the ambient ModalRoute lookup.
  void captureNavigation(
    BuildContext context, {
    String? routeNameOverride,
    Object? routeArgumentsOverride,
  }) {
    _navigator = Navigator.of(context);
    final route = ModalRoute.of(context);
    _data = UTDMinimizeData(
      controller: _controller,
      routeName: routeNameOverride ?? route?.settings.name,
      routeArguments: routeArgumentsOverride ?? route?.settings.arguments,
    );
  }

  bool startMinimize(
    BuildContext context, {
    String? routeNameOverride,
    Object? routeArgumentsOverride,
  }) {
    if (isMinimizing) return false;
    if (!_controller.isConnected) return false;

    captureNavigation(
      context,
      routeNameOverride: routeNameOverride,
      routeArgumentsOverride: routeArgumentsOverride,
    );
    log('[UTDMinimizeController] startMinimize — captured routeName='
        '${_data?.routeName}, navigator=$_navigator',
        name: 'minimize');
    _machine.changeState(UTDMiniOverlayState.minimizing);
    Navigator.of(context).pop();
    return true;
  }

  bool restore(BuildContext context) {
    if (!isMinimizing || _data == null) return false;

    _machine.changeState(UTDMiniOverlayState.inAudioRoom);

    final name = _data!.routeName;
    final args = _data!.routeArguments;
    if (name == null) return false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(name, arguments: args);
    });
    return true;
  }

  bool restoreWithNavigator() {
    log('[UTDMinimizeController] restoreWithNavigator — isMinimizing=$isMinimizing, '
        'data=$_data, navigator=$_navigator, navigatorMounted=${_navigator?.mounted}',
        name: 'minimize');
    if (!isMinimizing || _data == null || _navigator == null) {
      log('[UTDMinimizeController] restoreWithNavigator ABORTED — missing state',
          name: 'minimize');
      return false;
    }

    _machine.changeState(UTDMiniOverlayState.inAudioRoom);

    final nav = _navigator!;
    final name = _data!.routeName;
    final args = _data!.routeArguments;
    if (name == null) {
      log('[UTDMinimizeController] restoreWithNavigator ABORTED — routeName is null',
          name: 'minimize');
      return false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      log('[UTDMinimizeController] restoreWithNavigator — pushNamed($name), '
          'navigatorMounted=${nav.mounted}',
          name: 'minimize');
      nav.pushNamed(name, arguments: args);
    });
    return true;
  }

  Future<void> close() async {
    await _controller.leave();
    _machine.changeState(UTDMiniOverlayState.idle);
    _config?.onClose?.call();
    _data = null;
    _navigator = null;
  }

  /// Dismiss the overlay without triggering onClose or leaving the room.
  /// Used internally when the package auto-cleans a previous room.
  void dismiss() {
    _machine.changeState(UTDMiniOverlayState.idle);
    _data = null;
    _navigator = null;
  }
}

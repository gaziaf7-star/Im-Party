import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class VapView extends StatelessWidget {
  final int scaleType;
  final int? fps;
  final int? playLoop;
  final int contentMode;
  final ValueChanged<VapViewController>? onVapViewCreated;

  const VapView({
    Key? key,
    this.scaleType = 1,
    this.fps,
    this.playLoop,
    this.contentMode = 1,
    this.onVapViewCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> creationParams = <String, dynamic>{
      'scaleType': scaleType,
      if (fps != null) 'fps': fps,
      if (playLoop != null) 'playLoop': playLoop,
      'contentMode': contentMode,
    };
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: "flutter_vap",
        onPlatformViewCreated: _onPlatformViewCreated,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: StandardMessageCodec(),
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: "flutter_vap",
        onPlatformViewCreated: _onPlatformViewCreated,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: StandardMessageCodec(),
      );
    }
    return Container();
  }

  void _onPlatformViewCreated(int id) {
    if (onVapViewCreated == null) {
      return;
    }
    final MethodChannel channel = MethodChannel('flutter_vap_view_$id');
    onVapViewCreated?.call(VapViewController._(channel));
  }
}

class VapViewController {
  final MethodChannel _channel;

  VapViewController._(this._channel);

  /// return: play error:       {"status": "failure", "errorMsg": ""}
  ///         play complete:    {"status": "complete"}
  Future<Map<dynamic, dynamic>> playPath(String path) async {
    return await _channel.invokeMethod('playPath', {"path": path});
  }

  Future<Map<dynamic, dynamic>> playAsset(String asset) async {
    return await _channel.invokeMethod('playAsset', {"asset": asset});
  }

  void stop() {
    _channel.invokeMethod('stop');
  }
}

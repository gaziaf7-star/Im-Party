import 'package:livekit_client/livekit_client.dart';

/// Video publish quality for the local camera (host and guests).
///
/// Selects the capture resolution AND the publish encoding (max bitrate /
/// framerate) applied to every local camera track: the host self-preview →
/// Go Live path, `setCameraEnabled(true)`, guest go-live, and the SDK's
/// reconnect re-publish.
///
/// Set it via [UTDLiveRoomConfig.videoQuality] (or
/// [UTDRoomController.setVideoQuality] BEFORE `connect`). The default is
/// [hd] (720p).
enum UTDVideoQuality {
  /// 360p (640×360) — ~450 kbps, 20 fps. Minimal upload for very poor networks.
  low,

  /// 540p (960×540) — ~800 kbps, 25 fps. Balanced quality/bandwidth.
  sd,

  /// 720p HD (1280×720) — ~1.7 Mbps, 30 fps. The default.
  hd,

  /// 1080p Full HD (1920×1080) — ~3 Mbps, 30 fps. Highest quality; needs a
  /// strong uplink and increases battery/heat on the publisher's device.
  fullHd,
}

extension UTDVideoQualityParams on UTDVideoQuality {
  /// The LiveKit capture/encoding preset (16:9) for this quality tier.
  VideoParameters get parameters => switch (this) {
        UTDVideoQuality.low => VideoParametersPresets.h360_169,
        UTDVideoQuality.sd => VideoParametersPresets.h540_169,
        UTDVideoQuality.hd => VideoParametersPresets.h720_169,
        UTDVideoQuality.fullHd => VideoParametersPresets.h1080_169,
      };

  /// Simulcast layers published UNDER the primary encoding, so the SFU can
  /// serve low-bandwidth viewers without degrading the primary layer.
  /// Mirrors LiveKit's own 16:9 defaults ([h180 + h360]); [low] drops the
  /// h360 layer because it would duplicate the primary encoding.
  List<VideoParameters> get simulcastLayers => switch (this) {
        UTDVideoQuality.low => [VideoParametersPresets.h180_169],
        _ => [
            VideoParametersPresets.h180_169,
            VideoParametersPresets.h360_169,
          ],
      };
}

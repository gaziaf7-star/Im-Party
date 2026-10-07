/// UTD Audio Room Kit constants.
class UTDConstants {
  UTDConstants._();

  /// Message batch interval in milliseconds (60fps).
  static const int messageBatchIntervalMs = 16;

  /// Default room options.
  static const bool defaultAdaptiveStream = true;
  static const bool defaultDynacast = true;

  /// Connection retry settings.
  static const int maxConnectRetries = 2;
  static const Duration retryDelay = Duration(milliseconds: 500);

  /// Data channel reliability.
  static const bool reliableDataChannel = true;
}

import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/media_auto_download_prefs.dart';

/// WhatsApp-style media auto-download settings.
///
/// Two layers:
///   - Auto/manual switch: when off, media never downloads automatically — the
///     user must tap to download (saves data + battery, mirrors WhatsApp).
///   - Network policy (only relevant when auto is on): always / Wi-Fi only /
///     network only — lets the user spare their data plan.
///
/// Settings persist in SharedPreferences (Hive equivalent) under the keys in
/// [MediaAutoDownloadPrefs]. The download path consults [MediaAutoDownloadPrefs.shouldAutoDownload]
/// at runtime, so flipping a switch takes effect instantly without restart.
class MediaSettingsScreen extends StatefulWidget {
  const MediaSettingsScreen({super.key});

  @override
  State<MediaSettingsScreen> createState() => _MediaSettingsScreenState();
}

class _MediaSettingsScreenState extends State<MediaSettingsScreen> {
  bool _autoDownload = true;
  MediaNetworkPolicy _policy = MediaNetworkPolicy.always;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _autoDownload = MediaAutoDownloadPrefs.isAutoDownloadEnabled();
    _policy = MediaAutoDownloadPrefs.networkPolicy();
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _setAuto(bool v) async {
    setState(() => _autoDownload = v);
    await MediaAutoDownloadPrefs.setAutoDownloadEnabled(v);
  }

  Future<void> _setPolicy(MediaNetworkPolicy p) async {
    setState(() => _policy = p);
    await MediaAutoDownloadPrefs.setNetworkPolicy(p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fixed white + brand-gradient app bar (was the panel-driven
      // scaffoldBg/flat app bar) — matches the professional look used
      // across the app.
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        title: StringManager.mediaSettings.tr(),
        backgroundGradient: ColorManager.brandGradient,
        titleStyle: context.titleLarge.w600
            .size(16)
            .colorExt(ColorManager.onBrandGradient),
        iconColor: ColorManager.onBrandGradient,
      ),
      body: !_loaded
          ? const Center(child: LoadingWidget())
          : ListView(
        padding: context.paddingSymmetric(vertical: 12),
        children: [
          _sectionHeader(StringManager.autoDownload.tr()),
          _switchTile(
            title: StringManager.autoSaveMediaToDevice.tr(),
            subtitle: _autoDownload
                ? StringManager.autoSaveMediaOn.tr()
                : StringManager.autoSaveMediaOff.tr(),
            value: _autoDownload,
            onChanged: _setAuto,
          ),
          if (_autoDownload) ...[
            16.hBox,
            _sectionHeader(StringManager.whenToAutoDownload.tr()),
            _radioTile(
              title: StringManager.autoDownloadAlways.tr(),
              subtitle: StringManager.autoDownloadAlwaysHint.tr(),
              value: MediaNetworkPolicy.always,
            ),
            _radioTile(
              title: StringManager.autoDownloadWifiOnly.tr(),
              subtitle: StringManager.autoDownloadWifiOnlyHint.tr(),
              value: MediaNetworkPolicy.wifiOnly,
            ),
            _radioTile(
              title: StringManager.autoDownloadMobileOnly.tr(),
              subtitle: StringManager.autoDownloadMobileOnlyHint.tr(),
              value: MediaNetworkPolicy.mobileOnly,
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: context.paddingOnly(start: 16, end: 16, top: 8, bottom: 6),
      child: TextWidget(
        text,
        isTranslate: false,
        style: context.bodyMedium.w600
            .colorExt(ColorManager.momentPostTextColor),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: context.paddingSymmetric(horizontal: 12, vertical: 4),
      padding: context.paddingSymmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: ColorManager.momentPostTextColor.withValues(alpha: 0.05),
        borderRadius: 12.radius,
      ),
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        // Brand gradient accent colour (was the flat panel-driven primary).
        activeColor: ColorManager.brandGradientColors.last,
        title: TextWidget(
          title,
          isTranslate: false,
          style: context.bodyLarge.w500
              .colorExt(ColorManager.momentPostTextColor),
        ),
        subtitle: TextWidget(
          subtitle,
          isTranslate: false,
          style: context.bodySmall.colorExt(
              ColorManager.momentPostTextColor.withValues(alpha: 0.6)),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _radioTile({
    required String title,
    required String subtitle,
    required MediaNetworkPolicy value,
  }) {
    final selected = _policy == value;
    return InkWell(
      onTap: () => _setPolicy(value),
      child: Container(
        margin: context.paddingSymmetric(horizontal: 12, vertical: 4),
        padding: context.paddingSymmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Brand gradient accent colour (was the flat panel-driven primary).
          color: selected
              ? ColorManager.brandGradientColors.last.withValues(alpha: 0.10)
              : ColorManager.momentPostTextColor.withValues(alpha: 0.04),
          borderRadius: 12.radius,
          border: Border.all(
            color: selected
                ? ColorManager.brandGradientColors.last
                : ColorManager.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? ColorManager.brandGradientColors.last
                  : ColorManager.momentPostTextColor.withValues(alpha: 0.6),
              size: 22.h,
            ),
            12.wBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    title,
                    isTranslate: false,
                    style: context.bodyLarge
                        .w500
                        .colorExt(ColorManager.momentPostTextColor),
                  ),
                  TextWidget(
                    subtitle,
                    isTranslate: false,
                    style: context.bodySmall.colorExt(
                      ColorManager.momentPostTextColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
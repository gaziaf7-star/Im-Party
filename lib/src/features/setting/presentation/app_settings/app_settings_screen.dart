import 'package:general/src/core/index.dart';
import 'package:general/src/core/utils/mic_background_helper.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late bool _muteMicInBackground;

  @override
  void initState() {
    super.initState();
    _muteMicInBackground = MicBackgroundHelper.shouldMuteMicInBackground;
  }

  Future<void> _onMuteMicChanged(bool value) async {
    setState(() {
      _muteMicInBackground = value;
    });
    await MicBackgroundHelper.setMuteMicInBackground(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        backgroundColor: ColorManager.white,
        iconColor: ColorManager.black,
        titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
        title: StringManager.appSettings.tr(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.hBox,
          Container(
            width: ScreenUtil().screenWidth,
            margin: context.paddingSymmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: 14.radius,
              border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: context.paddingSymmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        StringManager.muteMicInBackground.tr(),
                        style: context.bodyMedium
                            .size(15)
                            .w500
                            .colorExt(ColorManager.black),
                      ),
                      6.hBox,
                      TextWidget(
                        StringManager.muteMicInBackgroundDescription.tr(),
                        style: context.bodySmall
                            .size(12)
                            .w400
                            .colorExt(ColorManager.black.withValues(alpha: 0.6)),
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
                16.wBox,
                Switch(
                  value: _muteMicInBackground,
                  onChanged: _onMuteMicChanged,
                  activeThumbColor: ColorManager.primary,
                  activeTrackColor: ColorManager.primary.withValues(alpha: 0.5),
                  inactiveThumbColor: ColorManager.grey,
                  inactiveTrackColor: ColorManager.grey.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
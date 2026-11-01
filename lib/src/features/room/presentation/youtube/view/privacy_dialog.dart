import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/room.dart';

import 'youtube_search_dialog.dart';

/// YouTube logo used across the cinema-mode UI.
const String kYoutubeLogo = 'assets/icons/ui_icons/youtube (1).png';

/// Accept-the-terms dialog shown before cinema mode / the YouTube picker.
/// Clean white card, black text, a clearly visible checkbox, and a warning if
/// the user presses OK without ticking it.
class PrivacyDialog extends StatefulWidget {
  final String roomId;
  final bool? isFromCinema;
  const PrivacyDialog({
    super.key,
    required this.roomId,
    this.isFromCinema,
  });

  @override
  State<PrivacyDialog> createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends State<PrivacyDialog> {
  static const Color _ink = Color(0xFF16161A);
  static const Color _muted = Color(0xFF6B6C74);
  static const Color _red = Color(0xFFFF0033);

  late bool _accepted;

  bool get _acceptedBefore =>
      HiveManager().getData<bool>(
          KeysManager.USER_BOX, KeysManager.ACCEPT_YOUTUBE_TERMS_KEY) ==
      true;

  @override
  void initState() {
    super.initState();
    _accepted = _acceptedBefore;
  }

  void _warnNotAccepted() {
    Methods.showToast(
      context,
      isError: true,
      message: 'Please tick the box to accept the YouTube terms first',
    );
  }

  void _openPicker() {
    context.popRoute();
    bottomDailog(
      context: context,
      widget: YoutubeAPISearchDialog(roomData: RoomData.instance.room),
    );
  }

  Future<void> _onOk() async {
    if (!_accepted) {
      _warnNotAccepted();
      return;
    }
    if (!_acceptedBefore) {
      await HiveManager().saveData<bool>(
        KeysManager.USER_BOX,
        KeysManager.ACCEPT_YOUTUBE_TERMS_KEY,
        true,
      );
    }
    if (!mounted) return;
    RoomData.instance.runningCinemaMode = true;

    if (widget.isFromCinema == true) {
      _openPicker();
      return;
    }

    if (PKWidget.isStartPK.value) {
      Methods.showToast(context,
          isError: true, message: StringManager.cantOpenCinemaMode.tr());
      return;
    }
    Future.delayed(const Duration(milliseconds: 50), () {
      final controller = RoomData.instance.utdController;
      final mode = controller?.resolveMode('5');
      controller?.seatController.setupSeats(
        identity: MyDataModel.getInstance().id.toString(),
        seatCount: mode?.seatCount ?? 9,
        seatMode: controller.seatController.seatMode.value,
        modeId: '5',
      );
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.07,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Image.asset(kYoutubeLogo, fit: BoxFit.contain),
            ),
            14.hBox,
            Text(
              'Watch YouTube together',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ink,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            8.hBox,
            Text(
              StringManager.cinemaModeHint.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 13.sp, height: 1.4),
            ),
            16.hBox,
            // Whole row toggles the box; the link opens the terms.
            InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () => setState(() => _accepted = !_accepted),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _accepted
                        ? _red.withValues(alpha: 0.5)
                        : const Color(0xFFE3E4E8),
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _accepted,
                      onChanged: (v) => setState(() => _accepted = v ?? false),
                      activeColor: _red,
                      checkColor: Colors.white,
                      side: const BorderSide(color: _ink, width: 1.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    4.wBox,
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Methods.safeLaunchUrl(
                            'https://www.youtube.com/t/terms'),
                        child: Text(
                          StringManager.cinemaModeHint2.tr(),
                          style: TextStyle(
                            color: const Color(0xFF1A73E8),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF1A73E8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            20.hBox,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(46.h),
                      side: const BorderSide(color: Color(0xFFD9DAE0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23.r),
                      ),
                    ),
                    child: Text(
                      StringManager.cancel.tr(),
                      style: TextStyle(
                        color: _ink,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                12.wBox,
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onOk,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(46.h),
                      elevation: 0,
                      // Dimmed until the box is ticked, but still tappable so
                      // it can show the warning.
                      backgroundColor:
                          _accepted ? _red : _red.withValues(alpha: 0.45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23.r),
                      ),
                    ),
                    child: Text(
                      StringManager.ok.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

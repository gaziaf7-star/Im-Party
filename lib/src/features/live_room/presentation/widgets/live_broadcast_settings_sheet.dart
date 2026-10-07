import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/body_theme_background.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/room/room.dart';

/// Host-only broadcast settings (إعدادات البث), opened from the live room's
/// (...) more-sheet: edit the broadcast NAME, the intro (المقدمة) and the
/// broadcast's own COVER image mid-stream. Saves through the same
/// `rooms/{owner}/edit` call the pre-live composer uses, updates the local
/// room model, and broadcasts `live_meta_updated` so every current viewer's
/// header/details refresh instantly.
class LiveBroadcastSettingsSheet {
  static Future<void> show(BuildContext context) {
    final room = LiveRoomData.instance.roomOrNull;
    if (room == null) return Future.value();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BroadcastSettingsBody(room: room),
    );
  }
}

class _BroadcastSettingsBody extends StatefulWidget {
  final EnterRoomModel room;
  const _BroadcastSettingsBody({required this.room});

  @override
  State<_BroadcastSettingsBody> createState() => _BroadcastSettingsBodyState();
}

class _BroadcastSettingsBodyState extends State<_BroadcastSettingsBody> {
  late final TextEditingController _name =
      TextEditingController(text: widget.room.roomName ?? '');
  late final TextEditingController _intro =
      TextEditingController(text: widget.room.roomIntro ?? '');
  File? _pickedCover;
  bool _saving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _name.dispose();
    _intro.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final file = await Methods.pickImageSafely(
      _picker,
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() => _pickedCover = File(file.path));
  }

  Future<void> _save() async {
    if (_saving) return;
    final room = widget.room;
    final name = _name.text.trim();
    final intro = _intro.text.trim();
    final nameChanged =
        name.isNotEmpty && name != (room.roomName ?? '').trim();
    final introChanged = intro != (room.roomIntro ?? '').trim();
    if (!nameChanged && !introChanged && _pickedCover == null) {
      Navigator.pop(context);
      return;
    }
    setState(() => _saving = true);
    final result = await di<UpdateRoomUC>().call(
      ParameterUpdate(
        ownerId: room.ownerId?.toString() ?? '',
        roomId: room.id.toString(),
        roomName: nameChanged ? name : null,
        roomIntro: introChanged ? intro : null,
        roomCover: _pickedCover,
        roomVideoType: 'live',
      ),
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _saving = false);
        Methods.showToast(
          context,
          isError: true,
          message: NetworkExceptions.getErrorMessage(failure),
        );
      },
      (success) {
        // The edit response carries the saved room (incl. the uploaded
        // cover's storage path) — apply it locally so the header/details
        // reflect the change without re-entering.
        final updated = success.data;
        final newCover = updated?.roomCover;
        room.copyWith(
          roomName: nameChanged ? name : null,
          roomIntro: introChanged ? intro : null,
          roomCover:
              (newCover != null && newCover.isNotEmpty) ? newCover : null,
        );
        if (nameChanged) {
          // Keep the pre-live composer's prefill in sync with the rename.
          HiveManager().saveData(
              KeysManager.ROOMS_BOX, KeysManager.LAST_LIVE_TITLE_KEY, name);
        }
        // Tell everyone currently watching (handled in the gift message
        // handler as `live_meta_updated`), and poke the local header rebuild.
        LiveRoomData.instance.sendLiveRoomData(data: {
          'message': 'live_meta_updated',
          'n': room.roomName ?? '',
          'i': room.roomIntro ?? '',
          'c': room.roomCover ?? '',
        });
        LiveRoomData.instance.liveController?.refreshParticipants();
        Methods.showToast(context, message: StringManager.success.tr());
        Navigator.pop(context);
      },
    );
  }

  Widget _coverThumb() {
    final saved = widget.room.roomCover ?? '';
    Widget child;
    if (_pickedCover != null) {
      child = Image.file(_pickedCover!,
          width: 64.r, height: 64.r, fit: BoxFit.cover);
    } else if (saved.isNotEmpty) {
      child = ImageViewWidget(
        url: EndPoints.getImage(saved),
        width: 64.r,
        height: 64.r,
        boxFit: BoxFit.cover,
        displayName: _name.text,
      );
    } else {
      child = Container(
        width: 64.r,
        height: 64.r,
        color: ColorManager.secondaryText.withValues(alpha: 0.12),
        child: Icon(Icons.camera_alt,
            color: ColorManager.secondaryText, size: 24.sp),
      );
    }
    return GestureDetector(
      onTap: _pickCover,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12.r), child: child),
          PositionedDirectional(
            bottom: -4,
            end: -4,
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: ColorManager.primary,
                shape: BoxShape.circle,
                border: Border.all(color: ColorManager.onDark, width: 1),
              ),
              child: Icon(Icons.edit, color: ColorManager.onDark, size: 11.sp),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: context.bodySmall.colorExt(ColorManager.secondaryText),
        counterStyle: context.bodySmall.colorExt(ColorManager.secondaryText),
        filled: true,
        fillColor: ColorManager.secondaryText.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Keep the sheet above the keyboard while editing.
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      // Follows the app body theme (color/gradient/image) like the home, via the
      // clipped Stack pattern; text uses adaptive tokens so it stays readable.
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: BodyThemeBackground()),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ColorManager.secondaryText.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  14.hBox,
                  Text(
                    StringManager.streamSettings.tr(),
                    style:
                        context.bodyLarge.w700.colorExt(ColorManager.textPrimary),
                  ),
                  18.hBox,
                  Row(
                    children: [
                      _coverThumb(),
                      14.wBox,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(StringManager.streamNameLabel.tr(),
                                style: context.bodySmall
                                    .colorExt(ColorManager.secondaryText)),
                            6.hBox,
                            TextField(
                              controller: _name,
                              maxLength: 60,
                              style: context.bodyMedium.w600
                                  .colorExt(ColorManager.textPrimary),
                              decoration: _decoration(
                                  StringManager.streamNameLabel.tr()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  12.hBox,
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(StringManager.streamIntro.tr(),
                        style: context.bodySmall
                            .colorExt(ColorManager.secondaryText)),
                  ),
                  6.hBox,
                  TextField(
                    controller: _intro,
                    maxLines: 3,
                    maxLength: 150,
                    style:
                        context.bodyMedium.colorExt(ColorManager.textPrimary),
                    decoration: _decoration(StringManager.streamIntro.tr()),
                  ),
                  16.hBox,
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      child: _saving
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: ColorManager.buttonTextColor),
                            )
                          : Text(
                              StringManager.save.tr(),
                              style: context.bodyMedium.w700
                                  .colorExt(ColorManager.buttonTextColor),
                            ),
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

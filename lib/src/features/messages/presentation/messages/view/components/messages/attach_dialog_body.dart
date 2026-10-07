part of 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

class _AttachDialogBody extends StatelessWidget {
  const _AttachDialogBody({required this.params});

  final MessagesParameter params;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      end: 85.w,
      bottom: 45.h,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _gallery(context),
            10.hBox,
            _camera(context),
            10.hBox,
            _video(context),
            10.hBox,
            // _record(),
            10.hBox,
          ],
        ),
      ),
    );
  }

  Widget _gallery(BuildContext context) {
    return _SelectMediaWidget(
      icon: CupertinoIcons.photo_fill_on_rectangle_fill,
      iconColor: ColorManager.white,
      onTap: () async => pickImage(camera: false, context: context),
    );
  }

  Widget _camera(BuildContext context) {
    return _SelectMediaWidget(
      icon: CupertinoIcons.camera_fill,
      iconColor: ColorManager.white,
      onTap: () async => pickImage(context: context),
    );
  }

  // Widget _record() {
  //   return _SelectMediaWidget(
  //     icon: CupertinoIcons.mic_fill,
  //     iconColor: ColorManager.primary,
  //     size: 26,
  //     onTap: () => di<TextFieldBloc>().startRecord(),
  //   );
  // }

  Widget _video(BuildContext context) {
    return _SelectMediaWidget(
      icon: CupertinoIcons.video_camera,
      iconColor: ColorManager.white,
      onTap: () async => _pickVideo(context),
    );
  }

  Future<void> pickImage(
      {bool camera = true, required BuildContext context}) async {
    if (!(await Methods.isCheckInternet())) {
      Methods.showToast(context,
          isError: true, message: StringManager.internetConnection.tr());
      return;
    }
    final ImagePicker picker = ImagePicker();
    final result = await Methods.pickImageSafely(
      picker,
      source: camera ? ImageSource.camera : ImageSource.gallery,
    );
    if (result == null) return;

    final String path = result.path;

    Methods.showToast(context, isLoading: true);
    // Image goes through ChatRepository.sendMedia() → optimistic drift row
    // (renders the on-device file) → outbox → MediaUploadWorker. The bubble
    // renders off the drift stream, so no separate AddMessageLocalEvent.
    di<SendMessagesBloc>().add(
      SendMessagesEvent(
        userId: params.userId,
        chatId: params.chatId,
        xFile: File(path),
        type: 'image',
        messageId: di<ToggleAppBarBloc>().state.replay?.messageId,
      ),
    );
  }

  Future<void> _pickVideo(BuildContext context) async {
    if (!(await Methods.isCheckInternet())) {
      Methods.showToast(context,
          isError: true, message: StringManager.internetConnection.tr());
      return;
    }
    di<ToggleAppBarBloc>().add(const ShowAttachBoxEvent(
      isShowMore: false,
    ));

    di<SendMessagesBloc>()
        .add(PickVideoEvent(context, params.userId, chatId: params.chatId));
  }
}

part of '../setting_page.dart';

class EditNameIntroScreen extends StatefulWidget {
  final EnterRoomModel room;
  final String title;
  const EditNameIntroScreen(
      {super.key, required this.room, required this.title});

  @override
  State<EditNameIntroScreen> createState() => _EditNameIntroScreenState();
}

class _EditNameIntroScreenState extends State<EditNameIntroScreen> {
  TextEditingController roomNameController = TextEditingController();
  TextEditingController roomIntroController = TextEditingController();

  @override
  void initState() {
    roomNameController.text = widget.room.roomName ?? "";
    roomIntroController.text = widget.room.roomIntro ?? "";

    super.initState();
  }

  @override
  void dispose() {
    roomNameController.dispose();
    roomIntroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData.fromView(View.of(context)),
      child: Scaffold(
        backgroundColor: ColorManager.white,
        appBar: AppBarWidget(
          title: widget.title,
          // Fixed black -- both were ColorManager.textPrimary (admin-theme
          // driven) before, which could go non-black even though this
          // screen's scaffold is hardcoded white. Covers both Room Name and
          // Room Notice, since they share this one screen by title.
          iconColor: ColorManager.black,
          titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
          actions: [
            ButtonWidget(
              title: StringManager.save.tr(),
              titleColor: ColorManager.black,
              width: 80.w,
              onPressed: () {
                di<UpdateRoomBloc>().add(
                  UpdateRoomEvent(
                    roomName: roomNameController.text,
                    ownerId: widget.room.ownerId.toString(),
                    roomIntro: roomIntroController.text,
                    roomVideoType: widget.room.streamType.toString(),
                    roomId: widget.room.id.toString(),
                  ),
                );
                Navigator.pop(context);
                Navigator.pop(context);
              },
              backgroundColor: ColorManager.transparent,
              height: 45.h,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: context.paddingSymmetric(horizontal: 20, vertical: 30),
              child: TextInputWidget(
                widget.title,
                title: widget.title,
                controller: widget.title == StringManager.roomName.tr()
                    ? roomNameController
                    : roomIntroController,
                fillColor: Colors.grey.withValues(alpha: (0.16)),
                minLines: 7,
                maxLines: 8,
                maxLength: 40,
                textColor: ColorManager.black,
                textStyle:
                context.bodyMedium.w700.colorExt(ColorManager.textPrimary),
                hintStyle: context.bodyMedium.bold
                    .colorExt(ColorManager.greyTextColor),
                enabledBorder: OutlineInputBorder(
                  borderRadius: 6.radius,
                  borderSide: const BorderSide(
                    color: ColorManager.transparent,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: 6.radius,
                  borderSide: const BorderSide(
                    color: ColorManager.transparent,
                    width: 1,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: 6.radius,
                  borderSide: const BorderSide(
                    color: ColorManager.transparent,
                    width: 1,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Padding(
            //   padding: context.paddingSymmetric(horizontal: 20),
            //   child: ButtonWidget(
            //     title: StringManager.save.tr(),
            //     onPressed: () {
            //       di<UpdateRoomBloc>().add(
            //         UpdateRoomEvent(
            //           roomName: roomNameController.text,
            //           ownerId: widget.room.ownerId.toString(),
            //           roomIntro: roomIntroController.text,
            //         ),
            //       );
            //       Navigator.pop(context);
            //     },
            //     height: 45.h,
            //   ),
            // ),
            30.hBox,
          ],
        ),
      ),
    );
  }
}
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class EnterRoomPasswordScreen extends StatefulWidget {
  final String roomId;
  final bool isLive;

  const EnterRoomPasswordScreen({
    required this.roomId,
    required this.isLive,
    super.key,
  });

  @override
  State<EnterRoomPasswordScreen> createState() =>
      _EnterPasswordRoomScreenState();
}

class _EnterPasswordRoomScreenState extends State<EnterRoomPasswordScreen> {
  late final TextEditingController passwordController;

  @override
  void initState() {
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomHandlerBloc, RoomHandlerStates>(
      bloc: di<RoomHandlerBloc>(),
      listenWhen: (_, current) => ModalRoute.of(context)?.isCurrent ?? false,
      listener: (context, state) {
        if (state is EnterRoomSuccesMessageState) {
          Navigator.pop(context);
          RoomData.instance.room = state.room;

          final roomEntity = RoomEntity(
            ownerId: state.room.ownerId,
            id: state.room.id,
            name: state.room.roomName,
            roomIntro: state.room.roomIntro,
            cover: state.room.roomCover,
            roomBackground: state.room.roomBackground,
            mode: state.room.mode,
            uuidOwnerRoom: state.room.uuidOwnerRoom,
            giftPrice: state.room.giftPrice,
          );
          di<RoomStateManager>().navigateToRoom(
            RoomEntryRequest(
              context: context,
              roomData: roomEntity,
              isLive: widget.isLive,
              isPasswordVerified: true,
            ),
          );
        } else if (state is EnterRoomErrorMessageState) {
          Methods.showToast(
            context,
            message: state.errorMessage,
            isError: true,
          );
        }
      },
      child: Container(
        padding: context.paddingOnly(top: 20, start: 20, end: 20),
        height: ScreenUtil().screenHeight * 0.25,
        width: ScreenUtil().screenWidth,
        decoration: BoxDecoration(
          color: ColorManager.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(32.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextWidget(
              StringManager.enterRoomPassword.tr(),
              style: context.bodyLarge.w600,
            ),
            20.hBox,
            TextInputWidget(
              StringManager.enterRoomPassword.tr(),
              controller: passwordController,
              hintStyle: context.bodyMedium.w400
                  .size(14)
                  .colorExt(ColorManager.greyTextColor),
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
              isPassword: true,
              maxLength: 6,
              textStyle: context.bodyLarge.copyWith(color: Colors.white),
            ),
            20.hBox,
            ButtonWidget(
              title: StringManager.enter.tr(),
              onPressed: () {
                if (passwordController.text.length != 6) {
                  Methods.showToast(context,
                      message: StringManager.passwordShouldBe6.tr(),
                      isError: true);
                } else {
                  di<RoomHandlerBloc>().add(
                    EnterRoomEvent(
                      context,
                      isVip: 0,
                      roomId: widget.roomId,
                      roomPassword: passwordController.text,
                    ),
                  );
                }
              },
              titleColor: Colors.white,
              backgroundColor: ColorManager.primary,
              width: 300.w,
              height: 50.w,
              padding: context.paddingAll(5),
            ),
          ],
        ),
      ),
    );
  }
}

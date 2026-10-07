import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/room.dart';

class LockRoomDialog extends StatefulWidget {
  const LockRoomDialog({super.key});

  static bool roomIsLoked = false;

  @override
  State<LockRoomDialog> createState() => _LockRoomDialogState();
}

class _LockRoomDialogState extends State<LockRoomDialog> {
  final int _passwordLength = 6;
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  TextEditingController passwordcontroler = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(_passwordLength, (_) => TextEditingController());
    _focusNodes = List.generate(_passwordLength, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNodes[0]);
        }
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    passwordcontroler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingOnly(top: 20, start: 10, end: 10),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.only(
          topLeft: 20.radiusCircular,
          topRight: 20.radiusCircular,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          // Wrap entire content
          child: Padding(
            padding: context.paddingAll(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StringManager.lockRoomDialog.tr(),
                      style: context.bodyMedium
                          .size(16)
                          .colorExt(ColorManager.black)
                          .bold,
                    ),
                    10.hBox,
                    Divider(color: ColorManager.grey.withValues(alpha: 0.1)),
                    20.hBox,
                  ],
                ),
                Image.asset(
                  AssetsManager.lockIcon,
                  filterQuality: FilterQuality.high,
                  color: ColorManager.primary,
                  colorBlendMode: BlendMode.modulate,
                  scale: 4,
                ),
                20.hBox,
                Text(
                  StringManager.enterSecretNumber.tr(),
                  style: context.bodyMedium
                      .size(14)
                      .colorExt(ColorManager.black.withValues(alpha: 0.5)),
                ),
                20.hBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_passwordLength, (index) {
                    final isFocused = _focusNodes[index].hasFocus;
                    // Smaller border radius (was a fully round 22.5, on
                    // request) and a light brand-gradient ring instead of a
                    // flat grey border -- brighter once the cell is
                    // focused, faint otherwise.
                    return Container(
                      width: 43,
                      height: 43,
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: ColorManager.brandGradientColors
                              .map((c) =>
                                  c.withValues(alpha: isFocused ? 1 : 0.35))
                              .toList(),
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isFocused ? ColorManager.primary : Colors.white,
                          borderRadius: BorderRadius.circular(8.5.r),
                        ),
                        child: TextField(
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: context.bodyMedium.copyWith(
                          fontSize: 16,
                          color: isFocused
                              ? ColorManager.white
                              : ColorManager.black,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          counterText: "",
                          border: InputBorder.none,
                        ),
                        cursorColor: ColorManager.primary,
                        onChanged: (value) {
                          if (value.isNotEmpty && index < _passwordLength - 1) {
                            _focusNodes[index + 1].requestFocus();
                          }

                          setState(() {
                            passwordcontroler.text =
                                _controllers.map((e) => e.text).join();
                          });
                        },
                        ),
                      ),
                    );
                  }),
                ),
                30.hBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        title: StringManager.cancel.tr(),
                        height: 50.h,
                        fontSize: 17.sp,
                        // ColorManager.blackColor is a dark-mode-aware "ink"
                        // token that flips to white in dark mode -- this
                        // sheet is fixed white now, so the fixed black
                        // constant is what actually renders black.
                        titleColor: ColorManager.black,
                        fontWeight: FontWeight.w400,
                        borderColor: ColorManager.grey,
                        padding: context.paddingSymmetric(horizontal: 15),
                        backgroundColor: ColorManager.transparent,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onDoubleTap: () {},
                        child: ButtonWidget(
                          title: StringManager.confirm.tr(),
                          height: 50.h,
                          padding: context.paddingSymmetric(horizontal: 15),
                          fontSize: 17.sp,
                          titleColor: ColorManager.whiteColor,
                          // Brand gradient instead of flat primary, on
                          // request.
                          backgroundColors: ColorManager.brandGradientColors,
                          fontWeight: FontWeight.w400,
                          onPressed: () {
                            if (passwordcontroler.text.length !=
                                _passwordLength) {
                              Methods.showToast(
                                context,
                                message: StringManager.passwordShouldBe6.tr(),
                                isError: true,
                              );
                            } else {
                              di<UpdateRoomBloc>().add(
                                UpdateRoomEvent(
                                  roomPass: passwordcontroler.text,
                                  roomVideoType: RoomData.instance.room.streamType
                                      .toString(),
                                  ownerId:
                                      MyDataModel.getInstance().id.toString(),
                                  roomId: RoomData.instance.room.id.toString(),
                                ),
                              );
                              LockRoomDialog.roomIsLoked = true;
                              // Real-time lock badge: flip locally + broadcast to
                              // everyone in the room.
                              RoomData.instance.isRoomLocked.value = true;
                              sendRoomData(data: {
                                "messageContent": {
                                  "message": "roomPassword",
                                  "value": true,
                                }
                              });
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

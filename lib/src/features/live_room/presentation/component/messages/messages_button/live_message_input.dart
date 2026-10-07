// Flutter imports:
import 'package:general/src/core/index.dart';
import 'package:general/src/features/live_room/presentation/live_room_data.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_badge/user_badges_bloc.dart';
import 'package:general/src/features/profile/presentation/profile/bloc/bloc_user_badges/get_user_badges_bloc.dart';
import 'package:general/src/features/room/data/model/user_in_room_model.dart';
import 'package:general/src/features/room/presentation/component/room_header/room_information/user_row_widget.dart';
import 'package:general/src/features/room/presentation/yallow_banner/controller/controller.dart';
import 'package:general/src/features/room/room.dart';

/// The live room's in-room chat input — a fork of the audio room's
/// `AudioRoomInRoomMessageInput`. Identical UX (rich `userData` payload, @mention
/// picker, "special bar" / yallow-banner toggle) but it sends through the LIVE
/// controller's chat channel ([LiveRoomData.instance.chatController]) instead of
/// the audio one (which is null during a live session).
class LiveInRoomMessageInput extends StatefulWidget {
  const LiveInRoomMessageInput({
    super.key,
    this.placeHolder = 'Say something...',
    this.payloadAttributes,
    this.backgroundColor,
    this.inputBackgroundColor,
    this.textColor,
    this.textHintColor,
    this.cursorColor,
    this.buttonColor,
    this.borderRadius,
    this.enabled = true,
    this.autofocus = true,
    this.onSubmit,
    this.valueNotifier,
    this.focusNotifier,
    this.mention,
  });

  final String placeHolder;
  final String? mention;
  final Map<String, String>? payloadAttributes;
  final Color? backgroundColor;
  final Color? inputBackgroundColor;
  final Color? textColor;
  final Color? textHintColor;
  final Color? cursorColor;
  final Color? buttonColor;
  final double? borderRadius;
  final bool enabled;
  final bool autofocus;
  final VoidCallback? onSubmit;
  final ValueNotifier<String>? valueNotifier;
  final ValueNotifier<bool>? focusNotifier;

  @override
  State<LiveInRoomMessageInput> createState() => _LiveInRoomMessageInputState();
}

class _LiveInRoomMessageInputState extends State<LiveInRoomMessageInput> {
  final TextEditingController textController = TextEditingController();
  ValueNotifier<bool> isEmptyNotifier = ValueNotifier(true);
  var focusNode = FocusNode();
  static ValueNotifier<String> yallowBannerPrice = ValueNotifier<String>("0");

  @override
  void initState() {
    super.initState();

    focusNode.addListener(onFocusChange);

    if (widget.mention != null) {
      textController.text = widget.mention!;
    }

    if (widget.valueNotifier != null) {
      textController.text = widget.valueNotifier!.value;

      isEmptyNotifier.value = textController.text.isEmpty;
    }
  }

  @override
  void dispose() {
    super.dispose();
    YallowBannerController().isYallowBannerEnabled.value = false;

    focusNode
      ..removeListener(onFocusChange)
      ..dispose();
  }

  void onFocusChange() {
    widget.focusNotifier?.value = focusNode.hasFocus;
  }

  void _showMentionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.h)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.3,
          minChildSize: 0.2,
          maxChildSize: 0.5,
          builder: (context, scrollController) {
            return StreamBuilder<List<UTDParticipant>>(
              stream: RoomService.instance.getUserListStream(),
              builder: (context, snapshot) {
                final allParticipants = snapshot.data ?? [];
                final allUsers = allParticipants
                    .map((p) => int.tryParse(p.id))
                    .whereType<int>()
                    .toSet();

                final mentionedNames = RegExp(r'@([\w_]+)')
                    .allMatches(textController.text)
                    .map((m) => m.group(1)?.toLowerCase())
                    .whereType<String>()
                    .toSet();

                final users = List.of(allUsers)
                  ..removeWhere((id) {
                    final user = UsersCache().getUser(id);
                    if (user == null) return false;
                    final name =
                        user.name?.replaceAll(' ', '_').toLowerCase() ?? '';
                    return name ==
                            MyDataModel.getInstance().name?.toLowerCase() ||
                        mentionedNames.contains(name);
                  });

                if (users.isEmpty) {
                  return const SizedBox();
                }

                final userWidgets = List.generate(users.length, (index) {
                  final userId = users[index];
                  final cachedUser = UsersCache().getUser(userId);

                  if (cachedUser != null) {
                    return _buildUserRow(
                      context,
                      scrollController,
                      cachedUser,
                      textController,
                    );
                  } else {
                    return FutureBuilder<Map<int, UserInRoomModel>>(
                      future: getUsersByIds([userId]),
                      builder: (context, snapshot) {
                        final fetchedUser =
                            snapshot.data?[userId] ?? const UserInRoomModel();
                        return _buildUserRow(
                          context,
                          scrollController,
                          fetchedUser,
                          textController,
                        );
                      },
                    );
                  }
                });

                return ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: userWidgets.length,
                  separatorBuilder: (_, __) => Container(
                    height: 1.h,
                    color: ColorManager.grey.withValues(alpha: 0.1),
                  ),
                  itemBuilder: (_, index) => userWidgets[index],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUserRow(
    BuildContext context,
    ScrollController scrollController,
    UserInRoomModel user,
    TextEditingController textController,
  ) {
    return GestureDetector(
      onTap: () {
        final text = textController.text;
        final newText = text.replaceRange(
          text.lastIndexOf('@'),
          text.length,
          "@${(user.name ?? '').replaceAll(' ', '_')} ",
        );
        textController.text = newText;
        textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length),
        );
        Navigator.pop(context);
      },
      child: UserRowWidget(
        isAdmin: false,
        canClick: false,
        ownerId: LiveRoomData.instance.room.id.toString(),
        frame: user.frame ?? "",
        frameType: user.frameType ?? "",
        vip: user.vipImage ?? "",
        image: user.image ?? "",
        name: user.name ?? "",
        id: user.id.toString(),
        gender: user.gender ?? 1,
        senderImage: user.senderLevelImage ?? "",
        receiverImage: user.receiverLevelImage ?? "",
        age: user.age ?? 0,
        uuid: user.uuid ?? "",
        coloredName: (user.vipColorName?.isNotEmpty == true)
            ? Color(int.parse(user.vipColorName!.replaceFirst('#', '0xff')))
            : ColorManager.black,
        imageColorEntity: user.imageColorEntity,
        specialId: user.specialId,
        idImage: user.idImage ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: YallowBannerController().isYallowBannerEnabled,
      builder: (context, bool value, Widget? child) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        color: widget.backgroundColor ??
            const Color(0xff222222).withValues(alpha: (0.8)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 50.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () async {
                  await getUserPopUp();
                  if (!mounted) return;

                  final myCoins =
                      int.tryParse(LiveRoomData.instance.myCoins.value) ?? 0;
                  final price = int.tryParse(yallowBannerPrice.value) ?? 0;

                  if (myCoins >= price) {
                    YallowBannerController().isYallowBannerEnabled.value =
                        !YallowBannerController().isYallowBannerEnabled.value;
                  } else {
                    Methods.showToast(
                      context,
                      isError: true,
                      message: StringManager.goRecharge.tr(),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    vertical: 5.h,
                    horizontal: 10.w,
                  ),
                  decoration: BoxDecoration(
                    color: value
                        ? ColorManager.yellow
                        : ColorManager.grey.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    StringManager.specialBar.tr(),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10.w),
                  ValueListenableBuilder<String>(
                    valueListenable: yallowBannerPrice,
                    builder: (context, String value, Widget? child) =>
                        messageInput(numPobUp: value),
                  ),
                  SizedBox(width: 10.w),
                  sendButton(),
                  SizedBox(width: 10.w),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messageInput({required String numPobUp}) {
    final messageSendCursorColor =
        widget.cursorColor ?? const Color(0xffA653ff);
    final messageSendHintStyle = TextStyle(
      color: widget.textHintColor ?? const Color(0xffa4a4a4),
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
    );
    final messageSendInputStyle = TextStyle(
      color: widget.textColor ?? Colors.white,
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
    );

    final ValueNotifier<int> charCount = ValueNotifier<int>(0);

    return ValueListenableBuilder<int>(
      valueListenable: charCount,
      builder: (context, count, _) => Expanded(
        child: Container(
          constraints: BoxConstraints(
            minHeight: 78.h,
            maxHeight: 180.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: TextField(
            enabled: widget.enabled,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: null,
            autofocus: widget.autofocus,
            focusNode: focusNode,
            inputFormatters: [
              LengthLimitingTextInputFormatter(199),
            ],
            controller: textController,
            onChanged: (String inputMessage) {
              if (inputMessage.endsWith('@')) {
                _showMentionDialog();
              }
              widget.valueNotifier?.value = inputMessage;

              final valueIsEmpty = inputMessage.isEmpty;
              if (valueIsEmpty != isEmptyNotifier.value) {
                isEmptyNotifier.value = valueIsEmpty;
              }

              charCount.value = inputMessage.length;
            },
            // Keyboard action inserts a NEW LINE (owner spec) — sending is
            // only via the send button.
            textInputAction: TextInputAction.newline,
            cursorColor: messageSendCursorColor,
            cursorHeight: 20.h,
            cursorWidth: 3.w,
            style: messageSendInputStyle,
            decoration: InputDecoration(
              hintText: YallowBannerController().isYallowBannerEnabled.value
                  ? '${StringManager.youWillSpend.tr()}:$numPobUp'
                  : widget.placeHolder,
              hintStyle: messageSendHintStyle,
              contentPadding: EdgeInsets.only(
                left: 10.w,
                top: 0.h,
                right: 10.w,
                bottom: 5.h,
              ),
              border: InputBorder.none,
              counter: Text(
                '$count / 100',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget sendButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: isEmptyNotifier,
      builder: (context, bool isEmpty, Widget? child) {
        return GestureDetector(
          onTap: () {
            if (!isEmpty) send();
          },
          child: Container(
            decoration: BoxDecoration(
              color: widget.buttonColor,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 25.sp,
              ),
            ),
          ),
        );
      },
    );
  }

  void send() {
    String message = textController.text.trim();
    if (message.isNotEmpty) {
      if (YallowBannerController().isYallowBannerEnabled.value) {
        // Re-check the balance here too (not just when the toggle was
        // switched on) -- the coin count can drop in between, and the
        // yellow-banner endpoint never returns an updated balance, so
        // this client also does the deduction itself, on request.
        final myCoins = int.tryParse(LiveRoomData.instance.myCoins.value) ?? 0;
        final price = int.tryParse(yallowBannerPrice.value) ?? 0;
        if (myCoins < price) {
          final ctx = navKey.currentContext;
          if (ctx != null && ctx.mounted) {
            Methods.showToast(
              ctx,
              isError: true,
              message: StringManager.goRecharge.tr(),
            );
          }
          YallowBannerController().isYallowBannerEnabled.value = false;
          return;
        }
        di<OnRoomBloc>().add(
          SendYallowBannerEvent(
            roomId: LiveRoomData.instance.room.id.toString(),
            message: textController.text.trim(),
          ),
        );
        LiveRoomData.instance.myCoins.value = (myCoins - price).toString();
      }
      LiveRoomData.instance.chatController?.sendMessage(
        message,
        userData: {
          "img": MyDataModel.getInstance().profile?.image ?? "",
          "bu": MyDataModel.getInstance().bubble ?? "",
          "buId": MyDataModel.getInstance().bubbleId.toString(),
          "sL": MyDataModel.getInstance().level?.senderImage ?? "",
          "rL": MyDataModel.getInstance().level?.receiverImage ?? "",
          "v": MyDataModel.getInstance().vip1?.img1 ?? "",
          "c": MyDataModel.getInstance().vip1?.colorName ?? "",
          "aI": (di<UserBadgesBloc>().state.myBadge ?? [])
              .map((b) => EndPoints.getImage(b.image))
              .toList(),
          "bT": (di<GetUserBadgesBloc>().state.userBadge?.top ?? [])
              .map((b) => EndPoints.getImage(b.image))
              .toList(),
          "sI": (MyDataModel.getInstance().specialId != null &&
                  MyDataModel.getInstance().specialId != 0)
              ? (MyDataModel.getInstance().specialIdImage ?? "")
              : "",
          "senderId": MyDataModel.getInstance().id?.toString() ?? "",
          "senderName": MyDataModel.getInstance().name ?? "",
          'type': 'message',
        },
      );
      textController.clear();

      widget.valueNotifier?.value = '';

      widget.onSubmit?.call();
    }
  }

  Future<void> getUserPopUp() async {
    try {
      final result = await RoomRemoteDataSourceImp(di()).fetchConfigKey(
          const GetConfigKeyPram(specialBar: "special_bar_coin"));
      yallowBannerPrice.value = result.data?.specialBar ?? '0';
    } catch (error) {
      Methods.printLog(
        'getUserPopUp failed: ${NetworkExceptions.getErrorMessage(NetworkExceptions.getDioException(error))}',
      );
    }
  }
}

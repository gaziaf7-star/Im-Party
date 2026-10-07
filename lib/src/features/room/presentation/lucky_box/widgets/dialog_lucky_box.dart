import 'dart:async';
import 'package:general/src/core/widgets/on_multiable_tab.dart';
import 'package:general/src/features/room/presentation/charisma/bloc/charisma_bloc.dart';
import 'package:general/src/features/room/room.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/index.dart';
import 'dart:math' as math;

class DialogLuckyBox extends StatefulWidget {
  final String ownerBoxName;
  final String coins;
  final String luckyBoxId;
  final TypeLuckyBox typeLuckyBox;
  final int usersNumber;
  final String ownerImage;
  final String uid;
  final VoidCallback? giftButtonCallBack;
  final String roomId;
  final String remTime;
  static bool startTime = false;

  const DialogLuckyBox({
    required this.coins,
    required this.luckyBoxId,
    required this.ownerBoxName,
    required this.typeLuckyBox,
    required this.ownerImage,
    required this.uid,
    required this.usersNumber,
    required this.roomId,
    required this.remTime,
    this.giftButtonCallBack,
    super.key,
  });

  @override
  DialogLuckyBoxState createState() => DialogLuckyBoxState();
}

class DialogLuckyBoxState extends State<DialogLuckyBox> {
  late final LuckyBoxBloc _luckyBoxesBloc;
  late final CharismaBloc _extraRoomDataBloc;

  void onCheckedPickUpModelValue() {
    _luckyBoxesBloc = di<LuckyBoxBloc>();
    _extraRoomDataBloc = di<CharismaBloc>();
  }

  @override
  void initState() {
    onCheckedPickUpModelValue();
    _checkCachedBox();
    super.initState();
  }

  void _checkCachedBox() async {
    if (widget.typeLuckyBox == TypeLuckyBox.superBox) {
      final prefs = await SharedPreferences.getInstance();
      final alreadyPicked =
          prefs.getBool('picked_${widget.luckyBoxId}') ?? false;
      if (alreadyPicked) {
        final remainingTime = math.max(
          0,
          DateTime.parse('${widget.remTime}Z')
              .difference(DateTime.now().toUtc())
              .inSeconds,
        );
        if (remainingTime > 0) {
          final timerService = di<SetTimerLuckyBox>();
          timerService.remTimeSuperBox = remainingTime;
          timerService.start(remainingTime, context);
        }
      }
    }
  }

  @override
  void dispose() {
    if (_luckyBoxesBloc.state.pickUpLuckyBoxEntity != null) {
      _extraRoomDataBloc.add(GetCharismaExtraDataEvent(roomId: widget.roomId));
    }
    _luckyBoxesBloc.add(ResetPickupLuckyBoxEvent());
    di<SetTimerLuckyBox>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LuckyBoxBloc, LuckyBoxState>(
      bloc: _luckyBoxesBloc,
      listener: (context, state) async {
        if (state.pickUpLuckyBoxReqState?.isLoaded == true) {
          if (widget.typeLuckyBox == TypeLuckyBox.superBox) {
            Navigator.pop(context);
          }
        }
        if (state.pickUpLuckyBoxReqState?.isError == true) {
          Methods.showToast(
            context,
            isError: true,
            message: state.pickUpLuckyBoxMessage ?? '',
          );
        }
      },
      builder: (context, state) {
        return StreamBuilder<String?>(
          stream: di<SetTimerLuckyBox>().stream,
          builder: (context, snapshot) {
            return Container(
              height: 500.h,
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.only(
                  topRight: 15.radiusCircular,
                  topLeft: 15.radiusCircular,
                ),
              ),
              child: Padding(
                padding: context.paddingSymmetric(horizontal: 15, vertical: 10),
                child: Column(
                  children: [
                    _HeaderContent(widget: widget),
                    10.hBox,
                    Image.asset(
                      state.pickUpLuckyBoxEntity?.isWin == true
                          ? AssetsManager.openLuckyBox
                          : AssetsManager.closeLuckyBox,
                      width: 250.h,
                      height: 150.h,
                    ),
                    20.hBox,
                    _CoinsContent(
                      widget: widget,
                      state: state.pickUpLuckyBoxEntity,
                    ),
                    10.hBox,
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 5,
                      ),
                      child: Text(
                        state.pickUpLuckyBoxEntity?.isWin == true
                            ? StringManager.congrats.tr()
                            : StringManager.unlockAndGetCoins.tr(),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: ColorManager.black,
                          fontSize: 16.h,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    MultiTapCard(
                      onTap: () {
                        if (state.pickUpLuckyBoxEntity?.isWin == true) {
                          Navigator.pop(context);
                          widget.giftButtonCallBack?.call();
                        } else {
                          if (DialogLuckyBox.startTime == false) {
                            _luckyBoxesBloc.add(
                              PickupLuckyBoxEvent(
                                boxId: widget.luckyBoxId,
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        height: 50.h,
                        width: ScreenUtil().screenWidth,
                        padding: context.paddingZero(),
                        decoration: BoxDecoration(
                          color: DialogLuckyBox.startTime
                              ? ColorManager.black.withValues(alpha: 0.2)
                              : ColorManager.primary,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: state.pickUpLuckyBoxReqState!.isLoading
                            ? const Center(child: LoadingWidget())
                            : Center(
                                child: TextWidget(
                                  state.pickUpLuckyBoxEntity?.isWin == true
                                      ? StringManager.sendGift.tr()
                                      : DialogLuckyBox.startTime
                                          ? snapshot.data ?? "00:00"
                                          : StringManager.open.tr(),
                                  style: context.bodyMedium
                                      .copyWith(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      )
                                      .colorExt(DialogLuckyBox.startTime
                                          ? Colors.black.withValues(alpha: 0.5)
                                          : ColorManager.whiteColor),
                                ),
                              ),
                      ),
                    ),
                    10.hBox,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CoinsContent extends StatelessWidget {
  const _CoinsContent({required this.widget, required this.state});

  final DialogLuckyBox widget;
  final PickUpLuckyBoxEntity? state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          AssetsManager.coin,
          width: 16.h,
          height: 16.h,
        ),
        16.wBox,
        Text(
          state?.isWin == true
              ? '${state?.coins} ${StringManager.coinCollect.tr()}'
              : widget.coins,
          overflow: TextOverflow.clip,
          style: TextStyle(
            color: ColorManager.green,
            fontSize: 16.h,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({required this.widget});

  final DialogLuckyBox widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ImageViewWidget(
          url: widget.ownerImage,
          displayName: widget.ownerBoxName,
          width: 50.h,
          height: 50.h,
          radius: 30.r,
        ),
        15.wBox,
        Expanded(
          flex: 2,
          child: Text(
            "${widget.ownerBoxName} ${StringManager.sentATreasureBox.tr()}",
            overflow: TextOverflow.clip,
            style:  TextStyle(
              color: ColorManager.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        20.wBox,
      ],
    );
  }
}

class SetTimerLuckyBox {
  // Not final: we close and reinitialise on dispose so the DI singleton
  // can be reused across multiple room sessions without leaking listeners.
  StreamController<String?> streamController =
      StreamController<String?>.broadcast();

  Timer? _timer;
  int remTimeSuperBox = -1;

  Stream<String?> get stream => streamController.stream;

  void start(int currentTime, BuildContext context) {
    DialogLuckyBox.startTime = true;
    if (_timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        remTimeSuperBox--;
        _updateSeconds(context);
      });
    } else {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        remTimeSuperBox--;
        _updateSeconds(context);
      });
    }
  }

  void _updateSeconds(BuildContext context) {
    if (remTimeSuperBox > 0) {
      final int days = remTimeSuperBox ~/ (24 * 3600);
      final int hours = (remTimeSuperBox % (24 * 3600)) ~/ 3600;
      final int minutes = (remTimeSuperBox % 3600) ~/ 60;
      final int seconds = remTimeSuperBox % 60;

      final String formattedTime = days > 0
          ? '$days:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
          : '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      streamController.sink.add(formattedTime);
    } else {
      streamController.sink.add(null);
      remTimeSuperBox = -1;
      _timer?.cancel();
      DialogLuckyBox.startTime = false;
      Navigator.pop(context);
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    streamController.close();
    // Reinitialise so the DI singleton is ready for the next session.
    streamController = StreamController<String?>.broadcast();
    remTimeSuperBox = -1;
    DialogLuckyBox.startTime = false;
  }
}





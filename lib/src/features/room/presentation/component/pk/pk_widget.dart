import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/bottom_dialog.dart';
import 'package:general/src/features/room/presentation/component/pk/counter_time_pk_widget.dart';
import 'package:general/src/features/room/presentation/component/pk/pk_functions.dart';
import 'package:general/src/features/room/presentation/component/pk/time_pk_widget.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_bloc.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_events.dart';
import 'package:general/src/features/room/presentation/manager/manager_pk/pk_states.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PKWidget extends StatelessWidget {
  final double scoreRedTem;
  final double scoreBlueTeam;
  final bool isHost;
  final String ownerId;
  final String roomId;
  static String pkId = '';
  final Function() notifyRoom;

  const PKWidget({
    required this.scoreBlueTeam,
    required this.isHost,
    required this.ownerId,
    required this.roomId,
    required this.notifyRoom,
    required this.scoreRedTem,
    super.key,
  });

  static ValueNotifier<bool> isStartPK = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PKBloc, PKStates>(
      bloc: di<PKBloc>(),
      buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
      builder: (context, state) {
        if (state is HidePKStateLoading) {
          return const Center(
            child: LoadingWidget(color: ColorManager.white),
          );
        } else {
          return ValueListenableBuilder<int>(
            valueListenable: PkController.updatePKNotifier,
            builder: (context, scoreTime1, _) {
              return Stack(
                children: [
                  ValueListenableBuilder(
                    valueListenable: isStartPK,
                    builder: (context, isStartPK, _) {
                      if (isStartPK) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          AssetsManager.timerBBackground),
                                      fit: BoxFit.fill)),
                              padding: EdgeInsets.only(
                                top: 20.h,
                              ),
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AssetsManager.pkIcon,
                                      scale: 3.5,
                                    ),
                                    // Rebuild the time text every tick. The
                                    // widget reads the live PkController values,
                                    // so both connection states render the same
                                    // current countdown.
                                    StreamBuilder<TimeData>(
                                      stream: di<SetTimerPK>().stream,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<TimeData> snapshot) {
                                        // Not const: the same canonicalized
                                        // const instance would make Flutter
                                        // skip rebuilding it on every tick,
                                        // freezing the displayed countdown.
                                        return CounterPkTimeWidget();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                  Positioned(
                    top: 20.h,
                    left: 0,
                    right: 0,
                    child: ValueListenableBuilder(
                      valueListenable: isStartPK,
                      builder: (context, isStartPK, _) {
                        if (isStartPK) {
                          return const SizedBox();
                        } else {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (isHost) {
                                    bottomDailog(
                                      context: context,
                                      widget: TimePKWidget(
                                        notifyRoom: notifyRoom,
                                        roomId: roomId,
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  width: 250.w,
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10.r),
                                      bottomRight: Radius.circular(10.r),
                                    ),
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFFFF0000),
                                        Color(0xFF0057FF),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      StringManager.start.tr(),
                                      style: context.bodyMedium
                                          .size(18)
                                          .w700
                                          .colorExt(ColorManager.textPrimary)
                                          .copyWith(
                                              fontStyle: FontStyle.italic),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  Animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                    effects: const [
                      ShimmerEffect(
                        duration: Duration(seconds: 4),
                        size: 0.2,
                        angle: 10,
                      )
                    ],
                    child: LinearPercentIndicator(
                      animateFromLastPercent: true,
                      curve: Curves.linearToEaseOut,
                      animation: true,
                      lineHeight: 20.h,
                      animationDuration: 2500,
                      percent: (PkController.precantgeTeam1 == 0.0
                          ? 0.1
                          : PkController.precantgeTeam1 == 1.0
                              ? 0.9
                              : PkController.precantgeTeam1),
                      backgroundColor: ColorManager.transparent,
                      progressColor: const Color(0xFFFF0000),
                    ),
                  ),
                  Animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                    effects: const [
                      ShimmerEffect(
                        duration: Duration(seconds: 4),
                        size: 0.20,
                      )
                    ],
                    child: LinearPercentIndicator(
                      animateFromLastPercent: true,
                      curve: Curves.linearToEaseOut,
                      animation: true,
                      lineHeight: 20.h,
                      isRTL: true,
                      animationDuration: 2500,
                      percent: (PkController.precantgeTeam2 == 0.0
                          ? 0.1
                          : PkController.precantgeTeam2 == 1.0
                              ? 0.9
                              : PkController.precantgeTeam2),
                      backgroundColor: ColorManager.transparent,
                      progressColor: const Color(0xFF0057FF),
                    ),
                  ),
                  Positioned(
                    left: 14.w,
                    child: Text(
                      PkController.scoreTeam1 == 0
                          ? ""
                          : Methods.formatCompactNumber(
                              PkController.scoreTeam1),
                      style:  TextStyle(
                        color: ColorManager.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 14.w,
                    child: Text(
                      PkController.scoreTeam2 == 0
                          ? ""
                          : Methods.formatCompactNumber(
                              PkController.scoreTeam2),
                      style:  TextStyle(
                        color: ColorManager.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isHost)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: context.paddingAll(25),
                          child: InkWell(
                            onTap: () {
                              di<PKBloc>().add(
                                  ClosePKEvent(roomId: roomId, pkId: pkId));
                              di<PKBloc>().add(HidePKEvent(roomId: roomId));
                              PkController.scoreTeam2 = 0;
                              PkController.scoreTeam1 = 0;
                              PkController.precantgeTeam1 = 0.5;
                              PkController.precantgeTeam2 = 0.5;
                              di<SetTimerPK>().stop();
                            },
                            child: Icon(
                              CupertinoIcons.clear_fill,
                              size: 20.sp,
                              color: const Color(0xFFFF0000),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          );
        }
      },
    );
  }
}

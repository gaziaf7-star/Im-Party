import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manager_add_room_backGround/add_room_background_bloc.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manager_add_room_backGround/add_room_background_event.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manager_add_room_backGround/add_room_background_state.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manger_get_my_background/get_my_background_bloc.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manger_get_my_background/get_my_background_event.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manger_get_my_background/get_my_background_state.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manger_get_my_background_setting/get_my_background_setting_bloc.dart';
import 'package:general/src/features/room/room.dart';
import 'package:general/src/core/index.dart';

class ThemePage extends StatefulWidget {
  final String ownerId;
  const ThemePage({super.key, required this.ownerId});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    if (di<ThemeBloc>().state.requestState != RequestState.loaded) {
      di<ThemeBloc>().add(const GetThemesEvent());
    }
    if (di<GetMyBackgroundBloc>().state is! GetMyBackgroundSuccessState) {
      di<GetMyBackgroundBloc>().add(const GetMyBackgroundEvent());
    }
  }

  File? _image;
  final ImagePicker _picker = ImagePicker();
  Future getImage() async {
    var pickedFile =
        await Methods.pickImageSafely(_picker, source: ImageSource.gallery);
    if (pickedFile?.path != null) {
      setState(() {
        _image = File(pickedFile!.path);
      });
      di<AddRoomBackgroundBloc>()
          .add(AddRoomBackgroundEvent(roomBackGround: _image!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddRoomBackgroundBloc, AddRoomBackgroundState>(
      bloc: di<AddRoomBackgroundBloc>(),
      listener: (context, state) {
        if (state is AddRoomBackgroundLoading) {
          Methods.showToast(context, isLoading: true);
        } else if (state is AddRoomBackgroundError) {
          Methods.showToast(context, message: state.error, isError: true);
        } else if (state is AddRoomBackgroundSuccess) {
          di<GetMyBackgroundBloc>()
              .add(const GetMyBackgroundEvent(isLoading: false));
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height / 2.6,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: ColorManager.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            10.hBox,
            Padding(
              padding: EdgeInsets.all(10.r),
              child: TextWidget(
                StringManager.me.tr(),
                style: context.bodyMedium.bold.colorExt(ColorManager.black),
              ),
            ),
            SizedBox(
              height: 100.h,
              child: BlocBuilder<GetMyBackgroundBloc, GetMyBackgroundState>(
                bloc: di<GetMyBackgroundBloc>(),
                buildWhen: (prev, curr) =>
                    prev.runtimeType != curr.runtimeType ||
                    prev.data != curr.data,
                builder: (context, state_) {
                  return HandlingDataWidget(
                    reqState: state_ is GetMyBackgroundSuccessState
                        ? RequestState.loaded
                        : state_ is GetMyBackgroundLoadingState
                            ? RequestState.loading
                            : RequestState.error,
                    title: "",
                    subTitle: "",
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state_.data.length + 1,
                      separatorBuilder: (context, index) => 10.wBox,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      itemBuilder: (context, index) {
                        if (state_.data.isNotEmpty &&
                            state_.data.length > index) {
                          return InkWell(
                            onTap: () {
                              // Modes 5 (cinema), 6 (date/2-seat), 8 (CP/8-seat),
                              // 9 (couples) ship a FIXED background bundled with
                              // the mode — changing the room background has no
                              // effect, so tell the user instead of a false success.
                              const fixedBgModes = {'5', '6', '8', '9'};
                              if (fixedBgModes
                                  .contains(RoomData.instance.room.mode)) {
                                Methods.showToast(context,
                                    message: StringManager
                                        .modeHasFixedBackground
                                        .tr(),
                                    isError: true);
                                return;
                              }
                              di<UpdateRoomBloc>().add(
                                UpdateRoomEvent(
                                  roomBackgroundId:
                                      state_.data[index].id.toString(),
                                  ownerId: widget.ownerId,
                                  roomVideoType: RoomData
                                      .instance.room.streamType
                                      .toString(),
                                  roomId: RoomData.instance.room.id.toString(),
                                  change: 'me',
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: 4.radius,
                              ),
                              child: ClipRRect(
                                borderRadius: 4.radius,
                                child: ImageViewWidget(
                                  url: state_.data[index].img,
                                  width: 100.w,
                                  boxFit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return InkWell(
                            onTap: () async {
                              if (!di<GetMyBackgroundSettingBloc>()
                                  .state
                                  .requestState
                                  .isLoaded) {
                                di<GetMyBackgroundSettingBloc>().add(
                                    GetMyBackgroundSettingEvent(
                                        context: context));
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AnimatedDialog(
                                    title: StringManager.uploadImage.tr(),
                                    onTap: () async {
                                      File? image;
                                      final FilePickerResult? result =
                                          await FilePicker.pickFiles(
                                        type: FileType.custom,
                                        allowMultiple: false,
                                        allowedExtensions: [
                                          'png',
                                          'jpeg',
                                          'jpg'
                                        ],
                                      );

                                      if (result != null) {
                                        final filePath =
                                            result.files.first.path!;
                                        final fileSizeInBytes =
                                            File(filePath).lengthSync();
                                        final fileSizeInMB =
                                            fileSizeInBytes / (1024 * 1024);
                                        if (filePath
                                            .toLowerCase()
                                            .endsWith('.gif')) {
                                          Methods.showToast(
                                            context,
                                            message: StringManager
                                                .gifImagesNotAllowed
                                                .tr(),
                                            isError: true,
                                          );
                                          context.popRoute();
                                          return;
                                        }
                                        if (fileSizeInMB > 2) {
                                          Methods.showToast(
                                            context,
                                            message: StringManager.picSize.tr(),
                                            isError: true,
                                          );
                                          context.popRoute();

                                          return;
                                        }
                                        image = File(filePath);
                                        di<AddRoomBackgroundBloc>().add(
                                          AddRoomBackgroundEvent(
                                              roomBackGround: image),
                                        );
                                        Navigator.pop(context);
                                      }
                                    },
                                    description:
                                        '${StringManager.thisImageWillCost.tr()} ${di<GetMyBackgroundSettingBloc>().state.backgroundSettingData?.cost} ${StringManager.coins_.tr()}  ${di<GetMyBackgroundSettingBloc>().state.backgroundSettingData?.expire} ${StringManager.days.tr()}',
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: 4.radius,
                                // Brand gradient "button" tile instead of
                                // flat grey, on request.
                                gradient: ColorManager.brandGradient,
                              ),
                              width: 100.w,
                              child: Icon(
                                Icons.add,
                                color: ColorManager.white,
                                size: 70.sp,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            10.hBox,
            Padding(
              padding: EdgeInsets.all(10.r),
              child: TextWidget(
                StringManager.store.tr(),
                style: context.bodyMedium.bold.colorExt(ColorManager.black),
              ),
            ),
            SizedBox(
              height: 100.h,
              child: BlocBuilder<ThemeBloc, ThemeStates>(
                bloc: di<ThemeBloc>(),
                buildWhen: (prev, curr) =>
                    prev.requestState != curr.requestState ||
                    prev.backgroundList != curr.backgroundList,
                builder: (context, state) {
                  return HandlingDataWidget(
                    reqState: state.requestState,
                    title: "",
                    subTitle: "",
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      itemCount: state.backgroundList.length,
                      separatorBuilder: (context, index) => 10.wBox,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            di<UpdateRoomBloc>().add(
                              UpdateRoomEvent(
                                roomVideoType: RoomData.instance.room.streamType
                                    .toString(),
                                roomBackgroundId:
                                    state.backgroundList[index].id.toString(),
                                ownerId: widget.ownerId,
                                roomId: RoomData.instance.room.id.toString(),
                                change: 'app',
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: 4.radius,
                            ),
                            child: ClipRRect(
                              borderRadius: 4.radius,
                              child: ImageViewWidget(
                                url: state.backgroundList[index].img,
                                width: 100.w,
                                boxFit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

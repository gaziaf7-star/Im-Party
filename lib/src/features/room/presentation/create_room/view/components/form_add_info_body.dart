part of '../create_room_page.dart';

class _FormAddInfoBody extends StatefulWidget {
  final bool isLive;

  const _FormAddInfoBody({this.isLive = false});

  @override
  State<_FormAddInfoBody> createState() => _FormAddInfoBodyState();
}

class _FormAddInfoBodyState extends State<_FormAddInfoBody> {
  @override
  void initState() {
    if (di<CreateRoomBloc>().state.typesRoomState != RequestState.loaded) {
      di<CreateRoomBloc>().add(GetTypesRoomEvent());
    }
    if (di<CreateRoomBloc>().state.createPaidRoomState != RequestState.loaded) {
      di<CreateRoomBloc>().add(CreatePaidRoomEvent());
    }
    super.initState();
  }

  @override
  void dispose() {
    di<CreateRoomBloc>().add(DisposeEvent());
    super.dispose();
  }

  int roomType = -1;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateRoomBloc, CreateRoomStates>(
      bloc: di<CreateRoomBloc>(),
      builder: (context, state) {
        return Form(
          key: state.formKey,
          child: Padding(
            padding: context.paddingSymmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                15.hBox,
                TextInputWidget(
                  contentPadding: context.paddingZero(),
                  maxLength: 100,
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.withValues(alpha: (0.2))),
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  errorBorder:
                      const UnderlineInputBorder(borderSide: BorderSide.none),
                  label: TextWidget(
                    StringManager.enterRoomName.tr(),
                    style: context.bodyMedium.colorExt(
                      ColorManager.blackColor.withValues(alpha: (0.45)),
                    ),
                  ),
                  StringManager.enterRoomName.tr(),
                  validator: (value) {
                    if (value == "") {
                      return StringManager.requiredField.tr();
                    } else {
                      return null;
                    }
                  },
                  controller: state.name,
                  maxLines: 8,
                ),
                15.hBox,
                TextInputWidget(
                  contentPadding: context.paddingZero(),
                  maxLength: 100,
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.withValues(alpha: (0.2))),
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  errorBorder:
                      const UnderlineInputBorder(borderSide: BorderSide.none),
                  label: TextWidget(
                    StringManager.enterRoomIntro.tr(),
                    style: context.bodyMedium.colorExt(
                      ColorManager.blackColor.withValues(alpha: (0.45)),
                    ),
                  ),
                  validator: (value) {
                    if (value == "") {
                      return StringManager.requiredField.tr();
                    } else {
                      return null;
                    }
                  },
                  StringManager.enterRoomIntro.tr(),
                  controller: state.bio,
                  maxLines: 8,
                ),
                35.hBox,
                TextWidget(
                  StringManager.selectRoomTyp.tr(),
                  style: context.bodySmall.w500
                      .colorExt(ColorManager.lightGray2)
                      .size(14),
                ),
                20.hBox,
                HandlingDataWidget(
                  reqState: state.typesRoomState,
                  title: "",
                  subTitle: "",
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.typesRoom.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 4.5,
                      childAspectRatio: 4.5,
                    ),
                    itemBuilder: (context, index) {
                      final type = state.typesRoom[index];
                      final isSelected = state.selectedRoomTypeId == type.id;

                      return GestureDetector(
                        onTap: () {
                          di<CreateRoomBloc>()
                              .add(SelectRoomTypeEvent(type.id));
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              activeColor: ColorManager.primary,
                              checkColor: ColorManager.white,
                              value: isSelected,
                              onChanged: (value) {
                                di<CreateRoomBloc>()
                                    .add(SelectRoomTypeEvent(type.id));
                              },
                              fillColor: WidgetStateProperty.all<Color>(
                                  isSelected
                                      ? ColorManager.primary
                                      : ColorManager.offWhite),
                              side: BorderSide(
                                color: ColorManager.black.withValues(
                                  alpha: (0.4),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextWidget(
                                type.name,
                                textAlign: TextAlign.start,
                                style: context.bodyMedium.colorExt(
                                  isSelected
                                      ? ColorManager.primary
                                      : ColorManager.blackColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                130.hBox,
                Padding(
                  padding: context.paddingSymmetric(horizontal: 20),
                  child: ButtonWidget(
                    title: state.createPaidRoomEntity?.isPaidRoom == true
                        ? StringManager.craeteRoomPaid(
                            coins: state.createPaidRoomEntity?.paidRoomAmount ??
                                "0")
                        : StringManager.createRoomDefult.tr(),
                    isLoading: state.reqState.isLoading,
                    onPressed: () {
                      if (state.formKey.currentState?.validate() == true) {
                        if (state.image == null) {
                          Methods.showToast(
                            context,
                            message: StringManager.addInfoRoomSubtitle.tr(),
                            isError: true,
                          );
                        } else if (state.selectedRoomTypeId == -1) {
                          Methods.showToast(
                            context,
                            message: StringManager.selectRoomType.tr(),
                            isError: true,
                          );
                        } else {
                          if (state.createPaidRoomEntity?.isPaidRoom == true) {
                            if (int.parse(state
                                        .createPaidRoomEntity?.paidRoomAmount ??
                                    "0") <=
                                di<MyStoreBloc>().state.myStore?.coins) {
                              di<CreateRoomBloc>().add(
                                CreateAudioRoomEvent(
                                  roomName: state.name.text,
                                  roomCover: state.image,
                                  password: '',
                                  roomIntero: state.bio.text,
                                  roomType: state.selectedRoomTypeId.toString(),
                                  type: widget.isLive ? 'live' : 'audio',
                                ),
                              );
                            } else {
                              Methods.showToast(context,
                                  isError: true,
                                  message: StringManager.goRecharge.tr());
                              Navigator.pushNamed(context, Routes.coinsPage);
                            }
                          } else {
                            di<CreateRoomBloc>().add(
                              CreateAudioRoomEvent(
                                roomName: state.name.text,
                                roomCover: state.image,
                                password: '',
                                type: widget.isLive ? 'live' : 'audio',
                                roomIntero: state.bio.text,
                                roomType: state.selectedRoomTypeId.toString(),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      listener: (context, state) {
        if (state.createPaidRoomEntity?.isPaidRoom == true &&
            state.createPaidRoomState.isLoaded) {
          di<MyStoreBloc>().add(const GetMyStoreEvent());
        }
      },
    );
  }
}

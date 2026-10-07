import 'dart:async';

import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/search_manager/search_user_agency_bloc.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/home/presentation/search_screen/components/search_user_row.dart';

import 'package:general/src/core/index.dart';
import '../../../../profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';

class DollarsView extends StatefulWidget {
  const DollarsView({super.key});

  @override
  State<DollarsView> createState() => _DollarsViewState();
}

class _DollarsViewState extends State<DollarsView> {
  final MyStoreBloc _myStoreBloc = di<MyStoreBloc>();
  late final TextEditingController userIdController;
  late final TextEditingController amountController;
  late final TextEditingController agencyIdController;
  final ValueNotifier<int> userType = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    userIdController = TextEditingController();
    agencyIdController = TextEditingController();
    amountController = TextEditingController();

    if (!_myStoreBloc.state.reqState.isLoaded) {
      _myStoreBloc.add(const GetMyStoreEvent());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchBloc = di<SearchUserAgencyBloc>();
      searchBloc.add(SearchUserEvent(id: userIdController.text));
      searchBloc.add(SearchAgencyEvent(id: userIdController.text));
    });
  }

  @override
  void dispose() {
    userIdController.dispose();
    agencyIdController.dispose();
    amountController.dispose();
    userType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChargeToBloc, ChargeToState>(
      bloc: di<ChargeToBloc>(),
      listener: (context, state) {
        if (state.requestState.isLoading) {
          Methods.showToast(context, isLoading: true);
        } else if (state.requestState.isLoaded) {
          Methods.showToast(context,
              message: StringManager.transferSuccess.tr());
          di<MyStoreBloc>().add(const GetMyStoreEvent());
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: context.paddingSymmetric(horizontal: 20),
        width: ScreenUtil().screenWidth,
        child: ValueListenableBuilder(
            valueListenable: userType,
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  164.hBox,
                  TextWidget(
                    StringManager.userType_,
                    style: TextStyle(fontSize: 15.sp, color: ColorManager.black),
                  ),
                  10.hBox,
                  UserTypeSwitcherWidget(userType: userType),
                  15.hBox,
                  const TransferNoteWidget(),
                  15.hBox,
                  Expanded(
                    child: UserTypeContentWidget(
                      userType: userType,
                      agencyIdController: agencyIdController,
                      userIdController: userIdController,
                      amountController: amountController,
                      onPressedTransfer: () {
                        if (!di<ChargeToBloc>().state.requestState.isLoading) {
                          di<ChargeToBloc>().add(
                            SendCharge(
                              context: context,
                              uId: di<SearchUserAgencyBloc>().state.param?.id ??
                                  '',
                              type: userType.value == 1 ? "user" : "agency",
                              usd: amountController.text,
                            ),
                          );
                        }
                      },
                      isDollarsValue: true,
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

void showTransferDialog(
    BuildContext context,
    AgencySmallParam param,
    String? dialogSubTitle,
    String type,
    void Function() onPressedTransfer,
    TextEditingController amountController) {
  bool isValidAmount(String text) {
    // Remove any spaces
    final trimmed = text.trim();

    // Try converting to a number
    final value = double.tryParse(trimmed);

    // Check: not null, greater than 0
    return value != null && value > 0;
  }

  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        backgroundColor: ColorManager.surfaceCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogHeader(param, context),
                5.hBox,
                _buildAmountInput(amountController, dialogSubTitle, context),
                20.hBox,
                Center(
                  child: ButtonWidget(
                    onPressed: () {
                      bool isAmountValid = isValidAmount(amountController.text);
                      if (amountController.text.isEmpty || !isAmountValid) {
                        Methods.showToast(context,
                            message: StringManager.pleaseEnterQuantity.tr(),
                            isError: true);
                        return;
                      } else {
                        final bloc = di<SearchUserAgencyBloc>();
                        bloc.add(
                            UserSelectedEvent(amount: amountController.text));
                        onPressedTransfer.call();
                      }
                    },
                    title: StringManager.transfer.tr(),
                    height: 55.h,
                    width: 200.w,
                    elevation: 0,
                    backgroundColor: ColorManager.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildDialogHeader(AgencySmallParam param, BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      UserImage(
        borderRadius: 50.radius,
        imageSize: 60.h,
        displayName: param.name ?? '',
        image: EndPoints.getImage(param.image ?? ''),
      ),
      10.wBox,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 170.w, minWidth: 1.w),
            child: TextWidget(
              param.name ?? '',
              overflow: TextOverflow.ellipsis,
              style: context.bodyMedium.w600
                  .size(14)
                  .colorExt(ColorManager.black),
            ),
          ),
          5.hBox,
          IdWithCopyIcon(
            userId: param.id ?? '',
            isNeedCopyIcon: true,
            mainAxisAlignment: MainAxisAlignment.start,
            isSpecial:
            (param.specialId != null && (param.specialId ?? '') != ''),
            specialImg: param.idImage ?? '',
            color: param.imageColorEntity?.color,
            img: param.imageColorEntity?.image,
            idColor: ColorManager.black,
            idStyle: context.bodyMedium
                .size(11)
                .w500
                .colorExt(ColorManager.black),
          ),
        ],
      ),
    ],
  );
}

Widget _buildAmountInput(TextEditingController controller,
    String? dialogSubTitle, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextWidget(
        dialogSubTitle ?? StringManager.theAmountOfDollars,
        style: context.bodyMedium
            .size(12)
            .colorExt(ColorManager.black),
      ),
      5.hBox,
      TextInputWidget(
        label: TextWidget(
          StringManager.amount.tr(),
          style: context.bodyLarge
              .colorExt(ColorManager.black),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.green)),
        errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red)),
        StringManager.amountYouWantToTransfer.tr(),
        controller: controller,
        keyboardType: TextInputType.number,
        hintStyle: context.bodyMedium.size(16).colorExt(ColorManager.secondaryText),
      ),
    ],
  );
}

class UserTypeSwitcherWidget extends StatelessWidget {
  final ValueNotifier<int> userType;

  const UserTypeSwitcherWidget({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: userType,
      builder: (context, selectedIndex, _) {
        return Container(
          padding: context.paddingAll(2.0),
          decoration: BoxDecoration(
            color: ColorManager.transparent,
            borderRadius: 30.radius,
            border: Border.all(
                color: ColorManager.textPrimary.withValues(alpha: 0.8),
                width: 1.5),
          ),
          child: Row(
            children: [
              _TabItem(
                title: StringManager.shippingAgents.tr(),
                isSelected: selectedIndex == 0,
                onTap: () => userType.value = 0,
              ),
              _TabItem(
                title: StringManager.user.tr(),
                isSelected: selectedIndex == 1,
                onTap: () => userType.value = 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

class TransferNoteWidget extends StatelessWidget {
  const TransferNoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(AssetsManager.notification, scale: 3.5),
        10.wBox,
        Flexible(
          child: TextWidget(
            StringManager.transferNote.tr(),
            maxLines: 2,
            style: context.bodyMedium
                .size(12)
                .colorExt(ColorManager.black),
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

class UserTypeContentWidget extends StatefulWidget {
  final ValueNotifier<int> userType;
  final TextEditingController agencyIdController;
  final TextEditingController userIdController;
  final TextEditingController amountController;
  final void Function() onPressedTransfer;
  final String? dialogSubTitle;
  final bool isDollarsValue;

  const UserTypeContentWidget({
    super.key,
    required this.userType,
    required this.agencyIdController,
    required this.userIdController,
    required this.amountController,
    required this.onPressedTransfer,
    required this.isDollarsValue,
    this.dialogSubTitle,
  });

  @override
  State<UserTypeContentWidget> createState() => _UserTypeContentWidgetState();
}

class _UserTypeContentWidgetState extends State<UserTypeContentWidget> {
  final searchBloc = di<SearchUserAgencyBloc>();

  void _handleTransferPressed(BuildContext context,
      {required String id,
        String? uuid,
        required String name,
        required String image,
        String? idImage,
        String? specialId,
        ImageColorEntity? imageColorEntity,
        required int userTypeValue,
        String? dialogSubTitle}) {
    final bloc = di<SearchUserAgencyBloc>();
    bloc.add(UserSelectedEvent(
        param: SearchUserAgencyParam(
          name: name,
          id: id,
          uuid: uuid,
          image: image,
          type: widget.userType.value == 1 ? 'user' : 'agency',
        )));
    showTransferDialog(
        context,
        AgencySmallParam(
          id: uuid ?? id,
          name: name,
          image: image,
          idImage: idImage,
          imageColorEntity: imageColorEntity,
          specialId: specialId,
        ),
        dialogSubTitle,
        userTypeValue == 1 ? "user" : "agency",
        widget.onPressedTransfer,
        widget.amountController);
  }

  @override
  void initState() {
    searchBloc.add(const SearchUserEvent(id: ''));
    searchBloc.add(const SearchAgencyEvent(id: ''));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ValueListenableBuilder<int>(
        valueListenable: widget.userType,
        builder: (context, type, _) {
          return IndexedStack(
            index: type,
            children: [
              // Agency Search View
              _UserInputListView(
                controller: widget.agencyIdController,
                hint: StringManager.agencyID.tr(),
                label: StringManager.agencyID.tr(),
                onChanged: (value) =>
                    searchBloc.add(SearchAgencyEvent(id: value ?? '-1')),
                buildList: SizedBox(
                  height: ScreenUtil().screenHeight * 0.28,
                  child:
                  BlocBuilder<SearchUserAgencyBloc, SearchUserAgencyStates>(
                    bloc: searchBloc,
                    buildWhen: (prev, curr) =>
                    prev.agenciesRequestState !=
                        curr.agenciesRequestState ||
                        prev.agencies != curr.agencies,
                    builder: (context, state) {
                      return HandlingDataWidget(
                        title: StringManager.noDataYet,
                        subTitle: StringManager.noDataYet,
                        reqState: state.agenciesRequestState,
                        titleStyle: context.bodyLarge.w600
                            .colorExt(ColorManager.black),
                        subTitleStyle: context.bodyMedium.copyWith(
                            color: ColorManager.black, height: 1.30),
                        buttonBackgroundColors: [
                          ColorManager.primary,
                          ColorManager.primary
                        ],
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: state.agencies?.length ?? 0,
                          itemBuilder: (context, index) {
                            final data =
                                state.agencies?[index].toShippingAgent() ??
                                    const ShippingAgentsFullDataModel();

                            return CardShippingAgent(
                              isDollarsValue: widget.isDollarsValue,
                              shippingAgentsFullDataEntity: data,
                              isFromSearchScreens: true,
                              stopTransferButton: false,
                              withdrawelOnPressed: () {
                                _handleTransferPressed(context,
                                    id: data.id.toString(),
                                    name: data.name ?? "",
                                    image: data.image ?? '',
                                    userTypeValue: type,
                                    dialogSubTitle: widget.dialogSubTitle);
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // User Search View
              _UserInputListView(
                controller: widget.userIdController,
                hint: StringManager.pleaseEnterID.tr(),
                label: StringManager.userID.tr(),
                onChanged: (value) =>
                    searchBloc.add(SearchUserEvent(id: value ?? '-1')),
                buildList: SizedBox(
                  height: ScreenUtil().screenHeight * 0.28,
                  child:
                  BlocBuilder<SearchUserAgencyBloc, SearchUserAgencyStates>(
                    bloc: searchBloc,
                    buildWhen: (prev, curr) =>
                    prev.usersRequestState != curr.usersRequestState ||
                        prev.users != curr.users,
                    builder: (context, state) {
                      return HandlingDataWidget(
                        title: StringManager.noDataYet,
                        subTitle: StringManager.noDataYet,
                        reqState: state.usersRequestState,
                        titleStyle: context.bodyLarge.w600
                            .colorExt(ColorManager.black),
                        subTitleStyle: context.bodyMedium.copyWith(
                            color: ColorManager.black, height: 1.30),
                        buttonBackgroundColors: [
                          ColorManager.primary,
                          ColorManager.primary
                        ],
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: state.users?.length ?? 0,
                          itemBuilder: (context, index) {
                            if ((state.users ?? []) != []) {
                              final user = state.users?[index];
                              if (user == null) return const SizedBox.shrink();
                              return SearchUserRow(
                                user: UserEntity(
                                  profile: ProfileRoomEntity(image: user.image),
                                  name: user.name,
                                  id: user.id,
                                  uuid: user.uuid,
                                  level: user.level,
                                  imageColorEntity: user.imageColorEntity,
                                  idImage: user.idImage,
                                  colorName: user.coloredName,
                                  // vip:VipCenterEntity(colorName: user.coloredName)
                                ),
                                endIcon: Column(
                                  children: [
                                    ButtonWidget(
                                      title: StringManager.transfer.tr(),
                                      onPressed: () {
                                        _handleTransferPressed(context,
                                            uuid: user.uuid.toString(),
                                            id: user.id.toString(),
                                            name: user.name,
                                            image: user.image,
                                            imageColorEntity:
                                            user.imageColorEntity,
                                            idImage: user.idImage ?? '',
                                            specialId: user.idImage ?? '',
                                            userTypeValue: type,
                                            dialogSubTitle:
                                            widget.dialogSubTitle);
                                      },
                                      isFittedBox: false,
                                      padding: EdgeInsets.zero,
                                      paddingButton: EdgeInsets.zero,
                                      width: 70.w,
                                      height: 25.h,
                                      fontSize: 12,
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserInputListView extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final dynamic Function(String?) onChanged;
  final Widget buildList;

  _UserInputListView({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    required this.buildList,
  });

  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextInputWidget(
          '',
          label: TextWidget(
            label,
            style: context.bodyLarge.colorExt(
              ColorManager.black,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          controller: controller,
          hintStyle: context.bodyMedium.size(16).colorExt(ColorManager.secondaryText),
          onChanged: (p0) {
            if (_debounce?.isActive ?? false) _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
              onChanged.call(p0);
            });
          },
          keyboardType: TextInputType.number,
        ),
        15.hBox,
        buildList
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: context.paddingSymmetric(vertical: 12.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? ColorManager.primary : ColorManager.transparent,
            borderRadius: 30.radius,
          ),
          child: TextWidget(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? ColorManager.buttonTextColor
                  : ColorManager.black.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
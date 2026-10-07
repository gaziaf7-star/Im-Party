part of 'package:general/src/features/agency/presentation/charge_agency/view/component/shipping_agent_requests_details/view/shipping_agent_requests_details.dart';

class CardUserMoneyRequest extends StatefulWidget {
  final ShippingAgentRequestEntity shippingAgentRequestEntity;
  final bool? isWaiting;
  final bool? isAccepted;
  final TabController controller;

  const CardUserMoneyRequest({
    super.key,
    required this.shippingAgentRequestEntity,
    required this.controller,
    this.isWaiting,
    this.isAccepted,
  });

  @override
  State<CardUserMoneyRequest> createState() => CardUserMoneyRequestState();
}

class CardUserMoneyRequestState extends State<CardUserMoneyRequest> {
  ValueNotifier<bool> isShowNotes = ValueNotifier<bool>(false);

  //static ValueNotifier<int> confirmeTransfer = ValueNotifier<int>(-1);

  static bool requestAction = false;
  static ShippingAgentRequestEntity shippingAgentRequestEntityOnAction =
      const ShippingAgentRequestEntity();

  @override
  void dispose() {
    di<GetShippingAgentsRequestsBloc>()
        .add(const UnPickConfirmationImageEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: ScreenUtil().screenWidth,
      // height: ScreenUtil().screenHeight*0.15,
      margin: context.paddingSymmetric(vertical: 5),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: 8.radius,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha:0.2), // Shadow color
        //     offset: const Offset(2, 4), // Shadow offset (x, y)
        //     blurRadius: 6, // Spread of the shadow
        //     spreadRadius: 2, // Intensity around the edges
        //   ),
        // ],
      ),
      child: Column(
        children: [
          _buildRequestContainer(context),
          (di<GetShippingAgentsRequestsBloc>().state.requestId ==
                  widget.shippingAgentRequestEntity.id)
              ? _buildConfirmationContainer(context)
              : const SizedBox()
        ],
      ),
    );
  }

  Widget _buildRequestContainer(BuildContext context) {
    return Container(
      width: ScreenUtil().screenWidth,
      margin: context.paddingAll(5),
      padding: context.paddingAll(5),
      child: Row(
        children: [
          InkWell(
            onTap: () => Methods().userProfileNavigator(
              context: context,
              userId: widget.shippingAgentRequestEntity.hostId.toString(),
            ),
            child: UserImage(
              imageSize: ScreenUtil().screenHeight * 0.07,
              boxFit: BoxFit.cover,
              image: widget.shippingAgentRequestEntity.hostImage ?? "",
              displayName: widget.shippingAgentRequestEntity.hostName ?? '',
            ),
          ),
          11.wBox,
          Expanded(child: _buildUserInfo(context)),

          // const Spacer(),
          Expanded(child: _buildCountryAndPaymentInfo()),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientTextVip(
          width: ScreenUtil().screenWidth * 0.36,
          color: ColorManager.textPrimary,
          textOverflow: TextOverflow.ellipsis,
          text: widget.shippingAgentRequestEntity.hostName ?? '',
          textStyle: context.bodyLarge.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          isVip: widget.shippingAgentRequestEntity.haseColoredName ?? false,
        ),
        2.hBox,
        IdWithCopyIcon(
          userId: widget.shippingAgentRequestEntity.hostUuid.toString(),
          idStyle: context.bodyMedium
              .size(12)
              .w500
              .colorExt(ColorManager.secondaryText),
          mainAxisAlignment: MainAxisAlignment.start,
          //  color: Colors.white,
          //color: Colors.black,
        ),
        4.hBox,
        _buildUserContactInfo(context),
      ],
    );
  }

  Widget _buildUserContactInfo(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Methods().navigatorToUserChat(
            userEntity: UserEntity(
              id: widget.shippingAgentRequestEntity.hostId,
              name: widget.shippingAgentRequestEntity.hostName,
              profile: ProfileRoomModel(
                image: widget.shippingAgentRequestEntity.hostImage,
              ),
            ),
            context: context,
          ),
          child: Center(
            child: Image.asset(
              AssetsManager.chatWithHim,
              scale: 4,
              color: ColorManager.primary,
            ),
          ),
        ),
        5.wBox,
        TextWidget('${_formatUsdAmount()} \$',
            style: context.bodyMedium
                .size(15)
                .w600
                .colorExt(ColorManager.primary)),
        //    Image.asset(AssetsManager.dollar, scale: 30),
      ],
    );
  }

  String _formatUsdAmount() {
    return (widget.shippingAgentRequestEntity.usd ==
                (widget.shippingAgentRequestEntity.usd ?? 0.0).toInt()
            ? (widget.shippingAgentRequestEntity.usd ?? 0.0).toInt()
            : widget.shippingAgentRequestEntity.usd)
        .toString();
  }

  Widget _buildCountryAndPaymentInfo() {
    return Column(
      children: [
        Row(
          children: [
            _buildCountryInfo(),
            5.wBox,
            _buildPaymentInfo(),
          ],
        ),
        5.hBox,
        if (widget.isWaiting == true) _buildActionButtons(),
        if (widget.isAccepted == true) _buildConfirmationButton(),
      ],
    );
  }

  Widget _buildCountryInfo() {
    return Column(
      children: [
        ImageViewWidget(
          url: widget.shippingAgentRequestEntity.countryFlag ?? '',
          width: 30.w,
          height: 30.h,
          boxFit: BoxFit.cover,
          radius: 11,
        ),
        4.hBox,
        SizedBox(
          width: ScreenUtil().screenWidth * 0.16,
          child: Center(
            child: TextWidget(
              widget.shippingAgentRequestEntity.countryName ?? '',
              style: context.bodyMedium.size(11).w600,
              overflow: TextOverflow.clip,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return Column(
      children: [
        ImageViewWidget(
          url: widget.shippingAgentRequestEntity.paymentGatewayImage ?? '',
          width: 30.w,
          height: 30.h,
          boxFit: BoxFit.cover,
          radius: 11,
        ),
        4.hBox,
        SizedBox(
          width: ScreenUtil().screenWidth * 0.16,
          child: Center(
            child: FittedBox(
              child: TextWidget(
                widget.shippingAgentRequestEntity.paymentGateway ?? '',
                style: context.bodyMedium.size(11).w600,
                overflow: TextOverflow.clip,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAcceptButton(),
        30.wBox,
        _buildDeclineButton(),
      ],
    );
  }

  Widget _buildAcceptButton() {
    return InkWell(
      onTap: () {
        di<MakeShippingAgentRequestActionBloc>().add(
          ShippingAgentRequestActionEvent(
              context: context,
              param: ShippingAgentRequestActionParam(
                requestId: widget.shippingAgentRequestEntity.id ?? 0,
                actionType: "1",
              ),
              controller: widget.controller),
        );
        requestAction = true;
        shippingAgentRequestEntityOnAction = widget.shippingAgentRequestEntity;
      },
      child: Container(
        padding: context.paddingAll(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().screenWidth * 0.05),
          color: Colors.green,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDeclineButton() {
    return InkWell(
      onTap: () {
        di<MakeShippingAgentRequestActionBloc>().add(
          ShippingAgentRequestActionEvent(
              context: context,
              param: ShippingAgentRequestActionParam(
                requestId: widget.shippingAgentRequestEntity.id ?? 0,
                actionType: "0",
              ),
              controller: widget.controller),
        );
        requestAction = false;
        shippingAgentRequestEntityOnAction = widget.shippingAgentRequestEntity;
      },
      child: Container(
        padding: context.paddingAll(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().screenWidth * 0.05),
          color: Colors.red,
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildConfirmationButton() {
    return ButtonWidget(
      title: StringManager.addConfirmation.tr(),
      onPressed: () {
        di<GetShippingAgentsRequestsBloc>().add(HandleConfirmationBodyEvent(
            id: widget.shippingAgentRequestEntity.id));
        // if (widget.shippingAgentRequestEntity.isConfirmationBodyOpen==true) {
        //   confirmeTransfer.value = -1;
        // } else {
        //   confirmeTransfer.value = widget.shippingAgentRequestEntity.id ?? -1;
        // }
      },
      width: 120.w,
      height: 25.h,
      backgroundColor: ColorManager.primary,
      fontSize: 10.sp,
      isFittedBox: false,
    );
  }

  // Widget _buildNotesContainer() {
  //   return InkWell(
  //     onTap: () {
  //       isShowNotes.value = !isShowNotes.value;
  //     },
  //     child: ValueListenableBuilder(
  //       valueListenable: isShowNotes,
  //       builder: (BuildContext context, bool value, Widget? child) {
  //         return isShowNotes.value
  //             ? Container(
  //                 padding: context.paddingAll(15),
  //                 width: ScreenUtil().screenWidth,
  //                 margin: EdgeInsets.only(
  //                   left: 5.w,
  //                   right: 5.w,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   border: Border.all(color: ColorManager.pink, width: 1.5),
  //                   borderRadius: 5.radius,
  //                 ),
  //                 child: TextWidget(
  //                   widget.shippingAgentRequestEntity.note ?? '',
  //                   style: TextStyle(color: Colors.grey, fontSize: 17.sp),
  //                   overflow: TextOverflow.clip,
  //                 ),
  //               )
  //             : Container(
  //                 width: ScreenUtil().screenWidth,
  //                 height: ScreenUtil().screenHeight * 0.04,
  //                 margin: EdgeInsets.only(
  //                   left: 5.w,
  //                   right: 5.w,
  //                 ),
  //                 decoration: BoxDecoration(
  //                     border: Border.all(color: ColorManager.pink, width: 1.5),
  //                     borderRadius: 5.radius),
  //                 child: Center(
  //                   child: TextWidget(
  //                     StringManager.notesAppear.tr(),
  //                     style: TextStyle(
  //                       color: Colors.grey.withValues(alpha:0.8),
  //                       fontSize: 16.sp,
  //                     ),
  //                   ),
  //                 ),
  //               );
  //       },
  //     ),
  //   );
  // }

  Widget _buildConfirmationContainer(BuildContext context) {
    return Container(
      width: ScreenUtil().screenWidth,
      margin: context.paddingOnly(bottom: 10, end: 5, start: 5),
      padding: context.paddingSymmetric(
        horizontal: 11,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: ColorManager.orangeIndcator, width: 1.5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
      ),
      child: Column(
        children: [
          TextWidget(
            StringManager.transferConfirmation.tr(),
            style: context.bodyMedium.size(12),
            overflow: TextOverflow.clip,
          ),
          14.wBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildConfirmationImagePicker(),
              _buildConfirmationDoneButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationImagePicker() {
    return BlocBuilder<GetShippingAgentsRequestsBloc, GetShippingAgentStates>(
      bloc: di<GetShippingAgentsRequestsBloc>(),
      buildWhen: (prev, curr) => prev.image != curr.image,
      builder: (context, state) {
        return InkWell(
          onTap: () => di<GetShippingAgentsRequestsBloc>()
              .add(const PickConfirmationImageEvent(quality: 50)),
          child: state.image != null
              ? Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(state.image!),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: (0.5)),
                      ),
                      borderRadius: 12.radius),
                  height: ScreenUtil().screenHeight * 0.1,
                  width: ScreenUtil().screenHeight * 0.1,
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: 15.radius,
                    color: ColorManager.white.withValues(alpha: (0.6)),
                  ),
                  height: ScreenUtil().screenHeight * 0.1,
                  width: ScreenUtil().screenHeight * 0.1,
                  child: Icon(
                    Icons.add,
                    size: 50.w,
                    color: ColorManager.black.withValues(alpha: (0.3)),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildConfirmationDoneButton(BuildContext context) {
    return ButtonWidget(
      title: StringManager.done.tr(),
      onPressed: () {
        if (di<GetShippingAgentsRequestsBloc>().state.image != null) {
          di<GetShippingAgentsRequestsBloc>()
              .add(const HandleConfirmationBodyEvent());
          di<SendConfirmationRequestBloc>().add(
            SendConfirmationRequestEvent(
                param: SendConfirmationRequestParam(
                  requestId: widget.shippingAgentRequestEntity.id ?? 0,
                  image: di<GetShippingAgentsRequestsBloc>().state.image!,
                ),
                context: context,
                controller: widget.controller),
          );
          shippingAgentRequestEntityOnAction =
              widget.shippingAgentRequestEntity;

          di<GetShippingAgentsRequestsBloc>()
              .add(const UnPickConfirmationImageEvent());
        } else {
          Methods.showToast(context,
              message: StringManager.addImage.tr(), isError: true);
        }
      },
      width: 100.w,
      height: 30.h,
    );
  }
}

part of 'package:general/src/features/agency/presentation/charge_agency/view/component/details_charge_agency/view/details_charge_agency_screen.dart';

class _TransactionDetailsDialog extends StatelessWidget {
  const _TransactionDetailsDialog({
    required this.data,
    required this.type,
  });

  final DetailsChargeAgencyModel data;
  final bool type;

  static void show(
      BuildContext context, DetailsChargeAgencyModel data, bool type) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _TransactionDetailsDialog(data: data, type: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: ColorManager.transparent,
        child: Container(
          width: ScreenUtil().screenWidth * 0.88,
          decoration: BoxDecoration(
            color: ColorManager.surfaceCardColor,
            borderRadius: 20.radius,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                Padding(
                  padding: context.paddingSymmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Divider(color: ColorManager.borderColor, height: 1),
                      16.hBox,
                      _buildInfoRow(
                        context,
                        'ID',
                        '#${data.id ?? 0}',
                      ),
                      10.hBox,
                      _buildInfoRow(
                        context,
                        StringManager.date.tr(),
                        Methods.formatTime(data.time ?? ''),
                      ),
                      10.hBox,
                      _buildInfoRow(
                        context,
                        StringManager.type.tr(),
                        type
                            ? StringManager.received.tr()
                            : StringManager.send.tr(),
                      ),
                      20.hBox,
                      const Divider(color: ColorManager.borderColor, height: 1),
                      16.hBox,
                      _TransactionUserRow(
                        title: StringManager.send.tr(),
                        user: data.senderEntity,
                        onTap: () =>
                            _navigateToProfile(context, data.senderEntity),
                      ),
                      12.hBox,
                      const Divider(color: ColorManager.borderColor, height: 1),
                      12.hBox,
                      _TransactionUserRow(
                        title: StringManager.received.tr(),
                        user: data.receiverEntity,
                        onTap: () =>
                            _navigateToProfile(context, data.receiverEntity),
                      ),
                      20.hBox,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: ColorManager.green.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 50.w,
                height: 50.h,
                decoration: const BoxDecoration(
                  color: ColorManager.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: ColorManager.white,
                  size: 30.sp,
                ),
              ),
            ),
          ),
          14.hBox,
          TextWidget(
            StringManager.theDetails.tr(),
            style: context.bodyLarge.w600
                .size(18)
                .colorExt(ColorManager.textPrimary),
          ),
          6.hBox,
          TextWidget(
            Methods().convertToAbbreviatedString(data.value ?? 0).toString(),
            style: context.bodyLarge.bold
                .size(28)
                .colorExt(ColorManager.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(
          label,
          style: context.bodyMedium
              .size(13)
              .w400
              .colorExt(ColorManager.secondaryText),
        ),
        Flexible(
          child: TextWidget(
            value,
            style: context.bodyMedium
                .size(13)
                .w600
                .colorExt(ColorManager.textPrimary),
          ),
        ),
      ],
    );
  }

  void _navigateToProfile(BuildContext context, ReceiverEntity? user) {
    if (user == null) return;
    Navigator.pop(context);
    final isAgency = user.type == 'agency';
    if (isAgency) {
      di<GetChargeAgencyBloc>().add(
        GetChargeAgencyEvent(
          agencyId: int.parse((user.id ?? 0).toString()),
          isFirstLoading: true,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShowShippingAgency(
            agencyData: null,
            isProfile: true,
            id: int.parse((user.id ?? 0).toString()),
          ),
        ),
      );
    } else {
      Methods().userProfileNavigator(
        context: context,
        userId: (user.id ?? '').toString(),
      );
    }
  }
}

class _TransactionUserRow extends StatelessWidget {
  const _TransactionUserRow({
    required this.title,
    required this.user,
    required this.onTap,
  });

  final String title;
  final ReceiverEntity? user;
  final VoidCallback onTap;

  bool get _isAgency => user?.type == 'agency';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          10.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  title,
                  style: context.bodyMedium
                      .size(11)
                      .w400
                      .colorExt(ColorManager.secondaryText),
                ),
                3.hBox,
                GradientTextVip(
                  isVip: !_isAgency && (user?.colorNamed ?? '') != '',
                  width: ScreenUtil().screenWidth * 0.45,
                  text: user?.name ?? '',
                  color: (!_isAgency
                          ? Methods.safeHexColor(user?.colorNamed)
                          : null) ??
                      ColorManager.textPrimary,
                  mainAxisAlignment: MainAxisAlignment.start,
                  textAlign: TextAlign.start,
                  textStyle: context.bodyMedium.size(13).w600.colorExt(
                        (!_isAgency
                                ? Methods.safeHexColor(user?.colorNamed)
                                : null) ??
                            ColorManager.textPrimary,
                      ),
                ),
                3.hBox,
                IdWithCopyIcon(
                  userId: user?.uuid ?? "",
                  idStyle: context.bodyMedium
                      .size(12)
                      .colorExt(ColorManager.secondaryText),
                  idColor: ColorManager.secondaryText,
                  isNeedCopyIcon: true,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: ColorManager.blackColor.withValues(alpha: 0.3),
            size: 16.sp,
          ),
        ],
      ),
    );
  }
}

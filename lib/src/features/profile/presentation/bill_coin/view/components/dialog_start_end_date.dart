import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/bill_coin/bloc/bill_bloc.dart';

class DialogStartEndDate extends StatelessWidget {
  DialogStartEndDate({super.key, required this.type});

  String start = '';
  String end = '';
  final String type;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillBloc, BillState>(
      bloc: di<BillBloc>(),
      buildWhen: (prev, curr) => prev.startDate != curr.startDate || prev.endDate != curr.endDate,
      builder: (context, state) {
        return Container(
          padding: context.paddingSymmetric(horizontal: 10),
          width: ScreenUtil().screenWidth,
          height: ScreenUtil().screenHeight * 0.2,
          decoration: BoxDecoration(
            color: ColorManager.scaffoldBackgroundColor,
            borderRadius: 16.radius,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  TextWidget(
                    StringManager.selectedStart.tr(),
                    style: context.bodyMedium.colorExt(ColorManager.textPrimary)
                        .bold,
                  ),
                  10.wBox,
                  TextWidget(
                    state.startDate,
                    style:
                        context.bodyMedium.colorExt(ColorManager.secondaryText),
                  ),
                  const Spacer(),
                  ButtonWidget(
                    onPressed: () {
                      DateTime selectedStartDate = state.endDate.isNotEmpty
                          ? DateTime.parse(state.endDate)
                          : DateTime.now();
                      start = selectedStartDate.toString().split(' ')[0];
                      Methods.showCupertinoDatePicker(
                          context: context,
                          initialDateTime: selectedStartDate,
                          onDateTimeChanged: (value) {
                            start = value.toString().split(' ')[0];
                          },
                          onConfirm: () {
                            di<BillBloc>().add(BillSelectEvent(start: start));
                            Navigator.pop(context);
                          });
                    },
                    title: StringManager.select.tr(),
                    radius: 30.r,
                    fontWeight: FontWeight.w400,
                    titleColor: ColorManager.primary,
                    fontSize: 13,
                    borderColor: ColorManager.primary,
                    backgroundColor: ColorManager.transparent,
                    width: 100.w,
                    height: 35.h,
                  ),
                ],
              ),
              10.hBox,
              Row(
                children: [
                  TextWidget(
                    '${StringManager.selectedEnd.tr()}  ',
                    style: context.bodyMedium.colorExt(ColorManager.textPrimary).bold,
                  ),
                  TextWidget(
                    state.endDate,
                    style:
                        context.bodyMedium.colorExt(ColorManager.secondaryText),
                  ),
                  const Spacer(),
                  ButtonWidget(
                    onPressed: () {
                      DateTime selectedEndDate = state.endDate.isNotEmpty
                          ? DateTime.parse(state.endDate)
                          : DateTime.now();
                      end = selectedEndDate.toString().split(' ')[0];
                      Methods.showCupertinoDatePicker(
                          initialDateTime:selectedEndDate,
                          context: context,
                          onDateTimeChanged: (value) {
                            end = value.toString().split(' ')[0];
                          },
                          onConfirm: () {
                            di<BillBloc>().add(BillSelectEvent(end: end));
                            Navigator.pop(context);
                          });
                    },
                    title: StringManager.select.tr(),
                    radius: 30.r,
                    fontWeight: FontWeight.w400,
                    titleColor: ColorManager.primary,
                    fontSize: 13,
                    borderColor: ColorManager.primary,
                    backgroundColor: ColorManager.transparent,
                    width: 100.w,
                    height: 35.h,
                  ),
                ],
              ),
              10.hBox,
              ButtonWidget(
                onPressed: () {
                  if (start.isEmpty) {
                    Methods.showToast(context,
                        message: 'please select start date');
                  } else if (end.isEmpty) {
                    Methods.showToast(context,
                        message: 'please select end date');
                  } else {
                    if (type == 'givin') {
                      di<BillBloc>().add(GetBillGivingEvent(
                          param: BillParam(
                              type: 'givin', startDate: start, endDate: end)));
                    }
                    if (type == 'receving') {
                      di<BillBloc>().add(GetBillReceivedEvent(
                          param: BillParam(
                              type: 'receving',
                              startDate: start,
                              endDate: end)));
                    }
                    if (type == 'recharge') {
                      di<BillBloc>().add(GetBillRechargeEvent(
                          param: BillParam(
                              type: 'recharge',
                              startDate: start,
                              endDate: end,shippingType: 'shipping')));
                    }
                    di<BillBloc>()
                        .add(const BillSelectEvent(start: '', end: ''));
                    Navigator.pop(context);
                  }
                },
                title: StringManager.save.tr(),
                backgroundColor: ColorManager.primary,
                width: 100.w,
                height: 35.h,
                radius: 20.r,
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/agency.dart';

import 'date_dilog.dart';
import 'linear_date_picker.dart';

class DateWidget extends StatefulWidget {
  const DateWidget({
    super.key,
    this.isManager = true,
    this.isNeedTitle = true,
    this.selectedDate,
    this.onPressed,
    required this.isFirstNotifier,
  });

  final void Function()? onPressed;
  final bool isManager;
  final bool isNeedTitle;
  final bool isFirstNotifier;
  final ValueChanged<String>? selectedDate;

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  String selectedDate = "";

  @override
  void initState() {
    super.initState();
    selectedDate = widget.isManager
        ? "${DateTime.now().year}/ ${DateTime.now().month}"
        : "${DateTime.now().year}/ ${DateTime.now().month}";
  }

  @override
  Widget build(BuildContext context) {
    final isWithdrawVisible = (StringManager.userType[1]! ||
        (di<InformationAgencyBloc>().state.data?.userStates ?? 0) == 1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDateSelector(context),
        //   if (StringManager.userType[1]! ||
        //                     (di<InformationAgencyBloc>().state.data?.userStates ?? 0) ==
        //                         1)
        //                   TextWidget(StringManager.withdrawMySalary.tr()),
        if (widget.isNeedTitle == true)
          SizedBox(
            width: ScreenUtil().screenWidth - 140.w,
            child: TextWidget(
              StringManager.updateTimeEvery.tr() +
                  (isWithdrawVisible
                      ? ' ${StringManager.salaryNote.tr()}'
                      : ''),
              style: context.bodyLarge.w600.size(13),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return InkWell(
      onTap: () => _showDateDialog(context),
      child: Container(
        padding: context.paddingSymmetric(
          horizontal: 5,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: ColorManager.primary,
          borderRadius: 5.radius,
        ),
        child: Center(
          child: Row(
            children: [
              Image.asset(
                AssetsManager.dateIcon,
                scale: 4,
              ),
              4.wBox,
              ValueListenableBuilder(
                valueListenable: firstTabAgencyTimeFilter,
                builder: (context, firstValue, child) {
                  return ValueListenableBuilder(
                    valueListenable: secondTabAgencyTimeFilter,
                    builder: (context, secondValue, child) {
                      return TextWidget(
                          formatYearMonth(widget.isFirstNotifier == true
                              ? firstValue
                              : secondValue),
                          //selectedDate,
                          style: context.bodySmall
                              .size(9)
                              .w500
                              .colorExt(ColorManager.onDark));
                    },
                  );
                },
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 15,
              ),
            ], //CupertinoIcons
          ),
        ),
      ),
    );
  }

  String formatYearMonth(String input) {
    final parts = input.split('/');
    if (parts.length != 2) return input; // invalid format

    final year = parts[0];
    final month =
        int.tryParse(parts[1])?.toString(); // removes leading zero if any

    if (month == null) return input; // invalid month part

    return '$year / $month';
  }

  Future<void> _showDateDialog(BuildContext context) async {
    await dailogDate(
      context: context,
      widget: Container(
        height: 250.h,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.only(
            topLeft: 30.radiusCircular,
            topRight: 30.radiusCircular,
          ),
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            _buildDialogHeader(context),
            _buildDatePicker(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: TextWidget(
            StringManager.cancel.tr(),
            style: context.bodyMedium.size(15).colorExt(ColorManager.textPrimary),
          ),
        ),
        TextButton(
          onPressed: widget.onPressed ??
              () {
                _onConfirmDateSelection();
                Navigator.pop(context);
              },
          child: TextWidget(
            StringManager.confirm.tr(),
            style: context.bodyMedium.size(15).colorExt(ColorManager.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      padding: context.paddingOnly(
        bottom: 30,
      ),
      child: PersianLinearDatePicker(
        showLabels: false,
        dateChangeListener: (String value) {
          widget.selectedDate?.call(value);
        },
        showDay: false,
        columnWidth: 130.w,
        selectedRowStyle: Theme.of(context).textTheme.headlineLarge!.colorExt(ColorManager.textPrimary),
        unselectedRowStyle: context.bodyLarge.colorExt(ColorManager.textPrimary),
        isPersian: false,
      ),
    );
  }

  void _onConfirmDateSelection() {
    if (widget.isManager) {
      di<AgencyTimeBloc>().add(
        AgencyHistoryEvent(
          month: selectedDate.split('/')[1],
          year: selectedDate.split('/')[0],
        ),
      );
      di<InformationAgencyBloc>().add(
        InformationAgencyEvent(
            month: selectedDate.split('/')[1],
            year: selectedDate.split('/')[0],
            isFirstLoading: false),
      );
    } else {
      di<AgencyHostReportBloc>().add(
        AgencyHostReportEvent(
          mounth: selectedDate.split("/").last.toString(),
          year: selectedDate.split("/").first.toString(),
        ),
      );
    }
  }
}

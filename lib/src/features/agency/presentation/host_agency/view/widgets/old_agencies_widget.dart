/*
import 'package:general/src/core/index.dart';

import '../component/agency_manager_screen/view/agency_manager_screen.dart';
import 'date_dilog.dart';
import 'linear_date_picker.dart';

class OldAgenciesWidget extends StatefulWidget{
  @override
  State<OldAgenciesWidget> createState() => _OldAgenciesWidgetState();
}

class _OldAgenciesWidgetState extends State<OldAgenciesWidget> {


  @override
  Widget build(BuildContext context) {

    return _buildDateSelector(context);
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
                valueListenable: agencyIdsFilter,
                builder: (context, firstValue, child) {
                 return   TextWidget(
                     agencyIdsFilter.value,
                     //selectedDate,
                     style: context.bodySmall
                         .size(9)
                         .w500
                         .colorExt(ColorManager.textPrimary));
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
        width: MediaQuery
            .of(context)
            .size
            .width,
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
            style:
            context.bodyMedium.size(15).colorExt(ColorManager.textPrimary),
          ),
        ),
        TextButton(
          onPressed: () {






          }
                 ,
          child: TextWidget(
            StringManager.confirm.tr(),
            style:
            context.bodyMedium.size(15).colorExt(ColorManager.primary),
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
      child:  WheelChooser.custom(
        onValueChanged: (a) => print(a),

        children: <Widget>[
          Text("data1"),
          Text("data2"),
          Text("data3"),
        ],
      )
    );
  }


}*/

part of 'package:general/src/features/agency/presentation/charge_agency/view/component/details_charge_agency/view/details_charge_agency_screen.dart';

class _CustomRowData extends StatelessWidget {
  const _CustomRowData({
    required this.img,
    required this.type,
    required this.name,
    required this.uuid,
    required this.id,
    required this.value,
    required this.stringValue,
    required this.date,
    required this.isAgency,
    required this.idImage,
    required this.coloredName,
    required this.imageColorEntity,
    this.model,
  });

  final String? img;
  final String? uuid;
  final String? id;
  final String? name;
  final int? value;
  final String? stringValue;
  final String? date;
  final bool? isAgency;
  final String? idImage;
  final String? coloredName;
  final ImageColorEntity? imageColorEntity;
  final bool type;
  final DetailsChargeAgencyModel? model;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (model != null) {
          _TransactionDetailsDialog.show(context, model!, type);
        }
      },
      child: Container(
        padding: context.paddingSymmetric(horizontal: 15, vertical: 5),
        margin: context.paddingSymmetric(vertical: 5, horizontal: 7),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: 15.radius,
          border: Border.all(
            color: ColorManager.transparent,
          ),
        ),
        width: ScreenUtil().screenWidth,
        child: Row(
          children: [
            Row(
              children: [
                SizedBox(
                  height: 55.h,
                  width: 55.w,
                  child: ImageViewWidget(
                    url: EndPoints.getImage(img ?? ''),
                    displayName: name ?? '',
                    height: 55.h,
                    width: 55.w,
                    radius: isAgency == true ? 0 : 60,
                  ),
                ),
                10.wBox,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientTextVip(
                      isVip: isAgency == false ? coloredName != "" : false,
                      width: ScreenUtil().screenWidth * 0.5,
                      text: name ?? "",
                      color: isAgency == false
                          ? coloredName != ""
                              ? Color((int.parse(
                                  coloredName!.replaceAll('#', '0xff'))))
                              : ColorManager.textPrimary
                          : ColorManager.textPrimary,
                      mainAxisAlignment: MainAxisAlignment.center,
                      textAlign: TextAlign.center,
                      textStyle: context.bodyMedium.size(14).w600.colorExt(
                            isAgency == false
                                ? coloredName != ""
                                    ? Color((int.parse(
                                        coloredName!.replaceAll('#', '0xff'))))
                                    : ColorManager.textPrimary
                                : ColorManager.textPrimary,
                          ),
                    ),
                    7.hBox,
                    IdWithCopyIcon(
                      userId: uuid ?? "",
                      idStyle: context.bodyMedium.size(12).colorExt(
                          ColorManager.secondaryText),
                      idColor: ColorManager.secondaryText,
                      isNeedCopyIcon: true,
                      isSpecial:
                          isAgency == false ? ((idImage ?? '') != '') : false,
                      specialImg: isAgency == false ? idImage ?? '' : '',
                      color: isAgency == false ? imageColorEntity?.color : null,
                      img: isAgency == false ? imageColorEntity?.image : null,
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                    TextWidget(
                      Methods.formatTime(date ?? ""),
                      style: context.bodyMedium.size(12).colorExt(
                          ColorManager.secondaryText),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              height: 20.h,
              width: 50.w,
              decoration: BoxDecoration(
                color: type
                    ? (Colors.green.withValues(alpha: 0.2))
                    : (Colors.red.withValues(alpha: 0.2)),
                borderRadius: 3.radius,
              ),
              child: Center(
                child: FittedBox(
                  child: TextWidget(
                    Methods().convertToAbbreviatedString(value ?? 0).toString(),
                    style: context.bodyMedium.size(16).bold.colorExt(
                          type ? Colors.green : Colors.red,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

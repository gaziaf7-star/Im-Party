import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/info_charge_agency/bloc/manager_get_charge_agency_info/get_charge_agency_bloc.dart';

class InformationCard extends StatelessWidget {
  const InformationCard({
    super.key,
    required this.state,
  });

  final GetChargeAgencyStates state;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetChargeAgencyBloc, GetChargeAgencyStates>(
      bloc: di<GetChargeAgencyBloc>(),
      buildWhen: (prev, curr) =>
          prev.data != curr.data ||
          prev.myChargeAgencyData != curr.myChargeAgencyData,
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            Clipboard.setData(
                ClipboardData(text: state.data?.id.toString() ?? ''));
            Methods.showToast(
              context,
              message: StringManager.theTextHasBeenCopied.tr(),
            );
          },
          child: SizedBox(
            height: 150,
            width: ScreenUtil().screenWidth,
            // padding: context.paddingAll(10),

            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  45.hBox,
                  Container(
                    padding: context.paddingAll(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorManager.primary),
                      borderRadius: 10.radius,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextWidget(
                          'ID: ${state.myChargeAgencyData?.id.toString() ?? ''}',
                          style: context.titleLarge
                              .colorExt(ColorManager.textPrimary),
                        ),
                        5.wBox,
                        Icon(
                          Icons.copy,
                          color: ColorManager.primary,
                        ),
                      ],
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
}

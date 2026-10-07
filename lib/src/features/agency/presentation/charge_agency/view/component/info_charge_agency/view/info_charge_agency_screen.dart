import 'package:flutter/cupertino.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/country_icon.dart';
import 'package:general/src/features/agency/agency.dart';

part 'components/choose_country_drop_down.dart';
part 'components/choose_payment_drop_down.dart';
part 'components/country_selection_body.dart';
part 'components/payment_selection_body.dart';
part 'components/pick_image_body.dart';
part 'components/save_button_body.dart';
part 'widgets/payment_selectable_item.dart';
part 'widgets/row_builder_widget.dart';

class InfoChargeAgencyScreen extends StatefulWidget {
  const InfoChargeAgencyScreen({super.key});

  @override
  State<InfoChargeAgencyScreen> createState() => _InfoChargeAgencyScreenState();
}

class _InfoChargeAgencyScreenState extends State<InfoChargeAgencyScreen> {
  final _updateBloc = di<UpdateChargeAgencyBloc>();
  final _getChargeAgencyBloc = di<GetChargeAgencyBloc>();

  @override
  void initState() {
    _updateBloc.add(SetNameEvent(
      name: _getChargeAgencyBloc.state.myChargeAgencyData?.name ?? '',
    ));

    super.initState();
  }

  @override
  void dispose() {
    if (_updateBloc.state.showPayments == true) {
      _updateBloc.add(const ShowPaymentsEvent());
    }

    if (_updateBloc.state.showCountries == true) {
      _updateBloc.add(const ShowCountriesEvent());
    }

    if (_updateBloc.state.pathImg.isNotEmpty) {
      _updateBloc.add(const UnPickImageEvent());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBgAlt,
      appBar: AppBarWidget(
        title: Row(
          children: [
            const Spacer(),
            Image.asset(
              AssetsManager.info,
              scale: 3.0,
              color: ColorManager.black,
            ),
            5.wBox,
            TextWidget(
              StringManager.information.tr(),
              style: context.bodyMedium.w600.size(20),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
      body: BlocBuilder<GetChargeAgencyBloc, GetChargeAgencyStates>(
        bloc: _getChargeAgencyBloc,
        buildWhen: (prev, curr) => prev.requestState != curr.requestState || prev.myChargeAgencyData != curr.myChargeAgencyData || prev.data != curr.data,
        builder: (context, state) {
          if (state.requestState.isLoaded) {
            di<UpdateChargeAgencyBloc>()
              ..add(const RemoveCountrySelectionEvent())
              ..add(const RemovePaymentSelectionEvent());

            di<UpdateChargeAgencyBloc>().add(SelectCountryEvent(
              countryList: state.myChargeAgencyData?.countries ?? [],
              country: null,
            ));

            di<UpdateChargeAgencyBloc>().add(SelectPaymentEvent(
              paymentList: state.myChargeAgencyData?.payments ?? [],
              payment: null,
            ));
          }

          return HandlingDataWidget(
            reqState: state.requestState,
            title: '',
            subTitle: '',
            child: BlocBuilder<UpdateChargeAgencyBloc, UpdateChargeAgencyState>(
              bloc: _updateBloc,
              buildWhen: (prev, curr) => prev.textEditingController != curr.textEditingController,
              builder: (context, state) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    padding: context.paddingSymmetric(horizontal: 20),
                    height: ScreenUtil().screenHeight,
                    width: ScreenUtil().screenWidth,
                    child: Column(
                      children: [
                        50.hBox,
                        _PickImageBody(
                          bloc: _updateBloc,
                          state: _getChargeAgencyBloc.state,
                        ),
                        5.hBox,
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AnimatedDialog(
                                onTap: () {
                                  di<UpdateChargeAgencyBloc>().add(
                                    UpdateChargeAgencyEvent(
                                      context: context,
                                      agencyId:
                                          _getChargeAgencyBloc.state.data?.id ??
                                              0,
                                    ),
                                  );
                                  Navigator.pop(context);
                                },
                                title: StringManager.nameAgency.tr(),
                                child: TextInputWidget(
                                  StringManager.nameAgency.tr(),
                                  controller:
                                      _updateBloc.state.textEditingController,
                                  fillColor: ColorManager.blackColor
                                      .withValues(alpha: (0.1)),
                                  contentPadding:
                                      context.paddingSymmetric(horizontal: 20),
                                  textColor: ColorManager.textPrimary,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: context.paddingSymmetric(
                                horizontal: 15, vertical: 5),
                            child: Text(
                              '“${_getChargeAgencyBloc.state.myChargeAgencyData?.name ?? ''}”',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: context.bodyMedium.size(20).w600,
                            ),
                          ),
                        ),
                        20.hBox,
                        const CountrySelectionBody(),
                        30.hBox,
                        const PaymentSelectionBody(),
                        50.hBox,
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: context.paddingSymmetric(horizontal: 40, vertical: 20),
        child: SaveButtonBody(
          bloc: _updateBloc,
          state: _getChargeAgencyBloc.state,
        ),
      ),
    );
  }
}

import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/country_icon.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/view/widgets/country_select_widget.dart';
import 'package:general/src/features/agency/presentation/charge_agency/view/component/host_withdrawel_screen/view/widgets/payment_select_widget.dart';
import 'package:general/src/features/agency/presentation/search_agency_screen/view/show_shipping_agency.dart';

import '../../../../../../../auth/domain/entities/profile_room_entity.dart';

part 'component/communication_button_body.dart';

// part 'component/countries_body.dart';
part 'component/country_body.dart';

part 'component/floating_action_btn_body.dart';

// part 'component/payment_body.dart';
part 'component/payment_getaways_body.dart';

part 'component/withdrawal_button_body.dart';

part 'widgets/card_shipping_agent.dart';

class HostWithdrawelScreen extends StatefulWidget {
  final CoinsScreenParam param;

  const HostWithdrawelScreen({
    super.key,
    required this.param,
  });

  @override
  State<HostWithdrawelScreen> createState() => _HostWithdrawelScreenState();
}

class _HostWithdrawelScreenState extends State<HostWithdrawelScreen> {
  final _agentsFullDataBloc = di<GetShippingAgentsFullDataModelBloc>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (!_agentsFullDataBloc.state.status.isLoaded) {
      _agentsFullDataBloc.add(const GetAgentsFullData(isFirstLoading: true));
    }

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _agentsFullDataBloc.add(const LoadMoreAgentsFullData());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    di<GetShippingAgentsFullDataModelBloc>().add(const ClearSelection());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        title: StringManager.withdrawal.tr(),
        iconColor: ColorManager.black,
        backgroundColor: ColorManager.white,
        titleStyle: context.bodyMedium.bold.colorExt(ColorManager.black),
      ),
      body: BlocBuilder<GetShippingAgentsFullDataModelBloc,
          GetShippingAgentsFullDataModelState>(
        bloc: _agentsFullDataBloc,
        buildWhen: (prev, curr) =>
        prev.status != curr.status ||
            prev.data != curr.data ||
            prev.isPaginating != curr.isPaginating,
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              _agentsFullDataBloc.add(const GetAgentsFullData());
            },
            child: ListView(
              controller: _scrollController,
              padding: context.paddingSymmetric(horizontal: 20),
              children: [
                if (widget.param.isFromCoinsScreen == false) ...[
                  const CountrySelectWidget(),
                  10.hBox,
                  const PaymentSelectWidget(),
                ],
                HandlingDataWidget(
                  reqState: state.status,
                  title: StringManager.noAgentsTitle.tr(),
                  subTitle: StringManager.noAgentsSubTitle.tr(),
                  titleStyle:
                  context.bodyLarge.w600.colorExt(ColorManager.black),
                  subTitleStyle: context.bodyMedium
                      .copyWith(color: ColorManager.black, height: 1.30),
                  buttonBackgroundColors: [
                    ColorManager.primary,
                    ColorManager.primary
                  ],
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.data.length,
                    itemBuilder: (context, index) {
                      return CardShippingAgent(
                        isDollarsValue: widget.param.isFromCoinsScreen,
                        shippingAgentsFullDataEntity: state.data[index],
                        stopTransferButton: widget.param.stopTransferButton,
                      );
                    },
                  ),
                  onTap: () {
                    _agentsFullDataBloc.add(const GetAgentsFullData());
                  },
                ),
                if (state.isPaginating)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: (widget.param.isFromCoinsScreen == true)
          ? const SizedBox()
          : FloatingActionBtnBody(bloc: _agentsFullDataBloc),
    );
  }
}
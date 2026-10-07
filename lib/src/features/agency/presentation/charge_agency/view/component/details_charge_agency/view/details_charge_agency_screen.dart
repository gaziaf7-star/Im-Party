import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/id_with_copy.dart';
import 'package:general/src/features/agency/agency.dart';
import 'package:general/src/features/agency/presentation/search_agency_screen/view/show_shipping_agency.dart';
import 'package:general/src/features/auth/domain/entities/my_data_entity.dart';

import '../../../../../../../../core/widgets/md_indicator.dart';

part 'component/tab_bar_body.dart';

part 'component/tab_bar_view_body.dart';

part 'widgets/custom_row_data.dart';

part 'widgets/transaction_details_bottom_sheet.dart';

class DetailsChargeAgency extends StatefulWidget {
  const DetailsChargeAgency({super.key});

  @override
  State<DetailsChargeAgency> createState() => _DetailsChargeAgencyState();
}

class _DetailsChargeAgencyState extends State<DetailsChargeAgency>
    with SingleTickerProviderStateMixin {
  final _detailsBloc = di<GetChargeAgencyDetailsBloc>();

  late final TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    if (_detailsBloc.state.senderState != RequestState.loaded) {
      _detailsBloc
          .add(const GetChargeAgencyDetailsSenderEvent(isFirstLoading: true));
    }
    _detailsBloc.add(const SenderAddListenerEvent());
    _detailsBloc.add(const ReceiverAddListenerEvent());
    _controller.addListener(_listener);
    super.initState();
  }


  void _listener() {
    if (_controller.indexIsChanging && _controller.index == 1) {
    if (!_detailsBloc.state.receiverState.isLoaded) {
      _detailsBloc
          .add(const GetChargeAgencyDetailsReceiverEvent(isFirstLoading: true));
    }}
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBgAlt,
      appBar: AppBarWidget(
        title: StringManager.theDetails.tr(),
        titleStyle: context.bodyLarge.w600,
      ),
      body: Column(
        children: [
          _TabBarBody(controller: _controller),
          5.hBox,
          Expanded(
            child: BlocBuilder<GetChargeAgencyDetailsBloc,
                GetChargeAgencyDetailsStates>(
              bloc: _detailsBloc,
              buildWhen: (prev, curr) => prev.senderState != curr.senderState || prev.receiverState != curr.receiverState || prev.senderData != curr.senderData || prev.receiverData != curr.receiverData,
              builder: (context, state) {
                return TabBarView(
                  controller: _controller,
                  children: [
                    HandlingDataWidget(
                      reqState: state.senderState,
                      title: StringManager.noDetailsReportsTitle.tr(),
                      subTitle: StringManager.noDetailsReportsSubTitle.tr(),
                      onTap: () {
                        _detailsBloc
                            .add(const GetChargeAgencyDetailsSenderEvent());
                      },
                      child: _TabBarViewBody(
                        scrollController: state.senderScrollCtrl,
                        data: state.senderData,
                        type: false,
                      ),
                    ),
                    HandlingDataWidget(
                      reqState: state.receiverState,
                      title: StringManager.noDetailsReportsTitle.tr(),
                      subTitle: StringManager.noDetailsReportsSubTitle.tr(),
                      onTap: () {
                        _detailsBloc
                            .add(const GetChargeAgencyDetailsSenderEvent());
                      },
                      child: _TabBarViewBody(
                        scrollController: state.receiverScrollCtrl,
                        data: state.receiverData,
                        type: true,
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

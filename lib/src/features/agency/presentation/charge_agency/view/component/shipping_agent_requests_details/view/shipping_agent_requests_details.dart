import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/md_indicator.dart';
import 'package:general/src/features/agency/agency.dart';

import '../../../../../../../../core/widgets/id_with_copy.dart';
import '../../../../../../../auth/data/model/profile_room_model.dart';

part 'widgets/card_user_money_request.dart';
part 'widgets/transfer_salary_tab_view_body.dart';
part 'widgets/transfer_salary_tabs.dart';

class ShippingAgentRequestsDetails extends StatefulWidget {
  const ShippingAgentRequestsDetails({super.key});

  @override
  State<ShippingAgentRequestsDetails> createState() =>
      _ShippingAgentRequestsDetailsState();
}

class _ShippingAgentRequestsDetailsState
    extends State<ShippingAgentRequestsDetails> with TickerProviderStateMixin {
  final _requestsBloc = di<GetShippingAgentsRequestsBloc>();
  late final TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 5, vsync: this);
    if (_requestsBloc.state.waitingReqState != RequestState.loaded) {
      _requestsBloc.add(
          const GetShippingAgentWaitingRequestsEvent(isFirstLoading: true));
    }
    _controller.addListener(_listener);
    di<GetShippingAgentsRequestsBloc>().add(const AddListenerForAllEvent());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_listener);
    di<GetShippingAgentsRequestsBloc>().add(const RemoveListenerForAllEvent());
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetShippingAgentsRequestsBloc, GetShippingAgentStates>(
      bloc: _requestsBloc,
      buildWhen: (prev, curr) => prev.waitingRequests != curr.waitingRequests || prev.acceptedRequests != curr.acceptedRequests || prev.waitingReqState != curr.waitingReqState || prev.acceptedReqState != curr.acceptedReqState,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ColorManager.scaffoldBgAlt,
          appBar: AppBarWidget(
            title: StringManager.salaryTransfer.tr(),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TransferSalaryTabs(controller: _controller),
              20.hBox,
              Expanded(
                child: TabBarView(
                  controller: _controller,
                  children: [
                    TransferSalaryTabViewBody(
                      requestDataList: state.waitingRequests,
                      requestDataMessage: state.waitingRequestsMessage,
                      stateRequest: state.waitingReqState,
                      isWaiting: true,
                      onTap: () {
                        _requestsBloc
                            .add(const GetShippingAgentWaitingRequestsEvent());
                      },
                      controller: _controller,
                      scrollController: state.waitingScrollController,
                    ),
                    TransferSalaryTabViewBody(
                      requestDataList: state.acceptedRequests,
                      requestDataMessage: state.acceptedRequestsMessage,
                      stateRequest: state.acceptedReqState,
                      isAccepted: true,
                      onTap: () {
                        _requestsBloc
                            .add(const GetShippingAgentAcceptedRequestsEvent());
                      },
                      controller: _controller,
                      scrollController: state.acceptedScrollController,
                    ),
                    TransferSalaryTabViewBody(
                      requestDataList: state.transferredRequests,
                      requestDataMessage: state.transferredRequestsMessage,
                      stateRequest: state.transferredReqState,
                      onTap: () {
                        _requestsBloc.add(
                            const GetShippingAgentTransferredRequestsEvent());
                      },
                      controller: _controller,
                      scrollController: state.transferredScrollController,
                    ),
                    TransferSalaryTabViewBody(
                      requestDataList: state.completeRequests,
                      requestDataMessage: state.completeRequestsMessage,
                      stateRequest: state.completeReqState,
                      onTap: () {
                        _requestsBloc
                            .add(const GetShippingAgentCompleteRequestsEvent());
                      },
                      controller: _controller,
                      scrollController: state.completedScrollController,
                    ),
                    TransferSalaryTabViewBody(
                      requestDataList: state.rejectedRequests,
                      requestDataMessage: state.rejectedRequestsMessage,
                      stateRequest: state.rejectedReqState,
                      onTap: () {
                        _requestsBloc
                            .add(const GetShippingAgentRejectedRequestsEvent());
                      },
                      controller: _controller,
                      scrollController: state.rejectedScrollController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _listener() {
    if (_controller.index == 1 &&
        _requestsBloc.state.acceptedReqState != RequestState.loaded) {
      _requestsBloc.add(
          const GetShippingAgentAcceptedRequestsEvent(isFirstLoading: true));
      return;
    }
    if (_controller.index == 2 &&
        _requestsBloc.state.transferredReqState != RequestState.loaded) {
      _requestsBloc.add(
          const GetShippingAgentTransferredRequestsEvent(isFirstLoading: true));
      return;
    }
    if (_controller.index == 3 &&
        _requestsBloc.state.completeReqState != RequestState.loaded) {
      _requestsBloc.add(
          const GetShippingAgentCompleteRequestsEvent(isFirstLoading: true));
      return;
    }
    if (_controller.index == 4 &&
        _requestsBloc.state.rejectedReqState != RequestState.loaded) {
      _requestsBloc.add(
          const GetShippingAgentRejectedRequestsEvent(isFirstLoading: true));
      return;
    }
  }
}

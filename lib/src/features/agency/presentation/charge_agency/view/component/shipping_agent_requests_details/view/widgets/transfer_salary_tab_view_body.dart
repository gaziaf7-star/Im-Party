






part of 'package:general/src/features/agency/presentation/charge_agency/view/component/shipping_agent_requests_details/view/shipping_agent_requests_details.dart';

class TransferSalaryTabViewBody extends StatelessWidget {
  final List<ShippingAgentRequestEntity> requestDataList;
  final RequestState stateRequest;
  final String requestDataMessage;
  final bool? isWaiting;
  final bool? isAccepted;
  final void Function()? onTap;
  final TabController controller;
  final ScrollController scrollController;

  const TransferSalaryTabViewBody({
    required this.requestDataList,
    required this.requestDataMessage,
    required this.stateRequest,
    required this.scrollController,
    required this.controller,
    this.isWaiting,
    this.isAccepted,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HandlingDataWidget(
      reqState: stateRequest,
      title: StringManager.noHostsAgentsTitle.tr(),
      subTitle: StringManager.noHostsAgentsSubTitle.tr(),
      onTap: onTap,
      child: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child:

        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.paddingSymmetric(horizontal: 10),
          itemCount: requestDataList.length,
          controller: scrollController,
          itemBuilder: (context, index) {
            return CardUserMoneyRequest(
              shippingAgentRequestEntity: requestDataList[index],
              isWaiting: isWaiting,
              isAccepted: isAccepted,
              controller: controller,
            );
          },
        ),

        // requestDataList.isEmpty
        //     ? Center(child: Text('No data available')) // Or any fallback UI
        //     : SizedBox()

        // ListView.builder(
        //   physics: const AlwaysScrollableScrollPhysics(),
        //   padding: context.paddingSymmetric(horizontal: 10),
        //   itemCount: requestDataList.length,
        //   controller: scrollController,
        //   itemBuilder: (context, index) {
        //     return CardUserMoneyRequest(
        //       shippingAgentRequestEntity: requestDataList[index],
        //       isWaiting: isWaiting,
        //       isAccepted: isAccepted,
        //       controller: controller,
        //     );
        //   },
        // ),
      ),
    );
  }

  void _refresh() {
    switch (controller.index) {
      case 0:
        di<GetShippingAgentsRequestsBloc>().add(
          const GetShippingAgentWaitingRequestsEvent(),
        );
        break;
      case 1:
        di<GetShippingAgentsRequestsBloc>().add(
          const GetShippingAgentAcceptedRequestsEvent(),
        );
        break;
      case 2:
        di<GetShippingAgentsRequestsBloc>().add(
          const GetShippingAgentTransferredRequestsEvent(),
        );
        break;
      case 3:
        di<GetShippingAgentsRequestsBloc>().add(
          const GetShippingAgentCompleteRequestsEvent(),
        );
        break;
      case 4:
        di<GetShippingAgentsRequestsBloc>().add(
          const GetShippingAgentRejectedRequestsEvent(),
        );
        break;
      default:
        break;
    }
  }
}


// part of'package:general/src/features/agency/presentation/charge_agency/view/component/shipping_agent_requests_details/view/shipping_agent_requests_details.dart';
//
// class TransferSalaryTabViewBody extends StatelessWidget {
//   final List<ShippingAgentRequestEntity> requestDataList;
//   final RequestState stateRequest;
//   final String requestDataMessage;
//   final bool? isWaiting;
//   final bool? isAccepted;
// final void Function()? onTap;
//   final TabController controller;
// final ScrollController scrollController;
//   const TransferSalaryTabViewBody({
//     required this.requestDataList,
//     required this.requestDataMessage,
//     required this.stateRequest,
//     required this.scrollController,
//     required this.controller,
//     this.isWaiting,
//     this.isAccepted,
//     this.onTap,
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//
//
//     return HandlingDataWidget(reqState: stateRequest,
//         title: StringManager.noHostsAgentsTitle.tr(),
//         subTitle:  StringManager.noHostsAgentsSubTitle.tr(),
//         onTap: onTap,
//         child: RefreshIndicator(
//           onRefresh:
//               () async {
//         _refresh();
//           },
//           child: ListView.builder(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: context.paddingSymmetric(
//             horizontal: 10
//                 ),
//                 itemCount: requestDataList.length,
//                 controller: scrollController,
//                 itemBuilder: (context, index) {
//           return CardUserMoneyRequest(
//             shippingAgentRequestEntity: requestDataList[index],
//             isWaiting: isWaiting,
//             isAccepted: isAccepted,
//             controller: controller,
//           );
//                 },
//               ),
//         )
//
//     );
//
//
//   }
//
//   void _refresh() async {
//     if (controller.index == 0) {
//       di<GetShippingAgentsRequestsBloc>().add(
//         const GetShippingAgentWaitingRequestsEvent(),
//       );
//     }
//     if (controller.index == 1) {
//       di<GetShippingAgentsRequestsBloc>().add(
//         const GetShippingAgentAcceptedRequestsEvent(),
//       );
//       return;
//     }
//     if (controller.index == 2) {
//       di<GetShippingAgentsRequestsBloc>().add(
//         const GetShippingAgentTransferredRequestsEvent(),
//       );
//       return;
//     }
//     if (controller.index == 3) {
//       di<GetShippingAgentsRequestsBloc>().add(
//         const GetShippingAgentCompleteRequestsEvent(),
//       );
//       return;
//     }
//     if (controller.index == 4) {
//       di<GetShippingAgentsRequestsBloc>().add(
//         const GetShippingAgentRejectedRequestsEvent(),
//       );
//       return;
//     }
//   }
//
// }

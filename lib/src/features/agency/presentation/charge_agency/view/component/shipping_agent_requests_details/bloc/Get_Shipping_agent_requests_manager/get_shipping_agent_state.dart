part of 'get_shipping_agent_bloc.dart';

class GetShippingAgentStates extends Equatable {
  // Waiting Requests
  final List<ShippingAgentRequestEntity> waitingRequests;
  final RequestState waitingReqState;
  final String waitingRequestsMessage;
  final ScrollController waitingScrollController;
  final int waitingCurrentPage;
  final int waitingLastPage;

  // Accepted Requests
  final List<ShippingAgentRequestEntity> acceptedRequests;
  final RequestState acceptedReqState;
  final String acceptedRequestsMessage;
  final ScrollController acceptedScrollController;
  final int acceptedCurrentPage;
  final int acceptedLastPage;

  // Transferred Requests
  final List<ShippingAgentRequestEntity> transferredRequests;
  final RequestState transferredReqState;
  final String transferredRequestsMessage;
  final ScrollController transferredScrollController;
  final int transferredCurrentPage;
  final int transferredLastPage;

  // Completed Requests
  final List<ShippingAgentRequestEntity> completeRequests;
  final RequestState completeReqState;
  final String completeRequestsMessage;
  final ScrollController completedScrollController;
  final int completedCurrentPage;
  final int completedLastPage;

  // Rejected Requests
  final List<ShippingAgentRequestEntity> rejectedRequests;
  final RequestState rejectedReqState;
  final String rejectedRequestsMessage;
  final ScrollController rejectedScrollController;
  final int rejectedCurrentPage;
  final int rejectedLastPage;

  // Additional properties
  final File? image;
  final int? requestId;

  const GetShippingAgentStates({
    // Waiting Requests
    this.waitingRequests = const [],
    this.waitingReqState = RequestState.loading,
    this.waitingRequestsMessage = "",
   required this.waitingScrollController,
    this.waitingCurrentPage = 1,
    this.waitingLastPage = -1,

    // Accepted Requests
    this.acceptedRequests = const [],
    this.acceptedReqState = RequestState.loading,
    this.acceptedRequestsMessage = "",
    required this.acceptedScrollController,
    this.acceptedCurrentPage = 1,
    this.acceptedLastPage = -1,

    // Transferred Requests
    this.transferredRequests = const [],
    this.transferredReqState = RequestState.loading,
    this.transferredRequestsMessage = "",
    required  this.transferredScrollController,
    this.transferredCurrentPage = 1,
    this.transferredLastPage = -1,

    // Completed Requests
    this.completeRequests = const [],
    this.completeReqState = RequestState.loading,
    this.completeRequestsMessage = "",
    required this.completedScrollController,
    this.completedCurrentPage = 1,
    this.completedLastPage = -1,

    // Rejected Requests
    this.rejectedRequests = const [],
    this.rejectedReqState = RequestState.loading,
    this.rejectedRequestsMessage = "",
    required this.rejectedScrollController,
    this.rejectedCurrentPage = 1,
    this.rejectedLastPage = -1,

    // Additional properties
    this.image,
    this.requestId = -1,
  });

  GetShippingAgentStates copyWith({
    // Waiting Requests
    List<ShippingAgentRequestEntity>? waitingRequests,
    RequestState? waitingReqState,
    String? waitingRequestsMessage,
    ScrollController? waitingScrollController,
    int? waitingCurrentPage,
    int? waitingLastPage,

    // Accepted Requests
    List<ShippingAgentRequestEntity>? acceptedRequests,
    RequestState? acceptedReqState,
    String? acceptedRequestsMessage,
    ScrollController? acceptedScrollController,
    int? acceptedCurrentPage,
    int? acceptedLastPage,

    // Transferred Requests
    List<ShippingAgentRequestEntity>? transferredRequests,
    RequestState? transferredReqState,
    String? transferredRequestsMessage,
    ScrollController? transferredScrollController,
    int? transferredCurrentPage,
    int? transferredLastPage,

    // Completed Requests
    List<ShippingAgentRequestEntity>? completeRequests,
    RequestState? completeReqState,
    String? completeRequestsMessage,
    ScrollController? completedScrollController,
    int? completedCurrentPage,
    int? completedLastPage,

    // Rejected Requests
    List<ShippingAgentRequestEntity>? rejectedRequests,
    RequestState? rejectedReqState,
    String? rejectedRequestsMessage,
    ScrollController? rejectedScrollController,
    int? rejectedCurrentPage,
    int? rejectedLastPage,

    // Additional properties
    File? image,
    int? requestId,
  }) {
    return GetShippingAgentStates(
      // Waiting Requests
      waitingRequests: waitingRequests ?? this.waitingRequests,
      waitingReqState: waitingReqState ?? this.waitingReqState,
      waitingRequestsMessage:
      waitingRequestsMessage ?? this.waitingRequestsMessage,
      waitingScrollController:
      waitingScrollController ?? this.waitingScrollController,
      waitingCurrentPage: waitingCurrentPage ?? this.waitingCurrentPage,
      waitingLastPage: waitingLastPage ?? this.waitingLastPage,

      // Accepted Requests
      acceptedRequests: acceptedRequests ?? this.acceptedRequests,
      acceptedReqState: acceptedReqState ?? this.acceptedReqState,
      acceptedRequestsMessage:
      acceptedRequestsMessage ?? this.acceptedRequestsMessage,
      acceptedScrollController:
      acceptedScrollController ?? this.acceptedScrollController,
      acceptedCurrentPage: acceptedCurrentPage ?? this.acceptedCurrentPage,
      acceptedLastPage: acceptedLastPage ?? this.acceptedLastPage,

      // Transferred Requests
      transferredRequests: transferredRequests ?? this.transferredRequests,
      transferredReqState: transferredReqState ?? this.transferredReqState,
      transferredRequestsMessage:
      transferredRequestsMessage ?? this.transferredRequestsMessage,
      transferredScrollController:
      transferredScrollController ?? this.transferredScrollController,
      transferredCurrentPage:
      transferredCurrentPage ?? this.transferredCurrentPage,
      transferredLastPage:
      transferredLastPage ?? this.transferredLastPage,

      // Completed Requests
      completeRequests: completeRequests ?? this.completeRequests,
      completeReqState: completeReqState ?? this.completeReqState,
      completeRequestsMessage:
      completeRequestsMessage ?? this.completeRequestsMessage,
      completedScrollController:
      completedScrollController ?? this.completedScrollController,
      completedCurrentPage:
      completedCurrentPage ?? this.completedCurrentPage,
      completedLastPage: completedLastPage ?? this.completedLastPage,

      // Rejected Requests
      rejectedRequests: rejectedRequests ?? this.rejectedRequests,
      rejectedReqState: rejectedReqState ?? this.rejectedReqState,
      rejectedRequestsMessage:
      rejectedRequestsMessage ?? this.rejectedRequestsMessage,
      rejectedScrollController:
      rejectedScrollController ?? this.rejectedScrollController,
      rejectedCurrentPage:
      rejectedCurrentPage ?? this.rejectedCurrentPage,
      rejectedLastPage: rejectedLastPage ?? this.rejectedLastPage,

      // Additional properties
      image: image ?? this.image,
      requestId: requestId ?? this.requestId,
    );
  }

  @override
  List<Object?> get props => [
    // Waiting Requests
    waitingRequests,
    waitingRequestsMessage,
    waitingReqState,
    waitingScrollController,
    waitingCurrentPage,
    waitingLastPage,

    // Accepted Requests
    acceptedRequests,
    acceptedRequestsMessage,
    acceptedReqState,
    acceptedScrollController,
    acceptedCurrentPage,
    acceptedLastPage,

    // Transferred Requests
    transferredRequests,
    transferredRequestsMessage,
    transferredReqState,
    transferredScrollController,
    transferredCurrentPage,
    transferredLastPage,

    // Completed Requests
    completeRequests,
    completeRequestsMessage,
    completeReqState,
    completedScrollController,
    completedCurrentPage,
    completedLastPage,

    // Rejected Requests
    rejectedRequests,
    rejectedRequestsMessage,
    rejectedReqState,
    rejectedScrollController,
    rejectedCurrentPage,
    rejectedLastPage,

    // Additional properties
    image,
    requestId,
  ];
}

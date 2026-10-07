part of 'agency_memeber_charges_history_bloc.dart';


class AgencyMemeberChargesHistoryState extends Equatable {
 // User data
 final List<AgencyMemberChargesHistoryModel>? userModel;
 final String userMessage;
 final RequestState userState;

 // Agency data
 final List<AgencyMemberChargesHistoryModel>? agencyModel;
 final String agencyMessage;
 final RequestState agencyState;

 const AgencyMemeberChargesHistoryState({
  this.userModel,
  this.userMessage = '',
  this.userState = RequestState.idle,
  this.agencyModel,
  this.agencyMessage = '',
  this.agencyState = RequestState.idle,
 });

 AgencyMemeberChargesHistoryState copyWith({
  List<AgencyMemberChargesHistoryModel>? userModel,
  String? userMessage,
  RequestState? userState,
  List<AgencyMemberChargesHistoryModel>? agencyModel,
  String? agencyMessage,
  RequestState? agencyState,
 }) {
  return AgencyMemeberChargesHistoryState(
   userModel: userModel ?? this.userModel,
   userMessage: userMessage ?? this.userMessage,
   userState: userState ?? this.userState,
   agencyModel: agencyModel ?? this.agencyModel,
   agencyMessage: agencyMessage ?? this.agencyMessage,
   agencyState: agencyState ?? this.agencyState,
  );
 }

 @override
 List<Object?> get props => [
  userModel,
  userMessage,
  userState,
  agencyModel,
  agencyMessage,
  agencyState,
 ];
}


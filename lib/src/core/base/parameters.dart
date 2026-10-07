import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/domain/entities/user_entity.dart';
import 'package:general/src/features/family/domain/entities/show_family_entity.dart';
import 'package:general/src/features/games/domain/entities/game_entity.dart';
import 'package:general/src/features/moment/domain/entities/moment_gift.dart';
import 'package:general/src/features/moment/moment.dart';
import 'package:general/src/features/reels/presentation/main_reels_page/bloc/get_reels/get_reels_bloc.dart';

import '../../../reels_viewer/bloc/reels_viewer_bloc.dart';
import '../../features/auth/domain/entities/my_data_entity.dart';
import '../../features/family/domain/entities/family_member_entity.dart';
import '../../features/profile/presentation/profile/view/page/user_profile/bloc/get_user_support/get_user_support_bloc.dart';

class LoginParameterUC extends Equatable {
  final String email;
  final String password;

  const LoginParameterUC({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SendCodeParameter extends Equatable {
  // old --> code , phone
  // new ---> newCode , newPhone
  final String code, newCode, newPhone, phone, password;
  final String userName, emile, gender;

  /// Firebase ID token (SMS verified client-side). Sent to the backend as
  /// "firebase_id_token" in place of the legacy WhatsApp "code"/"new_code".
  final String firebaseIdToken;
  final File? image;
  final OtpType otpType;
  final bool isDifferent;
  final String? type;

  const SendCodeParameter({
    this.code = '',
    this.newCode = '',
    this.phone = '',
    this.newPhone = '',
    this.password = '',
    this.firebaseIdToken = '',
    this.image,
    this.userName = '',
    this.gender = '',
    this.emile = '',
    required this.otpType,
    this.isDifferent = false,
    this.type,
  });

  @override
  List<Object?> get props => [
    code,
    newCode,
    phone,
    newPhone,
    password,
    firebaseIdToken,
    otpType,
    isDifferent,
    type,
  ];
}

class BillParam extends Equatable {
  final String startDate, endDate, type;
  final bool isLoading;
  final bool isRefresh;
  final int? page;
  final String? shippingType;

  const BillParam({
    this.startDate = '',
    this.endDate = '',
    this.type = '',
    this.shippingType = '',
    this.page = 1,
    this.isLoading = true,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props =>
      [startDate, isLoading, endDate, type, shippingType];
}

class SendMallParam extends Equatable {
  final String itemId, userId;

  const SendMallParam({
    this.itemId = '',
    this.userId = '',
  });

  @override
  List<Object?> get props => [itemId, userId];
}

class SendBagParam extends Equatable {
  final String itemId, userId, targetId;

  const SendBagParam({
    this.itemId = '',
    this.userId = '',
    this.targetId = '',
  });

  @override
  List<Object?> get props => [itemId, userId, targetId];
}

class CpRequestParam extends Equatable {
  final String userId, relationId;

  const CpRequestParam({
    required this.userId,
    required this.relationId,
  });

  @override
  List<Object?> get props => [userId, relationId];
}

class AuthParameterUC extends Equatable {
  final String phone;
  final String? password;
  final String? code;

  /// Firebase ID token (SMS verified client-side). Sent to the backend as
  /// "firebase_id_token" in place of the legacy WhatsApp "code".
  final String? firebaseIdToken;
  final String? credential;
  final bool? isMulti;

  const AuthParameterUC({
    required this.phone,
    this.password,
    this.code,
    this.firebaseIdToken,
    this.credential,
    this.isMulti,
  });

  @override
  List<Object?> get props =>
      [phone, password, code, firebaseIdToken, credential, isMulti];
}

class ThirdPartyParameters<T> extends Equatable {
  final T? data;
  final String? type;

  const ThirdPartyParameters({
    this.data,
    this.type,
  });

  @override
  List<Object?> get props => [data, type];
}

class ReplaceCoverImageParametersUC extends Equatable {
  final int? previousImageId;
  final File? newImage;

  const ReplaceCoverImageParametersUC({
    this.previousImageId,
    this.newImage,
  });

  @override
  List<Object?> get props => [previousImageId, newImage];
}

class InformationParametersUC extends Equatable {
  final String? bio;
  final String? name;
  final String? date;
  final File? image;
  final int? gender;
  final int? countryId;
  final String? email;
  final String? uuid;
  final List<File>? multiImages;
  final List<String>? oldMultiImages;
  final bool isUpdateOnlyUid;

  const InformationParametersUC({
    this.bio,
    this.gender,
    this.image,
    this.countryId,
    this.date,
    this.multiImages,
    this.oldMultiImages,
    this.name,
    this.email,
    this.uuid = '',
    this.isUpdateOnlyUid = false,
  });

  @override
  List<Object?> get props => [
    countryId,
    name,
    uuid,
    date,
    image,
    gender,
    email,
    bio,
    multiImages,
    oldMultiImages,
    isUpdateOnlyUid,
  ];
}

class AddMomentParametersUC extends Equatable {
  final String? text;
  final List<File>? multiImages;

  const AddMomentParametersUC({
    this.text,
    this.multiImages,
  });

  @override
  List<Object?> get props => [
    text,
    multiImages,
  ];
}

class SupportScreenParam extends Equatable {
  final GetSupporterBloc getSupporterBloc;
  final String userId;

  const SupportScreenParam({
    required this.getSupporterBloc,
    required this.userId,
  });

  @override
  List<Object?> get props => [
    getSupporterBloc,
    userId,
  ];
}

class AuthParameter extends Equatable {
  final String phone;
  final String? password;
  final String? code;
  final String? credential;
  final bool? isMulti;

  const AuthParameter(
      {required this.phone,
        this.password,
        this.code,
        this.credential,
        this.isMulti});

  @override
  List<Object?> get props => [phone, password, code, credential, isMulti];
}

class TestMallBagParam extends Equatable {
  final String? image;
  final String? svg;
  final String? type;
  final String? name;

  const TestMallBagParam({this.image, this.svg, this.type, this.name});

  @override
  List<Object?> get props => [image, svg, type, name];
}

class CpRequestRespondParam extends Equatable {
  final String cpId;
  final String messageId;
  final String status;

  const CpRequestRespondParam(
      {required this.cpId, required this.messageId, required this.status});

  @override
  List<Object?> get props => [cpId, messageId, status];
}

class UseUnUseBagItemParam extends Equatable {
  final String? itemId;
  final String? type;
  final bool? isUsed;

  const UseUnUseBagItemParam({this.isUsed, this.itemId, this.type});

  @override
  List<Object?> get props => [isUsed, itemId, type];
}

class MainParameter extends Equatable {
  final bool? isCacheGift;
  final bool? isCacheFrame;
  final bool? isCacheExtra;
  final bool? isCacheIntro;
  final bool? isCacheEmoji;
  final bool? isUpdate;
  final File? img;

  const MainParameter({
    this.isCacheEmoji,
    this.isCacheIntro,
    this.isUpdate,
    this.isCacheExtra,
    this.isCacheFrame,
    this.isCacheGift,
    this.img,
  });

  @override
  List<Object?> get props => [
    isCacheEmoji,
    isCacheIntro,
    isUpdate,
    isCacheExtra,
    isCacheFrame,
    isCacheGift,
    img,
  ];
}

class RoomsParameterUC extends Equatable {
  final int? countryId;
  final int? currentPage;
  final TypeGetRooms? type;

  const RoomsParameterUC({this.countryId, this.currentPage, this.type});

  @override
  List<Object?> get props => [countryId, currentPage, type];
}

class EditProfileParameter {
  final String content;
  final bool isUsername;

  EditProfileParameter({
    required this.content,
    this.isUsername = true,
  });
}

class FFFParameter extends Equatable {
  final int? page;
  final String type;
  final String? keyWord;
  final bool? isSearch;

  const FFFParameter({
    this.page,
    this.isSearch,
    this.keyWord,
    required this.type,
  });

  @override
  List<Object?> get props => [page, type];
}

class FeedBackParameter extends Equatable {
  final String? content;
  final String? phoneNumber;
  final File? image;
  final int? userId;
  final String? description;

  const FeedBackParameter(
      {this.description,
        this.content,
        this.phoneNumber,
        this.image,
        this.userId});

  @override
  List<Object?> get props => [content, phoneNumber, image, userId, description];
}

class DeleteMessageParamsUC extends Equatable {
  final String deleteType;
  final List<int> messageIds;

  const DeleteMessageParamsUC({
    required this.messageIds,
    required this.deleteType,
  });

  @override
  List<Object?> get props => [deleteType, messageIds];
}

class UpdateMessageUC extends Equatable {
  final String messageId;
  final String message;

  const UpdateMessageUC({
    required this.messageId,
    required this.message,
  });

  @override
  List<Object?> get props => [messageId, message];
}

class FetchMessagesParamsUC extends Equatable {
  final String? userId;
  final String? page;
  final int? chatId;
  final List<int>? messageIds;
  final String? newMessage;
  final bool? moveToMessage;
  final int? messageIdToMove;

  const FetchMessagesParamsUC(
      {this.chatId,
        this.page,
        this.userId,
        this.messageIds,
        this.newMessage,
        this.moveToMessage,
        this.messageIdToMove});

  @override
  List<Object?> get props => [
    userId,
    chatId,
    messageIds,
    page,
    newMessage,
    moveToMessage,
    messageIdToMove
  ];
}

class MakeReactParamsUC extends Equatable {
  final int messageId;
  final String react;

  const MakeReactParamsUC({required this.messageId, required this.react});

  @override
  List<Object?> get props => [
    messageId,
    react,
  ];
}

class SendMessageAllPram {
  final String users;
  final String? type;
  final String? message;
  final String? url;
  final String? exceptUsers;

  const SendMessageAllPram(
      {required this.users,
        this.message,
        this.type,
        this.url,
        this.exceptUsers});
}

class NotificationParameterUC extends Equatable {
  final String userId;
  final String? body;
  final String? image;

  const NotificationParameterUC({required this.userId, this.body, this.image});

  @override
  List<Object?> get props => [userId, body, image];
}

class MessagesParameter extends Equatable {
  final String userId;
  final String name;
  final String image;
  final String? message;
  final bool hasColorName;
  final bool? isNotFriend;
  final bool? inRoom;

  /// True when the chat recipient owns an agency. Agency owners can be messaged
  /// by anyone at any time, so the non-friend 3-message cap is skipped for them.
  /// The backend is authoritative; this only suppresses the client-side gate.
  final bool? isAgencyOwner;

  /// Server room id (chat_room_id). REQUIRED to activate the offline-first
  /// realtime path (drift stream + instant open + clear-unread + pagination).
  /// When null/0 the bloc falls back to the legacy REST path. Passed from the
  /// chats list / search so opening a known conversation renders from cache.
  final int? chatId;

  /// When the screen is opened from chats search on a specific message hit, this
  /// carries the target message id (server id, else local id) so the
  /// conversation scrolls to it and highlights it briefly on open.
  final int? messageIdToMove;

  const MessagesParameter({
    required this.name,
    required this.image,
    required this.userId,
    this.message,
    this.isNotFriend,
    this.inRoom,
    this.isAgencyOwner,
    this.chatId,
    this.messageIdToMove,
    required this.hasColorName,
  });

  @override
  List<Object?> get props => [
    name,
    image,
    userId,
    hasColorName,
    message,
    isNotFriend,
    inRoom,
    isAgencyOwner,
    chatId,
    messageIdToMove,
  ];
}

class TopParameter extends Equatable {
  final String sendOrReceiver;
  final String date;
  final String isHome;
  final String? roomId;
  final String? page;

  const TopParameter(
      {required this.sendOrReceiver,
        required this.date,
        required this.isHome,
        this.roomId,
        this.page});

  @override
  List<Object?> get props => [sendOrReceiver, date, isHome, roomId, page];
}

class BuyVipParameter extends Equatable {
  final String type;
  final String vipId;
  final String? uuid;

  const BuyVipParameter({required this.type, this.uuid, required this.vipId});

  @override
  List<Object?> get props => [type, vipId];
}

class NavigateVipParameter extends Equatable {
  final int? index;
  final int? vip;

  const NavigateVipParameter({this.index, this.vip});

  @override
  List<Object?> get props => [index, vip];
}

class FamilyParameter extends Equatable {
  final String? id;
  final String? name;
  final String? bio;
  final String? page;
  final String? imageUrl;
  final File? image;

  const FamilyParameter({
    this.name,
    this.bio,
    this.image,
    this.page,
    this.id,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, bio, image, page, imageUrl];
}

class CreateFamilyParam extends Equatable {
  final ShowFamilyEntity? data;
  final ValueNotifier? createFamilyButton;

  const CreateFamilyParam({
    this.data,
    this.createFamilyButton,
    Key? key,
  });

  @override
  List<Object?> get props => [
    createFamilyButton,
    data,
  ];
}

///////////////////////use case
class CreateAgencyParameter extends Equatable {
  final File? frontIdCard, backIdCard, video;
  final String phone, email, country, apps, username;
  final int salary, userId, count;

  const CreateAgencyParameter({
    required this.frontIdCard,
    required this.backIdCard,
    required this.video,
    required this.phone,
    required this.email,
    required this.country,
    required this.userId,
    required this.apps,
    required this.count,
    required this.username,
    required this.salary,
  });

  @override
  List<Object?> get props => [
    frontIdCard,
    backIdCard,
    video,
    phone,
    email,
    country,
    userId,
    apps,
    count,
    username,
    salary,
  ];
}

class UpdateAgencyParam extends Equatable {
  final String? agencyId;
  final String? bio;
  final File? image;
  final String? imagePath;
  final String? name;

  const UpdateAgencyParam({
    this.agencyId,
    this.imagePath,
    this.bio,
    this.image,
    this.name,
  });

  @override
  List<Object?> get props => [agencyId, imagePath, name, bio, image];
}

class AgencyHistoryParam extends Equatable {
  final String month;
  final String year;
  final String agencyId;
  final String? page;

  const AgencyHistoryParam({
    required this.month,
    required this.year,
    required this.agencyId,
    this.page,
  });

  @override
  List<Object?> get props => [month, year, page, agencyId];
}

class AgencyRequestsActionParam extends Equatable {
  final String id;
  final String? answer;
  final bool? action;

  const AgencyRequestsActionParam({required this.id, this.action, this.answer});

  @override
  List<Object?> get props => [id, action, answer];
}

class FetchChargeAgencyDetailsParam extends Equatable {
  String page;
  String type;

  FetchChargeAgencyDetailsParam({
    required this.type,
    required this.page,
  });

  @override
  List<Object?> get props => [type, page];
}

class FetchHostsAgencyDollarsParam extends Equatable {
  String page;
  String type;

  FetchHostsAgencyDollarsParam({
    required this.type,
    required this.page,
  });

  @override
  List<Object?> get props => [type, page];
}

class PlayMyReelParam extends Equatable {
  String userId;
  int index;
  GetReelsBloc getReelsBloc;
  ReelViewerBloc reelViewerBloc;

  PlayMyReelParam({
    required this.userId,
    required this.index,
    required this.getReelsBloc,
    required this.reelViewerBloc,
  });

  @override
  List<Object?> get props => [userId, index];
}

class UpdateChargeAgencyParam extends Equatable {
  final String? phone;
  final String? name;
  final int? appOwnerId;
  final int? agencyId;
  final File? image;
  final String? paymentIds;
  final String? countriesIds;

  const UpdateChargeAgencyParam(
      {this.image,
        this.appOwnerId,
        this.agencyId,
        this.name,
        this.phone,
        this.countriesIds,
        this.paymentIds});

  @override
  List<Object?> get props =>
      [appOwnerId, agencyId, name, phone, countriesIds, paymentIds];
}

class JoinAgencyParam extends Equatable {
  final String? agencyId, whatsAppNum;

  const JoinAgencyParam({
    this.agencyId,
    this.whatsAppNum,
  });

  @override
  List<Object?> get props => [
    agencyId,
    whatsAppNum,
  ];
}

class AgencySmallParam extends Equatable {
  final String? image, id, name, idImage, specialId;
  final ImageColorEntity? imageColorEntity;

  // final void Function() onPressed;

  const AgencySmallParam({
    required this.image,
    required this.id,
    required this.name,
    this.imageColorEntity,
    this.idImage,
    this.specialId,
    // required this.onPressed,
  });

  @override
  List<Object?> get props => [
    image, id, name, imageColorEntity, idImage, specialId
    //  onPressed
  ];
}

class ChargeToParam extends Equatable {
  final String userId, amount;
  final String? userType;

  const ChargeToParam({
    required this.userId,
    required this.amount,
    this.userType,
  });

  @override
  List<Object?> get props => [
    userId,
    amount,
    userType,
  ];
}

class SendConfirmationRequestParam extends Equatable {
  final File? image;
  final int requestId;

  const SendConfirmationRequestParam({
    required this.image,
    required this.requestId,
  });

  @override
  List<Object?> get props => [image, requestId];
}

class ShippingAgentRequestActionParam extends Equatable {
  final String actionType;
  final int requestId;

  const ShippingAgentRequestActionParam({
    required this.actionType,
    required this.requestId,
  });

  @override
  List<Object?> get props => [actionType, requestId];
}

class MakeShippingAgentToAdminWithdrawelRequestParam extends Equatable {
  final int type;
  final String amount;

  const MakeShippingAgentToAdminWithdrawelRequestParam({
    required this.type,
    required this.amount,
  });

  @override
  List<Object?> get props => [type, amount];
}

class ChargeCoinForUsersParam extends Equatable {
  final String id;
  final String amount;

  const ChargeCoinForUsersParam({required this.id, required this.amount});

  @override
  List<Object?> get props => [id, amount];
}

class ChangeFamilyUserTypeParameter extends Equatable {
  final String? userId;
  final String? familyId;
  final String? type;

  const ChangeFamilyUserTypeParameter({
    this.userId,
    this.familyId,
    this.type,
  });

  @override
  List<Object?> get props => [userId, familyId, type];
}

class FamilyTakeActionReq extends Equatable {
  final String reqId;
  final String userId;
  final String status;

  const FamilyTakeActionReq(
      {required this.status, required this.reqId, required this.userId});

  @override
  List<Object?> get props => [reqId, userId, status];
}

class MemberFamilyParam extends Equatable {
  final MemberFamilyEntity? owner;
  final int? familyId;

  const MemberFamilyParam({this.owner, this.familyId});

  @override
  List<Object?> get props => [owner, familyId];
}

class MakeProblemReportParam extends Equatable {
  final String description;
  final String contact;
  final String userId;
  final File? image;

  const MakeProblemReportParam({
    required this.description,
    this.image,
    required this.userId,
    required this.contact,
  });

  @override
  List<Object?> get props => [description, userId, contact, image];
}

class BindAccountParam extends Equatable {
  final String? phoneNumber;
  final String? password;
  final BuildContext? buildContext;
  final String? vrCode;
  final String? currentPhone;
  final dynamic credential;
  final String? oldCode;
  final String? newCode;

  /// Firebase ID token (SMS verified client-side). Sent to the backend as
  /// "firebase_id_token" in place of the legacy WhatsApp "code"/"old_code"/"new_code".
  final String? firebaseIdToken;
  final OtpType? otpType;

  const BindAccountParam(
      {this.credential,
        this.phoneNumber,
        this.currentPhone,
        this.buildContext,
        this.password,
        this.vrCode,
        this.otpType,
        this.oldCode,
        this.newCode,
        this.firebaseIdToken});

  @override
  List<Object?> get props => [
    phoneNumber,
    password,
    vrCode,
    firebaseIdToken,
  ];
}

class GetUserDataParameter extends Equatable {
  final String userId;
  final bool? isVisit;

  const GetUserDataParameter({
    required this.userId,
    this.isVisit,
  });

  @override
  List<Object?> get props => [userId, isVisit];
}

class UserReportParameter extends Equatable {
  final String? id;
  final String? typeReport;
  final File? image;
  final String? reportContent;

  const UserReportParameter(
      {this.id, this.typeReport, this.image, this.reportContent});

  @override
  List<Object?> get props => [id, typeReport, image, reportContent];
}

class UserProfileParameter extends Equatable {
  final String? userId;
  final UserEntity? userData;
  final bool? comesFromRoom;

  const UserProfileParameter({this.userId, this.userData, this.comesFromRoom});

  @override
  List<Object?> get props => [userData, userData, comesFromRoom];
}

class CreateRoomParameter extends Equatable {
  final String? roomIntero;
  final File? roomCover;
  final String? roomType;
  final String? roomName;
  final String? roomPassword;
  final String? type;

  const CreateRoomParameter({
    this.roomName,
    this.roomIntero,
    this.roomCover,
    this.roomPassword,
    this.type,
    this.roomType,
  });

  @override
  List<Object?> get props =>
      [id, roomIntero, roomCover, roomType, roomPassword, roomName, type];
}

class RoomHandlerParameter extends Equatable {
  final String ownerRoomId;

  final String passwordRoom;

  final MyDataModel myDataModel;

  const RoomHandlerParameter(
      {required this.ownerRoomId,
        this.passwordRoom = '',
        required this.myDataModel});

  @override
  List<Object?> get props => [
    ownerRoomId,
    passwordRoom,
    myDataModel,
  ];
}

class ParameterUpdate extends Equatable {
  final String ownerId;
  final String? roomId;
  final String? roomName;
  final String? freeMic;
  final File? roomCover;
  final String? roomBackgroundId;
  final String? roomIntro;
  final String? roomPass;
  final String? roomType;
  final String? roomClass;
  final String? change;
  final String? roomVideoType;

  const ParameterUpdate({
    required this.ownerId,
    this.roomName,
    this.freeMic,
    this.roomCover,
    this.roomBackgroundId,
    this.roomIntro,
    this.roomPass,
    this.roomType,
    this.roomClass,
    this.change,
    this.roomId,
    this.roomVideoType,
  });

  @override
  List<Object?> get props => [
    ownerId,
    roomName,
    freeMic,
    roomCover,
    roomBackgroundId,
    roomIntro,
    roomPass,
    roomType,
    roomClass,
    change,
    roomVideoType,
    roomId
  ];
}

class TopParameterInRoom extends Equatable {
  final String date;
  final String innerType;
  final String? roomId;

  const TopParameterInRoom({
    required this.date,
    required this.innerType,
    this.roomId,
  });

  @override
  List<Object?> get props => [date, roomId];
}

class SearchParameter extends Equatable {
  final String keyWord;
  final bool? isFriend;
  final String? page;

  const SearchParameter({
    required this.keyWord,
    this.isFriend,
    this.page,
  });

  @override
  List<Object?> get props => [keyWord, isFriend, page];
}

class GroupMessageParameter extends Equatable {
  final String mesaage;
  final String? url;
  final String? messageId;

  const GroupMessageParameter({
    required this.mesaage,
    this.url,
    this.messageId,
  });

  @override
  List<Object?> get props => [mesaage, url, messageId];
}

class MomentContentParameter {
  final int momentId;
  final int currentMomentIndex;
  final MomentEntity currentMoment;
  final MomentType type;
  final MomentBloc momentBloc;

  const MomentContentParameter(
      {required this.momentId,
        required this.type,
        required this.currentMoment,
        required this.momentBloc,
        required this.currentMomentIndex});
}

class RoomParameter {
  final MyDataModel myDataModel;
  final GameDataEntity? gameDataEntity;
  final bool isHost;
  final bool isLocked;
  final bool? isGame;
  final bool? fromDynamicLink;
  final bool? isExit;
  final String roomId;
  final String ownerId;
  final String? specialIdImage;
  final ImageColorEntity? imageColorEntity;

  const RoomParameter({
    required this.myDataModel,
    required this.isHost,
    required this.isLocked,
    required this.roomId,
    required this.ownerId,
    this.isGame,
    this.fromDynamicLink,
    this.isExit,
    this.gameDataEntity,
    this.specialIdImage,
    this.imageColorEntity,
  });
}

class EnterRoomParameter extends Equatable {
  final String roomId;
  final String? roomPassword;
  final bool? ignoreRoomPassword;
  final bool? sendToZego;
  final int isVip;

  const EnterRoomParameter(
      {required this.isVip,
        required this.roomId,
        this.roomPassword,
        this.ignoreRoomPassword,
        this.sendToZego});

  @override
  List<Object?> get props =>
      [roomId, roomPassword, ignoreRoomPassword, sendToZego];
}

class GiftParameter extends Equatable {
  final String roomId;
  final String id;
  final String toUid;
  final String num;
  final bool toZego;
  final String? count;
  final String? giftType;
  final String? nonce;

  const GiftParameter(
      {required this.roomId,
        required this.toZego,
        required this.id,
        required this.toUid,
        required this.num,
        this.giftType,
        this.count,
        this.nonce});

  @override
  List<Object?> get props =>
      [roomId, id, toUid, num, toZego, count, giftType, nonce];
}

class SendGiftMomentParameter extends Equatable {
  final String momentID;
  final String number;
  final String giftId;

  const SendGiftMomentParameter({
    required this.momentID,
    required this.number,
    required this.giftId,
  });

  @override
  List<Object?> get props => [momentID, number, giftId];
}

class GetConfigKeyPram extends Equatable {
  final String? specialBar;

  const GetConfigKeyPram({
    this.specialBar,
  });

  @override
  List<Object?> get props => [specialBar];
}

class GetAllUserPram {
  final String page;
  List<String>? usersId;
  final String ownerId;

  GetAllUserPram({required this.ownerId, required this.page, this.usersId});
}

class MusicParameter extends Equatable {
  final String ownerId;

  const MusicParameter({required this.ownerId});

  @override
  List<Object?> get props => [ownerId];
}

// Chat
class PinChatToTopParamsUC extends Equatable {
  final String userId;
  final String chatId;

  const PinChatToTopParamsUC({
    required this.userId,
    required this.chatId,
  });

  @override
  List<Object?> get props => [userId, chatId];
}

class AddAdminParameter extends Equatable {
  final String roomId;
  final String? userId;

  /// Granular admin permission keys; null = ALL powers (legacy default).
  final List<String>? permissions;

  const AddAdminParameter({
    required this.roomId,
    this.userId,
    this.permissions,
  });

  @override
  List<Object?> get props => [roomId, userId, permissions];
}

class RemoveAdminParameter extends Equatable {
  final String roomId;
  final String? userId;

  const RemoveAdminParameter({
    required this.roomId,
    this.userId,
  });

  @override
  List<Object?> get props => [roomId, userId];
}

class LockCommentsParameter extends Equatable {
  final String roomId;
  final int status;

  const LockCommentsParameter({
    required this.roomId,
    required this.status,
  });

  @override
  List<Object?> get props => [
    roomId,
    status,
  ];
}

class MusicObjectParam extends Equatable {
  final String uri;

  final String name;
  final String artist;

  final int duration;
  final int id;

  const MusicObjectParam({
    required this.uri,
    required this.artist,
    required this.id,
    required this.name,
    required this.duration,
  });

  MusicObjectParam.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        uri = json['uri'],
        artist = json['artist'],
        duration = json['duration'],
        id = json['id'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'artist': artist,
      'uri': uri,
      'id': id,
      'duration': duration
    };
  }

  @override
  List<Object?> get props => [uri, name, duration, id, artist];
}

class BlockCommentsParameter extends Equatable {
  final String ownerId;
  final String roomId;
  final bool value;

  const BlockCommentsParameter({
    required this.ownerId,
    required this.roomId,
    required this.value,
  });

  @override
  List<Object?> get props => [ownerId, roomId, value];
}

class ClosePKParameter extends Equatable {
  final String roomId;
  final String? pkId;

  const ClosePKParameter({
    required this.roomId,
    this.pkId,
  });

  @override
  List<Object?> get props => [roomId, pkId];
}

class StartPKParameter extends Equatable {
  final String roomId;
  final String? time;

  const StartPKParameter({
    required this.roomId,
    this.time,
  });

  @override
  List<Object?> get props => [roomId, time];
}

class FetchShippingAgentsFullDataModelParam extends Equatable {
  final int? countryId;
  final int? paymentId;
  final int page;

  const FetchShippingAgentsFullDataModelParam({
    this.countryId,
    this.paymentId,
    this.page = 1,
  });

  @override
  List<Object?> get props => [countryId, paymentId, page];
}

class SendWithdrawalRequestParam extends Equatable {
  final String? agentId;
  final String? note;
  final String? paymentId;
  final String? countryId;
  final String? usd;

  const SendWithdrawalRequestParam({
    this.usd,
    this.agentId,
    this.note,
    this.paymentId,
    this.countryId,
  });

  @override
  List<Object?> get props => [agentId, note, paymentId, countryId, usd];
}

class SuccessTransferScreenParam extends Equatable {
  final String value;
  final bool isCoins;

  const SuccessTransferScreenParam({
    required this.value,
    this.isCoins = false,
  });

  @override
  List<Object?> get props => [value, isCoins];
}

class MomentsParam extends Equatable {
  final String? userId;
  final String? type;
  final String? page;

  const MomentsParam({this.userId, this.type, this.page});

  @override
  List<Object?> get props => [userId, type, page];
}

class ReportMomentParam extends Equatable {
  final String description;
  final String momentId;
  final String type;

  const ReportMomentParam({
    required this.description,
    required this.momentId,
    required this.type,
  });

  @override
  List<Object?> get props => [description, momentId, type];
}

class GetMomentCommentPrameter extends Equatable {
  final String page;
  final String momentId;

  const GetMomentCommentPrameter({
    required this.page,
    required this.momentId,
  });

  @override
  List<Object?> get props => [page, momentId];
}

class GetMomentLikePrameter extends Equatable {
  final String page;
  final String momentId;

  const GetMomentLikePrameter({required this.page, required this.momentId});

  @override
  List<Object?> get props => [page, momentId];
}

class AddMomentCommentPrameter extends Equatable {
  final String comment;
  final String momentId;

  const AddMomentCommentPrameter({
    required this.comment,
    required this.momentId,
  });

  @override
  List<Object?> get props => [comment, momentId];
}

class DeleteMomentCommentPrameter extends Equatable {
  final String commentId;
  final String momentId;

  const DeleteMomentCommentPrameter({
    required this.commentId,
    required this.momentId,
  });

  @override
  List<Object?> get props => [commentId, momentId];
}

class ReelParam extends Equatable {
  final int? page;
  final String? reelId, userId, filter, comment, description;

  const ReelParam(
      {this.page,
        this.userId,
        this.filter,
        this.reelId,
        this.comment,
        this.description});

  @override
  List<Object?> get props =>
      [page, userId, reelId, filter, comment, description];
}

class FilterRoomsParam extends Equatable {
  final int? countryId;
  final String? title;

  const FilterRoomsParam({
    this.countryId,
    this.title,
  });

  @override
  List<Object?> get props => [countryId, title];
}

class UploadReelParam extends Equatable {
  final File? reel;
  final String? preSignedUrl;
  final String? description;
  final String? backendName;
  final void Function(double progress)? onProgress;

  const UploadReelParam({
    this.reel,
    this.description,
    this.preSignedUrl,
    this.backendName,
    this.onProgress,
  });

  UploadReelParam copyWith({
    File? reel,
    String? preSignedUrl,
    String? description,
    String? backendName,
    void Function(double progress)? onProgress,
  }) {
    return UploadReelParam(
      reel: reel ?? this.reel,
      preSignedUrl: preSignedUrl ?? this.preSignedUrl,
      description: description ?? this.description,
      backendName: backendName ?? this.backendName,
      onProgress: onProgress ?? this.onProgress,
    );
  }

  @override
  List<Object?> get props => [reel, description, preSignedUrl, backendName];
}

// class AddReelParam extends Equatable {
//   final File? reel;
//   final String? preSignedUrl;
//   final String? description;
//   final String? duration;
//   final String? backendName;
// //final CachedVideoPlayerController? controller;
//
//   const AddReelParam({
//     this.reel,
//     // this.controller,
//   });
//
//   @override
//   List<Object?> get props => [
//         reel,
//       ];
// }

class SendVideoParam extends Equatable {
  final File? video;
  final String? preSignedUrl;
  final String? description;
  final String? duration;
  final String? backendName;
  final String? userId;

  /// Server conversation id for a 1:1 VIDEO message — threaded to the send so it
  /// can resolve the local drift room (null for reels / brand-new DMs).
  final int? chatId;
  final String? videoId;
  final String? videoProgressId;
  final bool isReels;

  const SendVideoParam({
    this.video,
    this.description,
    this.preSignedUrl,
    this.duration,
    this.backendName,
    this.videoProgressId,
    this.videoId,
    this.userId,
    this.chatId,
    this.isReels = true,
  });

  // copyWith method
  SendVideoParam copyWith(
      {File? video,
        String? preSignedUrl,
        String? videoProgressId,
        String? description,
        String? videoId,
        String? backendName,
        String? userId,
        int? chatId,
        bool? isReels}) {
    return SendVideoParam(
      video: video ?? this.video,
      preSignedUrl: preSignedUrl ?? this.preSignedUrl,
      videoId: videoId ?? this.videoId,
      videoProgressId: videoProgressId ?? this.videoProgressId,
      description: description ?? this.description,
      backendName: backendName ?? this.backendName,
      userId: userId ?? this.userId,
      chatId: chatId ?? this.chatId,
      isReels: isReels ?? this.isReels,
    );
  }

  @override
  List<Object?> get props => [
    video,
    description,
    videoProgressId,
    preSignedUrl,
    videoId,
    backendName,
    isReels,
    userId,
    chatId,
  ];
}

class SendPobUpPram extends Equatable {
  final String roomId;
  final String message;

  const SendPobUpPram({
    required this.roomId,
    required this.message,
  });

  @override
  List<Object?> get props => [roomId, message];
}

class SearchUserAgencyParam extends Equatable {
  final String? name;
  final String type;
  final String? uuid;
  final String? image;
  final String? id;

  const SearchUserAgencyParam({
    this.name,
    this.uuid,
    this.image,
    required this.type,
    this.id,
  });

  @override
  List<Object?> get props => [name, uuid, image, id, type];
}

class GiftRankArguments {
  final List<MomentGiftEntity> momentGiftList;
  final int topIndexes;

  GiftRankArguments({
    required this.momentGiftList,
    required this.topIndexes,
  });
}

class CheckAdminOwnerParam extends Equatable {
  final String? roomId;
  final String? type;

  const CheckAdminOwnerParam({
    this.roomId,
    this.type,
  });

  @override
  List<Object?> get props => [roomId, type];
}

class ResetCharismaParam extends Equatable {
  final String roomId;
  final String ownerId;

  const ResetCharismaParam({
    required this.roomId,
    required this.ownerId,
  });

  @override
  List<Object?> get props => [roomId, ownerId];
}

class CoinsScreenParam extends Equatable {
  final bool stopTransferButton;
  final bool isFromCoinsScreen;

  const CoinsScreenParam({
    required this.stopTransferButton,
    required this.isFromCoinsScreen,
  });

  @override
  List<Object?> get props => [stopTransferButton, isFromCoinsScreen];
}

class SystemOfficialParam extends Equatable {
  final int type;
  final int page;

  const SystemOfficialParam({
    required this.type,
    required this.page,
  });

  @override
  List<Object?> get props => [type, page];
}

class LuckyBoxParam extends Equatable {
  final String? boxId;
  final String? roomId;
  final String? quantity;

  const LuckyBoxParam({
    this.boxId,
    this.roomId,
    this.quantity,
  });

  @override
  List<Object?> get props => [boxId, roomId, quantity];
}

class UploadSongParam extends Equatable {
  final File? song;
  final String? songImage;
  final String? preSignedUrl;
  final String? description;
  final String? backendName;

  /// Real display title of the song (track metadata or the picked file name).
  /// The storage object name is random, so without this the backend can only
  /// show the random filename.
  final String? songName;

  const UploadSongParam({
    this.song,
    this.description,
    this.preSignedUrl,
    this.backendName,
    this.songImage,
    this.songName,
  });

  // copyWith method
  UploadSongParam copyWith({
    File? song,
    String? songImage,
    String? preSignedUrl,
    String? description,
    String? backendName,
    String? songName,
  }) {
    return UploadSongParam(
      song: song ?? this.song,
      preSignedUrl: preSignedUrl ?? this.preSignedUrl,
      description: description ?? this.description,
      backendName: backendName ?? this.backendName,
      songImage: songImage ?? this.songImage,
      songName: songName ?? this.songName,
    );
  }

  @override
  List<Object?> get props =>
      [song, description, preSignedUrl, backendName, songImage, songName];
}

class CountryParams extends Equatable {
  const CountryParams({
    this.countryId = '',
    required this.type,
  });

  final String countryId;
  final String type;

  @override
  List<Object?> get props => [];
}

class SendPkInvitationParams extends Equatable {
  const SendPkInvitationParams({
    required this.taskId,
    required this.userId,
    required this.creatorId,
  });

  final String taskId;
  final String userId;
  final String creatorId;

  @override
  List<Object?> get props => [taskId, userId, creatorId];
}

class RespondPkInvitationParams extends Equatable {
  const RespondPkInvitationParams({
    required this.taskId,
    required this.status,
  });

  final String taskId;
  final String status;

  @override
  List<Object?> get props => [taskId, status];
}

class StartLivePkParams extends Equatable {
  const StartLivePkParams({
    required this.team1,
    required this.team2,
    required this.duration,
  });

  final List<String> team1;
  final List<String> team2;
  final String duration;

  @override
  List<Object?> get props => [team1, team2, duration];
}

// Repurposed for the new v2 diamond -> coin exchange API, per request
// ("এই API গুলো দিয়ে আগে যা করা আছে ওই বাদ, নতুন ভাবে করে দাও"):
// POST /wallets/exchange/v2/make, payload { "diamonds": 100, "exchange": 1000 }
// -- `diamonds` is the amount being exchanged away, `exchange` is the coin
// amount received back (computed client-side from the v2/list rate before
// this is sent). The old {exchangeTo, diamonds} shape was never actually
// used anywhere in the app (confirmed via search), so this is a clean swap,
// not a breaking change to any live call site.
class MakeDiamondExchangeParams extends Equatable {
  const MakeDiamondExchangeParams({
    required this.diamonds,
    required this.exchange,
  });

  final int diamonds;
  final int exchange;

  @override
  List<Object?> get props => [diamonds, exchange];
}

// POST /wallets/withdraw, payload:
// { "amount": 100, "meta": { "method": "bkash", "number": "017XXXXXXXX" } }
// per the withdraw API spec provided -- amount is required (min 1), meta is
// optional (method/number only sent when both are provided).
class MakeWalletWithdrawParams extends Equatable {
  const MakeWalletWithdrawParams({
    required this.amount,
    this.method,
    this.number,
  });

  final num amount;
  final String? method;
  final String? number;

  Map<String, dynamic> toJson() => {
    'amount': amount,
    if (method != null && number != null)
      'meta': {
        'method': method,
        'number': number,
      },
  };

  @override
  List<Object?> get props => [amount, method, number];
}

// ---------------------------------------------------------------------
// New Withdrawal System params (full spec provided for this feature).
// ---------------------------------------------------------------------

class AddPaymentMethodParams extends Equatable {
  const AddPaymentMethodParams({
    required this.methodName,
    required this.methodAccount,
  });

  final String methodName;
  final String methodAccount;

  Map<String, dynamic> toJson() => {
    'method_name': methodName,
    'method_account': methodAccount,
  };

  @override
  List<Object?> get props => [methodName, methodAccount];
}

/// POST /editPaymentMethod -- same shape as [AddPaymentMethodParams] plus the
/// id of the saved payment method being edited.
class EditPaymentMethodParams extends Equatable {
  const EditPaymentMethodParams({
    required this.id,
    required this.methodName,
    required this.methodAccount,
  });

  final String id;
  final String methodName;
  final String methodAccount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'method_name': methodName,
    'method_account': methodAccount,
  };

  @override
  List<Object?> get props => [id, methodName, methodAccount];
}

/// POST /withdrow_create. `receivedType` is `"admin"` or `"reseller"`;
/// `resellerId` is REQUIRED to always be sent (even as `null`) per the exact
/// example given in the API documentation, so `toJson` always includes the
/// key rather than omitting it when empty.
class CreateWithdrawRequestParams extends Equatable {
  const CreateWithdrawRequestParams({
    required this.methodId,
    required this.amount,
    required this.receivedType,
    this.resellerId,
  });

  final String methodId;
  final num amount;

  /// "admin" | "reseller".
  final String receivedType;

  /// Only meaningful when [receivedType] is "reseller" -- always present in
  /// the JSON body regardless (as `null` for "admin"), per spec.
  final String? resellerId;

  Map<String, dynamic> toJson() => {
    'method_id': methodId,
    'amount': amount,
    'received_type': receivedType,
    'reseller_id': resellerId,
  };

  @override
  List<Object?> get props =>
      [methodId, amount, receivedType, resellerId];
}

class MakeDollarsExchangeParams extends Equatable {
  const MakeDollarsExchangeParams({
    required this.id,
    required this.amount,
    required this.data,
  });

  final String amount;
  final String id;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [id, amount, data];
}

class GetRecordsParams extends Equatable {
  const GetRecordsParams({
    required this.type,
    this.startDate,
    this.endDate,
  });

  final String type;
  final String? startDate;
  final String? endDate;

  @override
  List<Object?> get props => [type, startDate, endDate];
}

/// Room id + the mode to store. See [ChangeRoomModeUC] for what `mode` means
/// for each room type.
class ChangeRoomModeParameter extends Equatable {
  final String roomId;
  final int mode;

  const ChangeRoomModeParameter({required this.roomId, required this.mode});

  @override
  List<Object?> get props => [roomId, mode];
}

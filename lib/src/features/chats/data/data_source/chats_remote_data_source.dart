import 'package:general/src/features/chats/chats.dart';

abstract class ChatsRemoteDataSource {
  Future<BaseResponse<List<SystemAndOfficialMessagesModel>>> getSystemMessage(
      SystemOfficialParam params);
  Future<BaseResponse<UserAllChatModel>> fetchChats(int? page);
  Future<UserAllChatRequestModel> fetchChatsRequest();
  Future<BaseResponse<DeleteChatModel>> deleteChat({required int userId});
}

class ChatsRemoteDataSourceImp extends ChatsRemoteDataSource {
  final DioFactory _dio;
  ChatsRemoteDataSourceImp(this._dio);

  @override
  Future<BaseResponse<List<SystemAndOfficialMessagesModel>>> getSystemMessage(
      SystemOfficialParam params) async {
    final timeZone = await Methods().getCurrentTimeZone();
    final response =
        await _dio.get(EndPoints.fetchAppMessages(params.type,params.page), headers: {'tz': timeZone});
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => SystemAndOfficialMessagesModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<UserAllChatModel>> fetchChats(int? page) async {
    final timeZone = await Methods().getCurrentTimeZone();

    final response = await _dio.get(EndPoints.oneUserChat,
        headers: {'tz': timeZone}, queryParameters: {'page': page ?? ''});
    //   Map<String, dynamic> result_ = response.data;
    return BaseResponse<UserAllChatModel>.fromJson(
      response.data,
      fromJsonT: (json) => UserAllChatModel.fromJson(json),
    );
  }

  @override
  Future<UserAllChatRequestModel> fetchChatsRequest() async {
    final timeZone = await Methods().getCurrentTimeZone();

    final response =
        await _dio.get(EndPoints.oneUserChatRequest, headers: {'tz': timeZone});
    Map<String, dynamic> result_ = response.data;
    return UserAllChatRequestModel.fromJson(
      result_['data'],
    );
  }

  @override
  Future<BaseResponse<DeleteChatModel>> deleteChat(
      {required int userId}) async {
    final response = await _dio.delete(
      EndPoints.deleteChat(userId),
    );

    return BaseResponse<DeleteChatModel>.fromJson(
      response.data,
      fromJsonT: (json) => DeleteChatModel.fromJson(response.data),
    );
  }
}


import 'package:general/src/core/index.dart';
import 'package:general/src/features/moment/data/models/moment_gift_model.dart';
import 'package:general/src/features/moment/moment.dart';

import '../models/moment_like_model.dart';

abstract class BaseMomentRemoteDataSource {
  Future<BaseResponse<List<MomentModel>>> fetchMoments(
      {required MomentsParam param});
  Future<BaseResponse<String>> addMomnet(
      {required AddMomentParametersUC param});
  Future<BaseResponse<int>> deleteMoment({required String momentId});
  Future<BaseResponse<String>> likeMoment({required String momentId});
  Future<BaseResponse<String>> reportMoment(
      ReportMomentParam reportMomentParam);
  Future<BaseResponse<List<MomentCommentsModel>>> fetchMomentComment(
      {required GetMomentCommentPrameter param});
  Future<BaseResponse<List<MomentLikeModel>>> getMomentLike(
      {required GetMomentLikePrameter param});

  Future<BaseResponse<String>> addMomentComment(
      {required AddMomentCommentPrameter data});
  Future<BaseResponse<String>> deleteMomentComment(
      {required DeleteMomentCommentPrameter data});
  Future<BaseResponse<List<MomentGiftModel>>> fetchGiftMoments(
      {required int userID});

  Future<String> sendGiftsMoment(SendGiftMomentParameter params);
}

class MomentRemoteDataSourceImp extends BaseMomentRemoteDataSource {
  final DioFactory _dio;
  MomentRemoteDataSourceImp(this._dio);

  @override
  Future<BaseResponse<List<MomentModel>>> fetchMoments(
      {required MomentsParam param}) async {
    final response = await _dio.get(
      EndPoints.getMoments(
          param.type ?? "", param.page ?? "", param.userId ?? ""),
    );
    return BaseResponse<List<MomentModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => MomentModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> addMomnet(
      {required AddMomentParametersUC param}) async {
    final FormData data;
    final List<MultipartFile> images = [];
    for (final element in param.multiImages ?? []) {
      images.add(await MultipartFile.fromFile(element.path));
    }
    data = FormData.fromMap({
      'contacts': param.text,
    });

    if (images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        data.files.add(MapEntry('multi_image[$i]', images[i]));
      }
    }

    final response = await _dio.post(
      EndPoints.addMoment,
      data: data,
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => response.data['message'],
    );
  }

  @override
  Future<BaseResponse<int>> deleteMoment({required String momentId}) async {
    final response = await _dio.delete(
      EndPoints.deleteMoment(momentId),
    );

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => response.data['data'],
    );
  }

  @override
  Future<BaseResponse<String>> likeMoment({required String momentId}) async {
    final response = await _dio.post(
      EndPoints.makeMomentLikes(momentId),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => response.data['message'],
    );
  }

  @override
  Future<BaseResponse<List<MomentCommentsModel>>> fetchMomentComment(
      {required GetMomentCommentPrameter param}) async {
    final response = await _dio.get(
      EndPoints.getMomentComment(param.momentId, param.page),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => MomentCommentsModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> addMomentComment(
      {required AddMomentCommentPrameter data}) async {
    final response = await _dio.post(
      EndPoints.addMomentComment(data.momentId),
      data: {
        "comment": data.comment,
      },
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => response.data['message'],
    );
  }

  @override
  Future<BaseResponse<String>> deleteMomentComment(
      {required DeleteMomentCommentPrameter data}) async {
    final response = await _dio.delete(
      EndPoints.deleteMomentComment(data.momentId, data.commentId),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => response.data['message'],
    );
  }

  @override
  Future<BaseResponse<String>> reportMoment(
      ReportMomentParam reportMomentParam) async {
    final response = await _dio.post(
      EndPoints.reportMoment(
        reportMomentParam.momentId,
        reportMomentParam.type,
        reportMomentParam.description,
      ),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => response.data['message'],
    );
  }

  @override
  Future<BaseResponse<List<MomentLikeModel>>> getMomentLike(
      {required GetMomentLikePrameter param}) async {
    final response = await _dio.get(
      EndPoints.getMomentLike(param.momentId, param.page),
    );
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => MomentLikeModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<MomentGiftModel>>> fetchGiftMoments(
      {required int userID}) async {
    final response = await _dio.get(
      EndPoints.fetchMomentGift(userID),
    );
    return BaseResponse<List<MomentGiftModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => MomentGiftModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<String> sendGiftsMoment(SendGiftMomentParameter params) async {
    final body = {
      'num': params.number,
      'gift_id': params.giftId,
    };
    final response = await _dio.post(
      EndPoints.sendMomentGift(params.momentID),
      data: body,
    );

    Map<String, dynamic> jsonData = response.data;

    return jsonData["message"] ?? "";
  }
}

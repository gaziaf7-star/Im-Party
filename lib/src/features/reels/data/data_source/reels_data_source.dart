import 'dart:io';
import 'package:mime/mime.dart';
import 'package:general/src/features/reels/data/model/reel_comment_model.dart';
import 'package:general/src/features/reels/data/model/reel_model.dart';
import '../../../../core/index.dart';
import '../../../../core/services/notification/notification_service.dart';

abstract class ReelsBaseDataSource {
  Future<BaseResponse<List<ReelsMainModel>>> getReels(ReelParam param);
  Future<BaseResponse<ReelsMainModel>> getOneReel(ReelParam param);

  Future<BaseResponse<String>> deleteReel(ReelParam param);
  Future<BaseResponse<String>> updateReelDescription(ReelParam param);
  Future<BaseResponse<List<ReelsMainModel>>> getMyReels(ReelParam param);

  Future<BaseResponse<List<ReelCommentModel>>> getComments(ReelParam param);

  Future<BaseResponse<String>> makeComments(ReelParam param);

  Future<BaseResponse<String>> makeLike(
    String reelId,
  );

  Future<BaseResponse<List<ReelsMainModel>>> getFollowingReels(String? page);

  Future<Map<String, String>> getPreSignedUrl(File reel);

  Future<int> uploadFileToStorage(
    UploadReelParam param,
  );

  Future<BaseResponse<ReelsMainModel>> notifyBackend(
    UploadReelParam param,
  );
}

class ReelsDataSourceImp implements ReelsBaseDataSource {
  final DioFactory dioFactory;

  ReelsDataSourceImp(this.dioFactory);

  // WF4 PERPAGE-01: larger page size for the for-you/following feed so the
  // user hits the end of the buffer less often.
  static const int _feedPerPage = 12;

  @override
  Future<BaseResponse<List<ReelsMainModel>>> getReels(ReelParam param) async {
    final response = await dioFactory.get(EndPoints.getReel(
      page: param.page,
      filter: param.filter,
      perPage: _feedPerPage,
    ));

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List)
          .map((element) => ReelsMainModel.fromJson(element))
          // WF4 MODEL-URL-01: drop reels with no playable video url so an
          // unplayable item never occupies a feed slot. Order is preserved.
          .where((reel) => reel.url != null && reel.url!.isNotEmpty)
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> deleteReel(ReelParam param) async {
    final response = await dioFactory.delete(
      EndPoints.deleteReel(param.reelId ?? '-1'),
    );
    return BaseResponse.fromJson(
      response.data,
    );
  }

  @override
  Future<BaseResponse<String>> updateReelDescription(ReelParam param) async {
    final response = await dioFactory.post(
        EndPoints.updateReelDescription(param.reelId ?? '-1'),
        data: {'description': param.description});

    return BaseResponse.fromJson(
      response.data,
    );
  }

  @override
  Future<BaseResponse<List<ReelsMainModel>>> getMyReels(ReelParam param) async {
    // final response = await dioFactory.get(EndPoints.getMyReels(page: param.page,));
    final response = await dioFactory.get(EndPoints.getReelUser(
      param.userId,
      param.page.toString(),
    ));

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List)
          .map((element) => ReelsMainModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<ReelCommentModel>>> getComments(
      ReelParam param) async {
    final response = await dioFactory
        .get(EndPoints.getReelComments(param.reelId ?? '', param.page));

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List)
          .map((element) => ReelCommentModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<ReelsMainModel>>> getFollowingReels(
      String? page) async {
    // EndPoints.getFollowingReels has no perPage param (do NOT edit end_points),
    // so only the url filter is applied here.
    final response =
        await dioFactory.get(EndPoints.getFollowingReels(page ?? '1'));

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => (json as List)
          .map((element) => ReelsMainModel.fromJson(element))
          // WF4 MODEL-URL-01: drop reels with no playable video url.
          .where((reel) => reel.url != null && reel.url!.isNotEmpty)
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> makeComments(ReelParam param) async {
    final response = await dioFactory.post(
        EndPoints.makeReelComments(param.reelId ?? '-1'),
        data: {'comment': param.comment});

    return BaseResponse.fromJson(
      response.data,
    );
  }

  @override
  Future<BaseResponse<String>> makeLike(String reelId) async {
    final response = await dioFactory.post(
      EndPoints.makeReelLike(reelId),
    );

    return BaseResponse.fromJson(
      response.data,
    );
  }

  @override
  Future<Map<String, String>> getPreSignedUrl(File reel) async {
    final fileName =
        reel.path.split('/').last.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final int fileSize = await reel.length();

    final String fileType = lookupMimeType(reel.path) ?? 'unknown';

    final response = await dioFactory.post(
      EndPoints.generateUploadLink,
      data: {
        "name": fileName,
        "type": fileType,
        "size": fileSize,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to generate pre-signed URL');
    }

    // The signed PUT URL is mandatory for the upload step; without it the next
    // stage would force-unwrap null and hand an empty URL to Dio. Fail here with
    // a clear error so the upload bloc surfaces it instead of crashing later.
    final uploadUrl = response.data['upload_url'] as String?;
    if (uploadUrl == null || uploadUrl.isEmpty) {
      throw Exception('Pre-signed URL missing in response');
    }

    return {
      'upload_url': uploadUrl,
      'name': response.data['name'],
    };
  }

  @override
  Future<int> uploadFileToStorage(
    UploadReelParam param,
  ) async {
    final File reel = param.reel!;
    final String fileType = lookupMimeType(reel.path) ?? 'unknown';
    final int fileSize = await reel.length();

    // Guard against a null/empty signed URL reaching Dio.put (which would throw
    // on an empty path). getPreSignedUrl already validates this, but the upload
    // step is also reachable via retry paths, so re-check here.
    final String? preSignedUrl = param.preSignedUrl;
    if (preSignedUrl == null || preSignedUrl.isEmpty) {
      throw Exception('Missing pre-signed URL for reel upload');
    }

    final response = await dioFactory.put(
      preSignedUrl,
      data: reel.openRead(),
      options: Options(headers: {
        'Content-Type': fileType,
        'Content-Length': fileSize.toString(),
      }, method: 'PUT'),
      onSendProgress: (int sent, int total) {
        if (total > 0) {
          final progress = (sent / total * 100).toInt();
          NotificationService().showProgressNotification(progress);
          param.onProgress?.call(progress / 100.0);

          if (progress == 100) {
            NotificationService().cancelProgressNotification();
          }
        }
      },
    );
    return response.statusCode ?? 500;
  }

  @override
  Future<BaseResponse<ReelsMainModel>> notifyBackend(
    UploadReelParam param,
  ) async {
    final response = await dioFactory.post(EndPoints.createReels,
        data: {
          "video": param.backendName,
          "description": param.description,
        },
        options: Options(method: 'POST'));

    if (response.statusCode != 200) {
      throw Exception('Failed to notify the backend');
    }
    return BaseResponse.fromJson(response.data,
        fromJsonT: (json) => ReelsMainModel.fromJson(json));
    // return BaseResponse.fromJson(response.data);
  }

  @override
  Future<BaseResponse<ReelsMainModel>> getOneReel(ReelParam param) async {
    final response =
        await dioFactory.get(EndPoints.getReel(reelId: param.reelId));

    return BaseResponse.fromJson(response.data,
        fromJsonT: (json) => ReelsMainModel.fromJson(json));
  }
}

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/realtime/realtime_config.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/data/model/agency_badge_model.dart';
import 'package:general/src/features/auth/data/model/colors_model.dart';
import 'package:general/src/features/auth/data/model/config_model.dart';
import 'package:general/src/features/auth/data/model/vip_frames_model.dart';
import 'package:general/src/features/auth/data/model/wabbles_model.dart';
import 'package:general/src/features/setting/data/model/switch_account_model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

abstract class BaseAuthenticationRemoteDataSource {
  Future<BaseResponse<SwitchLoginAccountModel>> login(AuthParameter params);

  /// Quick login: no credential, the device IS the identity.
  Future<BaseResponse<SwitchLoginAccountModel>> signInAsGuest();

  Future<BaseResponse<bool>> checkPhone(String phone);

  Future<BaseResponse<GoogleModel>> sigInWithGoogle();

  Future<BaseResponse<AppleModel>> sigInWithApple();

  Future<BaseResponse<AuthWithHuaweiModel>> sigInWithHuawei();

  Future<BaseResponse<List<CountryModel>>> fetchCountries();

  Future<BaseResponse<String>> register({required AuthParameterUC params});

  Future<BaseResponse<String>> forgetPassword({
    required AuthParameterUC params,
  });

  Future<BaseResponse<String>> replaceCoverImage({
    required ReplaceCoverImageParametersUC params,
  });

  Future<BaseResponse<MyDataModel>> addInfo({
    required InformationParametersUC params,
  });

  Future<BaseResponse<String>> changePassword(SendCodeParameter param);

  Future<BaseResponse<String>> changePhone(SendCodeParameter param);

  Future<ConfigModel> getConfigApp(ConfigModelBody configModelBody);

  Future<BaseResponse<bool>> getRealtimeSettings();

  Future<BaseResponse<List<VipFramesModel>>> getVipFrames();

  Future<List<AgencyBadgeModel>> getAgencyBadges();

  Future<List<WabblesModel>> getWabbles();

  Future<BaseResponse<ColorsModel>> fetchColors({bool forceRefresh});

  Future<BaseResponse<List<CountryCategoryModel>>> fetchCountryCategories();

  Future<BaseResponse<List<CountryModel>>> fetchCountriesByCategory(
      int categoryId);

  Future<String> setStorageUrl();

  Future<BaseResponse<String>> getFirebaseCustomToken();
}

class AuthenticationRemoteDataSourceImp
    extends BaseAuthenticationRemoteDataSource {
  final DioFactory dio;

  AuthenticationRemoteDataSourceImp({required this.dio});

  @override
  Future<BaseResponse<GoogleModel>> sigInWithGoogle() async {
    try {
      final google = GoogleSignIn();
      await google.signOut();

      final GoogleSignInAccount? user;
      try {
        user = await google.signIn();
      } on PlatformException catch (e) {
        Methods.printLog("❌ PlatformException during Google sign-in: $e");
        rethrow;
      }

      if (user == null) {
        Methods.printLog("⚠️ Google sign-in cancelled by user");
        throw const GoogleSignInCanceled();
      }

      Methods.printLog("✅ Google User => "
          "displayName: ${user.displayName}, "
          "email: ${user.email}, "
          "id: ${user.id}, "
          "photoUrl: ${user.photoUrl}");

      final googleAuth = await user.authentication;
      final idToken = googleAuth.idToken ?? '';
      Methods.printLog("✅ Google Auth => "
          "idToken: $idToken, "
          "accessToken: ${googleAuth.accessToken}");

      String? notificationId;
      final String deviceId = await dio.ensureDeviceId();
      Methods.printLog("✅ Device ID = $deviceId");

      try {
        notificationId = await FirebaseMessaging.instance.getToken();
        Methods.printLog("✅ FCM token = ${notificationId ?? 'null'}");
      } catch (error) {
        Methods.printLog("❌ Error getting FCM token: $error");
        notificationId = null;
      }

      MultipartFile? googleImageFile;
      if (user.photoUrl != null && (user.photoUrl?.isNotEmpty == true)) {
        try {
          final response = await http.get(Uri.parse(user.photoUrl ?? ""));
          Methods.printLog("✅ Google photo download status: ${response.statusCode}");
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final filePath = '${tempDir.path}/${basename(user.photoUrl ?? "")}';
            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            googleImageFile = await MultipartFile.fromFile(
              file.path,
              filename: basename(file.path),
            );
            Methods.printLog("✅ Google image saved at: $filePath "
                "(size: ${response.bodyBytes.length} bytes)");
          } else {
            Methods.printLog(
                "⚠️ Google photo URL returned status ${response.statusCode}");
          }
        } catch (e) {
          Methods.printLog("❌ Error downloading Google profile image: $e");
          googleImageFile = null;
        }
      } else {
        Methods.printLog("⚠️ No Google photo URL available");
      }

      final formData = FormData.fromMap({
        "type": "google",
        "name": user.displayName ?? '',
        "email": user.email.isNotEmpty ? user.email : 'no-email',
        "google_image": googleImageFile,
        "id_token": idToken.isNotEmpty ? idToken : 'no-id-token',
        "google_id": user.id,
        "device_token": deviceId,
        "notification_id": notificationId ?? '',
      });

      Methods.printLog("✅ FormData fields => "
          "type: google, "
          "name: ${user.displayName ?? ''}, "
          "email: ${user.email.isNotEmpty ? user.email : 'no-email'}, "
          "google_image: ${googleImageFile != null ? googleImageFile.filename : 'null'}, "
          "id_token: ${idToken.isNotEmpty ? idToken : 'no-id-token'}, "
          "google_id: ${user.id}, "
          "device_token: $deviceId, "
          "notification_id: ${notificationId ?? ''}");

      final response = await dio.post(EndPoints.login, data: formData);

      Methods.printLog("✅ Raw API response => ${response.data}");

      final rawData = response.data?['data'];
      if (rawData == null || rawData is! Map<String, dynamic>) {
        Methods.printLog("❌ Invalid Google login response: ${response.data}");
        throw const UnableToProcess();
      }

      Methods.printLog("✅ rawData from response => $rawData");

      final MyDataModel data = MyDataModel.fromJson(rawData);


      final result = BaseResponse<GoogleModel>.fromJson(
        response.data,
        fromJsonT: (_) => GoogleModel(data: data, googleID: user!),
      );


      return result;
    } catch (error, stackTrace) {
      Methods.printLog("❌ Error in Google sign-in: $error\n$stackTrace");
      rethrow;
    }
  }
  @override
  Future<BaseResponse<AppleModel>> sigInWithApple() async {
    final AuthorizationCredentialAppleID credential;
    credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final String deviceId = await dio.ensureDeviceId();
    String? notificationId;

    try {
      notificationId = await FirebaseMessaging.instance.getToken();
    } catch (error) {
      Methods.printLog("❌ Error getting FCM token: $error");
    }
    if (notificationId == null) {
      Methods.printLog(
          "⚠️ FCM token is null — sending 'no-fcm-token' in header");
    } else {
      Methods.printLog("✅ FCM token = $notificationId");
    }
    final body = {
      "type": "apple",
      "name": credential.givenName,
      "apple_id": credential.authorizationCode,
      'user_id': credential.userIdentifier,
      'device_token': deviceId,
      'notification_id': notificationId,
      // 'long': ConstantsManager.long,
      // 'lat': ConstantsManager.lat,
      // 'iso': ConstantsManager.country,
    };
    final response = await dio.post(EndPoints.login, data: body);

    final MyDataModel userData = MyDataModel.fromJson(response.data['data']);
    return BaseResponse<AppleModel>.fromJson(
      response.data,
      fromJsonT: (_) => AppleModel(data: userData, appleID: credential),
    );
  }

  @override
  Future<BaseResponse<AuthWithHuaweiModel>> sigInWithHuawei() async {
    final String deviceId = await dio.ensureDeviceId();
    AccountAuthParamsHelper accountAuthParamsHelper = AccountAuthParamsHelper(
      AccountAuthParams.defaultAuthRequestParam,
    );

    accountAuthParamsHelper.setProfile();
    accountAuthParamsHelper.setEmail();
    accountAuthParamsHelper.setIdToken();
    final AccountAuthParams accountAuthParams =
        accountAuthParamsHelper.createParams();
    final AccountAuthService accountAuthService =
        AccountAuthManager.getService(accountAuthParams);
    final AuthAccount account = await accountAuthService.signIn();
    String? notificationId;

    try {
      notificationId = await FirebaseMessaging.instance.getToken();
    } catch (error) {
      Methods.printLog("❌ Error getting FCM token: $error");
    }
    if (notificationId == null) {
      Methods.printLog(
          "⚠️ FCM token is null — sending 'no-fcm-token' in header");
    } else {
      Methods.printLog("✅ FCM token = $notificationId");
    }

    final body = {
      'type': "huawei",
      'name': account.displayName,
      "huawei_id": account.unionId,
      'id_token': account.idToken,
      'device_token': deviceId,
      'notification_id': notificationId,
    };
    final response = await dio.post(EndPoints.login, data: body);

    final MyDataModel userData = MyDataModel.fromJson(response.data['data']);

    return BaseResponse<AuthWithHuaweiModel>.fromJson(
      response.data,
      fromJsonT: (_) => AuthWithHuaweiModel(data: userData, huawei: account),
    );
  }

  @override
  Future<BaseResponse<SwitchLoginAccountModel>> login(params) async {
    final deviceData = await dio.ensureDeviceId();

    final body = {
      "type": "phone_pass",
      "phone": params.phone,
      "password": params.password,
      'device_token': deviceData,
      'is_multi': params.isMulti,
    };
    final response = await dio.post(EndPoints.login, data: body);
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => SwitchLoginAccountModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<SwitchLoginAccountModel>> signInAsGuest() async {
    // The same stable id the rest of the app already uses for this handset, so
    // a guest lands on their own account every launch without ever signing up.
    final deviceId = await dio.ensureDeviceId();

    final body = {
      "type": "guest",
      "guest_device_id": deviceId,
      "device_token": deviceId,
    };
    final response = await dio.post(EndPoints.login, data: body);

    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => SwitchLoginAccountModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<bool>> checkPhone(String phone) async {
    final body = {
      "phone": phone,
    };
    final response = await dio.post(EndPoints.checkPhone, data: body);

    return BaseResponse<bool>.fromJson(response.data,
        fromJsonT: (json) => json);
  }

  @override
  Future<BaseResponse<List<CountryModel>>> fetchCountries() async {
    Response response = await dio.get(
      EndPoints.countries,
      cacheDuration: const Duration(hours: 24),
    );
    return BaseResponse<List<CountryModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => CountryModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<CountryCategoryModel>>>
      fetchCountryCategories() async {
    Response response = await dio.get(
      EndPoints.countriesCategories,
      cacheDuration: const Duration(hours: 24),
    );
    return BaseResponse<List<CountryCategoryModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) =>
              CountryCategoryModel.fromJson(element as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<List<CountryModel>>> fetchCountriesByCategory(
      int categoryId) async {
    Response response = await dio.get(
      EndPoints.countriesByCategory(categoryId),
    );
    return BaseResponse<List<CountryModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => CountryModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<BaseResponse<String>> register({required params}) async {
    String? notificationId;
    final deviceData = await dio.ensureDeviceId();

    try {
      notificationId = await FirebaseMessaging.instance.getToken();
    } catch (error) {
      Methods.printLog("❌ Error getting FCM token: $error");
    }
    if (notificationId == null) {
      Methods.printLog(
          "⚠️ FCM token is null — sending 'no-fcm-token' in header");
    } else {
      Methods.printLog("✅ FCM token = $notificationId");
    }

    Response response = await dio.post(
      EndPoints.register,
      data: {
        "phone": params.phone,
        "password": params.password,
        "firebase_id_token": params.firebaseIdToken,
        'notification_id': notificationId,
        'device_token': deviceData,
      },
    );
    return BaseResponse<String>.fromJson(response.data,
        fromJsonT: (json) => json['auth_token'] as String);
  }

  @override
  Future<BaseResponse<MyDataModel>> addInfo({required params}) async {
    final FormData data;
    String? notificationId;

    // 🔔 Try getting FCM token
    try {
      notificationId = await FirebaseMessaging.instance.getToken();
      Methods.printLog("FCM token fetched: $notificationId");
    } catch (error, s) {
      Methods.printLog("Error getting FCM token: $error");
      Methods.printLog("StackTrace: $s");
    }

    // 🖼️ Prepare multi images if any
    final List<MultipartFile> images = [];
    for (final element in params.multiImages ?? []) {
      try {
        images.add(await MultipartFile.fromFile(element.path));
        Methods.printLog("Added multi-image: ${element.path}");
      } catch (e) {
        Methods.printLog("Failed to add image: ${element.path} → $e");
      }
    }

    if (params.isUpdateOnlyUid == true) {
      data = FormData.fromMap({
        if (params.uuid?.isNotEmpty == true) 'uuid': params.uuid,
      });
    } else {
      // 🧱 Build FormData based on conditions
      if (params.image == null) {
        data = FormData.fromMap({
          'bio': params.bio,
          'name': params.name,
          'birthday': params.date,
          "gender": params.gender ?? 1,
          'old_multi_image': (params.oldMultiImages ?? []).join(','),
          'notification_id': notificationId,
          // countryId reached this class and stopped here: it was never put in
          // the body, so every account was created with no country and the
          // home feed's country filter could not see them.
          if (params.countryId != null) 'country_id': params.countryId,
          if (params.uuid?.isNotEmpty == true) 'uuid': params.uuid,
        });
      } else {
        final File file = params.image!;
        final String name = file.path.split('/').last;

        data = FormData.fromMap({
          'bio': params.bio,
          "image": await MultipartFile.fromFile(file.path, filename: name),
          'name': params.name,
          'birthday': params.date,
          "gender": params.gender ?? 1,
          'old_multi_image': (params.oldMultiImages ?? []).join(','),
          'notification_id': notificationId,
          // countryId reached this class and stopped here: it was never put in
          // the body, so every account was created with no country and the
          // home feed's country filter could not see them.
          if (params.countryId != null) 'country_id': params.countryId,
          if (params.uuid?.isNotEmpty == true) 'uuid': params.uuid,
        });
      }
    }

    if (images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        data.files.add(MapEntry('new_multi_image[$i]', images[i]));
      }
      Methods.printLog("Added ${images.length} multi-images to FormData");
    }

    Response response;
    try {
      response = await dio.post(
        EndPoints.addInfo,
        data: data,
      );
    } catch (e, s) {
      Methods.printLog("Dio POST request failed: $e");
      Methods.printLog("StackTrace: $s");
      rethrow;
    }

    try {
      final parsedResponse = BaseResponse<MyDataModel>.fromJson(
        response.data,
        fromJsonT: (json) => MyDataModel.fromJson(json),
      );
      return parsedResponse;
    } catch (e, s) {
      Methods.printLog("Error parsing BaseResponse: $e");
      Methods.printLog("StackTrace: $s");
      rethrow;
    }
  }

  @override
  Future<BaseResponse<String>> replaceCoverImage({required params}) async {
    final FormData data;
    data = FormData.fromMap({
      "new_multi_image": await MultipartFile.fromFile(params.newImage!.path),
    });

    Response response = await dio.post(
      EndPoints.replaceCoverImage(params.previousImageId!.toString()),
      data: data,
    );
    return BaseResponse.fromJson(response.data);
  }

  @override
  Future<BaseResponse<String>> forgetPassword({required params}) async {
    Response response = await dio.post(
      EndPoints.forgotPassword,
      data: {
        "phone": params.phone,
        "password": params.password,
        "firebase_id_token": params.firebaseIdToken,
      },
    );
    return BaseResponse<String>.fromJson(response.data);
  }

  @override
  Future<BaseResponse<String>> changePassword(SendCodeParameter param) async {
    final body = {
      'phone': param.phone,
      if (param.firebaseIdToken.isNotEmpty)
        'firebase_id_token': param.firebaseIdToken,
      'password': param.password,
      'type': param.type,
    };
    final response = await dio.post(EndPoints.changePassword, data: body);

    return BaseResponse.fromJson(response.data);
  }

  @override
  Future<BaseResponse<String>> changePhone(SendCodeParameter param) async {
    final body = {
      'phone': param.phone,
      if (param.firebaseIdToken.isNotEmpty)
        'firebase_id_token': param.firebaseIdToken,
      if (param.newPhone != "") 'current_phone': param.newPhone,
    };
    final response = await dio.post(EndPoints.changePhone, data: body);

    return BaseResponse.fromJson(response.data);
  }

  @override
  Future<ConfigModel> getConfigApp(ConfigModelBody configModelBody) async {
    // Last UTC second the app received/applied colors. Sent so the server
    // compares it and returns colors=changed ONLY when the panel palette is
    // actually newer — turning the per-launch colors fetch into a no-op when
    // nothing changed (save-the-request). null on first launch (no cache yet).
    final colorsUpdatedTime =
        await Methods().getsLastTimeCache(TypesCache.color);
    final body = {
      'version': configModelBody.appVersion,
      'version_name': ConstantsManager.appVersionName,
      'OS': configModelBody.devicePlatform,
      'profile_frame_updated':
          await Methods().getsLastTimeCache(TypesCache.frame),
      'bubbles_frame_time':
          await Methods().getsLastTimeCache(TypesCache.bubble),
      'wabbles_frame_time':
          await Methods().getsLastTimeCache(TypesCache.wabbles),
      'badges_agency_time':
          await Methods().getsLastTimeCache(TypesCache.badges),
      'gift_time': await Methods().getsLastTimeCache(TypesCache.gift),
      'intro_time': await Methods().getsLastTimeCache(TypesCache.intro),
      'emoji_time': await Methods().getsLastTimeCache(TypesCache.emojie),
      'extra_time': await Methods().getsLastTimeCache(TypesCache.extra),
      'banner_time': await Methods().getsLastTimeCache(TypesCache.banner),
      'color_time': colorsUpdatedTime,
      'colors_updated_time': colorsUpdatedTime,
      'games_image_time': await Methods().getsLastTimeCache(TypesCache.games),
      'room_boom_videos': await Methods().getsLastTimeCache(TypesCache.boom),
      'boom_themes_time':
          await Methods().getsLastTimeCache(TypesCache.boomTheme),
    };
    final response = await dio.post(EndPoints.configApp, data: body);

    return ConfigModel.fromJson(response.data);
  }

  @override
  Future<BaseResponse<List<VipFramesModel>>> getVipFrames() async {
    final response = await dio.get(EndPoints.profileFrameWares);

    return BaseResponse<List<VipFramesModel>>.fromJson(
      response.data,
      fromJsonT: (json) => (json as List<dynamic>)
          .map((element) => VipFramesModel.fromJson(element))
          .toList(),
    );
  }

  @override
  Future<List<AgencyBadgeModel>> getAgencyBadges() async {
    final response = await dio.get(EndPoints.agencyBadges);

    return (response.data['data'] as List<dynamic>)
        .map((element) => AgencyBadgeModel.fromJson(element))
        .toList();
  }

  @override
  Future<List<WabblesModel>> getWabbles() async {
    final response = await dio.get(EndPoints.getWabbles);

    return (response.data['data'] as List<dynamic>)
        .map((element) => WabblesModel.fromJson(element))
        .toList();
  }

  @override
  Future<BaseResponse<ColorsModel>> fetchColors({bool forceRefresh = false}) async {
    final response = await dio.get(
      EndPoints.colors,
      cacheDuration: const Duration(hours: 1),
      forceRefresh: forceRefresh,
    );

    return BaseResponse<ColorsModel>.fromJson(
      response.data,
      fromJsonT: (json) => ColorsModel.fromJson(json),
    );
  }

  @override
  Future<BaseResponse<bool>> getRealtimeSettings() async {
    final response = await dio.get(EndPoints.realtimeSettings);

    return BaseResponse<bool>.fromJson(
      response.data,
      fromJsonT: (json) {
        // Server-driven realtime transport switch (per-user canary + instant
        // rollback). Flipping the flags on the backend switches this client
        // (Centrifugo chat + banners + ws url) with no app rebuild.
        if (json is Map<String, dynamic>) {
          RealtimeConfig.applyFromSettings(json);
        }
        return true;
      },
    );
  }

  @override
  Future<String> setStorageUrl() async {
    // The storage base is now sourced at runtime from the backend settings
    // (admin panel -> DB -> /config/settings -> RealtimeConfig.applyFromSettings
    // -> EndPoints.setStorageBaseUrl), with an empty per-build bootstrap default.
    // No client bucket is probed/hardcoded here anymore.
    return "set storage url noop";
  }

  @override
  Future<BaseResponse<String>> getFirebaseCustomToken() async {
    final response = await dio.post(EndPoints.firebaseCustomToken);
    return BaseResponse.fromJson(
      response.data,
      fromJsonT: (json) => json['firebase_token'] as String,
    );
  }
}

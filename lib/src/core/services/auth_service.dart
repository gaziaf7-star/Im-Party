import 'package:general/src/core/index.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static final Set<String> _publicEndpoints = {
    EndPoints.login,
    EndPoints.checkPhone,
    EndPoints.register,
    EndPoints.forgotPassword,
    EndPoints.countries,
    EndPoints.privacyPolicy,
    EndPoints.configApp,
    EndPoints.colors,
    EndPoints.addInfo,
  };

  bool get isAuthenticated {
    final token = HiveManager()
        .getData<String>(KeysManager.USER_BOX, KeysManager.TOKEN_KEY);
    return token != null && token.isNotEmpty;
  }

  bool isPublicEndpoint(String path) => _publicEndpoints.contains(path);

  bool canMakeRequest(String path) =>
      isAuthenticated || isPublicEndpoint(path);

  void clearToken() {
    HiveManager.instance.deleteData(
      KeysManager.USER_BOX,
      KeysManager.TOKEN_KEY,
    );
    // Auth scope is changing (logout / delete-account / 401-505 teardown).
    // Purge the persistent HTTP cache so cached GETs written under this user —
    // which dio_cache_interceptor keys by URL only, NOT by Authorization —
    // can never be served to the next user on this device. Fire-and-forget:
    // the clean is best-effort and must not block the synchronous logout flow.
    DioFactory.clearHttpCache();
  }
}

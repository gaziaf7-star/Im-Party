import 'dart:io';
import 'package:general/src/core/index.dart';

class NetworkExceptions {
  const NetworkExceptions();

  static NetworkExceptions handleResponse(Response? response) {
    List<String> errors = [];
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey("errors")) {
        final errorsData = data["errors"];
        if (errorsData is Map<String, dynamic>) {
          errorsData.forEach((key, value) {
            errors.add("${value.first}\n");
          });
        }
      } else {
        errors.add(data["message"] ?? "Unknown error");
      }
    }

    String error = errors
        .toString()
        .replaceAll("[", "")
        .replaceAll("]", "")
        .replaceAll(",", "")
        .trim();

    int statusCode = response?.statusCode ?? 0;
    switch (statusCode) {
      case 377:
        return BadRequest(error);
      case 400:
        return BadRequest(error);
      case 403:
        return BadRequest(error);
      case 401:
        // Logout/token teardown is owned solely by DioFactory._handleAuthFailure
        // (single-flight guarded). Clearing the token here too caused a
        // double logout on 401. This branch only maps the error for display.
        return UnauthorizedRequest(error);
      case 404:
        return NotFound(error);
      case 405:
        return const MethodNotAllowed();
      case 408:
        return const RequestTimeout();
      case 409:
        return Conflict(error);
      case 410:
        return PasswordWrong(error);
      case 422:
        return UnprocessableEntity(error);
      case 429:
        return TooManyRequests(error);
      case 444:
        return TooManyRequests(error);
      case 407:
        return LowBalance(error);
      case 500:
        return InternalServerError(error);
      case 503:
        return const ServiceUnavailable();
      case 505:
        return AnotherDeviceLoggedIn(error);
      default:
        int responseCode = statusCode;
        return DefaultError("Received invalid status code: $responseCode");
    }
  }

  static NetworkExceptions getDioException(error) {
    try {
      // If the error is already a NetworkExceptions, return it directly
      if (error is NetworkExceptions) {
        return error;
      }

      final errorType = error.runtimeType.toString();

      if (errorType.contains('GoogleSignInCanceled')) {
        return const GoogleSignInCanceled();
      } else if (errorType.contains('GoogleSignInFailed')) {
        return const GoogleSignInFailed();
      } else if (errorType.contains('GoogleSignInNetworkError')) {
        return const GoogleNetworkError();
      } else if (errorType.contains('GoogleSignInUnknownError')) {
        return const UnexpectedError();
      }

      // 🟡 Google Sign-In PlatformException fallback
      if (error is PlatformException) {
        switch (error.code) {
          case 'network_error':
            return const GoogleNetworkError();
          case 'sign_in_canceled':
          case 'canceled':
            return const GoogleSignInCanceled();
          case 'sign_in_failed':
          case 'failed':
            return const GoogleSignInFailed();
          default:
            return GoogleSignInUnknown(
              error.message ?? FailureMessage.googleSignInUnknown,
            );
        }
      }

      // 🔵 Dio errors
      if (error is DioException) {
        switch (error.type) {
          case DioExceptionType.cancel:
            return const RequestCancelled();

          case DioExceptionType.connectionTimeout:
            return const RequestTimeout();

          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.transformTimeout:
            return const SendTimeout();

          case DioExceptionType.badResponse:
            return handleResponse(error.response);

          case DioExceptionType.unknown:
            return const UnexpectedError();

          case DioExceptionType.badCertificate:
            return handleResponse(error.response);

          case DioExceptionType.connectionError:
            return handleResponse(error.response);
        }
      }
      // 🔴 Socket (no internet)
      if (error is SocketException) {
        return const NoInternetConnection();
      }

      // 🟠 Format issues
      if (error is FormatException) {
        return const FormatException();
      }

      // 🟣 Type casting / runtime mismatch
      if (error.toString().contains("is not a subtype of")) {
        Methods.printLog("⚠️ Type casting issue: $error");
        return const UnableToProcess();
      }

      // ⚫ Unknown fallback
      Methods.printLog("⚠️ Unknown error type: ${error.runtimeType}");
      return const UnexpectedError();
    } catch (e, stack) {
      Methods.printLog("⚠️ getDioException catch: $e\n$stack");
      return const UnexpectedError();
    }
  }

  static String getErrorMessage(NetworkExceptions networkExceptions) {
    String message = "";
    if (networkExceptions is NotFound) {
      message = networkExceptions.error;
    } else if (networkExceptions is NoInternetConnection) {
      message = FailureMessage.noInternetConnection;
    } else if (networkExceptions is RequestCancelled) {
      message = FailureMessage.requestCancelled;
    } else if (networkExceptions is InternalServerError) {
      message = networkExceptions.error;
    } else if (networkExceptions is ServiceUnavailable) {
      message = FailureMessage.serviceUnavailable;
    } else if (networkExceptions is MethodNotAllowed) {
      message = FailureMessage.methodAllowed;
    } else if (networkExceptions is BadRequest) {
      message = networkExceptions.error;
    } else if (networkExceptions is UnauthorizedRequest) {
      message = networkExceptions.error;
    } else if (networkExceptions is UnprocessableEntity) {
      message = networkExceptions.error;
    } else if (networkExceptions is UnexpectedError) {
      message = FailureMessage.unexpectedErrorOccurred;
    } else if (networkExceptions is RequestTimeout) {
      message = FailureMessage.connectionRequestTimeout;
    } else if (networkExceptions is Conflict) {
      message = networkExceptions.error;
    } else if (networkExceptions is SendTimeout) {
      message = FailureMessage.sendTimeoutInConnectionWithAPIServer;
    } else if (networkExceptions is UnableToProcess) {
      message = FailureMessage.unableToProcessTheData;
    } else if (networkExceptions is DefaultError) {
      message = networkExceptions.error;
    } else if (networkExceptions is FormatException) {
      message = FailureMessage.unexpectedErrorOccurred;
    } else if (networkExceptions is NotAcceptable) {
      message = FailureMessage.notAcceptable;
    } else if (networkExceptions is SiginGoogleException) {
      message = FailureMessage.googleSignInFailed;
    } else if (networkExceptions is AnotherDeviceLoggedIn) {
      message = networkExceptions.error;
    } else if (networkExceptions is LowBalance) {
      message = networkExceptions.error;
    } else if (networkExceptions is PasswordWrong) {
      message = networkExceptions.error;
    } else if (networkExceptions is TooManyRequests) {
      message = networkExceptions.error;
    } else if (networkExceptions is GoogleNetworkError) {
      message = FailureMessage.googleSignInNetworkError;
    } else if (networkExceptions is GoogleSignInCanceled) {
      message = FailureMessage.googleSignInCanceled;
    } else if (networkExceptions is GoogleSignInFailed) {
      message = FailureMessage.googleSignInFailed;
    } else if (networkExceptions is GoogleSignInUnknown) {
      message = networkExceptions.error;
    }

    return message;
  }
}

// ====== Network Exceptions ======
class RequestCancelled extends NetworkExceptions {
  const RequestCancelled();
}

class UnauthorizedRequest extends NetworkExceptions {
  final String error;
  const UnauthorizedRequest(this.error);
}

class BadRequest extends NetworkExceptions {
  final String error;
  const BadRequest(this.error);
}

class NotFound extends NetworkExceptions {
  final String error;
  const NotFound(this.error);
}

class MethodNotAllowed extends NetworkExceptions {
  const MethodNotAllowed();
}

class NotAcceptable extends NetworkExceptions {
  const NotAcceptable();
}

class RequestTimeout extends NetworkExceptions {
  const RequestTimeout();
}

class SendTimeout extends NetworkExceptions {
  const SendTimeout();
}

class UnprocessableEntity extends NetworkExceptions {
  final String error;
  const UnprocessableEntity(this.error);
}

class Conflict extends NetworkExceptions {
  final String error;
  const Conflict(this.error);
}

class InternalServerError extends NetworkExceptions {
  final String error;
  const InternalServerError(this.error);
}

class NotImplemented extends NetworkExceptions {
  const NotImplemented();
}

class ServiceUnavailable extends NetworkExceptions {
  const ServiceUnavailable();
}

class NoInternetConnection extends NetworkExceptions {
  const NoInternetConnection();
}

class FormatException extends NetworkExceptions {
  const FormatException();
}

class UnableToProcess extends NetworkExceptions {
  const UnableToProcess();
}

class DefaultError extends NetworkExceptions {
  final String error;
  const DefaultError(this.error);
}

class UnexpectedError extends NetworkExceptions {
  const UnexpectedError();
}

class SiginGoogleException extends NetworkExceptions {
  const SiginGoogleException();
}

class TooManyRequests extends NetworkExceptions {
  final String error;
  const TooManyRequests(this.error);
}

class PasswordWrong extends NetworkExceptions {
  final String error;
  const PasswordWrong(this.error);
}

class LowBalance extends NetworkExceptions {
  final String error;
  const LowBalance(this.error);
}

class AnotherDeviceLoggedIn extends NetworkExceptions {
  final String error;
  const AnotherDeviceLoggedIn(this.error);
}

// ====== Google Sign-In specific errors ======
class GoogleNetworkError extends NetworkExceptions {
  const GoogleNetworkError();
}

class GoogleSignInCanceled extends NetworkExceptions {
  const GoogleSignInCanceled();
}

class GoogleSignInFailed extends NetworkExceptions {
  const GoogleSignInFailed();
}

class GoogleSignInUnknown extends NetworkExceptions {
  final String error;
  const GoogleSignInUnknown(this.error);
}

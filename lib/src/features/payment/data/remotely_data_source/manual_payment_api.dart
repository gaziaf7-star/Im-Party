import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/payment/data/model/manual_payment_models.dart';

/// Manual recharge endpoints. Uses the app's [DioFactory], so the user's
/// token and headers are added automatically. Every call throws a
/// [ManualPaymentException] with a message ready to show the user.
class ManualPaymentApi {
  ManualPaymentApi([DioFactory? dio]) : _dio = dio ?? di<DioFactory>();
  final DioFactory _dio;

  /// Server limit for the payment-proof screenshot.
  static const int maxScreenshotBytes = 5 * 1024 * 1024;

  Future<List<ManualPaymentMethod>> methods() => _guard(() async {
        final res = await _dio.get(EndPoints.manualPaymentMethods);
        _check(res);
        return manualPaymentList(res.data, 'methods')
            .map(ManualPaymentMethod.fromJson)
            .toList();
      });

  Future<List<ManualPaymentPackage>> packages() => _guard(() async {
        final res = await _dio.get(
          EndPoints.manualPaymentPackages,
          // `all` returns both user and seller packages for the two tabs.
          queryParameters: {'target_type': 'all'},
        );
        _check(res);
        // `packages` only holds the caller's own type; `seller_packages` and
        // `user_packages` hold both. Merge them so either tab can be shown.
        final seen = <int>{};
        return [
          ...manualPaymentList(res.data, 'seller_packages'),
          ...manualPaymentList(res.data, 'user_packages'),
          ...manualPaymentList(res.data, 'packages'),
        ]
            .map(ManualPaymentPackage.fromJson)
            .where((p) => seen.add(p.id))
            .toList();
      });

  /// Sends the payment proof. Returns the server's message.
  Future<String> submit({
    required int methodId,
    required ManualPaymentPackage package,
    required String senderNumber,
    required String userTrxId,
    String? senderName,
    File? screenshot,
    // 'user' for a normal recharge, 'coinseller' for a coin-seller top-up.
    String rechargeType = 'user',
    ProgressCallback? onUploadProgress,
  }) =>
      _guard(() async {
        final body = <String, dynamic>{
          'method_id': methodId,
          'package_id': package.id,
          // The server also requires the package's amount and coins.
          'amount': package.price,
          'coins': package.coins,
          'bonus_coins': package.bonusCoins,
          'total_coins': package.totalCoins,
          'currency': package.currency,
          'sender_number': senderNumber.trim(),
          'user_trx_id': userTrxId.trim(),
          'recharge_type': rechargeType,
          if (senderName != null && senderName.trim().isNotEmpty)
            'sender_name': senderName.trim(),
        };
        if (screenshot != null && await screenshot.exists()) {
          if (await screenshot.length() > maxScreenshotBytes) {
            throw const ManualPaymentException(
                'Screenshot is too large. Please choose an image under 5 MB.');
          }
          body['screenshot'] = await MultipartFile.fromFile(
            screenshot.path,
            filename: screenshot.path.split(Platform.pathSeparator).last,
          );
        }
        final res = await _dio.post(
          EndPoints.manualPaymentSubmit,
          data: FormData.fromMap(body),
          onSendProgress: onUploadProgress,
        );
        _check(res);
        final data = res.data;
        return data is Map && data['message'] != null
            ? data['message'].toString()
            : 'Request submitted';
      });

  Future<List<ManualPaymentHistoryItem>> history({int page = 1}) =>
      _guard(() async {
        final res = await _dio.get(
          EndPoints.manualPaymentHistory,
          queryParameters: {'page': page, 'per_page': 20},
        );
        _check(res);
        return manualPaymentList(res.data, 'history')
            .map(ManualPaymentHistoryItem.fromJson)
            .toList();
      });

  /// The server answers `success`/`status`; anything falsy is an error.
  void _check(Response<dynamic> res) {
    if ((res.statusCode ?? 200) >= 400) {
      throw ManualPaymentException(_message(res.data) ??
          'Something went wrong (${res.statusCode}). Please try again.');
    }
    final data = res.data;
    if (data is Map) {
      final ok = data['success'] ?? data['status'];
      if (ok == false || ok == 0) {
        throw ManualPaymentException(
            _message(data) ?? 'Something went wrong. Please try again.');
      }
    }
  }

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on ManualPaymentException {
      rethrow;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg = _message(e.response?.data);
      if (msg != null) throw ManualPaymentException(msg);
      if (status == 409) {
        throw const ManualPaymentException(
            'This Transaction ID has already been submitted.');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const ManualPaymentException(
            'Network problem. Check your internet and try again.');
      }
      throw const ManualPaymentException(
          'Something went wrong. Please try again.');
    } catch (e) {
      Methods.printLog('[manual-payment] $e');
      throw const ManualPaymentException(
          'Something went wrong. Please try again.');
    }
  }

  /// `message`, or the first Laravel validation error. Errors come either at
  /// the top level or nested as `data.errors` (e.g. a duplicate TrxID 422).
  static String? _message(dynamic data) {
    if (data is! Map) return null;
    final nested = data['data'];
    final errors =
        data['errors'] ?? (nested is Map ? nested['errors'] : null);
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      final text = first is List && first.isNotEmpty ? first.first : first;
      if (text != null && text.toString().isNotEmpty) return text.toString();
    }
    final m = data['message']?.toString() ?? '';
    return m.isEmpty ? null : m;
  }
}

class ManualPaymentException implements Exception {
  const ManualPaymentException(this.message);
  final String message;

  @override
  String toString() => message;
}

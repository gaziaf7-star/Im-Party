import 'package:general/src/core/index.dart';

class BaseResponse<T> extends Equatable {
  final bool? success;
  final String message;
  final PaginatesModel? paginates;
  final T? data;

  const BaseResponse({
    required this.success,
    required this.message,
    this.paginates,
    required this.data,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJsonT,
  }) {

    dynamic data() {
      if (json['data'] == null) {
        return null;
      } else {
        final finalT = json['data'];
        return json.containsKey('data')
            ? (finalT is String || finalT is int)
                ? finalT
                : fromJsonT == null
                    ? null
                    : _parse(json['data'], fromJsonT)
            : null;
      }
    }

    return BaseResponse(
      success: json.containsKey('success') ? json['success'] as bool : null,
      message: json['message'] as String,
      paginates: json['paginates'] == null
          ? null
          : PaginatesModel.fromJson(json['paginates']),
      data: data(),
    );
  }

  static T _parse<T>(dynamic json, T Function(dynamic) fromJsonT) {
    if (json == null) {
      return null as T;
    } else if (json is T ||
        json is Map<String, dynamic> ||
        json is List<dynamic>) {
      return fromJsonT(json);
    } else {
      throw ArgumentError.value(json, 'json', 'Invalid data type');
    }
  }

  @override
  List<Object?> get props => [
        success,
        message,
        data,
      ];
}

class PaginatesModel extends Equatable {
  final int currentPage;
  final int lastPage;

  const PaginatesModel({
    this.currentPage = 0,
    this.lastPage = 0,
  });

  factory PaginatesModel.fromJson(Map<String, dynamic> json) => PaginatesModel(
    currentPage: parseValue<int>(json['meta']?['current_page'], 0),
    lastPage: parseValue<int>(json['meta']?['last_page'], 0),
      );

  @override
  List<Object?> get props => [currentPage, lastPage];
}

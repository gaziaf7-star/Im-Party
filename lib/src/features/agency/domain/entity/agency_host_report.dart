import 'package:equatable/equatable.dart';

class AgencyHostReportEntity extends Equatable {
  final UserSalaryEntity? userSalary;
  final dynamic requestLeaveAgency;
  final String? diamonds;
  final String? liveMinutes;
  final String? activeDays;
  final List<DalyReportsEntity>? dalyReports;

  const AgencyHostReportEntity({
    required this.userSalary,
    required this.requestLeaveAgency,
    required this.diamonds,
    required this.liveMinutes,
    required this.activeDays,
    required this.dalyReports,
  });

  AgencyHostReportEntity copyWith({
    UserSalaryEntity? userSalary,
    dynamic requestLeaveAgency,
    String? diamonds,
    String? liveMinutes,
    String? activeDays,
    List<DalyReportsEntity>? dalyReports,
  }) {
    return AgencyHostReportEntity(
      userSalary: userSalary ?? this.userSalary,
      requestLeaveAgency: requestLeaveAgency ?? this.requestLeaveAgency,
      diamonds: diamonds ?? this.diamonds,
      liveMinutes: liveMinutes ?? this.liveMinutes,
      activeDays: activeDays ?? this.activeDays,
      dalyReports: dalyReports ?? this.dalyReports,
    );
  }

  @override
  List<Object?> get props => [userSalary, requestLeaveAgency, diamonds, liveMinutes, activeDays, dalyReports];
}


class DalyReportsEntity extends Equatable {
  final String? day;
  final int? liveMinutes;
  final String? liveMinutesFormatted;
  final String? diamonds;
  final bool? isActiveDay;

  const DalyReportsEntity({
    required this.day,
    required this.liveMinutes,
    required this.liveMinutesFormatted,
    required this.diamonds,
    required this.isActiveDay,
  });

  @override
  List<Object?> get props => [day, liveMinutes, diamonds, isActiveDay];
}

class UserSalaryEntity extends Equatable {
  final dynamic cutAmount;
  final dynamic salary;

  const UserSalaryEntity({
    required this.cutAmount,
    required this.salary,
  });

  UserSalaryEntity copyWith({
    int? cutAmount,
    int? salary,
  }) {
    return UserSalaryEntity(
      cutAmount: cutAmount ?? this.cutAmount,
      salary: salary ?? this.salary,
    );
  }

  @override
  List<Object?> get props => [cutAmount, salary];
}

import 'package:general/src/features/agency/agency.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class AgencyHostReportModel extends AgencyHostReportEntity {
  const AgencyHostReportModel({
     super.userSalary,
     super.requestLeaveAgency,
     super.diamonds,
     super.liveMinutes,
     super.activeDays,
     super.dalyReports,
  });

  factory AgencyHostReportModel.fromJson(dynamic json) {
    return AgencyHostReportModel(
      userSalary: json['user_salary'] is Map<String, dynamic> ? UserSalaryModel.fromJson(json['user_salary']) : null,
      requestLeaveAgency: parseValue<dynamic>(json['request_leave_agency'],''),
      diamonds: parseValue<String>(json['diamonds'],''),
      liveMinutes:parseValue<String>(json['live_minutes'],'') ,
      activeDays:parseValue<String>(json['active_days'],'') ,
      dalyReports: json['daly_reports'] is List
          ? List<DalyReportsModel>.from((json['daly_reports'] as List).whereType<Map<String, dynamic>>().map((v) => DalyReportsModel.fromJson(v)))
          : null,
    );
  }

}

class DalyReportsModel extends DalyReportsEntity {
  const DalyReportsModel({
    required super.day,
    required super.liveMinutes,
    required super.liveMinutesFormatted,
    required super.diamonds,
    required super.isActiveDay,
  });

  factory DalyReportsModel.fromJson(dynamic json) {
    return DalyReportsModel(
      day:parseValue<String>(json['day'],'') ,
      liveMinutes:parseValue<int>( json['live_minutes'],0),
      liveMinutesFormatted: parseValue<String>(json['live_minutes_formatted'],''),
      diamonds:parseValue<String>(json['diamonds'],'') ,
      isActiveDay: parseValue<bool>(json['is_active_day'], false),
    );
  }

}

class UserSalaryModel extends UserSalaryEntity {
  const UserSalaryModel({
    required super.cutAmount,
    required super.salary,
  });

  factory UserSalaryModel.fromJson(dynamic json) {
    return UserSalaryModel(
      cutAmount: parseValue<dynamic>(json['cut_amount'],0),
      salary:parseValue<dynamic>( json['salary'],0),
    );
  }


}
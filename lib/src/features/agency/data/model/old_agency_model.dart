import 'package:general/src/features/agency/domain/entity/old_agency_entity.dart';

import '../../../../../reels_viewer/reels_viewer.dart';

class OldAgencyModel extends OldAgencyEntity {
  const OldAgencyModel({
    required super.joinDate,
    required super.leaveDate,
    required super.agencyId,
    required super.img,
    required super.joinTimeOnly,
  });

  factory OldAgencyModel.fromJson(Map<String, dynamic> json) {
    final joinDateRaw = parseValue<String>(json['join_date'],'');
    final joinTimeOnly = _extractTime(joinDateRaw);

    return OldAgencyModel(
      joinDate: joinDateRaw,
      leaveDate:parseValue<String>(json['leave_date'],'') ,
      agencyId: parseValue<int>(json['agency_id'],0),
      img: parseValue<String>(json['img'],''),
      joinTimeOnly: joinTimeOnly,
    );
  }

  static String _extractTime(String datetime) {
    try {
      final parts = datetime.split(' ');
      if (parts.length == 2) {
        final timeParts = parts[1].split(':');
        if (timeParts.length >= 2) {
          return '${timeParts[0]}:${timeParts[1]}';
        }
      }
      return '';
    } catch (_) {
      return '';
    }
  }
}

import '../../../../core/index.dart';

class CpProfileModel {
  int? seats;
  Wares? wares;
  MainCp? mainCp;
  List<RemainingCp>? remainingCp;

  CpProfileModel({
    this.seats,
    this.wares,
    this.mainCp,
    this.remainingCp,
  });

  CpProfileModel.fromJson(dynamic json) {
    seats = parseValue<int>(json['seats'], 0);
    wares = json['wares'] is Map<String, dynamic>
        ? Wares.fromJson(json['wares'])
        : null;
    mainCp = json['main_cp'] is Map<String, dynamic>
        ? MainCp.fromJson(json['main_cp'])
        : null;
    if (json['remaining_cp'] is List) {
      remainingCp = [];
      json['remaining_cp'].whereType<Map<String, dynamic>>().forEach((v) {
        remainingCp?.add(RemainingCp.fromJson(v));
      });
    }
  }
}

class RemainingCp {
  RemainingCp({
    this.id,
    this.level,
    this.nextLevel,
    this.di,
    this.ratio,
    this.user,
    this.relation,
  });

  RemainingCp.fromJson(dynamic json) {
    id = parseValue<int>(json['id'], 0);
    level = parseValue<int>(json['level'], 0);
    nextLevel = parseValue<int>(json['next_level'], 0);
    di = parseValue<int>(json['di'], 0);
    ratio = json['ratio'];
    user = json['user'] is Map ? User.fromJson(json['user']) : null;
    relation =
        json['relation'] is Map ? Relation.fromJson(json['relation']) : null;
  }
  int? id;
  int? level;
  int? nextLevel;
  dynamic di;
  dynamic ratio;
  User? user;
  Relation? relation;
}

class Relation {
  Relation({
    this.id,
    this.type,
    this.title,
  });

  Relation.fromJson(dynamic json) {
    id = parseValue<int>(json['id'], 0);
    type = parseValue<String>(json['type'], '');
    title = parseValue<String>(json['title'], '');
  }
  int? id;
  String? type;
  String? title;
}

class User {
  User({
    this.id,
    this.uid,
    this.name,
    this.image,
    this.gender,
  });

  User.fromJson(dynamic json) {
    id =parseValue<int>(json['id'], 0) ;
    uid = parseValue<String>(json['uid'], '');
    name = parseValue<String>(json['name'], '');
    image =parseValue<String>(json['image'], '') ;
    gender =parseValue<String>(json['gender'], '') ;
    frame =parseValue<String>(json['frame'], '');
  }
  int? id;
  String? uid;
  String? name;
  String? image;
  String? gender;
  String? frame;
}

class MainCp {
  MainCp({
    this.id,
    this.level,
    this.nextLevel,
    this.di,
    this.user,
    this.relation,
  });

  MainCp.fromJson(dynamic json) {
    id = parseValue<int>(json['id'], 0);
    level = parseValue<int>(json['level'], 0);
    nextLevel = parseValue<int>(json['next_level'], 0);
    di = parseValue<int>(json['di'], 0);

    user = (json['user'] is Map) ? User.fromJson(json['user']) : null;
    relation = (json['relation'] is Map) ? Relation.fromJson(json['relation']) : null;
  }

  int? id;
  int? level;
  int? nextLevel;
  int? di;
  User? user;
  Relation? relation;
}

class Wares {
  Wares({
    this.id,
    this.price,
    this.num,
  });

  Wares.fromJson(dynamic json) {
    id = parseValue<int>(json['id'], 0);
    price = parseValue<int>(json['price'], 0);
    num = parseValue<int>(json['num'], 0);
  }

  int? id;
  int? price;
  int? num;
}
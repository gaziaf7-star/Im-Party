import '../../../../core/utils/methods.dart';

class PrivacyPolicy {
  Html? html;

  PrivacyPolicy({this.html});

  PrivacyPolicy.fromJson(Map<String, dynamic> json) {
    html = json['html'] is Map<String, dynamic> ? Html.fromJson(json['html']) : null;
  }
}

class Html {
  int? id;
  dynamic type;
  String? name;
  String? url;
  String? content;
  String? createdAt;
  String? updatedAt;
  String? contentEn;

  Html(
      {this.id,
      this.type,
      this.name,
      this.url,
      this.content,
      this.createdAt,
      this.updatedAt,
      this.contentEn});

  Html.fromJson(Map<String, dynamic> json) {
    id = parseValue<int>(json['id'], 0);
    type = parseValue<String>(json['type'], '');
    name = parseValue<String>(json['name'], '');
    url = parseValue<String>(json['url'], '');
    content = parseValue<String>(json['content'], '');
    createdAt = parseValue<String>(json['created_at'], '');
    updatedAt = parseValue<String>(json['updated_at'], '');
    contentEn = parseValue<String>(json['content_en'], '');
  }
}

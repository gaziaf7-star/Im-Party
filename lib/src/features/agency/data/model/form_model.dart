import 'package:general/src/features/agency/domain/entity/form_entity.dart';

class FormModel extends FormEntity {
  const FormModel({
    required super.formType,
    required super.link,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) => FormModel(
        formType: json['form_type'] ?? '',
        link: json['link'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'form_type': formType,
        'link': link,
      };
}

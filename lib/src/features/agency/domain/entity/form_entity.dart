import 'package:general/src/core/index.dart';

class FormEntity extends Equatable {
  final String formType;
  final String link;

  const FormEntity({
    required this.formType,
    required this.link,
  });

  @override
  List<Object?> get props => [formType, link];
}

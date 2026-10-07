import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class BaseUserReportEvent extends Equatable {
  const BaseUserReportEvent();

  @override
  List<Object> get props => [];
}

class UserReportEvent extends BaseUserReportEvent {
  final String? id;
  final String? typeReport;
  final File? image;
  final String? reportContent;

  const UserReportEvent(
      {this.id, this.image, this.reportContent, this.typeReport});
}

class UserReportPickImageEvent extends BaseUserReportEvent {
  final ImageSource source;

  const UserReportPickImageEvent(this.source);
}

class UserReportRemoveImageEvent extends BaseUserReportEvent {
  const UserReportRemoveImageEvent();
}

class ChangeContactDetails extends BaseUserReportEvent {
  final int index;
  final String type;

  const ChangeContactDetails({required this.index, required this.type});
    
    @override
  List<Object> get props => [index, type];
}

class UpdateFormValidationEvent extends BaseUserReportEvent {
  const UpdateFormValidationEvent();
}

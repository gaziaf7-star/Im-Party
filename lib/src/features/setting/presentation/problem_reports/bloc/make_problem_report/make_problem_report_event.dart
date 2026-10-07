part of 'make_problem_report_bloc.dart';

abstract class BaseMakeProblemReportEvent extends Equatable {
  const BaseMakeProblemReportEvent();

  @override
  List<Object?> get props => [];
}
 class MakeProblemReportEvent extends BaseMakeProblemReportEvent {

 final  MakeProblemReportParam makeProblemReportParam;
 final BuildContext context;

  const MakeProblemReportEvent({required this.makeProblemReportParam,required this.context});

}
class MakeProblemReportPickImageEvent extends BaseMakeProblemReportEvent {
  final ImageSource source;

  const MakeProblemReportPickImageEvent(this.source);


}
class MakeProblemReportRemoveImageEvent extends BaseMakeProblemReportEvent {

  const MakeProblemReportRemoveImageEvent();


}
class ChangeContactDetails extends BaseMakeProblemReportEvent {
 final int index;
 final String type;

  const ChangeContactDetails({required this.index,required this.type});

 @override
 List<Object?> get props => [index];

}
class UpdateFormValidationEvent extends BaseMakeProblemReportEvent {
  const UpdateFormValidationEvent();
}


part of 'make_problem_report_bloc.dart';

class MakeProblemReportState extends Equatable {
  final RequestState reqState;

  final String? message;
  final int indexDetails;
  final int indexTypes;

  final String? imagePath;
  final bool isFormValid;
  final TextEditingController contactController;
  final TextEditingController descController;
  final List<bool> checkedFirst;
  final List<bool> checkedSecond;




  const MakeProblemReportState({
    this.reqState = RequestState.idle,
    this.message,
    this.indexDetails=0,
    this.indexTypes=0,

    this.imagePath="",
    this.isFormValid =false ,
    required this.contactController,
    required this.descController,
    this.checkedFirst = const [],
    this.checkedSecond = const [],


  });


  MakeProblemReportState copyWith({
    RequestState? reqState,
    String? message,
    int? indexDetails,
    int? indexTypes,
    String? imagePath,
    bool? isFormValid,
    String? phoneController,
    String? descController,
    List<bool>? checkedFirst,
    List<bool>? checkedSecond,


  }) {
    return MakeProblemReportState(
      reqState: reqState ?? this.reqState, // Update Google auth state
      message: message ?? this.message,
      indexDetails: indexDetails ?? this.indexDetails,
      indexTypes: indexTypes ?? this.indexTypes,
      imagePath: imagePath ?? this.imagePath,
      isFormValid:isFormValid ?? this.isFormValid,
      contactController: contactController.copyWith(text: phoneController),
      descController: this.descController.copyWith(text: descController),
      checkedFirst: checkedFirst ?? this.checkedFirst,
      checkedSecond: checkedSecond ?? this.checkedSecond,

      // Update Google auth success message
    );
  }

  @override
  List<Object?> get props => [
    reqState,
    message,
    indexDetails,
    indexTypes,
    imagePath,
    contactController,
    isFormValid,
    checkedFirst,
    checkedSecond,
  ];
}
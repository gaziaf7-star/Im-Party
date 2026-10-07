import 'package:general/src/core/index.dart';

class UserReportState extends Equatable {
  final NetworkExceptions? errorMsgReport;
  final RequestState requestStateReport;
  final String? successReport;
  final int indexDetails;
  final int indexTypes;

  final String? imagePath;
  final bool isFormValid;
  final TextEditingController descController;
  final List<bool> checkedFirst;


  const UserReportState({
    this.errorMsgReport,
    this.successReport = '',
    this.requestStateReport = RequestState.idle,
        this.indexDetails=0,
    this.indexTypes=0,

    this.imagePath="",
    this.isFormValid =false ,
    required this.descController,
    this.checkedFirst = const [],
    

  });

  UserReportState copyWith({
    NetworkExceptions? errorMsgReport,
    RequestState? requestStateReport,
    String? successReport,
    int? indexTypes,
    String? imagePath,
    bool? isFormValid,
    String? descController,
    List<bool>? checkedFirst,
  }) {
    return UserReportState(
      errorMsgReport: errorMsgReport ?? this.errorMsgReport,
      requestStateReport: requestStateReport ?? this.requestStateReport,
      successReport: successReport ?? this.successReport,
      indexDetails: indexDetails,
      indexTypes: indexTypes ?? this.indexTypes,
      imagePath: imagePath ?? this.imagePath,
      isFormValid:isFormValid ?? this.isFormValid,
      descController: this.descController.copyWith(text: descController),
      checkedFirst: checkedFirst ?? this.checkedFirst,
    );
  }

  @override
  List<Object?> get props => [
    errorMsgReport,
    requestStateReport,
    successReport,
    indexDetails,
    indexTypes,
    imagePath,
    isFormValid,
    checkedFirst,
  ];
}

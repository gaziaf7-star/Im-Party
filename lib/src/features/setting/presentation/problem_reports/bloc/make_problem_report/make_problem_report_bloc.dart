import 'dart:developer';

import 'package:general/src/core/index.dart';

import '../../../../domain/use_case/make_problem_report_usecase.dart';

part 'make_problem_report_event.dart';

part 'make_problem_report_state.dart';

class MakeProblemReportBloc
    extends Bloc<BaseMakeProblemReportEvent, MakeProblemReportState> {
  final MakeProblemReportUseCase makeProblemReportUseCase;
  final ImagePicker _imagePicker = ImagePicker(); // Add ImagePicker if not defined

  MakeProblemReportBloc({required this.makeProblemReportUseCase})
      : super(MakeProblemReportState(contactController: TextEditingController(),
      descController: TextEditingController(), checkedFirst: List.generate(4, (index) => false),
    checkedSecond: List.generate(4, (index) => false),)) {
    on<MakeProblemReportEvent>((event, emit) async {
      final result =
      await makeProblemReportUseCase(event.makeProblemReportParam);
      result.fold(
            (l) =>
            emit(state.copyWith(
                reqState: RequestState.error,
                message: NetworkExceptions.getErrorMessage(l))),
            (r) {
          emit(state.copyWith(message: r.message));
          Methods.showToast(event.context, message: StringManager.success.tr());
          event.context.popRoute();
        },
      );
    });

    on<ChangeContactDetails>((event, emit) async {
      List<bool> updatedFirst = List.generate(state.checkedFirst.length, (i) => false);
      List<bool> updatedSecond = List.generate(state.checkedSecond.length, (i) => false);
      if (event.type == 'type') {
        updatedFirst[event.index] = true;
        emit(state.copyWith(checkedFirst: updatedFirst,
            indexTypes: event.index));
      } else {
        updatedSecond[event.index] = true;
        emit(state.copyWith(checkedSecond: updatedSecond,
            indexDetails: event.index));
      }
    });
    on<MakeProblemReportPickImageEvent>((event, emit) async {
      try {
        final pickedFile =
            await Methods.pickImageSafely(_imagePicker, source: event.source);

        if (pickedFile != null) {
          log("$pickedFile  PickFile");
          if (pickedFile.path.contains('.gif')) {
            Methods().showWaringGifDialog();
          } else {
            final result = await Methods().compressFile(xFile: pickedFile);
            emit(state.copyWith(imagePath: result.path));
          }
        } else {
          emit(state.copyWith(message: 'No image selected'));
        }
      } catch (e) {
        emit(state.copyWith(message: '$e'));
      }
    });
    on<MakeProblemReportRemoveImageEvent>((event, emit) {
      emit(state.copyWith(
        imagePath: "",
        reqState: RequestState.empty,
      ));
    });

    on<UpdateFormValidationEvent>((event, emit) {
      bool isValid = (state.contactController.text.isNotEmpty &&
          state.descController.text.isNotEmpty);

      if (state.isFormValid != isValid) {
        emit(state.copyWith(isFormValid: isValid));
        if (kDebugMode) {
          print("✅ isFormValid updated: $isValid");
        }
      }
    }

    );
  }


}



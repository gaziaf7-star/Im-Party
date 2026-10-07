import 'dart:developer';
import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/domain/profile_use_case/user_report_uc.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/user_profile/bloc/user_report_bloc/user_report_state.dart';

import 'user_report_event.dart';

class UserReportBloc extends Bloc<BaseUserReportEvent, UserReportState> {
  UserReportUseCase userReportUseCase;
  final ImagePicker _imagePicker = ImagePicker();
  UserReportBloc({required this.userReportUseCase})
      : super(UserReportState(
          descController: TextEditingController(),
          checkedFirst: List.generate(4, (index) => false),
        )) {
    on<UserReportEvent>((event, emit) async {
      emit(state.copyWith(requestStateReport: RequestState.loading));
      final result = await userReportUseCase.call(UserReportParameter(
          id: event.id,
          image: event.image,
          reportContent: event.reportContent,
          typeReport: event.typeReport));
      result.fold(
        (l) {
          emit(state.copyWith(
              errorMsgReport: l, requestStateReport: RequestState.error));
        },
        (r) {
          emit(
          state.copyWith(
              successReport: r, requestStateReport: RequestState.loaded),
        );
        },
      );
    });

    on<ChangeContactDetails>((event, emit) async {
      List<bool> updatedFirst =
          List.generate(state.checkedFirst.length, (i) => false);
      updatedFirst[event.index] = true;
      emit(state.copyWith(checkedFirst: updatedFirst, indexTypes: event.index));
    });
    on<UserReportPickImageEvent>((event, emit) async {
      try {
        final pickedFile =
            await Methods.pickImageSafely(_imagePicker, source: event.source);

        if (pickedFile != null) {
          final filePath = pickedFile.path;
          final file = File(filePath);

          if (pickedFile.path.contains('.gif')) {
            Methods().showWaringGifDialog();

          } else {
            final fileSizeInBytes = await file.length();
            final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
            if (fileSizeInMB > 2) {
              Methods.safeShowToast(
                message: StringManager.picSize.tr(),
                isError: true,
              );
              return;
            }

            final result = await Methods().compressFile(xFile: pickedFile);
            emit(state.copyWith(imagePath: result.path));
          }

        } else {}
      } catch (e) {
        log("Error picking image: $e",);

      }
    });
    on<UserReportRemoveImageEvent>((event, emit) {
      emit(state.copyWith(
        imagePath: "",
        requestStateReport: RequestState.empty,
      ));
    });

    on<UpdateFormValidationEvent>((event, emit) {
      bool isValid = state.descController.text.isNotEmpty;

      if (state.isFormValid != isValid) {
        emit(state.copyWith(isFormValid: isValid));
      }
    });
  }
}

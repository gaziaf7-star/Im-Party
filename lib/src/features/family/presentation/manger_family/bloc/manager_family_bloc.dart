import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/family/family.dart';

part 'manager_family_event.dart';
part 'manager_family_state.dart';

class ManagerFamilyBloc
    extends Bloc<BaseManagerFamilyEvent, ManagerFamilyStates> {
  final CreateFamilyUC createFamilyUseCase;
  final EditFamilyUC editFamilyUC;

  ManagerFamilyBloc({
    required this.createFamilyUseCase,
    required this.editFamilyUC,
  }) : super(ManagerFamilyStates(
          name: TextEditingController(),
          bio: TextEditingController(),
          formKey: GlobalKey<FormState>(),
        )) {
    on<AssignValueToController>(_initValueToController);
    add(const AssignValueToController());
    on<ManagerFamilyEvent>(_handelEventAction);
    on<PickImageEvent>(_onPickImage);
  }

  Future<void> _initValueToController(
    AssignValueToController event,
    Emitter<ManagerFamilyStates> emit,
  ) async {
    if (MyDataModel.getInstance().familyId != 0 ||
        MyDataModel.getInstance().familyId != null) {
      emit(state.copyWith(
        name: di<ShowFamilyBloc>().state.showFamilyEntity?.name,
        bio: di<ShowFamilyBloc>().state.showFamilyEntity?.introduce,
      ));
    }
  }

  Future<void> _handelEventAction(
    ManagerFamilyEvent event,
    Emitter<ManagerFamilyStates> emit,
  ) async {
    if (event.familyId == '' || event.familyId == null) {
      if (state.pathImage.isEmpty) {
        Methods.showToast(event.context, message: 'please upload family image');
      } else if (state.formKey.currentState?.validate() == false) {
        return;
      } else {
        await _createFamilyEvent(event);
      }
    } else {
      await _editFamily(event.familyId);
    }
  }

  Future<void> _createFamilyEvent(ManagerFamilyEvent event) async {
    emit(state.copyWith(reqState: RequestState.loading));
    final result = await createFamilyUseCase(FamilyParameter(
        bio: state.bio.text,
        name: state.name.text,
        image: File(state.pathImage)));
    result.fold((l) {
      emit(state.copyWith(
          message: NetworkExceptions.getErrorMessage(l),
          reqState: handleErrorResponse(l)));
      Methods.showToast(
        event.context,
        isError: true,
        message: state.message,
      );
    }, (r) {
      emit(state.copyWith(
          message: r.message,
          familyId: r.data ?? 0,
          reqState: handleLoadedResponse<int>(r.data)));
      MyDataModel.updateInstance(familyId: state.familyId);
      di<FetchUserDataBloc>()
          .add(UpdateLocalDataEvent(userEntity: MyDataModel.getInstance()));
      di<ShowFamilyBloc>()
          .add(ShowFamilyEvent(familyId: state.familyId.toString()));
      final context = SafeNavigator.context;
      if (context == null) return;
      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        Routes.familyScreen,
        arguments: state.familyId.toString(),
      );
    });
  }

  Future<void> _editFamily(id) async {
    emit(state.copyWith(reqState: RequestState.loading));
    final result = await editFamilyUC(FamilyParameter(
        bio: state.bio.text,
        name: state.name.text,
        image: state.pathImage.isEmpty ? null : File(state.pathImage),
        id: id));
    result.fold((l) {
      emit(state.copyWith(
          message: NetworkExceptions.getErrorMessage(l),
          reqState: handleErrorResponse(l)));

      Methods.safeShowToast(
        message: state.message,
      );
    }, (r) {
      emit(state.copyWith(
          message: r.message,
          showFamilyEntity: r.data,
          reqState: handleLoadedResponse<ShowFamilyEntity>(r.data)));

      di<ShowFamilyBloc>().add(EditFamilyLocallyEvent(
        familyParameter: state.showFamilyEntity!,
      ));
      SafeNavigator.context?.popRoute();
    });
  }

  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<ManagerFamilyStates> emit,
  ) async {
    try {
      final pickedFileResult = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      );

      if (pickedFileResult != null && pickedFileResult.files.isNotEmpty) {
        if (pickedFileResult.files.first.path!.toLowerCase().endsWith('.gif')) {
          Methods().showWaringGifDialog();
        }
        final filePath = pickedFileResult.files.first.path!;
        final xFile = XFile(filePath);

        final compressedXFile = await Methods().compressFile(xFile: xFile);

        emit(state.copyWith(pathImage: compressedXFile.path));
      } else {
        emit(state.copyWith(pathImage: ''));
      }
    } catch (e) {
      emit(state.copyWith(pathImage: ''));
    }
  }

// @override
// Future<void> close() {
//   state.name.dispose();
//   state.bio.dispose();
//   return super.close();
// }
}

import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/domain/entity/information_agency_entity.dart';
import 'package:general/src/features/agency/domain/use_case/update_host_agency_data_uc.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/manager_information_agency/information_agency_bloc.dart';

part 'update_host_agency_data_event.dart';

part 'update_host_agency_data_state.dart';

class UpdateHostAgencyDataBloc
    extends Bloc<BaseUpdateHostAgencyDataEvent, UpdateHostAgencyDataState> {
  final UpdateHostAgencyDataUc useCase;
  final ImagePicker _imagePicker = ImagePicker();

  UpdateHostAgencyDataBloc(this.useCase)
      : super(const UpdateHostAgencyDataState()) {
    on<UpdateHostAgencyDataEvent>((event, emit) async {
      emit(state.copyWith(requestState: RequestState.loading));
      final result = await useCase(event.param);

      result.fold((l) {
        emit(state.copyWith(
            requestState: RequestState.error,
            message: NetworkExceptions.getErrorMessage(l)));
      }, (r) {
        emit(state.copyWith(requestState: RequestState.loaded, data: r.data));
        di<InformationAgencyBloc>().add(InformationAgencyEvent(
            month: '${DateTime.now().month}', year: '${DateTime.now().year}'));
      });
    });
    on<PickImageEvent>((event, emit) async {
      try {
        final pickedFile =
            await Methods.pickImageSafely(_imagePicker, source: event.source);

        if (pickedFile != null) {
          if (pickedFile.path.contains('.gif')) {
            Methods().showWaringGifDialog();
          } else {

             final XFile compressedXFile = await Methods().compressFile(xFile: pickedFile);

            final File theFile = File(compressedXFile.path);

            emit(
              state.copyWith(
                pathImg: theFile.path,
                imageFile: theFile,
              ),
            );
          }
        } else {
          emit(
            state.copyWith(message: 'No image selected'),
          );
        }
      } catch (error) {
        emit(state.copyWith(message: '$error'));
      }
    });
  }
}

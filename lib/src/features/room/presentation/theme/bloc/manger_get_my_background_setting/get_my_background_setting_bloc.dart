import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/background_setting_model.dart';
import 'package:general/src/features/room/domain/use_case/get_my_background_setting_uc.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manager_add_room_backGround/add_room_background_bloc.dart';
import 'package:general/src/features/room/presentation/theme/bloc/manager_add_room_backGround/add_room_background_event.dart';

part 'get_my_background_setting_event.dart';
part 'get_my_background_setting_state.dart';

class GetMyBackgroundSettingBloc
    extends Bloc<BaseGetMyBackgroundEvent, GetMyBackgroundSettingState> {
  final GetMyBackgroundSettingUc _getMyBackgroundSettingUc;
  GetMyBackgroundSettingBloc(this._getMyBackgroundSettingUc)
      : super(const GetMyBackgroundSettingState()) {
    on<GetMyBackgroundSettingEvent>((event, emit) async {
      final result = await _getMyBackgroundSettingUc();
      result.fold(
        (left) => emit(
          state.copyWith(
            message: NetworkExceptions.getErrorMessage(left),
          ),
        ),
        (right) {
          emit(
            state.copyWith(
                backgroundSettingData: right.data!,
                requestState: RequestState.loaded),
          );

          showDialog(
            context: event.context,
            builder: (context) => AnimatedDialog(
              title: StringManager.uploadImage.tr(),
              onTap: () async {
                context.popRoute();
                File? image;
                final FilePickerResult? result = await FilePicker.pickFiles(
                  type: FileType.custom,
                  allowMultiple: false,
                  allowedExtensions: ['png', 'jpeg', 'jpg'],
                );
                if (result != null) {
                  Methods.printLog(result.files.first.path.toString());
                  if (result.files.first.path!.contains('.gif')) {
                    Methods.showToast(context,
                        message: StringManager.warningGif.tr(), isError: true);
                  } else {
                    image = File(result.files.first.path!);
                    di<AddRoomBackgroundBloc>()
                        .add(AddRoomBackgroundEvent(roomBackGround: image));
                  }
                  //setState(() {
                }
                //  }
              },
              description:
                  '${StringManager.thisImageWillCost.tr()} ${state.backgroundSettingData?.cost ?? ''} ${StringManager.coins_.tr()}  ${state.backgroundSettingData?.expire ?? ''} ${StringManager.days.tr()}',
            ),
          );
        },
      );
    });
  }
}

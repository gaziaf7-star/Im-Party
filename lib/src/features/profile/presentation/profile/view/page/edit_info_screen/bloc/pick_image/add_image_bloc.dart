import 'package:general/src/core/index.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/edit_info_screen/bloc/pick_image/add_image_event.dart';
import 'package:general/src/features/profile/presentation/profile/view/page/edit_info_screen/bloc/pick_image/add_image_state.dart';

class AddImageBloc extends Bloc<BaseAddImageEvent, AddImageState> {
  final ImagePicker _imagePicker = ImagePicker();
  AddImageBloc() : super(const AddImageInitial()) {
    on<PickImageEvent>(_onPickImage);
  }
  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<AddImageState> emit,
  ) async {
    try {
      final pickedFile =
          await Methods.pickImageSafely(_imagePicker, source: event.source);

      if (pickedFile != null) {
        if (pickedFile.path.contains('.gif') &&
            MyDataModel.getInstance().vip1?.isUploadGif == false) {
          Methods().showWaringGifDialog();
        } else {
          if (pickedFile.path.contains('.gif')) {
            emit(ImagePickerSuccess(imagePath: pickedFile.path));
          } else {
            final result = await Methods().compressFile(xFile: pickedFile);
            emit(ImagePickerSuccess(imagePath: result.path));
          }
        }
      } else {
        emit(const ImagePickerFailure(error: 'No image selected'));
      }
    } catch (e) {
      emit(ImagePickerFailure(error: '$e'));
    }
  }
}

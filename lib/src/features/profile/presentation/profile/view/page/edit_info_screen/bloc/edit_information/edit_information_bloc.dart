import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:general/src/features/profile/domain/profile_use_case/change_country_uc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/auth/auth.dart';
import 'package:general/src/features/auth/domain/use_cases/replace_cover_image_us.dart';
import 'package:general/src/features/auth/presentation/country/country_page.dart';
import 'package:general/src/features/room/presentation/room_controller.dart';

part 'edit_information_event.dart';
part 'edit_information_state.dart';

class EditInformationBloc
    extends Bloc<BaseEditInformationEvent, EditInformationState> {
  final AddInfoUc addInfoUc;
  final ReplaceCoverImageUseCase replaceCoverImageUseCase;
  final ChangeCountryUC changeCountryUC;

  bool isPicking = false;

  EditInformationBloc({
    required this.addInfoUc,
    required this.replaceCoverImageUseCase,
    required this.changeCountryUC,
  }) : super(
          EditInformationState(
            formKey: GlobalKey<FormState>(),
            name: TextEditingController(),
            bio: TextEditingController(),
            birthday: TextEditingController(),
            country: TextEditingController(),
            gender: TextEditingController(),
          ),
        ) {
    on<SelectedGenderEvent>(_genderEvent);
    on<SelectedBirthdayEvent>(_birthdayEvent);
    on<PickImageEvent>(_pickFileEvent);
    on<EditInformationEvent>(_addInformation);
    on<PickMultiPicBloc>(_multiImages);
    on<AssignInformationEvent>(_assignInfo);
    on<InitialStateEvent>(_initialStateEEvent);
    on<ActiveSaveButtonEvent>(_activeSaveButtonEvent);
    on<CropImageEvent>(_cropImageEvent);
    on<PickCoverImageEvent>(_pickCoverFileEvent);
    on<DeleteCoverImageEvent>(_deleteCoverFileEvent);
    on<ChangeCountryEvent>(_changeCountryEvent);
  }
  // Events
  void _assignInfo(
    AssignInformationEvent event,
    Emitter<EditInformationState> emit,
  ) {
    emit(
      state.copyWith(
          name: MyDataModel.getInstance().name,
          gender: MyDataModel.getInstance().profile?.gender == 1
              ? StringManager.male.tr()
              : StringManager.female.tr(),
          bio: MyDataModel.getInstance().bio,
          isSaveButtonActive: false,
          coverImages: MyDataModel.getInstance().multiImages != null
              ? MyDataModel.getInstance()
                  .multiImages
                  ?.map((e) => e.img)
                  .toList()
              : [],
          birthday: MyDataModel.getInstance().profile?.birthday ?? '',
          country: HiveManager().getData(
                      KeysManager.USER_BOX, KeysManager.LANG_CODE_KEY) ==
                  "ar"
              ? MyDataModel.getInstance().country?.name
              : MyDataModel.getInstance().country?.nameEn,
          requestState: RequestState.idle),
    );
  }

  void _initialStateEEvent(
    InitialStateEvent event,
    Emitter<EditInformationState> emit,
  ) =>
      emit(
        state.copyWith(
          requestState: RequestState.idle,
          reqStateChangeCountry: RequestState.idle,
        ),
      );

  void _genderEvent(
    SelectedGenderEvent event,
    Emitter<EditInformationState> emit,
  ) =>
      emit(state.copyWith(gender: event.gender));

  void _birthdayEvent(
    SelectedBirthdayEvent event,
    Emitter<EditInformationState> emit,
  ) {
    if (event.dateTime == null) return;
    final String formattedDate =
        DateFormat('yyyy-MM-dd').format(event.dateTime ?? DateTime.now());
    emit(state.copyWith(birthday: formattedDate));
  }

  void _activeSaveButtonEvent(
    ActiveSaveButtonEvent event,
    Emitter<EditInformationState> emit,
  ) {
    if (event.isUserName) {
      bool isValid = (state.name.text.isNotEmpty);
      if (state.isSaveButtonActive != isValid) {
        emit(state.copyWith(isSaveButtonActive: isValid));
      }
    } else {
      bool isValid = (state.bio.text.isNotEmpty);
      if (state.isSaveButtonActive != isValid) {
        emit(state.copyWith(isSaveButtonActive: isValid));
      }
    }
  }

  Future<void> _pickFileEvent(
    PickImageEvent event,
    Emitter<EditInformationState> emit,
  ) async {
    if (isPicking) return;
    isPicking = true;
    try {
      final ImagePicker picker = ImagePicker();
      XFile? result = await Methods.pickImageSafely(
        picker,
        source: event.fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (result != null) {
        if (result.path.toLowerCase().endsWith('.gif') &&
            MyDataModel.getInstance().vip1?.isUploadGif == false) {
          Methods().showWaringGifDialog();
          emit(state.copyWith(isImageNull: true));
          return;
        } else {
          if (result.path.contains('.gif')) {
            add(CropImageEvent(result, false, false, null, true));
          } else {
            final pick = await Methods().compressFile(xFile: result);
            add(CropImageEvent(pick, false, false, null, null));
          }
        }
      } else {
        emit(state.copyWith(isImageNull: true));
      }
    } on PlatformException catch (_) {
      emit(state.copyWith(isImageNull: true, requestState: RequestState.idle));
    } catch (error) {
      emit(
        state.copyWith(
          isImageNull: true,
          requestState: RequestState.error,
          message: StringManager.somethingWrong.tr(),
        ),
      );
    } finally {
      isPicking = false;
    }
  }

  Future<void> _cropImageEvent(
    CropImageEvent event,
    Emitter<EditInformationState> emit,
  ) async {
    add(AssignInformationEvent());

    try {
      if (event.isGif != true) {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: event.image.path,
          maxWidth: 2048,
          maxHeight: 2048,
          compressFormat: ImageCompressFormat.jpg,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: StringManager.photo.tr(),
              toolbarColor: ColorManager.greyDark,
              statusBarColor: ColorManager.greyDark,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false,
              hideBottomControls: true,
              cropFrameStrokeWidth: 2,
              cropGridStrokeWidth: 2,
              showCropGrid: true,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPresetCustom(),
              ],
            ),
            IOSUiSettings(
              title: StringManager.photo.tr(),
              aspectRatioLockEnabled: false,
              hidesNavigationBar: false,
              rotateButtonsHidden: true,
              rotateClockwiseButtonHidden: true,
              resetButtonHidden: true,
            ),
          ],
        );
        if (croppedFile != null) {
          File finalFile = File(croppedFile.path);
          if (event.isReplace) {
            final result = await replaceCoverImageUseCase(
              ReplaceCoverImageParametersUC(
                newImage: finalFile,
                previousImageId: event.previousImageId,
              ),
            );
            result.fold(
              (left) {
                emit(
                  state.copyWith(
                    requestState: RequestState.error,
                    message: NetworkExceptions.getErrorMessage(left),
                  ),
                );
              },
              (right) {
                emit(
                  state.copyWith(
                    requestState: RequestState.loaded,
                    message: right.message,
                  ),
                );
              },
            );
          } else {
            if (event.isCover) {
              emit(
                state.copyWith(
                  coverImage: finalFile,
                  coverImages: MyDataModel.getInstance().multiImages != null
                      ? MyDataModel.getInstance()
                          .multiImages
                          ?.map((e) => e.img)
                          .toList()
                      : [],
                ),
              );
            } else {
              emit(state.copyWith(image: finalFile));
            }
            add(
              const EditInformationEvent(),
            );
          }
        }
      } else {
        File finalFile = File(event.image.path);
        if (event.isReplace) {
          final result = await replaceCoverImageUseCase(
            ReplaceCoverImageParametersUC(
              newImage: finalFile,
              previousImageId: event.previousImageId,
            ),
          );
          result.fold(
            (left) {
              emit(
                state.copyWith(
                  requestState: RequestState.error,
                  message: NetworkExceptions.getErrorMessage(left),
                ),
              );
            },
            (right) {
              emit(
                state.copyWith(
                  requestState: RequestState.loaded,
                  message: right.message,
                ),
              );
            },
          );
        } else {
          if (event.isCover) {
            emit(state.copyWith(
                coverImage: finalFile,
                coverImages: MyDataModel.getInstance().multiImages != null
                    ? MyDataModel.getInstance()
                        .multiImages
                        ?.map((e) => e.img)
                        .toList()
                    : []));
          } else {
            emit(state.copyWith(image: finalFile));
          }
          add(const EditInformationEvent());
        }
      }
    } catch (error) {
      if (event.isCover) {
        emit(
          state.copyWith(
            isCoverImageNull: true,
            requestState: RequestState.error,
            message: StringManager.somethingWrong.tr(),
          ),
        );
      } else {
        emit(
          state.copyWith(
            isImageNull: true,
            requestState: RequestState.error,
            message: StringManager.somethingWrong.tr(),
          ),
        );
      }
    }
  }

  Future<void> _pickCoverFileEvent(
    PickCoverImageEvent event,
    Emitter<EditInformationState> emit,
  ) async {
    if (isPicking) return;
    isPicking = true;
    try {
      final ImagePicker picker = ImagePicker();
      XFile? result = await Methods.pickImageSafely(
        picker,
        source: event.fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (result != null) {
        if (result.path.toLowerCase().endsWith('.gif')) {
          Methods().showWaringGifDialog();
          emit(state.copyWith(isCoverImageNull: true));
        } else {
          final pick = await Methods().compressFile(xFile: result);
          add(
            CropImageEvent(
              pick,
              true,
              event.isReplace,
              event.previousImageId,
              false,
            ),
          );
        }
      } else {
        emit(state.copyWith(isCoverImageNull: true));
      }
    } catch (error) {
      emit(
        state.copyWith(
          isCoverImageNull: true,
          requestState: RequestState.error,
          message: StringManager.somethingWrong.tr(),
        ),
      );
    } finally {
      isPicking = false;
    }
  }

  Future<void> _deleteCoverFileEvent(
    DeleteCoverImageEvent event,
    Emitter<EditInformationState> emit,
  ) async {
    List<String> currentCoverImages =
        MyDataModel.getInstance().multiImages != null
            ? MyDataModel.getInstance().multiImages!.map((e) => e.img).toList()
            : [];
    currentCoverImages.remove(event.imageUrl);
    emit(
      state.copyWith(
        isCoverImageNull: true,
        coverImages: currentCoverImages,
      ),
    );
    add(const EditInformationEvent());
  }

  Future<void> _addInformation(
    EditInformationEvent event,
    Emitter<EditInformationState> emit,
  ) async {
    emit(
      state.copyWith(requestState: RequestState.loading),
    );

    final result = await addInfoUc(
      InformationParametersUC(
        name: state.name.text,
        bio: state.bio.text,
        image: state.image,
        multiImages: state.coverImage != null ? [state.coverImage!] : [],
        oldMultiImages: state.coverImages,
        gender: state.gender.text == StringManager.female.tr() ? 0 : 1,
        date: event.date ??
            Methods().convertNumerals(state.birthday.text, toEnglish: true),
        countryId: CountriesScreen.countryId.value,
      ),
    );

    result.fold(
      (left) {
        emit(
          state.copyWith(
            coverImage: null,
            isCoverImageNull: true,
            requestState: RequestState.error,
            message: NetworkExceptions.getErrorMessage(left),
            isSaveButtonActive: false,
          ),
        );
      },
      (right) {
        emit(
          state.copyWith(
            requestState: RequestState.loaded,
            message: right.message,
            coverImage: null,
            isCoverImageNull: true,
          ),
        );
        // Re-fetch my-data so screens bound to FetchUserDataBloc (e.g. the
        // "me" tab header) reflect the new name/bio immediately, without
        // waiting for a manual pull-to-refresh.
        di<FetchUserDataBloc>().add(const FetchMyDataEvent(isLoading: false));
        // Invalidate the room's own cached copy of "me" too (UsersCache),
        // same as privacy_screen.dart/vip_center_bloc.dart already do for
        // their own "something about me changed" cases -- without this the
        // @-mention picker inside an active room kept showing the name from
        // before this edit (it reads from UsersCache, not MyDataModel).
        UsersCache().removeUser(MyDataModel.getInstance().id ?? -1);
      },
    );
  }

  Future<void> _changeCountryEvent(
    ChangeCountryEvent event,
    Emitter<EditInformationState> emit,
  ) async {
    emit(state.copyWith(reqStateChangeCountry: RequestState.loading));

    final result = await changeCountryUC(
      '${di<CountriesBloc>().state.countryEntity?.id}',
    );

    result.fold(
      (left) {
        emit(
          state.copyWith(
            reqStateChangeCountry: RequestState.error,
            message: NetworkExceptions.getErrorMessage(left),
          ),
        );
      },
      (right) {
        emit(
          state.copyWith(
            reqStateChangeCountry: RequestState.loaded,
            message: right.message,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    state.name.dispose();
    state.birthday.dispose();
    state.country.dispose();
    state.bio.dispose();
    state.gender.dispose();
    return super.close();
  }

  Future<void> _multiImages(
    PickMultiPicBloc event,
    Emitter<EditInformationState> emit,
  ) async {
    List<File> files = [];
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      for (final file in result.files) {
        if (['jpg', 'jpeg', 'png'].contains(file.extension)) {
          final originalFile = File(file.path!);

          final xFile = XFile(originalFile.path);

          final compressedXFile = await Methods().compressFile(xFile: xFile);

          files.add(File(compressedXFile.path));
        }
      }

      emit(state.copyWith(multiImages: files));
    }
  }

  void removeFile({required File element}) {
    final List<File> currentFiles = state.multiImages;

    currentFiles.removeWhere((x) => x.path == element.path);

    emit(state.copyWith(multiImages: currentFiles));
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}

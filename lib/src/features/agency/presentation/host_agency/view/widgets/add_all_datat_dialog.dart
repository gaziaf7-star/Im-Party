import 'dart:io';

import 'package:general/src/core/index.dart';
import 'package:general/src/features/agency/domain/entity/information_agency_entity.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/manager_information_agency/information_agency_bloc.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/update_host_agency_data/update_host_agency_data_bloc.dart';

class AddAllDataDialog extends StatefulWidget {
  const AddAllDataDialog({super.key, required this.data});

  final InformationAgencyEntity data;

  @override
  State<AddAllDataDialog> createState() => _AddAllDataDialogState();
}

class _AddAllDataDialogState extends State<AddAllDataDialog> {
  late TextEditingController controllerBio;
  late TextEditingController controllerName;

  @override
  void initState() {
    controllerBio = TextEditingController(text: widget.data.bio);
    controllerName = TextEditingController(text: widget.data.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: 12.radius,
      ),
      child: Padding(
        padding: context.paddingAll(16),
        child:
            BlocConsumer<UpdateHostAgencyDataBloc, UpdateHostAgencyDataState>(
          bloc: di<UpdateHostAgencyDataBloc>(),
          listener: (context, state) {
            if (state.requestState.isError) {
              Methods.showToast(context, isError: true, message: state.message);
            } else if (state.requestState.isLoaded) {
              Methods.showToast(context, message: StringManager.success);
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, Routes.layout, (route) => false);
                      },
                      icon: Icon(
                        Icons.close,
                        color: ColorManager.textPrimary,
                      ),
                    ),
                  ),
                  Text(StringManager.agencyAddInfo.tr(),
                      style: context.bodyMedium.size(18).bold),
                  16.hBox,
                  InkWell(
                    overlayColor: WidgetStateColor.transparent,
                    onTap: () {
                      di<UpdateHostAgencyDataBloc>().add(const PickImageEvent(
                        ImageSource.gallery,
                      ));
                    },
                    child: (state.pathImg.isNotEmpty)
                        ? Container(
                            height: 80.h,
                            width: 80.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    ColorManager.white.withValues(alpha: (0.4)),
                              ),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(
                                  File(state.pathImg),
                                ),
                              ),
                            ),
                          )
                        : (widget.data.img ?? '').isNotEmpty
                            ? ImageViewWidget(
                                url: widget.data.img ?? '',
                                displayName: widget.data.name ?? '',
                                height: 80.h,
                                width: 80.w,
                              )
                            : CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[300],
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                  color: ColorManager.redAccount,
                                ),
                              ),
                  ),

                  16.hBox, //
                  TextInputWidget(
                    StringManager.agencyAddName.tr(),
                    controller: controllerName,
                  ),
                  16.hBox,

                  TextInputWidget(
                    StringManager.agencyAddBio.tr(),
                    controller: controllerBio,
                  ),
                  16.hBox, // Save Button
                  ButtonWidget(
                    onPressed: () {
                      if (controllerName.text.isEmpty) {
                        Methods.showToast(context,
                            message: StringManager.agencyAddName.tr(),
                            isError: true);
                      } else if (controllerBio.text.isEmpty) {
                        Methods.showToast(context,
                            message: StringManager.agencyAddBio.tr(),
                            isError: true);
                      } else if (state.pathImg.isEmpty &&
                          (widget.data.img ?? '').isEmpty) {
                        Methods.showToast(context,
                            message: StringManager.agencyAddImage.tr(),
                            isError: true);
                      } else {
                        di<UpdateHostAgencyDataBloc>().add(
                          UpdateHostAgencyDataEvent(
                            UpdateAgencyParam(
                              name: controllerName.text,
                              bio: controllerBio.text,
                              image: state.imageFile,
                              agencyId: widget.data.id.toString(),
                            ),
                          ),
                        );
                      }
                    },
                    title: StringManager.save.tr(),
                    isLoading: di<InformationAgencyBloc>()
                            .state
                            .requestState
                            .isLoading ||
                        di<UpdateHostAgencyDataBloc>()
                            .state
                            .requestState
                            .isLoading,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void showCustomDialog(BuildContext context, InformationAgencyEntity data) {
  showDialog(
    context: context,
    builder: (context) {
      return AddAllDataDialog(
        data: data,
      );
    },
  );
}

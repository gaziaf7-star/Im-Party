import 'dart:io';
import 'package:general/src/features/agency/domain/entity/information_agency_entity.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/update_host_agency_data/update_host_agency_data_bloc.dart';

import '../../../../../../../../core/index.dart';

class UpdateHostAgencyScreen extends StatefulWidget {
  const UpdateHostAgencyScreen({super.key, required this.data});

  final InformationAgencyEntity data;

  @override
  State<UpdateHostAgencyScreen> createState() => _UpdateHostAgencyScreenState();
}

class _UpdateHostAgencyScreenState extends State<UpdateHostAgencyScreen> {
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
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBg,
      appBar: AppBarWidget(
        title: StringManager.updateAgency,
        backgroundColor: ColorManager.scaffoldBg,
      ),
      body: Padding(
        padding: context.paddingAll(16),
        child: BlocConsumer<UpdateHostAgencyDataBloc, UpdateHostAgencyDataState>(
          bloc: di<UpdateHostAgencyDataBloc>(),
          listenWhen: (prev, curr) =>
              prev.requestState != curr.requestState,
          listener: (context, state) {
            if (state.requestState.isError) {
              Methods.showToast(context, isError: true, message: state.message);
            } else if (state.requestState.isLoaded) {
              Methods.showToast(context, message: StringManager.success);
              Navigator.pop(context);
            }
          },
          buildWhen: (prev, curr) =>
              prev.pathImg != curr.pathImg || prev.imageFile != curr.imageFile,
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                16.hBox,
                GestureDetector(
                  onTap: () {
                    di<UpdateHostAgencyDataBloc>().add(const PickImageEvent(
                      ImageSource.gallery,
                    ));
                  },
                  child: (state.pathImg.isNotEmpty)
                      ? Container(
                          height: 110.h,
                          width: 110.w,
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
                              height: 110.h,
                              width: 110.w,
                              shape: BoxShape.circle,
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: ColorManager.black,
                              ),
                            ),
                ),
                10.hBox,
                Text(
                  StringManager.agencyAddInfo.tr(),
                  style: context.bodySmall.w600
                      .colorExt(ColorManager.secondaryText),
                ),
                40.hBox, //
                TextInputWidget(
                  StringManager.agencyAddName.tr(),
                  controller: controllerName,
                  fillColor: ColorManager.scaffoldBackgroundColor,
                  // Fixed black (was the panel-driven textPrimary default,
                  // which can resolve light and go invisible here).
                  textColor: ColorManager.black,
                ),

                //   16.hBox,
                // TextInputWidget(
                //   StringManager.agencyAddPhone,
                //   controller: controllerPhone,
                //   // decoration: const InputDecoration(
                //   //   labelText: 'Bio',
                //   //   hintText: 'Enter your bio',
                //   //   border: OutlineInputBorder(),
                //   // ),
                // ),
                30.hBox,

                TextInputWidget(
                  StringManager.agencyAddBio.tr(),
                  controller: controllerBio,
                  fillColor: ColorManager.scaffoldBackgroundColor,
                  // Fixed black (was the panel-driven textPrimary default,
                  // which can resolve light and go invisible here).
                  textColor: ColorManager.black,
                  // decoration: const InputDecoration(
                  //   labelText: 'Bio',
                  //   hintText: 'Enter your bio',
                  //   border: OutlineInputBorder(),
                  // ),
                ),
                const Spacer(),
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
                ),
                20.hBox,
              ],
            );
          },
        ),
      ),
    );
  }
}

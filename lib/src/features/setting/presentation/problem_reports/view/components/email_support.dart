part of '../problem_reports_screen.dart';

class EmailSupport extends StatefulWidget {
  const EmailSupport({super.key});

  @override
  State<EmailSupport> createState() => _EmailSupportState();
}

class _EmailSupportState extends State<EmailSupport> {
  late TextEditingController emailController;
  late TextEditingController contactController;

  final formKey = GlobalKey<FormState>();
  String? selectedImagePath;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    contactController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MakeProblemReportBloc, MakeProblemReportState>(
      bloc: di<MakeProblemReportBloc>(),
      listener: (context, state) {
        if (state.reqState.isLoaded) {
          Methods.showToast(context, message: state.message ?? '');
        } else if (state.reqState.isError) {
          Methods.showToast(context,
              message: state.message ?? '', isError: true);
        }
      },
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              20.hBox,
              Container(
                height: 103.h,
                width: 321.w,
                margin: context.paddingAll(10),
                decoration: BoxDecoration(
                  borderRadius: 10.radius,
                  border: Border.all(color: ColorManager.grey2),
                ),
                child: TextFormField(
                  controller: contactController,
                  maxLines: null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return StringManager.requiredField.tr();
                    }
                    if (value.length < 10) {
                      return StringManager.yourDescriptionLessThan.tr();
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: StringManager.writeYourComplaint.tr(),
                    hintStyle: const TextStyle(color: ColorManager.grey2),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ),
              Container(
                height: 103.h,
                width: 321.w,
                margin: context.paddingAll(10),
                decoration: BoxDecoration(
                  borderRadius: 10.radius,
                  border: Border.all(color: ColorManager.grey2),
                ),
                child: TextFormField(
                  controller: emailController,
                  maxLines: null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return StringManager.requiredField.tr();
                    }
                    if (value.length < 10) {
                      return StringManager.yourDescriptionLessThan.tr();
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    //hintText: StringManager.writeYouremail,
                    hintStyle: TextStyle(color: ColorManager.grey2),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  di<MakeProblemReportBloc>().add(
                    const MakeProblemReportPickImageEvent(ImageSource.gallery),
                  );
                },
                radius: 10,
                child:
                    BlocBuilder<MakeProblemReportBloc, MakeProblemReportState>(
                  bloc: di<MakeProblemReportBloc>(),
                  buildWhen: (prev, curr) => prev.imagePath != curr.imagePath,
                  builder: (context, state) {
                    selectedImagePath = state.imagePath;
                    return DashedBorderContainer(
                      width: 113.w,
                      height: 37.h,
                      borderRadius: 5,
                      borderColor: ColorManager.supportBorderColor,
                      strokeWidth: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorManager.supportColor,
                          image: selectedImagePath != null
                              ? DecorationImage(
                                  fit: BoxFit.contain,
                                  image: FileImage(
                                    File(selectedImagePath ?? ''),
                                  ),
                                )
                              : null,
                          borderRadius: 5.radius,
                        ),
                        child: selectedImagePath == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AssetsManager.addGallery,
                                    color: Colors.black,
                                    width: 16.w,
                                  ),
                                  10.hBox,
                                ],
                              )
                            : const SizedBox(),
                      ),
                    );
                  },
                ),
              ),
              30.hBox,
              MainButton(
                onTap: () {
                  if (formKey.currentState?.validate() ?? false) {
                    di<MakeProblemReportBloc>().add(
                      MakeProblemReportEvent(
                        context: context,
                        makeProblemReportParam: MakeProblemReportParam(
                          description: emailController.text,
                          userId: MyDataModel.getInstance().id.toString(),
                          contact: contactController.text,
                          image: selectedImagePath == null ||
                                  selectedImagePath!.isEmpty
                              ? null
                              : File(selectedImagePath!),
                        ),
                      ),
                    );
                  }
                },
                title: StringManager.send.tr(),
                style: context.bodyMedium.bold
                    .size(10)
                    .colorExt(ColorManager.textPrimary),
                width: 197.w,
                height: 36.h,
                isLoading: false,
                radius: 20,
                buttonColor: ColorManager.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

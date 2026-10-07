import 'dart:io';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/dotted_container.dart';
import 'package:general/src/features/setting/setting.dart';
import '../bloc/get_questions_bloc/get_questions_bloc.dart';
import '../bloc/get_questions_bloc/get_questions_state.dart';

part 'components/problem_type_body.dart';
part 'components/support_tab_bar.dart';
part 'components/faq_component.dart';
part 'components/email_support.dart';

class ProblemReportsScreen extends StatefulWidget {
  const ProblemReportsScreen({super.key});

  @override
  State<ProblemReportsScreen> createState() => _ProblemReportsScreenState();
}

class _ProblemReportsScreenState extends State<ProblemReportsScreen> {
  late TextEditingController controller;
  late TextEditingController contactController;
  final _formKey = GlobalKey<FormState>();
  String? selectedImagePath;

  static const Color _pageBackground = Colors.white;
  static const Color _primaryText = Colors.black;
  static const Color _secondaryText = Color(0xFF6B7280);
  static const Color _surface = Color(0xFFF8F9FB);
  static const Color _border = Color(0xFFE5E7EB);

  @override
  void initState() {
    final bloc = di<MakeProblemReportBloc>();
    bloc.state.contactController.clear();
    bloc.state.descController.clear();

    bloc.add(const MakeProblemReportRemoveImageEvent());
    bloc.add(const ChangeContactDetails(index: 0, type: 'type'));
    bloc.add(const ChangeContactDetails(index: 0, type: 'details'));

    controller = TextEditingController();
    contactController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    final bloc = di<MakeProblemReportBloc>();
    bloc.state.contactController.clear();
    bloc.state.descController.clear();

    bloc.add(const MakeProblemReportRemoveImageEvent());

    controller.dispose();
    contactController.dispose();
    super.dispose();
  }

  OutlineInputBorder _inputBorder({Color color = _border, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(BuildContext context, String title,
      {bool required = false}) {
    return Row(
      children: [
        Expanded(
          child: TextWidget(
            title,
            style: context.bodyMedium.w600.size(15).colorExt(_primaryText),
          ),
        ),
        if (required)
          TextWidget(
            '*',
            style: context.bodyMedium.bold.colorExt(Colors.red),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MakeProblemReportBloc, MakeProblemReportState>(
      bloc: di<MakeProblemReportBloc>(),
      listener: (context, state) {
        if (state.reqState.isLoaded) {
          Methods.showToast(context, message: state.message ?? '');
        } else if (state.reqState.isError) {
          Methods.showToast(
            context,
            message: state.message ?? '',
            isError: true,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _pageBackground,
          appBar: AppBarWidget(
            backgroundColor: _pageBackground,
            shadow: Colors.transparent,
            iconColor: _primaryText,
            title: StringManager.feedBack.tr(),
            titleStyle:
            context.titleLarge.w600.size(18).colorExt(_primaryText),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: ButtonWidget(
                  title: StringManager.save.tr(),
                  width: 78,
                  height: 34,
                  radius: 12,
                  backgroundColor: Colors.black,
                  titleColor: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  onPressed: () {
                    if (_formKey.currentState?.validate() == false) {
                      Methods.showToast(
                        context,
                        message: StringManager.enterYorFullData.tr(),
                      );
                    } else if (state.descController.text.length < 10) {
                      Methods.showToast(
                        context,
                        message: StringManager.yourDescriptionLessThan.tr(),
                      );
                    } else {
                      di<MakeProblemReportBloc>().add(
                        MakeProblemReportEvent(
                          context: context,
                          makeProblemReportParam: MakeProblemReportParam(
                            description: state.descController.text,
                            userId: MyDataModel.getInstance().id.toString(),
                            contact: state.contactController.text,
                            image: selectedImagePath == null ||
                                selectedImagePath?.isEmpty == true
                                ? null
                                : File(selectedImagePath ?? ''),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                16.w,
                12.h,
                16.w,
                24.h + MediaQuery.of(context).padding.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      StringManager.feedBack.tr(),
                      style: context.titleLarge.w600
                          .size(24)
                          .colorExt(_primaryText),
                    ),
                    6.hBox,
                    TextWidget(
                      StringManager.feedbackDescription.tr(),
                      style: context.bodyMedium
                          .size(13)
                          .colorExt(_secondaryText),
                    ),
                    22.hBox,
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            context,
                            StringManager.selectFeedback.tr(),
                          ),
                          14.hBox,
                          ProblemType(
                            types: [
                              StringManager.suggestion.tr(),
                              StringManager.bug.tr(),
                              StringManager.help.tr(),
                              StringManager.other.tr(),
                            ],
                            type: 'type',
                          ),
                        ],
                      ),
                    ),
                    14.hBox,
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            context,
                            StringManager.contactDetails.tr(),
                            required: true,
                          ),
                          14.hBox,
                          ProblemType(
                            types: [
                              StringManager.whatsappDetails.tr(),
                              StringManager.email.tr(),
                              StringManager.phone.tr(),
                            ],
                            type: 'details',
                          ),
                          16.hBox,
                          TextWidget(
                            state.indexDetails == 0
                                ? StringManager.whatsapp.tr()
                                : state.indexDetails == 1
                                ? StringManager.email.tr()
                                : StringManager.phone.tr(),
                            style: context.bodyMedium.w600
                                .size(13)
                                .colorExt(_primaryText),
                          ),
                          8.hBox,
                          TextInputWidget(
                            '',
                            onChanged: (value) {
                              di<MakeProblemReportBloc>()
                                  .add(const UpdateFormValidationEvent());
                            },
                            keyboardType: state.indexDetails == 0
                                ? TextInputType.phone
                                : state.indexDetails == 1
                                ? TextInputType.emailAddress
                                : TextInputType.phone,
                            controller: state.contactController,
                            inputFormatters: state.indexDetails == 1
                                ? null
                                : [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\+?\d*'),
                              ),
                            ],
                            enabledBorder: _inputBorder(),
                            focusedBorder:
                            _inputBorder(color: Colors.black, width: 1.4),
                            border: _inputBorder(),
                            errorBorder:
                            _inputBorder(color: Colors.red, width: 1),
                            focusedErrorBorder:
                            _inputBorder(color: Colors.red, width: 1.2),
                            fillColor: Colors.white,
                            cursorColor: Colors.black,
                            textColor: Colors.black,
                            hintStyle: context.bodyMedium
                                .size(14)
                                .colorExt(_secondaryText),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return StringManager.requiredField.tr();
                              }

                              if (state.indexDetails == 1) {
                                final emailRegex = RegExp(
                                  r'^(?!.*\.\.)([a-zA-Z0-9_.+-])+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$',
                                );

                                if (!emailRegex.hasMatch(value)) {
                                  return StringManager.invalidEmail.tr();
                                }

                                final commonDomains = [
                                  'gmail.com',
                                  'hotmail.com',
                                  'yahoo.com',
                                ];
                                final emailParts = value.split('@');
                                if (emailParts.length == 2) {
                                  final domain = emailParts[1].toLowerCase();
                                  if (!commonDomains.contains(domain)) {
                                    return StringManager.invalidEmail.tr();
                                  }
                                }
                              }

                              return null;
                            },
                          ),
                          8.hBox,
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextWidget(
                              DateFormat('yyyy/MM/dd hh:mm a')
                                  .format(DateTime.now()),
                              style: context.bodyMedium.w500
                                  .size(11)
                                  .colorExt(_secondaryText),
                            ),
                          ),
                        ],
                      ),
                    ),
                    14.hBox,
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            context,
                            StringManager.description.tr(),
                            required: true,
                          ),
                          10.hBox,
                          TextInputWidget(
                            StringManager.feedbackDescription.tr(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 14.h,
                              horizontal: 14.w,
                            ),
                            enabledBorder: _inputBorder(),
                            focusedBorder:
                            _inputBorder(color: Colors.black, width: 1.4),
                            border: _inputBorder(),
                            errorBorder:
                            _inputBorder(color: Colors.red, width: 1),
                            focusedErrorBorder:
                            _inputBorder(color: Colors.red, width: 1.2),
                            fillColor: Colors.white,
                            cursorColor: Colors.black,
                            textColor: Colors.black,
                            controller: state.descController,
                            maxLines: 8,
                            minLines: 6,
                            maxLength: 500,
                            showMaxLength: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return StringManager.requiredField.tr();
                              }
                              return null;
                            },
                            hintStyle: context.bodyMedium
                                .size(13)
                                .colorExt(_secondaryText),
                          ),
                        ],
                      ),
                    ),
                    14.hBox,
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            context,
                            StringManager.screenshot.tr(),
                          ),
                          14.hBox,
                          InkWell(
                            borderRadius: BorderRadius.circular(14.r),
                            onTap: () {
                              if (selectedImagePath == null ||
                                  selectedImagePath!.isEmpty) {
                                di<MakeProblemReportBloc>().add(
                                  const MakeProblemReportPickImageEvent(
                                    ImageSource.gallery,
                                  ),
                                );
                              }
                            },
                            child: BlocBuilder<MakeProblemReportBloc,
                                MakeProblemReportState>(
                              bloc: di<MakeProblemReportBloc>(),
                              buildWhen: (prev, curr) =>
                              prev.imagePath != curr.imagePath,
                              builder: (context, imageState) {
                                selectedImagePath = imageState.imagePath;

                                return DashedBorderContainer(
                                  width: 104.w,
                                  height: 104.h,
                                  borderRadius: 14.r,
                                  borderColor: Colors.black,
                                  strokeWidth: 1.2,
                                  child: Container(
                                    width: 104.w,
                                    height: 104.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      image: selectedImagePath != null &&
                                          selectedImagePath!.isNotEmpty
                                          ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(
                                          File(selectedImagePath ?? ''),
                                        ),
                                      )
                                          : null,
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: (selectedImagePath ?? '').isEmpty
                                        ? Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 38.w,
                                          height: 38.w,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF1F2F4),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            AssetsManager.addGallery,
                                            color: Colors.black,
                                            width: 20.w,
                                          ),
                                        ),
                                        8.hBox,
                                        TextWidget(
                                          StringManager.screenshot.tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.bodyMedium.w600
                                              .size(11)
                                              .colorExt(Colors.black),
                                        ),
                                      ],
                                    )
                                        : const SizedBox(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    24.hBox,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

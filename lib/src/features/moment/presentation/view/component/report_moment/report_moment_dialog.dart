import 'package:general/src/features/moment/moment.dart';
import 'package:general/src/features/moment/presentation/view/component/report_moment/problem_type.dart';
import '../../../../../../core/index.dart';

class MomentReportDialog extends StatefulWidget {
  final String momentId;
  const MomentReportDialog({super.key, required this.momentId});
  @override
  State<MomentReportDialog> createState() => _MomentReportDialogState();
}

class _MomentReportDialogState extends State<MomentReportDialog> {
  late TextEditingController detailsController;
  late TextEditingController contactController;

  @override
  void initState() {
    super.initState();
    detailsController = TextEditingController();
    contactController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // White page (was the panel-driven scaffoldBg) + brand-gradient app
      // bar — matches the rest of the Moment redesign instead of a bare
      // default form.
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        title: StringManager.flag.tr(),
        backgroundGradient: ColorManager.brandGradient,
        titleStyle:
        context.titleLarge.w600.size(16).colorExt(ColorManager.white),
        iconColor: ColorManager.white,
        actions: [
          Center(
            child: BlocBuilder<MomentBloc, MomentStates>(
              bloc: di<MomentBloc>(),
              buildWhen: (prev, curr) => false,
              builder: (context, state) {
                return ButtonWidget(
                    width: 90.w,
                    height: 36.h,
                    radius: 18,
                    padding: context.paddingZero(),
                    // Solid white pill on the gradient header — same
                    // treatment as the Post Updates screen's action button.
                    backgroundColor: ColorManager.white,
                    titleColor: const Color(0xFF5204C6),
                    fontWeight: FontWeight.w600,
                    onPressed: () {
                      if (detailsController.text.isEmpty) {
                        Methods.showToast(
                            isError: true,
                            context,
                            message: StringManager.pleaseEnterAllData.tr());
                      } else {
                        di<MomentBloc>().add(ReportMomentEvent(
                          context: context,
                          reportMomentParam: ReportMomentParam(
                              description: detailsController.text,
                              momentId: widget.momentId,
                              type: ProblemType.typesArabic[
                              ProblemType.seletedMomentProblem]),
                        ));
                      }
                    },
                    title: StringManager.send.tr());
              },
            ),
          ),
          10.wBox,
        ],
      ),
      body: Padding(
        padding: context.paddingSymmetric(
          horizontal: 15,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.hBox,
              TextWidget(StringManager.typeOfProblem.tr(),
                  style: context.bodyLarge.w600
                      .colorExt(ColorManager.momentPostTextColor)),
              15.hBox,
              const ProblemType(),
              35.hBox,
              Text(StringManager.details.tr(),
                  style: context.bodyLarge.w600
                      .colorExt(ColorManager.momentPostTextColor)),
              10.hBox,
              // Bordered compose card (was a borderless field floating
              // directly on the page) — a defined text box reads as more
              // deliberate/professional than plain unbounded input.
              Container(
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: 14.radius,
                  border: Border.all(
                    color: ColorManager.grey.withValues(alpha: 0.25),
                  ),
                ),
                padding: context.paddingSymmetric(horizontal: 12, vertical: 4),
                child: TextInputWidget(
                  maxLines: 10,
                  minLines: 5,
                  StringManager.explainProblem.tr(),
                  controller: detailsController,
                  textColor: ColorManager.momentPostTextColor,
                  fillColor: ColorManager.white,
                  maxLength: 200,
                  contentPadding: context.paddingZero(),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
              ),
              20.hBox,
            ],
          ),
        ),
      ),
    );
  }
}
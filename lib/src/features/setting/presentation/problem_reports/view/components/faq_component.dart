part of '../problem_reports_screen.dart';

class FaqComponent extends StatefulWidget {
  const FaqComponent({super.key});

  @override
  State<FaqComponent> createState() => _FaqComponentState();
}

class _FaqComponentState extends State<FaqComponent> {
  @override
  void initState() {
    super.initState();
    di<GetQuestionsBloc>().add(
      GetQuestionsDetailsEvent(context: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetQuestionsBloc, GetQuestionsState>(
      bloc: di<GetQuestionsBloc>(),
      buildWhen: (prev, curr) => prev.reqState != curr.reqState || prev.data != curr.data,
      builder: (context, state) {
        return HandlingDataWidget(
          reqState: state.reqState,
          title: StringManager.tittleEmptyIntro.tr(),
          subTitle: StringManager.subTittleEmptyIntro.tr(),
          child: ListView.builder(
            itemCount: state.data.length,
            padding: context.paddingSymmetric(horizontal: 16, vertical: 8),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                margin: context.paddingOnly(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorManager.greyBorderColor),
                ),
                child: ExpansionTile(
                  title: TextWidget(
                    state.data[index].question ?? '',
                    style: context.bodyMedium
                        .size(10)
                        .colorExt(ColorManager.textPrimary.withValues(alpha: (0.8 ))),
                  ),
                  trailing: Icon(
                    state.data[index].answer?.isNotEmpty == true
                        ? Icons.remove
                        : Icons.add,
                    color: ColorManager.black.withValues(alpha: (0.8 )),
                    weight: 12.w,
                  ),
                  children: [
                    if (state.data[index].answer != null &&
                        state.data[index].answer!.isNotEmpty)
                      Padding(
                        padding: context.paddingSymmetric(
                            horizontal: 16, vertical: 8),
                        child: TextWidget(
                          state.data[index].answer!,
                          style: context.bodyMedium
                              .size(10)
                              .colorExt(ColorManager.textPrimary.withValues(alpha: (0.35 ))),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

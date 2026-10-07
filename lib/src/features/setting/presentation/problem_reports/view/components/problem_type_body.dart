part of '../problem_reports_screen.dart';

class ProblemType extends StatefulWidget {
  static int selectedProblem = 0;
  final List<String> types;
  final String type;

  const ProblemType({super.key, required this.types, required this.type});

  @override
  State<ProblemType> createState() => _ProblemTypeState();
}

class _ProblemTypeState extends State<ProblemType> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MakeProblemReportBloc, MakeProblemReportState>(
      bloc: di<MakeProblemReportBloc>(),
      buildWhen: (prev, curr) => widget.type == 'type'
          ? prev.indexTypes != curr.indexTypes
          : prev.indexDetails != curr.indexDetails,
      builder: (context, state) {
        final selectedIndex =
        widget.type == 'type' ? state.indexTypes : state.indexDetails;

        return LayoutBuilder(
          builder: (context, constraints) {
            final gap = 10.w;
            final itemWidth = (constraints.maxWidth - gap) / 2;

            return Wrap(
              spacing: gap,
              runSpacing: 10.h,
              children: List.generate(widget.types.length, (index) {
                final isSelected = selectedIndex == index;

                return InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () {
                    di<MakeProblemReportBloc>().add(
                      ChangeContactDetails(index: index, type: widget.type),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: itemWidth,
                    constraints: BoxConstraints(minHeight: 46.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF1F2F4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? Colors.black
                            : const Color(0xFFE5E7EB),
                        width: isSelected ? 1.3 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.black : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : const Color(0xFFB8BDC7),
                              width: 1.2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 13.sp,
                          )
                              : null,
                        ),
                        9.wBox,
                        Expanded(
                          child: TextWidget(
                            widget.types[index],
                            maxLines: 2,
                            style: context.bodyMedium.w500
                                .size(13)
                                .colorExt(Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }
}

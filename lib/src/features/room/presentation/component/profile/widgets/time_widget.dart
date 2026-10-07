import 'package:general/src/core/index.dart';

class TimeWidget extends StatefulWidget {
  final ValueChanged<String> onSelected;
  const TimeWidget({super.key, required this.onSelected});

  @override
  State<TimeWidget> createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  // Timed-kick (طرد) durations, ordered low→high. No "permanent" here — a
  // permanent removal is the separate حظر (ban) action.
  final List<String> global = [
    StringManager.oneMin.tr(),
    StringManager.threeMin.tr(),
    StringManager.tenMin.tr(),
    StringManager.thirtyMin.tr(),
    StringManager.sixtyMin.tr(),
    StringManager.twenyFourMin.tr(),
  ];
  String? selectedValue;
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        15.hBox,
        GridView.builder(
          itemCount: global.length,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 10,
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            childAspectRatio: 2.3,
          ),
          itemBuilder: (context, index) {
            return ButtonWidget(
              title: global[index],
              height: 30,
              // Use the theme's text color (not primary) for the unselected
              // label/border: the dialog surface and primary can be the same
              // hue in some admin-panel themes, which made unselected options
              // invisible (only the selected white-on-primary chip showed).
              titleColor: selectedIndex == index
                  ? ColorManager.buttonTextColor
                  : ColorManager.textPrimary,
              backgroundColor: selectedIndex == index
                  ? ColorManager.primary
                  : ColorManager.transparent,
              borderColor: selectedIndex == index
                  ? ColorManager.primary
                  : ColorManager.textPrimary,
              onPressed: () {
                setState(() {
                  selectedValue = global[index];
                  widget.onSelected.call(global[index]);
                  selectedIndex = index;
                });
              },
            );
          },
        ),
      ],
    );
  }
}

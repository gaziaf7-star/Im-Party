import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/md_indicator.dart';
import 'package:general/src/features/agency/presentation/host_agency/bloc/manager_information_agency/information_agency_bloc.dart';

class TabBarAgency extends StatefulWidget {
  const TabBarAgency({
    super.key,
    required this.controller,
    required this.isOwner,
  });

  final TabController? controller;
  final bool isOwner;

  @override
  State<TabBarAgency> createState() => _TabBarAgencyState();
}

class _TabBarAgencyState extends State<TabBarAgency> {
  late final ValueNotifier<int> selectedIndexNotifier;

  @override
  void initState() {
    super.initState();
    selectedIndexNotifier = ValueNotifier<int>(widget.controller!.index);
    widget.controller!.addListener(() {
      selectedIndexNotifier.value = widget.controller!.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndexNotifier,
      builder: (context, value, _) {
        return Row(
          children: [
            TabBar(
              controller: widget.controller,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              labelStyle:
                  context.bodyMedium.size(12).colorExt(ColorManager.textPrimary),
              unselectedLabelStyle: context.bodyMedium
                  .size(10)
                  .colorExt(ColorManager.textPrimary.withValues(alpha: (0.5))),
              indicator: MDIndicator(
                  indicatorColor: ColorManager.textPrimary,
                  indicatorWidth: 17.w,
                  indicatorHeight: 4.h,
                  radius: 20),
              labelPadding: context.paddingSymmetric(horizontal: 10),
              indicatorSize: TabBarIndicatorSize.label,
              dividerHeight: 0,
              tabs: [
                Text(StringManager.hostCenter.tr().toUpperCase()),
                Text(
                  StringManager.public.tr().toUpperCase(),
                ),
                if (StringManager.userType[2]! ||
                    (di<InformationAgencyBloc>().state.data?.userStates ?? 0) ==
                        1)
                  Text(
                    StringManager.target.tr().toUpperCase(),
                  ),
              ],
            ),
           ],
        );
      },
    );
  }
}

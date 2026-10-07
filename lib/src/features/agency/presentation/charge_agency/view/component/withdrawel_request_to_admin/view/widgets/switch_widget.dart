part of 'package:general/src/features/agency/presentation/charge_agency/view/component/withdrawel_request_to_admin/view/shipping_agent_withdrawel.dart';
class SwitchWidget extends StatelessWidget {
  const SwitchWidget({super.key, 
    required this.value,
    required this.title,
    this.onChanged,
  });

  final bool value;
  final String title;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return  SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: TextWidget(
        title.tr(),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: ColorManager.white,
      activeTrackColor: ColorManager.primary,
      inactiveThumbColor: ColorManager.white,
      inactiveTrackColor: ColorManager.primary.withValues(alpha: (0.5 )),
      thumbColor: WidgetStateProperty.resolveWith((Set states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return null;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((Set states) {
        if (states.contains(WidgetState.selected)) {
          return ColorManager.transparent;
        }
        return ColorManager.transparent;
      }),
    );
  }
}

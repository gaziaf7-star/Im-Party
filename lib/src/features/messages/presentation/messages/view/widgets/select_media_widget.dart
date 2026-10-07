part of 'package:general/src/features/messages/presentation/messages/view/messages_page.dart';

class _SelectMediaWidget extends StatelessWidget {
  const _SelectMediaWidget({
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: 50.radius,
      child: Container(
        width: 45.w,
        height: 45.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Brand gradient (was the flat panel-driven primary).
          gradient: ColorManager.brandGradient,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20.h,
        ),
      ),
    );
  }
}
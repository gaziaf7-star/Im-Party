part of 'package:general/src/features/family/presentation/create_family/view/create_family_intro.dart';

class _ListTileBody extends StatelessWidget {
  const _ListTileBody({
    required this.title,
    this.subtitle,
    required this.icon,
    //this.onTap, this.isPadding,
  });

 // final VoidCallback? onTap;

  final String? subtitle, title;
//  final bool? isPadding;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
     // onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 0.h),
      leading: Image.asset(
        icon,
        width: 30,
        color: ColorManager.primary,
      ),
      title: Padding(
        padding: context.paddingOnly(bottom: 5.h),
        child: TextWidget(
          title!,
          style: context.bodyLarge.bold.colorExt(ColorManager.textPrimary),
        ),
      ),
      dense: true,
      subtitle: TextWidget(
        subtitle!,
        style: context.bodyLarge.w400.colorExt(ColorManager.textPrimary),
      ),
    );
  }
}

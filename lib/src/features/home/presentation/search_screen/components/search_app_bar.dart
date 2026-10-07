

import '../../../../../core/index.dart';
import '../bloc/search_manager/search_bloc.dart';
import '../bloc/search_manager/search_events.dart';

class AppBarSearchWidget extends StatelessWidget
    implements PreferredSizeWidget {
   AppBarSearchWidget({
    super.key,
    required this.hintText,
  });

  final String hintText;
final  TextEditingController controller =TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorManager.transparent,
      leading: IconButton.filled(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          backgroundColor: ColorManager.surfaceCardColor,
          // shape: RoundedRectangleBorder(
          //   borderRadius: 4.radius,
          //   side: const BorderSide(
          //     color: Color(0xFFE8E9E9),
          //   ),
          // ),
        ),
        icon: Icon(
          Icons.arrow_back_ios,
          size: 18.5.h,
          color: ColorManager.iconColor,
        ),
      ),
      title: SizedBox(
        height: 40.h,
        child: TextField(
          decoration: InputDecoration(
            contentPadding: context.paddingAll(10),
            border: OutlineInputBorder(
              borderRadius: 8.radius,
              borderSide: BorderSide.none,
            ),
            fillColor: ColorManager.surfaceCardColor,
            filled: true,
            hintText: tr(hintText),
            prefixIcon:
                Icon(Icons.search, color: ColorManager.iconColor, size: 20.w),
          ),
          onChanged: (value){
            if(value!='') {
              di<SearchBloc>().add(SearchEvent(keyWord: value));
            }

          },
          controller: controller,
          style: context.bodyMedium.size(15), // Custom text style with extensions
        ),
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(56.h); // Height adjusted with ScreenUtil
}

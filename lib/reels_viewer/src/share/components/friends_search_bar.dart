part of 'package:general/reels_viewer/src/share/share_internel_screen.dart';

class _FriendsSearchBar extends StatelessWidget {
  const _FriendsSearchBar({
    required this.searchController,
  });
  final TextEditingController searchController;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManager.surfaceCardColor,
      child: Padding(
        padding: context.paddingOnly(start: 20, end: 8, bottom: 10),
        child: TextInputWidget(
          StringManager.enterUserID.tr(),
          
          hintStyle: context.bodyMedium.size(16).colorExt(ColorManager.greyTextColor),
          contentPadding:
              context.paddingSymmetric(horizontal: 10, vertical: 5),
          fillColor: ColorManager.greyTextColor.withValues(alpha: (0.1 )),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: 10.radius,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: 10.radius,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: 10.radius,
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: 10.radius,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: 10.radius,
          ),
          keyboardType: TextInputType.number,
          textStyle:  context.bodyMedium.size(17).colorExt( ColorManager.blackColor),
          controller: searchController,
          suffixIcon: TextButton(
              onPressed: () {
                di<SearchBloc>().add(SearchEvent(
                    keyWord: searchController.text,
                    isFriend: true,
                    loading: false,
                    page: '1'));
              },
              child: Text(
                StringManager.search.tr(),
                style: context.bodyMedium.size(16).colorExt( ColorManager.primary).bold,

              )),
        ),
      ),
    );
  }
}

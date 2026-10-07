import 'package:general/src/features/room/presentation/gifts/view/component/normal_gift/gift_bottom_bar.dart';

import '../../../../../../../reels_viewer/reels_viewer.dart';
import '../../../../../../core/widgets/md_indicator.dart';
import '../../bloc/fetch_gift_bloc/fetch_gift_bloc.dart';
import '../../bloc/fetch_gift_bloc/fetch_gift_events.dart';

class GiftTabBarWithSearch extends StatefulWidget {
  final TabController? giftController;
  final List<Widget> tabs;
  final Color selectedLabelColor;
  final Color unselectedLabelColor;
  final Color labelColorWhenBagActive;
  final bool showSearchIcon;
  final Color briefcaseIconColor;

  const GiftTabBarWithSearch({
    super.key,
    required this.giftController,
    required this.tabs,
    required this.selectedLabelColor,
    required this.unselectedLabelColor,
    required this.labelColorWhenBagActive,
    required this.showSearchIcon,
    required this.briefcaseIconColor,
  });

  @override
  State<GiftTabBarWithSearch> createState() => GiftTabBarWithSearchState();
}

class GiftTabBarWithSearchState extends State<GiftTabBarWithSearch>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  static ValueNotifier<bool> showSearchNotifier = ValueNotifier(false);
  static ValueNotifier<bool> showBagGiftNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showSearchNotifier,
      builder: (context, showSearch, child) {
        return Padding(
          padding: context.paddingOnly(
            start: 5,
            end: 5,
            bottom: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    /// TabBar
                    Opacity(
                      opacity: showSearch ? 0.0 : 1.0,
                      child: ValueListenableBuilder(
                          valueListenable: showBagGiftNotifier,
                          builder: (context, value, child) {
                            return TabBar(
                              //how to unselect all the tab when i tab on the bag down
                              onTap: (value) {
                                GiftTabBarWithSearchState
                                    .showBagGiftNotifier.value = false;
                                GiftTabBarWithSearchState
                                    .showSearchNotifier.value = false;
                              },
                              tabAlignment: TabAlignment.start,
                              isScrollable: true,
                              dividerHeight: 0,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: MDIndicator(
                                indicatorColor: ColorManager.transparent,
                                indicatorWidth: 0,
                                indicatorHeight: 0,
                                radius: 20.r,
                              ),
                              labelStyle: context.bodyMedium
                                  .size(12.5)
                                  .colorExt(showBagGiftNotifier.value == true
                                      ? widget.labelColorWhenBagActive
                                      : widget.selectedLabelColor),
                              unselectedLabelStyle:
                                  context.bodyMedium.size(12.5).colorExt(
                                        widget.unselectedLabelColor,
                                      ),
                              controller: widget.giftController,
                              padding: EdgeInsets.zero,
                              labelPadding: context.paddingSymmetric(
                                vertical: 5,
                                horizontal: 2,
                              ),
                              automaticIndicatorColorAdjustment: false,
                              tabs: widget.tabs,
                            );
                          }),
                    ),

                    /// Animated Search TextField
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: showSearch ? maxWidth : 0,
                          child: showSearch
                              ? SizedBox(
                                  height: 30,
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    style: context.bodyMedium
                                        .colorExt(ColorManager.textPrimary)
                                        .size(14),
                                    onChanged: (value) {
                                      di<FetchGiftBloc>()
                                          .add(SearchGiftCategoryEvent(value));
                                    },
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.transparent),
                                        borderRadius: BorderRadius.circular(
                                            50), // match your design
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.transparent),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.transparent),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      hintText: StringManager.search.tr(),
                                      hintStyle: context.bodyMedium
                                          .colorExt(
                                              ColorManager.white.withAlpha(150))
                                          .size(14),
                                      filled: true,
                                      fillColor: ColorManager.white
                                          .withValues(alpha: 0.1),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 0),
                                      prefixIcon: SizedBox(
                                        height: 14,
                                        width: 14,
                                        child: Center(
                                          child: Image.asset(
                                            AssetsManager.searchIcon1,
                                            height: 1412,
                                            width: 14,
                                            color: ColorManager.white,
                                          ),
                                        ),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Container(
                                          padding: context.paddingAll(3),
                                          decoration: BoxDecoration(
                                            borderRadius: 50.radius,
                                            color: ColorManager.white
                                                .withValues(alpha: 0.3),
                                          ),
                                          child: const Icon(Icons.close,
                                              color: ColorManager.white,
                                              size: 14),
                                        ),
                                        onPressed: () {
                                          showBagGiftNotifier.value = false;
                                          showSearchNotifier.value =
                                              !showSearchNotifier.value;
                                          _searchController.clear();
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                            maxHeight: 16),
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
              5.wBox,
              if (!showSearch)
                Text(
                  '|',
                  style: context.bodySmall.colorExt(ColorManager.textPrimary),
                ),
              5.wBox,
              if (!showSearch && widget.showSearchIcon)
                InkWell(
                  child: Image.asset(
                    AssetsManager.searchIcon1,
                    height: 20,
                    width: 20,
                    color: ColorManager.white,
                  ),
                  onTap: () {
                    showBagGiftNotifier.value = false;
                    showSearchNotifier.value = !showSearchNotifier.value;
                  },
                ),
              5.wBox,
              InkWell(
                child: Image.asset(
                  AssetsManager.briefcase,
                  height: 20,
                  width: 20,
                  color: widget.briefcaseIconColor,
                ),
                onTap: () {
                  showSearchNotifier.value = false;

                  if (showBagGiftNotifier.value) {
                    showBagGiftNotifier.value = false;
                    GiftBottomBar.giftType = TypeGift.normal;
                  } else {
                    di<FetchGiftBloc>().add(const FetchBagGiftEvent());

                    GiftBottomBar.giftType = TypeGift.bag;
                    showBagGiftNotifier.value = true;
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

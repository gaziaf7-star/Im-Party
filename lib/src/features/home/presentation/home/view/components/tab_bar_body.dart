part of 'package:general/src/features/home/presentation/home/view/home_page.dart';

class _TabBarBody extends StatelessWidget {
  const _TabBarBody({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Nudged right per owner request — was 5.wBox, sitting almost flush
        // against the screen edge.
        16.wBox,

        Expanded(
          child: TabBar(
            controller: controller,

            overlayColor: WidgetStateColor.transparent,

            indicatorSize: TabBarIndicatorSize.label,

            isScrollable: true,

            tabAlignment: TabAlignment.start,

            dividerHeight: 0,

            // Fixed white here instead of the panel-driven ColorManager.headerColor —
            // this tab bar now always sits on the fixed purple→lavender
            // ColorManager.homeBackgroundGradient (see HomePage), so it needs a
            // colour that stays readable on THAT gradient specifically, not
            // whatever the admin panel happens to have set for headerColor.
            indicator: MDIndicator(
              indicatorColor: ColorManager.homeHeaderTextColor,

              indicatorWidth: 17.0.w,

              indicatorHeight: 4.h,

              radius: 20,
            ),

            labelPadding: context.paddingOnly(end: 10),

            unselectedLabelStyle: context.bodyLarge.w500
                .colorExt(ColorManager.homeHeaderTextColorMuted)
                .size(18),

            labelStyle: context.bodyLarge.w600
                .colorExt(ColorManager.homeHeaderTextColor)
                .size(18),

            tabs: [
              if (ConstantsManager.isAudioRoomsEnabled)
                Text(StringManager.me.tr()),

              if (ConstantsManager.isAudioRoomsEnabled)
                Text(StringManager.popular.tr()),

              // Discover now precedes Live (tabs swapped per owner request).
              Text(StringManager.discover.tr()),

              if (ConstantsManager.isShowLive)
                Stack(
                  clipBehavior: Clip.none,

                  children: [
                    Text(StringManager.live.tr()),

                    Positioned(
                      top: -5,

                      right: -10,

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),

                        decoration: BoxDecoration(
                          color: ColorManager.primary,

                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Text(
                          "New",

                          style: context.bodySmall.w600
                              .colorExt(ColorManager.buttonTextColor)
                              .size(8),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Country/region filter — sits to the LEFT of the search icon, per
        // the reference design. Reuses the exact same picker
        // (CountryFilterPage) the Popular tab's own country re-tap already
        // opens elsewhere on this page, so there's only ever one
        // country-picker UI in the app, just two ways to reach it. Was a
        // bottomDailog() slide-up panel — now a real full page (on request),
        // pushed the normal way.
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CountryFilterPage()),
            );
          },

          icon: Image.asset(
            AssetsManager.icWorld,

            height: 22.h,

            width: 22.w,

            // Fixed white, same reasoning as the search icon beside it.
            color: ColorManager.homeHeaderTextColor,
          ),
        ),

        // The go-live control that used to sit here — an `icHome` glyph beside
        // search, which read as a home button rather than as the app's primary
        // action — is now the raised centre button in the bottom bar. Its
        // BlocBuilder, tap body and loaded-state guard were copied VERBATIM
        // into _GoLiveButton in layout/view/layout_page.dart — the chooser
        // popover anchors to the pressed widget's RenderBox, so it has to keep
        // its own BuildContext rather than share a helper. Nothing about the
        // flow changed; only where you press it.
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.searchScreen);
          },

          icon: Image.asset(
            AssetsManager.icHomeSearch,

            height: 24.5.h,

            width: 24.5.w,

            // Same reasoning as the tab labels above: fixed white so it stays
            // visible on the fixed home-page gradient regardless of the
            // panel's headerColor.
            color: ColorManager.homeHeaderTextColor,
          ),
        ),
      ],
    );
  }
}
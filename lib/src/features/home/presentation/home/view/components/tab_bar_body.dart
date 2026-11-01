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

            // Selected #F8284D / unselected black, bold (owner request): readable on the admin body image
            // header painted behind this bar.
            indicator: MDIndicator(
              indicatorColor: const Color(0xFFF8284D),

              indicatorWidth: 17.0.w,

              indicatorHeight: 4.h,

              radius: 20,
            ),

            labelPadding: context.paddingOnly(end: 10),

            unselectedLabelStyle: context.bodyLarge.w700
                .colorExt(Colors.black)
                .size(18),

            labelStyle: context.bodyLarge.w800
                .colorExt(const Color(0xFFF8284D))
                .size(21),

            tabs: [
              if (ConstantsManager.isAudioRoomsEnabled)
                Text(StringManager.me.tr()),

              if (ConstantsManager.isAudioRoomsEnabled)
                Text(StringManager.popular.tr()),

              // Discover now precedes Live (tabs swapped per owner request).
              Text(StringManager.discover.tr()),

              if (_showLiveTabOnHome)
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

            // Black, like the tab labels beside it.
            color: Colors.black,
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

            // Black, like the tab labels beside it.
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
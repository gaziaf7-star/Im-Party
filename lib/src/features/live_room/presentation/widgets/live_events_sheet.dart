import 'package:general/src/core/index.dart';
import 'package:general/src/core/widgets/web_view_events.dart';
import 'package:general/src/features/home/domain/entities/carousel_entity.dart';

/// In-live events browser: a 2/3-screen bottom sheet with one TAB per event
/// (thumbnail tabs) and an embedded events webview per tab — so the host/viewer
/// browses every running event without leaving the stream (#21).
class LiveEventsSheet {
  static Future<void> show(
    BuildContext context, {
    required List<CarouselEntity> events,
    int initialIndex = 0,
  }) {
    if (events.isEmpty) return Future.value();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LiveEventsSheetBody(
        events: events,
        initialIndex: initialIndex.clamp(0, events.length - 1),
      ),
    );
  }

  /// The event webview URL with the auth/branding params the events pages
  /// expect (token, lang, base_url, bucket_name) — same contract as the
  /// full-screen events route.
  static String eventUrl(CarouselEntity event) {
    final raw = event.url ?? '';
    if (raw.isEmpty) return raw;
    final token = Methods.getUserToken();
    final lang = HiveManager().getData<String>(
          KeysManager.USER_BOX,
          KeysManager.LANG_CODE_KEY,
        ) ??
        'en';
    final originalUri = Uri.parse(raw);
    final updatedParams = Map<String, String?>.from(originalUri.queryParameters)
      ..putIfAbsent('token', () => token)
      ..putIfAbsent('lang', () => lang)
      ..putIfAbsent('base_url', () => EndPoints.baseURL)
      ..putIfAbsent('bucket_name', () => EndPoints.storageURL);
    return originalUri.replace(queryParameters: updatedParams).toString();
  }
}

class _LiveEventsSheetBody extends StatelessWidget {
  final List<CarouselEntity> events;
  final int initialIndex;

  const _LiveEventsSheetBody({
    required this.events,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 2 / 3,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: ColorManager.scaffoldBgAlt,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: DefaultTabController(
        length: events.length,
        initialIndex: initialIndex,
        child: Column(
          children: [
            8.hBox,
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            6.hBox,
            // One thumbnail tab per running event.
            TabBar(
              isScrollable: events.length > 4,
              tabAlignment: events.length > 4 ? TabAlignment.start : null,
              dividerHeight: 0,
              indicatorColor: ColorManager.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                for (final e in events)
                  Tab(
                    height: 52.h,
                    child: ClipRRect(
                      borderRadius: 8.radius,
                      child: ImageViewWidget(
                        url: e.img,
                        width: 44.w,
                        height: 44.w,
                        boxFit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  for (final e in events)
                    WebViewEvents(url: LiveEventsSheet.eventUrl(e)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

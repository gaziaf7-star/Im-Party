import 'package:general/src/core/index.dart';
import 'package:general/src/features/home/domain/entities/carousel_entity.dart';
import 'package:general/src/features/home/presentation/home/bloc/get_carousel_manager/get_carousel_bloc.dart';
import 'package:general/src/features/live_room/presentation/widgets/live_events_sheet.dart';

/// The Event feed — recharge rewards, weekly room support, and whatever else the
/// panel is running.
///
/// Source is the SAME carousel position the in-live events sheet already reads
/// (`display_at=live`), not a new endpoint: an event is one row in
/// `home_carousels` with an image and a URL, and the operator adds it from
/// Home Carousel Settings. Reusing that position means an event added for the
/// live room shows up here too, with nothing to keep in sync.
///
/// Tapping a card opens the same authenticated webview the live sheet opens, so
/// the event pages get their `token`, `lang`, `base_url` and `bucket_name`
/// exactly as they expect.
class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final bloc = di<GetCarouselBloc>();
    // The live room asks for the same list, so on a warm app this is already
    // loaded and re-requesting it would flash the list back to a spinner.
    if (!bloc.state.liveState.isLoaded) {
      bloc.add(const GetLiveCarouselEvent());
    }
  }

  void _open(CarouselEntity event) {
    final url = LiveEventsSheet.eventUrl(event);
    if (url.isEmpty) return;
    context.pushNamedRoute(
      Routes.webViewEvents,
      arguments: {'url': url, 'type': 'events'},
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<GetCarouselBloc, GetCarouselState>(
      bloc: di<GetCarouselBloc>(),
      buildWhen: (p, c) =>
      p.liveState != c.liveState || p.liveCarousels != c.liveCarousels,
      builder: (context, state) {
        if (state.liveState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.liveCarousels.isEmpty) {
          return _EmptyEvents(
            onRetry: () =>
                di<GetCarouselBloc>().add(const GetLiveCarouselEvent()),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => di<GetCarouselBloc>()
              .add(const GetLiveCarouselEvent(isLoading: false)),
          child: ListView.separated(
            padding: context.paddingSymmetric(horizontal: 14, vertical: 14),
            itemCount: state.liveCarousels.length,
            separatorBuilder: (_, __) => 14.hBox,
            itemBuilder: (context, index) => _EventCard(
              event: state.liveCarousels[index],
              onTap: () => _open(state.liveCarousels[index]),
            ),
          ),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.onTap});

  final CarouselEntity event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: 14.radius,
        child: Container(
          color: ColorManager.surfaceCardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Was AspectRatio(aspectRatio: 2) — width/2, which on a normal
              // phone width comes out noticeably taller than the Home page's
              // own top banner. Fixed to the SAME height Home's CarouselWidget
              // defaults to (110.h) so the two read as the same size banner,
              // per owner request.
              SizedBox(
                height: 110.h,
                width: double.infinity,
                child: ImageViewWidget(
                  url: event.img,
                  boxFit: BoxFit.cover,
                ),
              ),
              if ((event.eventType ?? '').isNotEmpty)
                Padding(
                  padding: context.paddingSymmetric(horizontal: 12, vertical: 10),
                  child: TextWidget(
                    event.eventType!,
                    style: context.bodyMedium.w600
                        .colorExt(ColorManager.textPrimary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty is the normal state on a fresh deployment, not a fault.
///
/// Saying "no events" alone sends the operator looking for a bug in the app;
/// naming the panel screen that fills this list is the difference between a
/// support ticket and a two-minute fix.
class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.paddingSymmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration_outlined,
              size: 56.h,
              color: ColorManager.secondaryText,
            ),
            18.hBox,
            TextWidget(
              StringManager.noDataYet.tr(),
              textAlign: TextAlign.center,
              style: context.bodyLarge.w600.colorExt(ColorManager.textPrimary),
            ),
            10.hBox,
            TextWidget(
              StringManager.noEventsHint.tr(),
              textAlign: TextAlign.center,
              style: context.bodyMedium.colorExt(ColorManager.secondaryText),
            ),
            22.hBox,
            TextButton(
              onPressed: onRetry,
              child: TextWidget(
                StringManager.tryAgain.tr(),
                style: context.bodyMedium.colorExt(ColorManager.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
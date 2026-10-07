import 'package:general/src/features/home/domain/entities/carousel_entity.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../core/index.dart';
import '../../../../domain/entities/room_entity.dart';
import '../../bloc/get_carousel_manager/get_carousel_bloc.dart';
import '../components/carousel_page_view.dart';

class CarouselWidget extends StatefulWidget {
  final String type;
  final String source;
  final bool? isNeedLoadingWidget;

  /// Exact box height. Passed by the home banner, which sizes itself from the
  /// screen width and the artwork's aspect ratio instead of the fixed design
  /// height, so the image covers the box exactly and no page background shows.
  final double? height;

  const CarouselWidget({
    super.key,
    required this.type,
    required this.source,
    this.isNeedLoadingWidget,
    this.height,
  });

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  // Cache translated strings
  late final String _noEventsTitle;
  late final String _noEventsSubtitle;

  // Cache height calculation
  late final double _defaultHeight;

  @override
  void initState() {
    super.initState();
    _noEventsTitle = StringManager.noEventsNow.tr();
    _noEventsSubtitle = StringManager.noEventsNowMsg.tr();
    _defaultHeight = ConstantsManager.isTheme1 ? 100.h : 110.h;
  }

  // Helper to extract carousel data based on source
  ({List<CarouselEntity> list, RequestState state}) _getCarouselData(
      GetCarouselState state) {
    return switch (widget.source) {
      "discover" => (list: state.discoverCarousels, state: state.discoverState),
      "homeMiddle" => (
          list: state.homeMiddleCarousels,
          state: state.reqStateHomeMiddle
        ),
      "live" => (list: state.liveCarousels, state: state.liveState),
      "country" => (list: state.countryCarousels, state: state.countryState),
      _ => (list: state.homeTopCarousels, state: state.reqStateHomeTop),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetCarouselBloc, GetCarouselState>(
      bloc: di<GetCarouselBloc>(),
      buildWhen: (previous, current) {
        // Only rebuild when relevant source data changes
        return switch (widget.source) {
          "discover" =>
            previous.discoverCarousels != current.discoverCarousels ||
                previous.discoverState != current.discoverState,
          "homeMiddle" =>
            previous.homeMiddleCarousels != current.homeMiddleCarousels ||
                previous.reqStateHomeMiddle != current.reqStateHomeMiddle,
          "live" => previous.liveCarousels != current.liveCarousels ||
              previous.liveState != current.liveState,
          "country" => previous.countryCarousels != current.countryCarousels ||
              previous.countryState != current.countryState,
          _ => previous.homeTopCarousels != current.homeTopCarousels ||
              previous.reqStateHomeTop != current.reqStateHomeTop,
        };
      },
      builder: (context, state) {
        final data = _getCarouselData(state);
        final hasData = data.list.isNotEmpty;
        final showLoader = data.state.isLoading;

        if (!hasData && !showLoader) return const SizedBox.shrink();

        final height = (widget.source == "country" && !hasData)
            ? 0.0
            : (widget.height ?? _defaultHeight);

        return SizedBox(
          height: height,
          child: HandlingDataWidget(
            reqState: data.state,
            title: _noEventsTitle,
            subTitle: _noEventsSubtitle,
            childEmpty: const SizedBox.shrink(),
            // Was the generic spinning GradientLoader -- a same-size white
            // shimmer box instead, on request ("banner a hoi nai").
            isNeedLoadingWidget: false,
            child: hasData
                ? CarouselPageView(
                    sliders: data.list,
                    source: widget.source,
                    height: widget.height,
                  )
                : showLoader
                    ? _CarouselShimmer(height: height)
                    : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

/// Same size as the real banner, white shimmer -- shown while the banner
/// carousel is loading, on request.
class _CarouselShimmer extends StatelessWidget {
  const _CarouselShimmer({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.paddingSymmetric(horizontal: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.35),
        highlightColor: Colors.white,
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: 12.radius,
          ),
        ),
      ),
    );
  }
}

class DiscoverCarouselList extends StatefulWidget {
  const DiscoverCarouselList({super.key});

  @override
  State<DiscoverCarouselList> createState() => _DiscoverCarouselListState();
}

class _DiscoverCarouselListState extends State<DiscoverCarouselList> {
  // Cache translated strings
  late final String _noEventsTitle;
  late final String _noEventsSubtitle;

  // Cache screen width
  late final double _screenWidth;

  @override
  void initState() {
    super.initState();
    _noEventsTitle = StringManager.noEventsNow.tr();
    _noEventsSubtitle = StringManager.noEventsNowMsg.tr();
    _screenWidth = ScreenUtil().screenWidth;
  }

  void _handleCarouselTap(BuildContext context, CarouselEntity item) {
    Methods.printLog('item.type ${item.type}');

    switch (item.type) {
      case 'normal':
        break;

      case 'room':
        final roomData = item.myRoomData;
        di<RoomStateManager>().navigateToRoom(
          RoomEntryRequest(
            context: context,
            roomData: RoomEntity(
              passwordStatus: roomData?.passwordStatus,
              ownerId: item.ownerId,
              id: roomData?.id ?? 0,
              name: roomData?.name ?? "",
              cover: roomData?.cover ?? "",
              roomBackground: roomData?.background ?? "",
              mode: roomData?.toString() ?? '',
              uuidOwnerRoom: roomData?.ownerUuid ?? "",
              giftPrice: roomData?.giftPrice ?? "",
            ),
            isLive: false,
          ),
        );
        break;

      case 'link':
        final url = item.url ?? "";
        if (url.contains("wa.me") || url.contains("whatsapp.com")) {
          Methods().whatsAppLink(context, url);
        } else if (context.mounted) {
          Navigator.pushNamed(
            context,
            Routes.webViewEvents,
            arguments: {
              'url': url,
              'type': 'events',
            },
          );
        }
        break;

      case 'event':
        if (!context.mounted || item.url?.isEmpty != false) break;

        final token = Methods.getUserToken();
        final lang = HiveManager().getData<String>(
              KeysManager.USER_BOX,
              KeysManager.LANG_CODE_KEY,
            ) ??
            "en";
        const baseUrl = EndPoints.baseURL;
        final bucketName = EndPoints.storageURL;

        final originalUri = Uri.parse(item.url!);
        final updatedParams =
            Map<String, String?>.from(originalUri.queryParameters);

        updatedParams.putIfAbsent('token', () => token);
        updatedParams.putIfAbsent('lang', () => lang);
        updatedParams.putIfAbsent('base_url', () => baseUrl);
        updatedParams.putIfAbsent('bucket_name', () => bucketName);

        final finalUri = originalUri.replace(queryParameters: updatedParams);

        Navigator.pushNamed(
          context,
          Routes.webViewEvents,
          arguments: {
            'url': finalUri.toString(),
            'type': 'events',
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetCarouselBloc, GetCarouselState>(
      bloc: di<GetCarouselBloc>(),
      buildWhen: (previous, current) =>
          previous.discoverCarousels != current.discoverCarousels ||
          previous.discoverState != current.discoverState,
      builder: (context, state) {
        final sliders = state.discoverCarousels;
        final hasData = sliders.isNotEmpty;

        return HandlingDataWidget(
          reqState: state.discoverState,
          title: _noEventsTitle,
          subTitle: _noEventsSubtitle,
          childEmpty: const SizedBox.shrink(),
          child: hasData
              ? ListView.separated(
                  shrinkWrap: true,
                  padding: context.paddingZero(),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sliders.length,
                  itemBuilder: (context, index) {
                    final item = sliders[index];

                    return RepaintBoundary(
                      child: GestureDetector(
                        onTap: () => _handleCarouselTap(context, item),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: ImageViewWidget(
                            url: item.img,
                            boxFit: BoxFit.fill,
                            width: _screenWidth,
                            height: 110.h,
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => 4.hBox,
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/get_games_images_model.dart';

class DiceGameBody extends StatefulWidget {
  final int randomNum;

  const DiceGameBody({
    super.key,
    required this.randomNum,
  });

  static void clearCache() => _DiceGameBodyState._diceFaceShown.clear();

  @override
  State<DiceGameBody> createState() => _DiceGameBodyState();
}

class _DiceGameBodyState extends State<DiceGameBody>
    with AutomaticKeepAliveClientMixin {
  static final Map<String, bool> _diceFaceShown = {};

  Timer? _timer;
  SvgaDataModel? _displayedData;

  bool get _isShowFinalFace => _diceFaceShown[widget.key.toString()] ?? false;

  set _isShowFinalFace(bool value) {
    _diceFaceShown[widget.key.toString()] = value;
  }

  final List<String> dicNum = [
    AssetsManager.dic1,
    AssetsManager.dic2,
    AssetsManager.dic3,
    AssetsManager.dic4,
    AssetsManager.dic5,
    AssetsManager.dic6,
  ];

  @override
  void initState() {
    super.initState();

    final fallbackJsonString = HiveManager().getData<String>(
      KeysManager.GAMES_BOX,
      KeysManager.GAMES_KEY,
    );
    _displayedData = fallbackJsonString != null
        ? SvgaDataModel.fromJason(jsonDecode(fallbackJsonString))
        : null;

    if (!_isShowFinalFace) {
      _timer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isShowFinalFace = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _diceFaceShown.remove(widget.key.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final displayedData = _displayedData;

    if (displayedData == null) {
      return const LoadingWidget();
    }

    final String img = displayedData.diceModel?.image ?? '';

    return Center(
      child: !_isShowFinalFace
          ? SizedBox(
              width: 35.w,
              height: 35.h,
              child: (img.contains(".svga") ||
                      img.contains(".zz") ||
                      img.contains(".zzz"))
                  ? CacheSvgaWidget(
                      url: img,
                      boxFit: BoxFit.contain,
                    )
                  : img.contains(".svg")
                      ? SvgPicture.network(
                          EndPoints.getImage(img),
                          placeholderBuilder: (context) => const SizedBox(),
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(),
                          fit: BoxFit.contain,
                        )
                      : ImageViewWidget(
                          url: EndPoints.getImage(img),
                          boxFit: BoxFit.contain,
                        ),
            )
          : Image.asset(
              dicNum[widget.randomNum],
              width: 35.w,
              height: 35.h,
            ),
    );

    /* return ValueListenableBuilder<bool>(
      valueListenable: isInPip,
      builder: (context, pipValue, _) {
        if (pipValue && !_isShowFinalFace) {
          return Image.asset(
            widget.image,
            width: 25.w,
            height: 25.h,
          );
        }

        return _isShowFinalFace
            ? Image.asset(
                widget.image,
                width: 25.w,
                height: 25.h,
              )
            : SizedBox(
                width: 40.w,
                height: 40.h,
                child: (img.contains(".svga") ||
                        img.contains(".zz") ||
                        img.contains(".zzz"))
                    ? CacheSVGAWidget(
                        svgaUrl: img,
                        fit: BoxFit.contain,
                        typesCache: TypesCache.other,
                      )
                    : img.contains(".svg")
                        ? SvgPicture.network(
                            EndPoints.getImage(img),
                            placeholderBuilder: (context) => const SizedBox(),
                            height: 100,
                            fit: BoxFit.contain,
                          )
                        : ImageViewWidget(
                            url: EndPoints.getImage(img),
                            boxFit: BoxFit.contain,
                          ),
              );
      },
    );
   */
  }

  @override
  bool get wantKeepAlive => true;
}

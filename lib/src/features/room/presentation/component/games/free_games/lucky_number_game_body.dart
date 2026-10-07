import 'dart:async';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/cache/svga_movie_cache.dart';
import 'package:flutter_svga/flutter_svga.dart';

class LuckyNumberGameBody extends StatefulWidget {
  const LuckyNumberGameBody({
    super.key,
    required this.randomNum,
  });

  final String randomNum;

  @override
  State<LuckyNumberGameBody> createState() => _LuckyNumberGameBodyState();
}

class _LuckyNumberGameBodyState extends State<LuckyNumberGameBody>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  static final Map<String, bool> _luckyNumShown = {};

  Timer? _timer;
  late final SVGAAnimationController _svgaController;

  String get _cacheKey => widget.key?.toString() ?? widget.randomNum;

  bool get _isShowFinalFace => _luckyNumShown[_cacheKey] ?? false;

  set _isShowFinalFace(bool value) {
    _luckyNumShown[_cacheKey] = value;
  }

  final List<String> luckyNum = [
    AssetsManager.luckyNum1,
    AssetsManager.luckyNum2,
    AssetsManager.luckyNum3,
    AssetsManager.luckyNum4,
    AssetsManager.luckyNum5,
    AssetsManager.luckyNum6,
    AssetsManager.luckyNum7,
    AssetsManager.luckyNum8,
    AssetsManager.luckyNum9,
  ];

  @override
  void initState() {
    super.initState();

    _svgaController = SVGAAnimationController(vsync: this);
    _loadSvgaFromAssets();

    if (!_isShowFinalFace) {
      _timer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;

        setState(() {
          _isShowFinalFace = true;
        });
      });
    }
  }

  Future<void> _loadSvgaFromAssets() async {
    final videoItem = await SvgaMovieCache.instance.loadFromAsset(
      AssetsManager.number,
    );

    if (!mounted || videoItem == null) return;

    _svgaController.videoItem = videoItem;
    _svgaController.repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _svgaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final sanitizedNum = widget.randomNum.replaceAll(RegExp(r'[^1-9]'), '');

    return Center(
      child: !_isShowFinalFace
          ? SizedBox(
              height: 35.h,
              child: SVGAImage(_svgaController),
            )
            : Row(
              children: [
                TextWidget(
                  StringManager.luckyNumGame.tr(),
                  style: context.bodySmall.colorExt(ColorManager.textPrimary),
                ),
                10.wBox,
                if (sanitizedNum.isNotEmpty) ...[
                  Image.asset(
                    luckyNum[int.parse(sanitizedNum[0])],
                    scale: 10,
                  ),
                  if (sanitizedNum.length > 1)
                    Image.asset(
                      luckyNum[int.parse(sanitizedNum[1])],
                      scale: 10,
                    ),
                  if (sanitizedNum.length > 2)
                    Image.asset(
                      luckyNum[int.parse(sanitizedNum[2])],
                      scale: 10,
                    ),
                ],
              ],
            ),
  
    );
  }

  @override
  bool get wantKeepAlive => true;
}
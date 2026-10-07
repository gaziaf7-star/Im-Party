import 'dart:async';
import 'dart:convert';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/data/model/get_games_images_model.dart';

class RockPaperScissorsGameBody extends StatefulWidget {
  const RockPaperScissorsGameBody({super.key, required this.randomNum});
  final int randomNum;

  @override
  State<RockPaperScissorsGameBody> createState() =>
      _RockPaperScissorsGameBodyState();
}

class _RockPaperScissorsGameBodyState extends State<RockPaperScissorsGameBody>
    with AutomaticKeepAliveClientMixin {
  static final Map<String, bool> _rpsFaceShown = {};

  Timer? _timer;

  bool get _isShowFinalFace => _rpsFaceShown[widget.key.toString()] ?? false;

  set _isShowFinalFace(bool value) {
    _rpsFaceShown[widget.key.toString()] = value;
  }

  final List<String> brickPaperNum = [
    AssetsManager.brick,
    AssetsManager.paper,
    AssetsManager.scissors,
  ];

  @override
  void initState() {
    super.initState();
    if (!_isShowFinalFace) {
      _timer = Timer(const Duration(seconds: 3), () {
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
    // _rpsFaceShown.remove(widget.key.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final fallbackJsonString = HiveManager().getData<String>(
      KeysManager.GAMES_BOX,
      KeysManager.GAMES_KEY,
    );

    final displayedData = fallbackJsonString != null
        ? SvgaDataModel.fromJason(jsonDecode(fallbackJsonString))
        : null;

    if (displayedData == null) {
      return const LoadingWidget();
    }

    final String img = displayedData.rpsModel?.image ?? '';

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
                  : ImageViewWidget(
                      url: img,
                      boxFit: BoxFit.contain,
                    ),
            )
          : Image.asset(
              brickPaperNum[widget.randomNum],
              width: 35.w,
              height: 35.h,
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

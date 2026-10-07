import 'dart:io';
import 'package:flutter_vap2/flutter_vap.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/core/cache/vap_cache_manager.dart';
import 'package:general/src/features/room/presentation/component/widgets/show_entro_widget.dart';
import 'package:general/src/features/room/presentation/gifts/controller/gift_controller.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';

class CachedVapWidget extends StatefulWidget {
  final String url;
  final double? height, width;
  final bool isLoop;
  final bool isShowGift, isReels;
  final void Function()? detectError;

  const CachedVapWidget({
    required this.url,
    this.height,
    this.width,
    this.detectError,
    this.isLoop = false,
    this.isShowGift = false,
    this.isReels = false,
    super.key,
  });

  @override
  CachedVapWidgetState createState() => CachedVapWidgetState();
}

class CachedVapWidgetState extends State<CachedVapWidget> {
  final VapAssetCacheManager _manager = VapAssetCacheManager();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<bool?> _isError = ValueNotifier<bool?>(false);
  final ValueNotifier<bool> _hiddenVap = ValueNotifier(false);

  late String _cachedFilePath = '';
  VapViewController? _vapViewController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    if (widget.url.isNotEmpty) {
      _loadVap();
    } else {
      widget.detectError?.call();
      _isError.value = true;
      _handleGiftFallback();
    }
  }

  Future<void> _loadVap() async {
    final url = EndPoints.getImage(widget.url);

    Methods.printLog('[VapWidget] Loading VAP: $url');

    _isLoading.value = true;
    _isError.value = null;

    File? file;

    try {
      file = await _manager.getCachedAsset(url);

      if (_isDisposed) return;

      final fileExists = file != null && await file.exists();

      if (_isDisposed) return;

      if (fileExists) {
        _cachedFilePath = file.path;
        _isError.value = null;
        Methods.printLog('[VapWidget] VAP loaded successfully: $_cachedFilePath');
      } else {
        Methods.printLog('[VapWidget] VAP file not found or null');
        widget.detectError?.call();
        _isError.value = true;
        _handleGiftFallback();
      }
    } catch (e) {
      Methods.printLog('[VapWidget] Error loading VAP: $e');
      if (_isDisposed) return;
      widget.detectError?.call();
      _isError.value = true;
      _handleGiftFallback();
    } finally {
      if (!_isDisposed) _isLoading.value = false;
    }
  }

  void _handleGiftFallback() {
    if (GiftController().normalGiftsToShow.isEmpty) return;

    Future.delayed(const Duration(seconds: 3), () {
      if (GiftController().normalGiftsToShow.isEmpty) return;
      GiftController().normalGiftsToShow.removeAt(0);
      final next = GiftController().normalGiftsToShow.isNotEmpty
          ? GiftController().normalGiftsToShow[0]
          : null;

      if (next != null && next['wappel']['wappelImage'] != '') {
        ShowEntroWidget.showEntro.value = next['wappel'];
      }
    });

    Future.delayed(
      const Duration(seconds: 4),
      () {
        if (GiftController().normalGiftsToShow.isEmpty) {
          di<GiftBloc>().add(
            const ShowGiftsEvent(
              pathGift: '',
              isShowGift: false,
              giftType: ShowGiftType.mp4,
            ),
          );
          return;
        }

        final next = GiftController().normalGiftsToShow[0];
        final giftType = next['giftType'];
        final path = next['pathGift'];

        final type = {
          'vap': ShowGiftType.vap,
          'mp4': ShowGiftType.mp4,
          'svga': ShowGiftType.svga
        }[giftType];

        if (giftType == 'alpha') {
          di<AlphaGiftManagerBloc>().add(
            ShowAlphaGift(
              imgFile: path,
              isFamousGift: next['isFamousGift'],
            ),
          );
        } else {
          di<GiftBloc>().add(
            ShowGiftsEvent(
              isShowGift: true,
              pathGift: path,
              giftType: type ?? ShowGiftType.vap,
              isFamousGift: next['isFamousGift'],
            ),
          );
        }

        if (next['wappel']['wappelImage'] != '') {
          ShowEntroWidget.showEntro.value = next['wappel'];
        }
      },
    );
  }

  void _handleNextGift() {
    if (GiftController().normalGiftsToShow.isEmpty) return;

    final next = GiftController().normalGiftsToShow[0];
    final giftType = next['giftType'];
    final path = next['pathGift'];

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (giftType == 'alpha') {
          di<AlphaGiftManagerBloc>().add(
            ShowAlphaGift(
              imgFile: path,
              isFamousGift: next['isFamousGift'],
            ),
          );
        } else {
          final type = {
            'vap': ShowGiftType.vap,
            'mp4': ShowGiftType.mp4,
            'svga': ShowGiftType.svga
          }[giftType];

          di<GiftBloc>().add(
            ShowGiftsEvent(
              isShowGift: true,
              pathGift: path,
              giftType: type ?? ShowGiftType.vap,
              isFamousGift: next['isFamousGift'],
            ),
          );
        }

        if (next['wappel']['wappelImage'] != '') {
          ShowEntroWidget.showEntro.value = next['wappel'];
        }
      },
    );
  }

  @override
  void didUpdateWidget(CachedVapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _vapViewController?.stop();
      _vapViewController = null;
      _loadVap();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isLoading.dispose();
    _isError.dispose();
    _hiddenVap.dispose();
    _vapViewController?.stop();
    _vapViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) return const SizedBox.shrink();

        return _cachedFilePath.isEmpty
            ? const SizedBox()
            : ValueListenableBuilder<bool?>(
                valueListenable: _isError,
                builder: (context, isError, _) {
                  if (isError == true) {
                    return const SizedBox.shrink();
                  }

                  return ValueListenableBuilder<bool>(
                    valueListenable: _hiddenVap,
                    builder: (context, shouldHide, _) {
                      if (shouldHide) return const SizedBox.shrink();

                      return SizedBox(
                        width: widget.width ?? double.infinity,
                        height: widget.height,
                        child: VapView(
                          scaleType: 0,
                          playLoop: widget.isLoop ? 100 : 0,
                          onVapViewCreated: (controller) {
                            _vapViewController = controller;
                            _vapViewController
                                ?.playPath(_cachedFilePath)
                                .whenComplete(
                              () {
                                _vapViewController?.stop();
                                _vapViewController = null;
                                _hiddenVap.value = true;

                                di<GiftBloc>().add(
                                  const ShowGiftsEvent(
                                    pathGift: "",
                                    isShowGift: false,
                                    giftType: ShowGiftType.vap,
                                  ),
                                );

                                if (GiftController()
                                    .normalGiftsToShow
                                    .isNotEmpty) {
                                  GiftController()
                                      .normalGiftsToShow
                                      .removeAt(0);
                                  Future.delayed(
                                    const Duration(milliseconds: 10),
                                    () {
                                      if (GiftController()
                                          .normalGiftsToShow
                                          .isEmpty) {
                                        di<GiftBloc>().add(
                                          const ShowGiftsEvent(
                                            pathGift: "",
                                            isShowGift: false,
                                            giftType: ShowGiftType.vap,
                                          ),
                                        );
                                      } else {
                                        _handleNextGift();
                                      }
                                    },
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
      },
    );
  }

  Future<void> endWidget() async {
    await Future.microtask(
      () {
        di<GiftBloc>().add(const SetVideoVisibilityEvent(isVisible: false));
        di<GiftBloc>().add(
          const ShowGiftsEvent(
            pathGift: '',
            isShowGift: false,
            giftType: ShowGiftType.mp4,
          ),
        );

        if (GiftController().normalGiftsToShow.isNotEmpty) {
          GiftController().normalGiftsToShow.removeAt(0);
          if (GiftController().normalGiftsToShow.isEmpty) {
            di<GiftBloc>().add(
              const ShowGiftsEvent(
                pathGift: '',
                isShowGift: false,
                giftType: ShowGiftType.mp4,
              ),
            );
          } else {
            final next = GiftController().normalGiftsToShow[0];
            Future.delayed(
              const Duration(microseconds: 50),
              () {
                di<GiftBloc>().add(
                  ShowGiftsEvent(
                    isShowGift: true,
                    pathGift: next['pathGift'],
                    isFamousGift: next['isFamousGift'],
                    giftType: ShowGiftType.svga,
                  ),
                );
              },
            );
          }
        }

        _hiddenVap.value = true;
      },
    );
  }
}

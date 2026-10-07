import 'package:general/src/core/cache/asset_preview_prefetch.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';
import 'package:general/src/features/mall_bag/presentation/mall/bloc/mall_send_bloc/mall_send_bloc.dart';
import '../../../../../core/widgets/md_indicator.dart';
import '../../../../profile/presentation/coins/bloc/my_store_bloc/my_store_bloc.dart';
import '../../bag/view/widgets/send_bottom_sheet.dart';
import '../../component/custom_model_bottom_sheet.dart';

part '../../component/mall_tab_bar_item.dart';
part 'components/mall_tab_bar.dart';
part 'components/mall_tab_bar_view.dart';
part 'widgets/mall_product_item.dart';

class MallPage extends StatefulWidget {
  final int? index;

  const MallPage({this.index, super.key});

  @override
  State<MallPage> createState() => _MallPageState();
}

class _MallPageState extends State<MallPage> with TickerProviderStateMixin {
  static const Color _pageBg = Color(0xFF170F1A);
  static const Color _cardTop = Color(0xFF2C195E);
  static const Color _cardBottom = Color(0xFF171124);
  static const Color _softPurple = Color(0xFF6A4BB2);
  static const Color _cyan = Color(0xFF38E8FF);

  late TabController controller;
  final MallBloc _mallBloc = di<MallBloc>();

  late int _activeIndex;
  late bool _showLanding;

  @override
  void initState() {
    super.initState();

    final requestedIndex = widget.index ?? 0;
    _activeIndex = requestedIndex < 0
        ? 0
        : requestedIndex > 4
        ? 4
        : requestedIndex;
    _showLanding = true;

    controller = TabController(
      length: 5,
      vsync: this,
      initialIndex: _activeIndex,
    );

    di<MallBloc>().add(ChangeAppBarUIMallEvent(index: _activeIndex));

  }

  @override
  void dispose() {
    controller.dispose();
    di<MallBloc>().add(const ChangeAppBarUIMallEvent(index: 0));
    super.dispose();
  }

  Future<bool> _handleBack() async {
    if (!_showLanding) {
      setState(() => _showLanding = true);
      return false;
    }
    return true;
  }

  void _openCategory(int index) {
    final safeIndex = index < 0
        ? 0
        : index > 4
        ? 4
        : index;

    if (controller.index != safeIndex) {
      controller.index = safeIndex;
    }

    setState(() {
      _activeIndex = safeIndex;
      _showLanding = false;
    });

    di<MallBloc>().add(ChangeAppBarUIMallEvent(index: safeIndex));
    _ensureCategoryLoaded(safeIndex, showLoading: true);
  }

  void _ensureCategoryLoaded(int index, {bool showLoading = false}) {
    final state = _mallBloc.state;

    switch (index) {
      case 0:
        if (state.bubbleMallRequest != RequestState.loaded) {
          _mallBloc.add(GetBubbleMallEvent(isLoading: showLoading));
        }
        break;
      case 1:
        if (state.frameMallRequest != RequestState.loaded) {
          _mallBloc.add(GetFramesMallEvent(isLoading: showLoading));
        }
        break;
      case 2:
        if (state.carMallRequest != RequestState.loaded) {
          _mallBloc.add(GetCarMallEvent(isLoading: showLoading));
        }
        break;
      case 3:
        if (state.emojisMallRequest != RequestState.loaded) {
          _mallBloc.add(GetSpecialIdMallEvent(isLoading: showLoading));
        }
        break;
      case 4:
        if (state.profileFramesMallRequest != RequestState.loaded) {
          _mallBloc.add(GetProfileFramesMallEvent(isLoading: showLoading));
        }
        break;
    }
  }

  String _categoryTitle(BuildContext context, int index) {
    switch (index) {
      case 0:
        return StringManager.bubble.tr();
      case 1:
        return StringManager.frames.tr();
      case 2:
        return StringManager.entries.tr();
      case 3:
        return StringManager.specialId.tr();
      case 4:
        return StringManager.profileFrame.tr();
      default:
        return StringManager.store.tr();
    }
  }

  MallOrBagType _categoryType(int index) {
    switch (index) {
      case 0:
        return MallOrBagType.bubble;
      case 1:
        return MallOrBagType.frame;
      case 2:
        return MallOrBagType.intro;
      case 3:
        return MallOrBagType.specialId;
      case 4:
        return MallOrBagType.profileFrame;
      default:
        return MallOrBagType.bubble;
    }
  }

  String _categoryImage(int index) {
    switch (index) {
      case 0:
        return 'assets/icons/Babuel.png';
      case 1:
        return 'assets/icons/Frame (2).png';
      case 2:
        return 'assets/icons/entryCar.png';
      case 3:
        return 'assets/icons/spasialId.png';
      case 4:
        return 'assets/icons/profileCard.png';
      default:
        return 'assets/icons/Babuel.png';
    }
  }

  Widget _buildLanding(BuildContext context) {
    final categories = List<int>.generate(5, (index) => index);
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight + 8.h;

    return Stack(
      key: const ValueKey('mall_landing'),
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/icons/Mall bgoImage.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.04),
                  const Color(0xFF120C1A).withValues(alpha: 0.16),
                  const Color(0xFF120C1A).withValues(alpha: 0.34),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            14.w,
            topInset,
            14.w,
            22.h,
          ),
          children: [
            _BackpackHeroCard(
              imagePath: 'assets/icons/backpackimage.png',
              onTap: () => Navigator.pushNamed(context, Routes.bagScreen),
            ),
            16.hBox,
            TextWidget(
              StringManager.purchaseItems.tr(),
              style: context.bodyLarge
                  .size(17)
                  .bold
                  .colorExt(Colors.white),
            ),
            10.hBox,
            GridView.builder(
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.96,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
              ),
              itemBuilder: (context, index) {
                final categoryIndex = categories[index];
                return _MallCategoryCard(
                  title: _categoryTitle(context, categoryIndex),
                  imagePath: _categoryImage(categoryIndex),
                  onTap: () => _openCategory(categoryIndex),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCatalog(BuildContext context, GetDataMallStates state) {
    final index = _activeIndex;
    final type = _categoryType(index);

    switch (index) {
      case 0:
        return HandlingDataWidget(
          key: const ValueKey('mall_bubble_catalog'),
          title: StringManager.tittleEmptySpecialId.tr(),
          subTitle: StringManager.subTittleEmptySpecialId.tr(),
          reqState: state.bubbleMallRequest,
          isNeedLoadingWidget: true,
          onTap: () => _mallBloc.add(const GetBubbleMallEvent()),
          child: _MallTabBarView(
            mall: state.bubblesMall,
            tabType: type,
            isLoading: state.bubbleMallRequest.isLoading,
          ),
        );
      case 1:
        return HandlingDataWidget(
          key: const ValueKey('mall_frame_catalog'),
          title: StringManager.tittleEmptyFrame.tr(),
          subTitle: StringManager.subTittleEmptyFrame.tr(),
          reqState: state.frameMallRequest,
          isNeedLoadingWidget: true,
          onTap: () => _mallBloc.add(const GetFramesMallEvent()),
          child: _MallTabBarView(
            mall: state.framesMall,
            tabType: type,
            isLoading: state.frameMallRequest.isLoading,
          ),
        );
      case 2:
        return HandlingDataWidget(
          key: const ValueKey('mall_entry_catalog'),
          title: StringManager.tittleEmptyIntro.tr(),
          subTitle: StringManager.subTittleEmptyIntro.tr(),
          reqState: state.carMallRequest,
          isNeedLoadingWidget: true,
          onTap: () => _mallBloc.add(const GetCarMallEvent()),
          child: _MallTabBarView(
            mall: state.carsMall,
            tabType: type,
            isLoading: state.carMallRequest.isLoading,
          ),
        );
      case 3:
        return HandlingDataWidget(
          key: const ValueKey('mall_special_id_catalog'),
          title: StringManager.tittleEmptySpecialId.tr(),
          subTitle: StringManager.subTittleEmptySpecialId.tr(),
          reqState: state.emojisMallRequest,
          isNeedLoadingWidget: true,
          onTap: () => _mallBloc.add(const GetSpecialIdMallEvent()),
          child: _MallTabBarView(
            mall: state.emojisMall,
            tabType: type,
            isLoading: state.emojisMallRequest.isLoading,
          ),
        );
      case 4:
        return HandlingDataWidget(
          key: const ValueKey('mall_profile_frame_catalog'),
          title: StringManager.tittleEmptyProfileFrame.tr(),
          subTitle: StringManager.subTittleEmptyProfileFrame.tr(),
          reqState: state.profileFramesMallRequest,
          isNeedLoadingWidget: true,
          onTap: () => _mallBloc.add(const GetProfileFramesMallEvent()),
          child: _MallTabBarView(
            mall: state.profileFramesMall,
            tabType: type,
            isLoading: state.profileFramesMallRequest.isLoading,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MallSendBloc, MallSendState>(
      bloc: di<MallSendBloc>(),
      listener: (context, state) {
        if (state is SendSuccessState) {
          Methods.showToast(context, message: state.message);
        } else if (state is SendErrorState) {
          Methods.showToast(context, message: state.message, isError: true);
        } else if (state is SendLoadingState) {
          Methods.showToast(context, isLoading: true);
        }
      },
      child: BlocListener<MallBuyBloc, MallBuyState>(
        bloc: di<MallBuyBloc>(),
        listener: (_, state) {
          if (state is BuySuccessState) {
            Methods.showToast(context, message: state.massage);
          } else if (state is BuyErrorState) {
            Methods.showToast(context, message: state.massage, isError: true);
          } else if (state is BuyLoadingState) {
            Methods.showToast(context, isLoading: true);
          }
        },
        child: BlocBuilder<MallBloc, GetDataMallStates>(
          bloc: _mallBloc,
          buildWhen: (prev, curr) =>
          prev.bubbleMallRequest != curr.bubbleMallRequest ||
              prev.bubblesMall != curr.bubblesMall ||
              prev.frameMallRequest != curr.frameMallRequest ||
              prev.framesMall != curr.framesMall ||
              prev.carMallRequest != curr.carMallRequest ||
              prev.carsMall != curr.carsMall ||
              prev.emojisMallRequest != curr.emojisMallRequest ||
              prev.emojisMall != curr.emojisMall ||
              prev.profileFramesMallRequest != curr.profileFramesMallRequest ||
              prev.profileFramesMall != curr.profileFramesMall ||
              prev.selectedItem != curr.selectedItem,
          builder: (context, state) {
            return WillPopScope(
              onWillPop: _handleBack,
              child: Scaffold(
                backgroundColor: _pageBg,
                extendBodyBehindAppBar: true,
                appBar: AppBarWidget(
                  backgroundColor: Colors.transparent,
                  shadow: Colors.transparent,
                  iconColor: Colors.white,
                  title: _showLanding
                      ? StringManager.store.tr()
                      : _categoryTitle(context, _activeIndex),
                  titleStyle: context.titleLarge
                      .size(20)
                      .bold
                      .colorExt(Colors.white),
                  onLeadingPressed: () async {
                    if (!_showLanding) {
                      setState(() => _showLanding = true);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                body: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 230),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _showLanding
                      ? _buildLanding(context)
                      : KeyedSubtree(
                    key: ValueKey('catalog_$_activeIndex'),
                    child: _buildCatalog(context, state),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BackpackHeroCard extends StatelessWidget {
  const _BackpackHeroCard({
    required this.imagePath,
    required this.onTap,
  });

  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 320),
      tween: Tween(begin: 0.98, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Ink(
            height: 145.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF32205B),
                  Color(0xFF281A49),
                  Color(0xFF1B142B),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF7652B8).withValues(alpha: 0.70),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A2C7A).withValues(alpha: 0.18),
                  blurRadius: 20.r,
                  offset: Offset(0, 7.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                children: [
                  Positioned(
                    left: -42.w,
                    top: -46.h,
                    child: Container(
                      width: 175.w,
                      height: 175.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B8DFF)
                                .withValues(alpha: 0.20),
                            blurRadius: 62.r,
                            spreadRadius: 8.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -3.w,
                    top: 2.h,
                    bottom: -5.h,
                    width: 172.w,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerRight,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  Positioned(
                    left: 20.w,
                    top: 30.h,
                    right: 156.w,
                    child: TextWidget(
                      StringManager.myProps.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.titleLarge
                          .size(21)
                          .w600
                          .colorExt(Colors.white),
                    ),
                  ),
                  Positioned(
                    left: 20.w,
                    top: 82.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 13.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF071B26).withValues(alpha: 0.76),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: const Color(0xFF42E7FF),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF42E7FF)
                                .withValues(alpha: 0.28),
                            blurRadius: 12.r,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWidget(
                            StringManager.watch.tr(),
                            style: context.bodyMedium
                                .size(13)
                                .w600
                                .colorExt(const Color(0xFF68F2FF)),
                          ),
                          4.wBox,
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 15.h,
                            color: const Color(0xFF68F2FF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MallCategoryCard extends StatelessWidget {
  const _MallCategoryCard({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  final String title;
  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 260),
      tween: Tween(begin: 0.97, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17.r),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF32205B),
                  Color(0xFF281A49),
                  Color(0xFF1B142B),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF7652B8).withValues(alpha: 0.62),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 13.r,
                  offset: Offset(0, 5.h),
                ),
                BoxShadow(
                  color: const Color(0xFF5A35D5).withValues(alpha: 0.07),
                  blurRadius: 18.r,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17.r),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.2, -0.45),
                            radius: 0.9,
                            colors: [
                              const Color(0xFF7540EE)
                                  .withValues(alpha: 0.16),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    right: 6.w,
                    bottom: 34.h,
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_not_supported_outlined,
                          size: 42.h,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8.w,
                    right: 8.w,
                    bottom: 11.h,
                    child: TextWidget(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium
                          .size(13)
                          .bold
                          .colorExt(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


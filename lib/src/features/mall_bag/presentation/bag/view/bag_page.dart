import 'package:general/src/core/cache/asset_preview_prefetch.dart';
import 'package:general/src/core/index.dart';
import 'package:general/src/features/mall_bag/mall_bag.dart';
import 'package:general/src/features/mall_bag/presentation/bag/view/widgets/send_bottom_sheet.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/widgets/md_indicator.dart';
import '../../component/custom_model_bottom_sheet.dart';

part '../view/components/bag_tab_bar.dart';
part '../view/components/bag_tab_bar_view.dart';
part '../view/widgets/bag_product_item.dart';

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  static const Color _pageBg = Color(0xFF170F1A);

  final MyBagBloc _bloc = di<MyBagBloc>();

  int _activeIndex = 0;
  bool _showLanding = true;

  @override
  void initState() {
    super.initState();
    di<MyBagBloc>().add(const ChangeAppBarUIEvent(index: 0));
  }

  @override
  void dispose() {
    di<MyBagBloc>().add(const ChangeAppBarUIEvent(index: 0));
    di<MyBagBloc>().add(const SelectBagItemEvent(selectedItem: null));
    super.dispose();
  }

  Future<bool> _handleBack() async {
    if (!_showLanding) {
      setState(() => _showLanding = true);
      return false;
    }
    return true;
  }

  void _openMall() {
    Navigator.pushReplacementNamed(
      context,
      Routes.mallScreen,
      arguments: 0,
    );
  }

  void _openCategory(int index) {
    setState(() {
      _activeIndex = index;
      _showLanding = false;
    });

    di<MyBagBloc>().add(ChangeAppBarUIEvent(index: index));
    _ensureLoaded(index, showLoading: true);
  }

  void _ensureLoaded(int index, {bool showLoading = false}) {
    final state = _bloc.state;

    switch (index) {
      case 0:
        if (state.bubbleBagRequest != RequestState.loaded) {
          _bloc.add(GetBubbleBackPackMyBagEvent(isLoading: showLoading));
        }
        break;
      case 1:
        if (state.frameBagRequest != RequestState.loaded) {
          _bloc.add(GetFramesMyBagEvent(isLoading: showLoading));
        }
        break;
      case 2:
        if (state.carBagRequest != RequestState.loaded) {
          _bloc.add(GetEntrieMyBagEvent(isLoading: showLoading));
        }
        break;
      case 3:
        if (state.emojisBagRequest != RequestState.loaded) {
          _bloc.add(GetSpecialIdMyBagEvent(isLoading: showLoading));
        }
        break;
      case 4:
        if (state.profileFrameRequest != RequestState.loaded) {
          _bloc.add(GetProfileFrameMyBagEvent(isLoading: showLoading));
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
        return 'Backpack';
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

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/icons/Mall bgoImage.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.03),
                  const Color(0xFF120C1A).withValues(alpha: 0.16),
                  const Color(0xFF120C1A).withValues(alpha: 0.36),
                ],
                stops: const [0.0, 0.50, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanding(BuildContext context) {
    final topInset =
        MediaQuery.of(context).padding.top + kToolbarHeight + 6.h;

    return Stack(
      key: const ValueKey('bag_landing'),
      children: [
        _buildBackground(),
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            14.w,
            topInset,
            14.w,
            24.h,
          ),
          children: [
            TextWidget(
              'My items',
              isTranslate: false,
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
              itemCount: 5,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.96,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
              ),
              itemBuilder: (context, index) {
                return _BagCategoryCard(
                  title: _categoryTitle(context, index),
                  imagePath: _categoryImage(index),
                  onTap: () => _openCategory(index),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategory(
      BuildContext context,
      MyBagState state,
      ) {
    final type = _categoryType(_activeIndex);

    switch (_activeIndex) {
      case 0:
        return HandlingDataWidget(
          key: const ValueKey('bag_bubble_catalog'),
          isNeedLoadingWidget: true,
          reqState: state.bubbleBagRequest,
          title: StringManager.titleEmptyBubbles.tr(),
          subTitle: StringManager.subEmptyBubbles.tr(),
          onTap: () =>
              _bloc.add(const GetBubbleBackPackMyBagEvent()),
          child: BagTabBarView(
            bagList: state.bubblesBag,
            selectedItem: state.selectedItemBubble,
            tabType: type,
            isLoading: state.bubbleBagRequest.isLoading,
          ),
        );

      case 1:
        return HandlingDataWidget(
          key: const ValueKey('bag_frame_catalog'),
          isNeedLoadingWidget: true,
          reqState: state.frameBagRequest,
          title: StringManager.titleEmptyFrame.tr(),
          subTitle: StringManager.subEmptyFrame.tr(),
          onTap: () => _bloc.add(const GetFramesMyBagEvent()),
          child: BagTabBarView(
            bagList: state.framesBag,
            selectedItem: state.selectedItemFrame,
            tabType: type,
            isLoading: state.frameBagRequest.isLoading,
          ),
        );

      case 2:
        return HandlingDataWidget(
          key: const ValueKey('bag_entry_catalog'),
          isNeedLoadingWidget: true,
          reqState: state.carBagRequest,
          title: StringManager.titleEmptyCar.tr(),
          subTitle: StringManager.subEmptyCar.tr(),
          onTap: () => _bloc.add(const GetEntrieMyBagEvent()),
          child: BagTabBarView(
            bagList: state.carsBag,
            selectedItem: state.selectedItemIntro,
            tabType: type,
            isLoading: state.carBagRequest.isLoading,
          ),
        );

      case 3:
        return HandlingDataWidget(
          key: const ValueKey('bag_special_id_catalog'),
          isNeedLoadingWidget: true,
          reqState: state.emojisBagRequest,
          title: StringManager.tittleEmptyProfileFrame.tr(),
          subTitle: StringManager.subTittleEmptyProfileFrame.tr(),
          onTap: () => _bloc.add(const GetSpecialIdMyBagEvent()),
          child: BagTabBarView(
            bagList: state.emojisBag,
            selectedItem: state.selectedItemSpecialId,
            tabType: type,
            isLoading: state.emojisBagRequest.isLoading,
          ),
        );

      case 4:
        return HandlingDataWidget(
          key: const ValueKey('bag_profile_frame_catalog'),
          isNeedLoadingWidget: true,
          reqState: state.profileFrameRequest,
          title: StringManager.tittleEmptyProfileFrame.tr(),
          subTitle: StringManager.subTittleEmptyProfileFrame.tr(),
          onTap: () => _bloc.add(const GetProfileFrameMyBagEvent()),
          child: BagTabBarView(
            bagList: state.profileFrames,
            selectedItem: state.selectedItemProfileFrame,
            tabType: type,
            isLoading: state.profileFrameRequest.isLoading,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBagBloc, MyBagState>(
      bloc: _bloc,
      buildWhen: (prev, curr) =>
      prev.bubbleBagRequest != curr.bubbleBagRequest ||
          prev.bubblesBag != curr.bubblesBag ||
          prev.selectedItemBubble != curr.selectedItemBubble ||
          prev.frameBagRequest != curr.frameBagRequest ||
          prev.framesBag != curr.framesBag ||
          prev.selectedItemFrame != curr.selectedItemFrame ||
          prev.carBagRequest != curr.carBagRequest ||
          prev.carsBag != curr.carsBag ||
          prev.selectedItemIntro != curr.selectedItemIntro ||
          prev.emojisBagRequest != curr.emojisBagRequest ||
          prev.emojisBag != curr.emojisBag ||
          prev.selectedItemSpecialId != curr.selectedItemSpecialId ||
          prev.profileFrameRequest != curr.profileFrameRequest ||
          prev.profileFrames != curr.profileFrames ||
          prev.selectedItemProfileFrame != curr.selectedItemProfileFrame,
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
                  ? 'Backpack'
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
              actions: [
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 10.w),
                  child: TextButton(
                    onPressed: _openMall,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 7.h,
                      ),
                      backgroundColor:
                      Colors.white.withValues(alpha: 0.10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                        side: BorderSide(
                          color: const Color(0xFF6EEBFF)
                              .withValues(alpha: 0.62),
                        ),
                      ),
                    ),
                    child: Text(
                      'Mall',
                      style: TextStyle(
                        color: const Color(0xFF70EEFF),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _showLanding
                  ? _buildLanding(context)
                  : Stack(
                key: ValueKey('bag_catalog_$_activeIndex'),
                children: [
                  _buildBackground(),
                  Positioned.fill(
                    child: _buildCategory(context, state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BagCategoryCard extends StatelessWidget {
  const _BagCategoryCard({
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
      duration: const Duration(milliseconds: 240),
      tween: Tween(begin: 0.97, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
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
                color: const Color(0xFF7652B8)
                    .withValues(alpha: 0.62),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 13.r,
                  offset: Offset(0, 5.h),
                ),
                BoxShadow(
                  color: const Color(0xFF5A35D5)
                      .withValues(alpha: 0.07),
                  blurRadius: 18.r,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17.r),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.2, -0.42),
                          radius: 0.95,
                          colors: [
                            const Color(0xFF7540EE)
                                .withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
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

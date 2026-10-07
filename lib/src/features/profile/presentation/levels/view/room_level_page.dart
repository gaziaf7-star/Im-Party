import 'package:general/src/core/index.dart';
import 'package:general/src/features/room/presentation/gifts/gift.dart';
import '../bloc/levels_bloc/levels_bloc.dart';
import '../bloc/levels_bloc/levels_event.dart';
import '../bloc/levels_bloc/levels_state.dart';
import '../../../domain/entities/level_badges_entity.dart'
    show RoomLevelBadgeEntity;
// Reuses the shared, already-professional "My Level" card (white
// scaffold/appbar, gradient level header with the user's avatar + progress
// bar) instead of this page's own flat dark-green card -- on request, this
// page's design should match My Level's, not have its own separate look.
// `LevelCard` is declared in a part file of level_page.dart but, since Dart
// part declarations belong to the library's *defining* file, importing
// level_page.dart itself is enough to use it here.
import 'level_page.dart' show LevelCard;

class RoomLevelPage extends StatefulWidget {
  const RoomLevelPage({super.key});

  @override
  State<RoomLevelPage> createState() => _RoomLevelPageState();
}

class _RoomLevelPageState extends State<RoomLevelPage> {
  @override
  void initState() {
    di<LevelBloc>().add(GetUserLevels());
    di<LevelBloc>().add(GetRoomLevelBadges());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final normalPage = BlocBuilder<LevelBloc, AllLevelsState>(
      bloc: di<LevelBloc>(),
      buildWhen: (prev, curr) =>
      prev.roomLevelBadgesRequest != curr.roomLevelBadgesRequest ||
          prev.userLevels != curr.userLevels,
      builder: (context, state) {
        return MediaQuery(
          data: MediaQueryData.fromView(View.of(context)),
          child: Scaffold(
            // White scaffold + black appbar, matching My Level's page shell
            // exactly (was a dark `ColorManager.bgLevel` page before).
            backgroundColor: ColorManager.white,
            appBar: AppBarWidget(
              title: StringManager.roomLevel.tr(),
              iconColor: ColorManager.black,
              backgroundColor: ColorManager.white,
              titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
            ),
            body: HandlingDataWidget(
              titleStyle: context.bodyLarge.colorExt(ColorManager.black),
              reqState: state.roomLevelBadgesRequest,
              title: StringManager.noLevels.tr(),
              subTitle: StringManager.noLevelsMsg.tr(),
              onTap: () {
                di<LevelBloc>().add(GetUserLevels());
                di<LevelBloc>().add(GetRoomLevelBadges());
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Same gradient level card the My Level page's own tabs
                    // use ("room" already has its own theme/data wiring
                    // inside LevelCard) instead of a bespoke flat card.
                    LevelCard(
                      type: "room",
                      isSender: false,
                      color: ColorManager.green,
                      text: StringManager.room.tr(),
                    ),
                    Padding(
                      padding: context.paddingAll(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            StringManager.roomLevelDescription.tr(),
                            style: context.bodyMedium
                                .colorExt(ColorManager.black)
                                .size(15)
                                .w600,
                          ),
                          10.hBox,
                          TextWidget(
                            StringManager.roomLevelDescriptionBody.tr(),
                            style: context.bodyMedium.size(15).colorExt(
                                ColorManager.black.withValues(alpha: 0.65)),
                          ),
                        ],
                      ),
                    ),
                    20.hBox,
                    _RoomLevelRangeTable(data: state.roomLevelBadges),
                    20.hBox,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return normalPage;
  }
}

/// The level → badge breakdown, styled as a clean bordered white table
/// (was a dark navy panel) -- matches `_LevelRangeTable` in
/// `components/level_view.dart` (My Level's Wealth tab), recreated here
/// rather than reused directly since that class is private to the
/// level_page.dart library.
class _RoomLevelRangeTable extends StatelessWidget {
  const _RoomLevelRangeTable({required this.data});

  final List<RoomLevelBadgeEntity> data;

  // Same green/teal tone LevelCard uses for the "room" type internally, so
  // this table reads as one design with the card above it.
  static const Color _trackColor = Color(0xFFE3FBF0);
  static const Color _textColor = Color(0xFF065F46);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: context.paddingSymmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: 16.radius,
        border: Border.all(color: ColorManager.grey2.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: context.paddingSymmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: _trackColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  StringManager.theLevel.tr(),
                  style: context.bodyMedium.w600.colorExt(_textColor),
                ),
                Text(
                  StringManager.icLevel.tr(),
                  style: context.bodyMedium.w600.colorExt(_textColor),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var item = index % 2 == 0;
              return Container(
                padding:
                context.paddingSymmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: item
                      ? ColorManager.white
                      : _trackColor.withValues(alpha: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "${data[index].level}",
                      style: context.bodyMedium.copyWith(
                        color: ColorManager.black,
                        fontSize: 16,
                      ),
                    ),
                    ImageViewWidget(
                      url: data[index].badge ?? "",
                      width: 70.w,
                      height: 25.h,
                      boxFit: BoxFit.contain,
                    ),
                  ],
                ),
              );
            },
            itemCount: data.length,
          ),
        ],
      ),
    );
  }
}
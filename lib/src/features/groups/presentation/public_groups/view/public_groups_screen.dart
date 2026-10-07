import 'package:general/src/core/index.dart';
import 'package:general/src/features/groups/domain/entities/group_entity.dart';
import 'package:general/src/features/groups/domain/repository/groups_repository.dart';
import 'package:general/src/features/groups/presentation/groups_list/bloc/groups_list_bloc.dart';

/// Browse + join PUBLIC groups (chat rebuild §4). Lists `privacy=public` groups
/// from the server; tapping "انضمام" joins an open group then opens its chat.
/// Private/invite-only groups never appear here.
class PublicGroupsScreen extends StatefulWidget {
  const PublicGroupsScreen({super.key});

  @override
  State<PublicGroupsScreen> createState() => _PublicGroupsScreenState();
}

class _PublicGroupsScreenState extends State<PublicGroupsScreen> {
  final GroupsRepository _repo = di<GroupsRepository>();
  final TextEditingController _search = TextEditingController();

  RequestState _state = RequestState.loading;
  List<GroupEntity> _groups = const [];
  int? _joiningId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({String? query}) async {
    setState(() => _state = RequestState.loading);
    final result = await _repo.fetchPublicGroups(query: query);
    if (!mounted) return;
    result.fold(
          (l) => setState(() => _state = RequestState.error),
          (r) {
        final list = r.data ?? const <GroupEntity>[];
        setState(() {
          _groups = list;
          _state = list.isEmpty ? RequestState.empty : RequestState.loaded;
        });
      },
    );
  }

  Future<void> _join(GroupEntity group) async {
    setState(() => _joiningId = group.id);
    final result = await _repo.joinPublicGroup(group.id);
    if (!mounted) return;
    setState(() => _joiningId = null);
    result.fold(
          (l) => Methods.showToast(context,
          isError: true, message: NetworkExceptions.getErrorMessage(l)),
          (r) {
        final joined = r.data ?? group;
        // The groups list is event-driven (not drift-reactive): tell it about the
        // new membership so the group shows up immediately, matching the invite
        // and group-info join paths. Without this the joined group only appears
        // after a manual refresh / app relaunch.
        di<GroupsListBloc>().add(UpsertGroupLocallyEvent(joined));
        context.pushReplacementNamedRoute(
          Routes.groupChatDetailScreen,
          arguments: joined,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fixed white + brand-gradient app bar (was wrapped in the panel-driven
      // BackgroundImgWidget/transparent app bar) — matches the professional
      // look used across the app.
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        title: StringManager.publicGroupsTitle.tr(),
        backgroundGradient: ColorManager.brandGradient,
        titleStyle: context.titleLarge.w600
            .size(16)
            .colorExt(ColorManager.onBrandGradient),
        iconColor: ColorManager.onBrandGradient,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: context.paddingSymmetric(horizontal: 12, vertical: 8),
              child: TextInputWidget(
                StringManager.search.tr(),
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: (q) => _load(query: q),
                fillColor: ColorManager.white,
                border: OutlineInputBorder(borderRadius: 30.radius),
                focusedBorder: OutlineInputBorder(borderRadius: 30.radius),
                enabledBorder: OutlineInputBorder(borderRadius: 30.radius),
                prefixIcon: Icon(Icons.search,
                    color: ColorManager.grey.withValues(alpha: 0.4)),
                textColor: ColorManager.momentPostTextColor,
                // Fixed dark hint + brand cursor (was defaulting to
                // secondaryText/textPrimary, which the panel can override) —
                // guarantees the placeholder and caret both stay visible on
                // this white field.
                hintStyle: context.bodyMedium.colorExt(
                    ColorManager.momentPostTextColor.withValues(alpha: 0.5)),
                cursorColor: ColorManager.brandGradientColors.last,
              ),
            ),
            Expanded(
              child: HandlingDataWidget(
                reqState: _state,
                title: StringManager.noPublicGroups.tr(),
                subTitle: StringManager.noPublicGroupsHint.tr(),
                titleStyle: context.bodyLarge
                    .colorExt(ColorManager.momentPostTextColor)
                    .w600,
                subTitleStyle: context.bodyMedium
                    .colorExt(ColorManager.momentPostTextColor),
                buttonBackgroundColors: ColorManager.brandGradientColors,
                buttonBorderColor: ColorManager.transparent,
                onTap: () => _load(query: _search.text),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: context.paddingSymmetric(vertical: 8),
                  itemCount: _groups.length,
                  itemBuilder: (_, i) => _tile(_groups[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(GroupEntity group) {
    final joining = _joiningId == group.id;
    return Padding(
      padding: context.paddingSymmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          UserImage(
            imageSize: 52.w,
            image: group.avatar.isEmpty ? '' : EndPoints.getImage(group.avatar),
            displayName: group.name,
          ),
          12.wBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  group.name,
                  isTranslate: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyLarge.w600
                      .colorExt(ColorManager.momentPostTextColor),
                ),
                3.hBox,
                TextWidget(
                  '${group.membersCount} ${StringManager.membersCount.tr()}',
                  isTranslate: false,
                  style: context.bodyMedium
                      .colorExt(ColorManager.greyTextColor),
                ),
              ],
            ),
          ),
          8.wBox,
          GestureDetector(
            onTap: joining ? null : () => _join(group),
            child: Container(
              padding: context.paddingSymmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                // Brand gradient (was the flat panel-driven primary).
                gradient: ColorManager.brandGradient,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: joining
                  ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorManager.onBrandGradient),
              )
                  : TextWidget(
                StringManager.join.tr(),
                isTranslate: false,
                style: context.bodyMedium.w600
                    .colorExt(ColorManager.onBrandGradient),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
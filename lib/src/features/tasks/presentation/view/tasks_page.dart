import 'package:general/src/features/tasks/presentation/view/widgets/task_item_widget.dart';
import 'package:general/src/features/tasks/tasks.dart';

import '../../../../core/index.dart';

/// Daily tasks: what the admin has configured for the current day, how far the
/// user has got on each, and the claim button.
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late final TasksBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di<TasksBloc>();
    // Always refetch on open: progress is derived from activity that happened
    // outside this screen (going live, joining rooms), so a cached list would
    // be stale the moment the user came back from doing the task.
    _bloc.add(const GetTasksProgressEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Explicit white on request -- the old `ColorManager.scaffoldBg`
      // turns fully transparent whenever the user has a custom app-wide
      // "body theme" background enabled, so this page could end up showing
      // whatever background image/colour is behind it instead of a clean
      // white page. Forcing white here keeps this screen looking the same
      // (professional, readable) regardless of that setting.
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        title: StringManager.tasks.tr(),
      ),
      body: BlocConsumer<TasksBloc, TasksState>(
        bloc: _bloc,
        listenWhen: (prev, curr) =>
        prev.reqStateCollect != curr.reqStateCollect &&
            !curr.reqStateCollect.isLoading,
        listener: _onCollectSettled,
        builder: (context, state) {
          return HandlingDataWidget(
            reqState: state.reqStateProgress,
            title: StringManager.taskNoTasksTitle,
            subTitle: StringManager.taskNoTasksSubtitle,
            onTap: () => _bloc.add(const GetTasksProgressEvent()),
            child: RefreshIndicatorWidget(
              onRefresh: () async =>
                  _bloc.add(const GetTasksProgressEvent(isRefresh: true)),
              child: ListView(
                padding: context.paddingSymmetric(horizontal: 16, vertical: 16),
                children: [
                  _PointsHeader(
                    totalPoints: state.totalPoints,
                    day: state.progress?.activeDay,
                  ),
                  16.hBox,
                  ...state.tasks.map(
                        (task) => TaskItemWidget(
                      task: task,
                      isCollecting: state.collectingTaskId == task.id,
                      onCollect: () =>
                          _bloc.add(CollectTaskPointsEvent(task.id)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onCollectSettled(BuildContext context, TasksState state) {
    if (state.reqStateCollect.isLoaded) {
      final result = state.collectResult;

      if (result != null && result.dayCompleted) {
        _showDayRewardDialog(result);
        return;
      }

      Methods.showToast(
        context,
        message: state.collectMessage ?? '',
      );
      return;
    }

    Methods.showToast(
      context,
      message: state.errorCollect ?? '',
      isError: true,
    );
  }

  void _showDayRewardDialog(CollectTaskResultModel result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        // Explicit white/black here too, for the same reason as the
        // Scaffold above -- guaranteed readable regardless of remote
        // branding/theme tokens.
        backgroundColor: ColorManager.white,
        title: TextWidget(
          StringManager.taskDayCompleted.tr(),
          style: context.bodyLarge.w600.colorExt(ColorManager.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: result.rewards
              .map(
                (reward) => TextWidget(
              _rewardLabel(reward),
              isTranslate: false,
              style: context.bodyMedium.colorExt(ColorManager.gold),
            ),
          )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: TextWidget(
              StringManager.ok.tr(),
              style: context.bodyMedium.colorExt(ColorManager.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Only `coins` has a human-readable target (an amount); the rest carry an
  /// id, so they are named by type rather than showing a bare number.
  String _rewardLabel(TaskRewardModel reward) {
    if (reward.type == 'coins') {
      return '+${reward.target} ${StringManager.taskCoinsEarned.tr()}';
    }
    return '${StringManager.taskDayReward.tr()}: ${reward.type}';
  }
}

class _PointsHeader extends StatelessWidget {
  const _PointsHeader({required this.totalPoints, required this.day});

  final int totalPoints;
  final TaskDayModel? day;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingSymmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [ColorManager.primary, ColorManager.gold],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWidget(
                  StringManager.taskMyPoints.tr(),
                  style: context.bodySmall.colorExt(ColorManager.white),
                ),
                4.hBox,
                TextWidget(
                  '$totalPoints',
                  isTranslate: false,
                  style: context.titleLarge.w600
                      .colorExt(ColorManager.white),
                ),
              ],
            ),
          ),
          if (day != null)
            Container(
              padding: context.paddingSymmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ColorManager.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: TextWidget(
                '${StringManager.taskDayNumber.tr()} ${day!.dayNumber}',
                isTranslate: false,
                style: context.bodyMedium.w600.colorExt(ColorManager.white),
              ),
            ),
        ],
      ),
    );
  }
}
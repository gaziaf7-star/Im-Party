import '../../../../core/index.dart';

/// One `/days` payload: the day strip, the current day's task list, and the
/// user's lifetime point total.
class TasksProgressModel extends Equatable {
  const TasksProgressModel({
    required this.totalPoints,
    required this.days,
    required this.tasks,
  });

  final int totalPoints;
  final List<TaskDayModel> days;
  final List<DailyTaskModel> tasks;

  factory TasksProgressModel.fromJson(Map<String, dynamic> json) {
    return TasksProgressModel(
      totalPoints: parseValue<int>(json['total_points'], 0),
      days: (json['days'] is List)
          ? (json['days'] as List)
              .whereType<Map<String, dynamic>>()
              .map(TaskDayModel.fromJson)
              .toList()
          : const [],
      tasks: (json['tasks'] is List)
          ? (json['tasks'] as List)
              .whereType<Map<String, dynamic>>()
              .map(DailyTaskModel.fromJson)
              .toList()
          : const [],
    );
  }

  /// The day whose tasks [tasks] belongs to — the first one still open, which
  /// is the same rule the backend uses to pick it.
  TaskDayModel? get activeDay {
    for (final day in days) {
      if (!day.isCompleted) return day;
    }
    return days.isEmpty ? null : days.last;
  }

  @override
  List<Object?> get props => [totalPoints, days, tasks];
}

class TaskDayModel extends Equatable {
  const TaskDayModel({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.isUnlocked,
    required this.isCompleted,
    required this.getRewards,
  });

  final int id;
  final int dayNumber;
  final String title;
  final bool isUnlocked;
  final bool isCompleted;
  final bool getRewards;

  factory TaskDayModel.fromJson(Map<String, dynamic> json) {
    return TaskDayModel(
      id: parseValue<int>(json['id'], 0),
      dayNumber: parseValue<int>(json['day_number'], 0),
      title: parseValue<String>(json['title'], ''),
      isUnlocked: parseValue<bool>(json['is_unlocked'], false),
      isCompleted: parseValue<bool>(json['is_completed'], false),
      getRewards: parseValue<bool>(json['get_rewards'], false),
    );
  }

  @override
  List<Object?> get props =>
      [id, dayNumber, title, isUnlocked, isCompleted, getRewards];
}

class DailyTaskModel extends Equatable {
  const DailyTaskModel({
    required this.id,
    required this.dayId,
    required this.title,
    required this.type,
    required this.subType,
    required this.count,
    required this.progress,
    required this.totalPoints,
    required this.isCompleted,
    required this.isCollect,
  });

  final int id;
  final int dayId;
  final String title;

  /// `live_minutes` | `up_mic` | `enter_room` | `images` — the admin decides
  /// which of these a day contains, so an unknown value must still render.
  final String type;
  final String? subType;

  /// The target. For `live_minutes` it is MINUTES, not hours.
  final int count;

  /// How far the user has got, derived server-side from their real activity.
  final int progress;
  final int totalPoints;
  final bool isCompleted;
  final bool isCollect;

  factory DailyTaskModel.fromJson(Map<String, dynamic> json) {
    return DailyTaskModel(
      id: parseValue<int>(json['id'], 0),
      dayId: parseValue<int>(json['day_id'], 0),
      title: parseValue<String>(json['title'], ''),
      type: parseValue<String>(json['type'], ''),
      subType: json['sub_type'] == null
          ? null
          : parseValue<String>(json['sub_type'], ''),
      count: parseValue<int>(json['count'], 0),
      progress: parseValue<int>(json['progress'], 0),
      totalPoints: parseValue<int>(json['total_points'], 0),
      isCompleted: parseValue<bool>(json['is_completed'], false),
      isCollect: parseValue<bool>(json['is_collect'], false),
    );
  }

  /// Reward already taken. The two server flags move together, but either one
  /// being set means there is nothing left to claim.
  bool get isClaimed => isCollect || isCompleted;

  /// Target reached and not yet claimed — the only state where the button acts.
  bool get isClaimable => !isClaimed && progress >= count && count > 0;

  /// 0..1 for the progress bar. Guarded because a misconfigured task can have
  /// a count of zero, and dividing by it would paint a NaN-wide bar.
  double get ratio {
    if (count <= 0) return isClaimed ? 1 : 0;
    return (progress / count).clamp(0.0, 1.0);
  }

  DailyTaskModel copyWith({int? progress, bool? isCompleted, bool? isCollect}) {
    return DailyTaskModel(
      id: id,
      dayId: dayId,
      title: title,
      type: type,
      subType: subType,
      count: count,
      progress: progress ?? this.progress,
      totalPoints: totalPoints,
      isCompleted: isCompleted ?? this.isCompleted,
      isCollect: isCollect ?? this.isCollect,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dayId,
        title,
        type,
        subType,
        count,
        progress,
        totalPoints,
        isCompleted,
        isCollect,
      ];
}

/// What `/tasks/{id}/collect` gives back: the new point total, plus the day
/// reward list on the call that finished the day.
class CollectTaskResultModel extends Equatable {
  const CollectTaskResultModel({
    required this.totalPoints,
    required this.rewards,
  });

  final int totalPoints;
  final List<TaskRewardModel> rewards;

  factory CollectTaskResultModel.fromJson(Map<String, dynamic> json) {
    return CollectTaskResultModel(
      totalPoints: parseValue<int>(json['total_points'], 0),
      rewards: (json['rewards'] is List)
          ? (json['rewards'] as List)
              .whereType<Map<String, dynamic>>()
              .map(TaskRewardModel.fromJson)
              .toList()
          : const [],
    );
  }

  /// True on the claim that completed the day, so the caller knows to show the
  /// reward dialog rather than a plain toast.
  bool get dayCompleted => rewards.isNotEmpty;

  @override
  List<Object?> get props => [totalPoints, rewards];
}

class TaskRewardModel extends Equatable {
  const TaskRewardModel({
    required this.type,
    required this.target,
  });

  /// `coins` | `vip` | `ware` | `achievement` | `badge`.
  final String type;

  /// Meaning depends on [type]: an amount for coins, an id for everything else.
  final String target;

  factory TaskRewardModel.fromJson(Map<String, dynamic> json) {
    return TaskRewardModel(
      type: parseValue<String>(json['type'], ''),
      target: parseValue<String>(json['target'], ''),
    );
  }

  @override
  List<Object?> get props => [type, target];
}

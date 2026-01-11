class Goal {
  final String id;
  final String name;
  final double targetDistance;
  final double targetPace;
  final bool isArchived;
  final bool isCompleted;
  final String createdAt;
  final String? completedAt;
  final int? completedWithActivityId; // ID of last activity when completed

  Goal({
    required this.id,
    required this.name,
    required this.targetDistance,
    required this.targetPace,
    required this.createdAt,
    this.isArchived = false,
    this.isCompleted = false,
    this.completedAt,
    this.completedWithActivityId,
  });

  static String get _today => DateTime.now().toString().split(' ')[0];

  static bool _parseBool(dynamic v) => v == true || v == 'true';

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'],
    name: json['name'],
    targetDistance: json['targetDistance'].toDouble(),
    targetPace: json['targetPace'].toDouble(),
    isArchived: _parseBool(json['isArchived']),
    isCompleted: _parseBool(json['isCompleted']),
    createdAt: json['createdAt'] ?? _today,
    completedAt: json['completedAt'],
    completedWithActivityId: json['completedWithActivityId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetDistance': targetDistance,
    'targetPace': targetPace,
    'isArchived': isArchived,
    'isCompleted': isCompleted,
    'createdAt': createdAt,
    'completedAt': completedAt,
    'completedWithActivityId': completedWithActivityId,
  };

  Goal copyWithArchived(bool archived) => Goal(
    id: id, name: name, targetDistance: targetDistance, targetPace: targetPace,
    isArchived: archived, isCompleted: isCompleted, createdAt: createdAt,
    completedAt: completedAt, completedWithActivityId: completedWithActivityId,
  );

  Goal copyWithCompleted(bool completed, {int? activityId}) => Goal(
    id: id, name: name, targetDistance: targetDistance, targetPace: targetPace,
    isArchived: isArchived, isCompleted: completed, createdAt: createdAt,
    completedAt: completed ? _today : null,
    completedWithActivityId: completed ? activityId : null,
  );
}

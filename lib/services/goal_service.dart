import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/goal.dart';
import '../models/activity.dart';
import 'activity_service.dart';

class GoalService {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  final ActivityService _activityService = ActivityService();
  static const _headers = {'Content-Type': 'application/json; charset=UTF-8'};

  // CRUD Operations
  Future<List<Goal>> fetchGoals() async {
    final response = await http.get(Uri.parse('$_baseUrl/Goal'));
    if (response.statusCode != 200) throw Exception('Failed to load goals');
    return (json.decode(response.body) as List).map((j) => Goal.fromJson(j)).toList();
  }

  Future<Goal> createGoal(Goal goal) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/Goal'),
      headers: _headers,
      body: jsonEncode(goal.toJson()),
    );
    if (response.statusCode != 201) throw Exception('Failed to create goal');
    return Goal.fromJson(json.decode(response.body));
  }

  Future<void> updateGoal(Goal goal) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/Goal/${goal.id}'),
      headers: _headers,
      body: jsonEncode(goal.toJson()),
    );
    if (response.statusCode != 200) throw Exception('Failed to update goal');
  }

  Future<void> deleteGoal(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/Goal/$id'));
    if (response.statusCode != 200) throw Exception('Failed to delete goal');
  }

  // Status Updates
  Future<Goal> setGoalArchived(Goal goal, bool archived) async {
    final updated = goal.copyWithArchived(archived);
    await updateGoal(updated);
    return updated;
  }

  Future<Goal> setGoalCompleted(Goal goal, bool completed) async {
    final updated = goal.copyWithCompleted(completed);
    await updateGoal(updated);
    return updated;
  }

  // Calculations
  double calculateProgress(List<Activity> activities, Goal goal) {
    if (goal.isCompleted) return 100.0;
    final total = _activityService.calculateTotalDistance(getGoalActivities(activities, goal));
    return (total / goal.targetDistance * 100).clamp(0, 100);
  }

  double calculateGoalDistance(List<Activity> activities, Goal goal) {
    if (goal.isCompleted) return goal.targetDistance;
    final total = _activityService.calculateTotalDistance(getGoalActivities(activities, goal));
    return total > goal.targetDistance ? goal.targetDistance : total;
  }

  double calculateGoalAveragePace(List<Activity> activities, Goal goal) {
    return _activityService.calculateAveragePace(getGoalActivities(activities, goal));
  }

  // Activity Filtering
  List<Activity> getGoalActivities(List<Activity> activities, Goal goal) {
    if (!goal.isCompleted) {
      return activities.where((a) => a.date.compareTo(goal.createdAt) >= 0).toList();
    }

    final endDate = goal.completedAt ?? goal.createdAt;

    // Try activities before completion date
    var filtered = activities.where((a) =>
      a.date.compareTo(goal.createdAt) >= 0 && a.date.compareTo(endDate) < 0
    ).toList();

    // Same-day completion: take only activities up to target distance
    if (filtered.isEmpty) {
      filtered = activities.where((a) =>
        a.date.compareTo(goal.createdAt) >= 0 && a.date.compareTo(endDate) <= 0
      ).toList();

      double cumulative = 0;
      return filtered.takeWhile((a) {
        if (cumulative >= goal.targetDistance) return false;
        cumulative += a.distance;
        return true;
      }).toList();
    }

    return filtered;
  }
}

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/goal.dart';
import '../models/activity.dart';
import 'activity_service.dart';

class GoalService {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  final ActivityService _activityService = ActivityService(); // Helper for calculations

  // Fetch Goals
  Future<List<Goal>> fetchGoals() async {
    final response = await http.get(Uri.parse('$_baseUrl/Goal'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Goal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load goals');
    }
  }

  // Create Goal
  Future<Goal> createGoal(Goal goal) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/Goal'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(goal.toJson()),
    );

    if (response.statusCode == 201) {
      return Goal.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create goal');
    }
  }

  // Update Goal
  Future<void> updateGoal(Goal goal) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/Goal/${goal.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(goal.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update goal');
    }
  }

  // Update Goal Archived Status
  Future<Goal> setGoalArchived(Goal goal, bool archived) async {
    final updatedGoal = goal.copyWithArchived(archived);
    await updateGoal(updatedGoal);
    return updatedGoal;
  }

  // Delete Goal
  Future<void> deleteGoal(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/Goal/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete goal');
    }
  }

  // Calculate Progress
  double calculateProgress(List<Activity> activities, Goal goal) {
    // Filter activities that happened after goal creation
    final filteredActivities = activities.where((activity) {
      return activity.date.compareTo(goal.createdAt) >= 0;
    }).toList();

    double totalDistance = _activityService.calculateTotalDistance(filteredActivities);
    double progress = (totalDistance / goal.targetDistance) * 100;
    return progress > 100 ? 100 : progress; // Max 100%
  }
  
  // Helper to get distance strictly for the goal's range (useful for chart/display)
  double calculateGoalDistance(List<Activity> activities, Goal goal) {
    final filteredActivities = activities.where((activity) {
      return activity.date.compareTo(goal.createdAt) >= 0;
    }).toList();
    return _activityService.calculateTotalDistance(filteredActivities);
  }
}

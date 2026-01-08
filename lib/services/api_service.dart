import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/activity.dart';
import '../models/goal.dart';
import 'package:http/http.dart' as http;

// Jednoduchý API service s mock dátami
class ApiService {

  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  // Načítanie aktivít z MockAPI
  Future<List<Activity>> fetchActivities() async {
    final response = await http.get(Uri.parse('$_baseUrl/Activity'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) {
        if (json['id'] is String) {
          json['id'] = int.tryParse(json['id']) ?? 0;
        }
        return Activity.fromJson(json);
      }).toList();
    } else {
      throw Exception('Failed to load activities');
    }
  }

  // Vytvorenie aktivity na MockAPI
  Future<Activity> createActivity(Activity activity) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/Activity'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(activity.toJson()),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      if (json['id'] is String) {
        json['id'] = int.tryParse(json['id']) ?? 0;
      }
      return Activity.fromJson(json);
    } else {
      throw Exception('Failed to create activity');
    }
  }

  // Načítanie cieľov z MockAPI
  Future<List<Goal>> fetchGoals() async {
    final response = await http.get(Uri.parse('$_baseUrl/Goal'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Goal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load goals');
    }
  }

  // Vytvorenie cieľa na MockAPI
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

  // Aktualizácia cieľa (napr. archivácia)
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

  // Odstránenie cieľa
  Future<void> deleteGoal(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/Goal/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete goal');
    }
  }

  // Výpočet celkovej vzdialenosti
  double calculateTotalDistance(List<Activity> activities) {
    return activities.fold(0.0, (sum, activity) => sum + activity.distance);
  }

  // Výpočet progresu voči cieľu
  double calculateProgress(List<Activity> activities, Goal goal) {
    // Filtruj aktivity, ktoré vznikli po vytvorení cieľa (vrátane dňa vytvorenia)
    final filteredActivities = activities.where((activity) {
      return activity.date.compareTo(goal.createdAt) >= 0;
    }).toList();

    double totalDistance = calculateTotalDistance(filteredActivities);
    double progress = (totalDistance / goal.targetDistance) * 100;
    return progress > 100 ? 100 : progress; // Max 100%
  }
}

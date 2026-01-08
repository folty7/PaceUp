import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/activity.dart';

class ActivityService {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  // Get all activities
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

  // Create new activity
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

  // Calculate total distance
  double calculateTotalDistance(List<Activity> activities) {
    return activities.fold(0.0, (sum, activity) => sum + activity.distance);
  }

  // Calculate average pace
  double calculateAveragePace(List<Activity> activities) {
    if (activities.isEmpty) return 0;
    final totalPace = activities.fold(0.0, (sum, activity) => sum + activity.pace);
    return totalPace / activities.length;
  }
}

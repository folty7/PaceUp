import 'dart:convert';
import '../models/activity.dart';

// Jednoduchý API service s mock dátami
class ApiService {

  // Simulácia API volania s mock dátami
  Future<List<Activity>> fetchActivities() async {
    // Simulácia network delay
    await Future.delayed(Duration(seconds: 1));

    // Mock JSON data (hardcoded)
    final String mockJson = '''
    [
      {
        "id": 1,
        "distance": 5.2,
        "duration": 28,
        "date": "2025-01-05",
        "pace": 5.38
      },
      {
        "id": 2,
        "distance": 3.8,
        "duration": 21,
        "date": "2025-01-03",
        "pace": 5.52
      },
      {
        "id": 3,
        "distance": 7.5,
        "duration": 42,
        "date": "2025-01-01",
        "pace": 5.6
      },
      {
        "id": 4,
        "distance": 4.2,
        "duration": 23,
        "date": "2024-12-30",
        "pace": 5.47
      }
    ]
    ''';

    // Parsovanie JSON
    final List<dynamic> jsonList = json.decode(mockJson);
    return jsonList.map((json) => Activity.fromJson(json)).toList();
  }

  // Výpočet celkovej vzdialenosti
  double calculateTotalDistance(List<Activity> activities) {
    return activities.fold(0.0, (sum, activity) => sum + activity.distance);
  }

  // Výpočet progresu voči cieľu
  double calculateProgress(List<Activity> activities, double goalDistance) {
    double totalDistance = calculateTotalDistance(activities);
    double progress = (totalDistance / goalDistance) * 100;
    return progress > 100 ? 100 : progress; // Max 100%
  }
}

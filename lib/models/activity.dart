// Model pre bežeckú aktivitu
class Activity {
  final int id;
  final double distance; // km
  final int duration;    // minúty
  final String date;     // ISO 8601 timestamp
  final double pace;     // min/km

  Activity({
    required this.id,
    required this.distance,
    required this.duration,
    required this.date,
    required this.pace,
  });

  // Vytvorenie objektu z JSON
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      distance: json['distance'].toDouble(),
      duration: json['duration'],
      date: json['date'],
      pace: json['pace'].toDouble(),
    );
  }

  // Konverzia na JSON pre uloženie
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'distance': distance,
      'duration': duration,
      'date': date,
      'pace': pace,
    };
  }

  Activity copyWith({double? distance, int? duration, String? date, double? pace}) {
    return Activity(
      id: id,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      pace: pace ?? this.pace,
    );
  }
}

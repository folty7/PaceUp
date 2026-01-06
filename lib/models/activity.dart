// Model pre bežeckú aktivitu
class Activity {
  final int id;
  final double distance; // km
  final int duration;    // minúty
  final String date;
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
}

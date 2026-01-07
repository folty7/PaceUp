// Model pre bežecký cieľ
class Goal {
  final String id;
  final String name;
  final double targetDistance; // km
  final double targetPace;     // min/km
  final bool isArchived;       // či je cieľ archivovaný
  final String createdAt;      // dátum vytvorenia

  Goal({
    required this.id,
    required this.name,
    required this.targetDistance,
    required this.targetPace,
    required this.createdAt,
    this.isArchived = false,
  });

  // Konverzia na JSON pre uloženie
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetDistance': targetDistance,
      'targetPace': targetPace,
      'isArchived': isArchived,
      'createdAt': createdAt,
    };
  }

  // Vytvorenie objektu z JSON
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      name: json['name'],
      targetDistance: json['targetDistance'].toDouble(),
      targetPace: json['targetPace'].toDouble(),
      isArchived: json['isArchived'] ?? false,
      createdAt: json['createdAt'] ?? DateTime.now().toString().split(' ')[0], // fallback for old data
    );
  }

  // Vytvorenie kópie s archivovaním
  Goal copyWithArchived(bool archived) {
    return Goal(
      id: id,
      name: name,
      targetDistance: targetDistance,
      targetPace: targetPace,
      isArchived: archived,
      createdAt: createdAt,
    );
  }
}

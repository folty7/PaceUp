// Model pre bežecký cieľ
class Goal {
  final String id;
  final String name;
  final double targetDistance; // km
  final double targetPace;     // min/km
  final bool isArchived;       // či je cieľ archivovaný
  final String? archivedDate;  // dátum archivovanie

  Goal({
    required this.id,
    required this.name,
    required this.targetDistance,
    required this.targetPace,
    this.isArchived = false,
    this.archivedDate,
  });

  // Konverzia na JSON pre uloženie
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetDistance': targetDistance,
      'targetPace': targetPace,
      'isArchived': isArchived,
      'archivedDate': archivedDate,
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
      archivedDate: json['archivedDate'],
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
      archivedDate: archived ? DateTime.now().toString().split(' ')[0] : null,
    );
  }
}

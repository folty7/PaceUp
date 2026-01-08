import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/goal.dart';
import '../services/api_service.dart';
import '../widgets/goal_chart.dart';

class ArchivedGoalsScreen extends StatefulWidget {
  final List<Goal> archivedGoals;

  const ArchivedGoalsScreen({super.key, required this.archivedGoals});

  @override
  State<ArchivedGoalsScreen> createState() => _ArchivedGoalsScreenState();
}

class _ArchivedGoalsScreenState extends State<ArchivedGoalsScreen> {
  final ApiService _apiService = ApiService();
  List<Activity> _activities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  // Načítanie aktivít z API
  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final activities = await _apiService.fetchActivities();
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Výpočet priemerného tempa
  double _calculateAveragePace(List<Activity> activities) {
    if (activities.isEmpty) return 0;
    final totalPace = activities.fold(0.0, (sum, activity) => sum + activity.pace);
    return totalPace / activities.length;
  }

  @override
  Widget build(BuildContext context) {
    final totalDistance = _apiService.calculateTotalDistance(_activities);
    final averagePace = _calculateAveragePace(_activities);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archivované ciele'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: widget.archivedGoals.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.archive_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Žiadne archivované ciele',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Splnené ciele sa tu zobrazia po archivovaní',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: widget.archivedGoals.length,
                  itemBuilder: (context, index) {
                    final goal = widget.archivedGoals[index];
                    final progress = _activities.isEmpty
                        ? 0.0
                        : _apiService.calculateProgress(_activities, goal);

                    final goalActivities = _activities.where((a) => a.date.compareTo(goal.createdAt) >= 0).toList();
                    final currentDistance = _apiService.calculateTotalDistance(goalActivities);

                    final paceOk = averagePace > 0 && averagePace <= goal.targetPace;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header s názvom a trofej ikonou
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              goal.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Success badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'SPLNENÉ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _removeGoal(goal.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Progress bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Vzdialenosť:', style: TextStyle(fontWeight: FontWeight.w500)),
                                    Text(
                                      '${progress.toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: progress >= 100 ? 1.0 : progress / 100,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${currentDistance.toStringAsFixed(1)} / ${goal.targetDistance.toStringAsFixed(1)} km',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Stats
                            Row(
                              children: [
                                Expanded(
                                  child: _StatBox(
                                    icon: Icons.speed,
                                    label: 'Cieľové tempo',
                                    value: '${goal.targetPace.toStringAsFixed(2)} min/km',
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatBox(
                                    icon: Icons.trending_up,
                                    label: 'Tvoje tempo',
                                    value: averagePace > 0
                                        ? '${averagePace.toStringAsFixed(2)} min/km'
                                        : '- -',
                                    color: paceOk ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Graf vzdialenosti
                            GoalChart(
                              activities: goalActivities,
                              targetValue: goal.targetDistance,
                              title: 'Vzdialenosť v čase',
                              unit: 'km',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// Widget pre stat box
class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

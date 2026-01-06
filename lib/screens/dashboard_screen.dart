import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';
import '../models/goal.dart';
import '../services/api_service.dart';
import '../widgets/goal_chart.dart';
import 'activities_screen.dart';
import 'add_goal_modal.dart';
import 'archived_goals_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();

  List<Activity> _activities = [];
  List<Goal> _goals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  // Načítanie uložených cieľov
  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString('goals');
    if (goalsJson != null) {
      final List<dynamic> decoded = json.decode(goalsJson);
      setState(() {
        _goals = decoded.map((json) => Goal.fromJson(json)).toList();
      });
    }
  }

  // Uloženie cieľov
  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = json.encode(_goals.map((g) => g.toJson()).toList());
    await prefs.setString('goals', goalsJson);
  }

  // Pridanie nového cieľa
  Future<void> _addGoal() async {
    final goal = await showDialog<Goal>(
      context: context,
      builder: (context) => const AddGoalModal(),
    );

    if (goal != null) {
      setState(() {
        _goals.add(goal);
      });
      await _saveGoals();
    }
  }

  // Odstránenie cieľa
  Future<void> _removeGoal(String goalId) async {
    setState(() {
      _goals.removeWhere((g) => g.id == goalId);
    });
    await _saveGoals();
  }

  // Archivovanie cieľa
  Future<void> _archiveGoal(String goalId) async {
    setState(() {
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = _goals[index].copyWithArchived(true);
      }
    });
    await _saveGoals();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cieľ bol archivovaný!'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba pri načítavaní: $e')),
        );
      }
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

    final archivedGoals = _goals.where((g) => g.isArchived).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PaceUp Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (archivedGoals.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.archive),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArchivedGoalsScreen(archivedGoals: archivedGoals),
                      ),
                    );
                  },
                  tooltip: 'Archivované ciele',
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${archivedGoals.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tlačidlo "Načítať aktivity"
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadActivities,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isLoading ? 'Načítavam...' : 'Načítať aktivity'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),

                if (_activities.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivitiesScreen(activities: _activities),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list),
                    label: Text('Zobraziť aktivity (${_activities.length})'),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // Sekcia cieľov
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Moje ciele',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addGoal,
                  icon: const Icon(Icons.add),
                  label: const Text('Pridať cieľ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Zoznam cieľov ako bubble sekcie
            if (_goals.where((g) => !g.isArchived).isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.flag_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Zatiaľ nemáš žiadne ciele',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pridaj si svoj prvý bežecký cieľ',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._goals.where((g) => !g.isArchived).map((goal) {
                final progress = _activities.isEmpty
                    ? 0.0
                    : _apiService.calculateProgress(_activities, goal.targetDistance);

                final paceOk = averagePace > 0 && averagePace <= goal.targetPace;
                final progressColor = progress >= 100 ? Colors.green : Colors.blue;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        progressColor.withOpacity(0.1),
                        progressColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: progressColor.withOpacity(0.3), width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header s názvom a delete tlačidlom
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: progressColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.flag, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      goal.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (progress >= 100)
                                  IconButton(
                                    icon: const Icon(Icons.archive, color: Colors.green),
                                    onPressed: () => _archiveGoal(goal.id),
                                    tooltip: 'Archivovať splnený cieľ',
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeGoal(goal.id),
                                ),
                              ],
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: progressColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress / 100,
                              minHeight: 10,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${totalDistance.toStringAsFixed(1)} / ${goal.targetDistance.toStringAsFixed(1)} km',
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
                          activities: _activities,
                          targetValue: goal.targetDistance,
                          title: 'Vzdialenosť v čase',
                          unit: 'km',
                          isPaceChart: false,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
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

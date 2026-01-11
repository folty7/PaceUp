import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/goal.dart';
import '../services/activity_service.dart';
import '../services/goal_service.dart';
import '../widgets/goal_chart.dart';
import 'activities_screen.dart';
import 'add_activity_modal.dart';
import 'add_goal_modal.dart';
import 'archived_goals_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ActivityService _activityService = ActivityService();
  final GoalService _goalService = GoalService();

  List<Activity> _activities = [];
  List<Goal> _goals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Fetch data (Activities and Goals)
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _activityService.fetchActivities(),
        _goalService.fetchGoals(),
      ]);

      setState(() {
        _activities = results[0] as List<Activity>;
        _goals = results[1] as List<Goal>;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba pri načítavaní dát: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArchivedGoalsScreen(
                          archivedGoals: archivedGoals,
                          goalService: _goalService, // Pass service instance
                        ),
                      ),
                    );
                    _loadData(); // Refresh on return
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
                // Load Data Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadData,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isLoading ? 'Načítavam...' : 'Načítať dáta'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),

                if (_activities.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // Goals Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Moje ciele',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        // Add Activity Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            final activity = await showDialog<Activity>(
                              context: context,
                              builder: (context) => const AddActivityModal(),
                            );
                            if (activity != null) {
                              try {
                                final created = await _activityService.createActivity(activity);
                                setState(() => _activities.add(created));
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Aktivita bola úspešne pridaná!'), backgroundColor: Colors.green),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Pridať aktivitu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Add Goal Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            final goal = await showDialog<Goal>(
                              context: context,
                              builder: (context) => const AddGoalModal(),
                            );
                            if (goal != null) {
                              try {
                                final created = await _goalService.createGoal(goal);
                                setState(() => _goals.add(created));
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Cieľ bol úspešne vytvorený!'), backgroundColor: Colors.green),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Pridať cieľ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Goals List
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
                    : _goalService.calculateProgress(_activities, goal);

                final currentDistance = _goalService.calculateGoalDistance(_activities, goal);
                final goalAveragePace = _goalService.calculateGoalAveragePace(_activities, goal);

                final paceOk = goalAveragePace > 0 && goalAveragePace <= goal.targetPace;
                final progressColor = goal.isCompleted ? Colors.green : (progress >= 100 ? Colors.green : Colors.blue);

                // Check if goal should be marked as completed (only if not already completed)
                if (!goal.isCompleted && progress >= 100) {
                  // Schedule completion update after build
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    try {
                      final goalActivities = _goalService.getGoalActivities(_activities, goal);
                      final lastActivityId = goalActivities.isNotEmpty ? goalActivities.last.id : null;
                      final updated = await _goalService.setGoalCompleted(goal, true, activityId: lastActivityId);
                      if (mounted) {
                        setState(() {
                          final index = _goals.indexWhere((g) => g.id == goal.id);
                          if (index != -1) _goals[index] = updated;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gratulujeme! Cieľ "${goal.name}" bol splnený! 🎉'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      // Silently fail - will retry on next build
                    }
                  });
                }

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
                        // Card Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: progressColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          goal.isCompleted ? Icons.check : Icons.flag,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      if (goal.isCompleted)
                                        Positioned(
                                          right: -2,
                                          top: -2,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.done,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ),
                                    ],
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
                                        if (goal.isCompleted && goal.completedAt != null)
                                          Text(
                                            'Splnené: ${goal.completedAt}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (goal.isCompleted)
                                  IconButton(
                                    icon: const Icon(Icons.archive, color: Colors.green),
                                    onPressed: () async {
                                      try {
                                        final updated = await _goalService.setGoalArchived(goal, true);
                                        setState(() {
                                          final index = _goals.indexWhere((g) => g.id == goal.id);
                                          if(index != -1) _goals[index] = updated;
                                        });
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Cieľ archivovaný!'), backgroundColor: Colors.green),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chyba: $e')));
                                        }
                                      }
                                    },
                                    tooltip: 'Archivovať splnený cieľ',
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                      try {
                                        await _goalService.deleteGoal(goal.id);
                                        setState(() {
                                          _goals.removeWhere((g) => g.id == goal.id);
                                        });
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red));
                                        }
                                      }
                                  },
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
                                value: goalAveragePace > 0
                                    ? '${goalAveragePace.toStringAsFixed(2)} min/km'
                                    : '- -',
                                color: paceOk ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Chart
                        GoalChart(
                          activities: _goalService.getGoalActivities(_activities, goal),
                          targetValue: goal.targetDistance,
                          title: 'Vzdialenosť v čase',
                          unit: 'km',
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

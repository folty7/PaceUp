import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/goal.dart';
import '../services/activity_service.dart';
import '../services/goal_service.dart';
import '../widgets/goal_card.dart';
import 'activities_screen.dart';
import 'add_activity_modal.dart';
import 'add_goal_modal.dart';
import 'archived_goals_screen.dart';
import 'edit_goal_modal.dart';

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
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivitiesScreen(activities: _activities),
                            ),
                          );
                          _loadData(); // Refresh on return
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
                final goalActivities = _goalService.getGoalActivities(_activities, goal);

                // Auto-complete goal when progress reaches 100%
                if (!goal.isCompleted && progress >= 100) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    try {
                      final updated = await _goalService.setGoalCompleted(goal, true);
                      if (mounted) {
                        setState(() {
                          final index = _goals.indexWhere((g) => g.id == goal.id);
                          if (index != -1) _goals[index] = updated;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gratulujeme! Cieľ "${goal.name}" bol splnený!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      // Silently fail - will retry on next build
                    }
                  });
                }

                return GoalCard(
                  goal: goal,
                  progress: progress,
                  currentDistance: currentDistance,
                  goalAveragePace: goalAveragePace,
                  goalActivities: goalActivities,
                  onEdit: () async {
                    final updated = await showDialog<Goal>(
                      context: context,
                      builder: (context) => EditGoalModal(goal: goal),
                    );
                    if (updated != null) {
                      try {
                        await _goalService.updateGoal(updated);
                        setState(() {
                          final index = _goals.indexWhere((g) => g.id == goal.id);
                          if (index != -1) _goals[index] = updated;
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cieľ bol upravený!'), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red));
                        }
                      }
                    }
                  },
                  onArchive: goal.isCompleted
                      ? () async {
                          try {
                            final updated = await _goalService.setGoalArchived(goal, true);
                            setState(() {
                              final index = _goals.indexWhere((g) => g.id == goal.id);
                              if (index != -1) _goals[index] = updated;
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
                        }
                      : null,
                  onDelete: () async {
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
                );
              }),
          ],
        ),
      ),
    );
  }
}

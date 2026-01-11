import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/goal.dart';
import '../services/activity_service.dart';
import '../services/goal_service.dart';
import '../widgets/goal_card.dart';

class ArchivedGoalsScreen extends StatefulWidget {
  final List<Goal> archivedGoals;
  final GoalService goalService;

  const ArchivedGoalsScreen({
    super.key,
    required this.archivedGoals,
    required this.goalService,
  });

  @override
  State<ArchivedGoalsScreen> createState() => _ArchivedGoalsScreenState();
}

class _ArchivedGoalsScreenState extends State<ArchivedGoalsScreen> {
  final ActivityService _activityService = ActivityService();
  List<Activity> _activities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  // Load activities from API
  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);

    try {
      final activities = await _activityService.fetchActivities();
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        : widget.goalService.calculateProgress(_activities, goal);

                    final currentDistance = widget.goalService.calculateGoalDistance(_activities, goal);
                    final goalAveragePace = widget.goalService.calculateGoalAveragePace(_activities, goal);
                    final goalActivities = widget.goalService.getGoalActivities(_activities, goal);

                    return GoalCard(
                      goal: goal,
                      progress: progress,
                      currentDistance: currentDistance,
                      goalAveragePace: goalAveragePace,
                      goalActivities: goalActivities,
                      isArchived: true,
                      onDelete: () async {
                        try {
                          await widget.goalService.deleteGoal(goal.id);
                          setState(() {
                            widget.archivedGoals.removeAt(index);
                          });
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red));
                          }
                        }
                      },
                    );
                  },
                ),
    );
  }
}

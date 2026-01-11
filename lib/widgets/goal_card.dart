import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/goal.dart';
import 'goal_chart.dart';
import 'stat_box.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final double progress;
  final double currentDistance;
  final double goalAveragePace;
  final List<Activity> goalActivities;
  final bool isArchived;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.progress,
    required this.currentDistance,
    required this.goalAveragePace,
    required this.goalActivities,
    this.isArchived = false,
    this.onArchive,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final paceOk = goalAveragePace > 0 && goalAveragePace <= goal.targetPace;
    final progressColor = isArchived || goal.isCompleted
        ? Colors.green
        : (progress >= 100 ? Colors.green : Colors.blue);

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
            _buildHeader(progressColor),
            const SizedBox(height: 16),
            _buildProgressSection(progressColor),
            const SizedBox(height: 16),
            _buildStatsRow(paceOk),
            const SizedBox(height: 20),
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
  }

  Widget _buildHeader(Color progressColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              _buildIconBadge(progressColor),
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
                    if (goal.completedAt != null)
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
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildIconBadge(Color progressColor) {
    if (isArchived) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
      );
    }

    return Stack(
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
    );
  }

  Widget _buildActionButtons() {
    if (isArchived) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
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
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (goal.isCompleted && onArchive != null)
          IconButton(
            icon: const Icon(Icons.archive, color: Colors.green),
            onPressed: onArchive,
            tooltip: 'Archivovať splnený cieľ',
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
      ],
    );
  }

  Widget _buildProgressSection(Color progressColor) {
    return Column(
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
          value: progress >= 100 ? 1.0 : progress / 100,
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
    );
  }

  Widget _buildStatsRow(bool paceOk) {
    return Row(
      children: [
        Expanded(
          child: StatBox(
            icon: Icons.speed,
            label: 'Cieľové tempo',
            value: '${goal.targetPace.toStringAsFixed(2)} min/km',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatBox(
            icon: Icons.trending_up,
            label: 'Tvoje tempo',
            value: goalAveragePace > 0
                ? '${goalAveragePace.toStringAsFixed(2)} min/km'
                : '- -',
            color: paceOk ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}

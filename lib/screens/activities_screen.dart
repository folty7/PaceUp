import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import 'edit_activity_modal.dart';

class ActivitiesScreen extends StatefulWidget {
  final List<Activity> activities;

  const ActivitiesScreen({super.key, required this.activities});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final ActivityService _activityService = ActivityService();
  late List<Activity> _activities;

  @override
  void initState() {
    super.initState();
    _activities = List.from(widget.activities);
  }

  Future<void> _editActivity(Activity activity) async {
    final updated = await showDialog<Activity>(
      context: context,
      builder: (context) => EditActivityModal(activity: activity),
    );

    if (updated != null) {
      try {
        await _activityService.updateActivity(updated);
        setState(() {
          final index = _activities.indexWhere((a) => a.id == updated.id);
          if (index != -1) _activities[index] = updated;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aktivita bola upravená!'), backgroundColor: Colors.green),
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
  }

  Future<void> _deleteActivity(Activity activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vymazať aktivitu?'),
        content: Text('Naozaj chceš vymazať aktivitu z ${DateFormat('dd.MM.yyyy').format(DateTime.parse(activity.date))}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Zrušiť')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vymazať', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _activityService.deleteActivity(activity.id);
        setState(() => _activities.removeWhere((a) => a.id == activity.id));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aktivita bola vymazaná!'), backgroundColor: Colors.green),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje aktivity'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _activities.isEmpty
          ? const Center(child: Text('Žiadne aktivity'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.directions_run, color: Colors.white),
                    ),
                    title: Text(
                      '${activity.distance.toStringAsFixed(1)} km',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Dátum: ${DateFormat('dd.MM.yyyy').format(DateTime.parse(activity.date))}'),
                        Text('Čas: ${activity.duration} min'),
                        Text('Tempo: ${activity.pace.toStringAsFixed(2)} min/km'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editActivity(activity),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteActivity(activity),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}

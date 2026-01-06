import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivitiesScreen extends StatelessWidget {
  final List<Activity> activities;

  const ActivitiesScreen({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje aktivity'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: const Icon(Icons.directions_run, color: Colors.white),
              ),
              title: Text(
                '${activity.distance.toStringAsFixed(1)} km',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Dátum: ${activity.date}'),
                  Text('Čas: ${activity.duration} min'),
                  Text('Tempo: ${activity.pace.toStringAsFixed(2)} min/km'),
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

import 'package:flutter/material.dart';

Widget buildStatisticsCard(Map<String, dynamic> stats) {
  final totalTasks = stats['total_tasks'] ?? 0;
  final completedTasks = stats['completed_tasks'] ?? 0;
  final pendingTasks = stats['pending_tasks'] ?? 0;
  final completionRate = (stats['completion_rate'] ?? 0).toDouble();

  return Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Statistics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildStatItem('Total', totalTasks.toString()),
            buildStatItem('Done', completedTasks.toString()),
            buildStatItem('Pending', pendingTasks.toString()),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: completionRate / 100,
          backgroundColor: Colors.grey[800],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF7DF27)),
        ),
        const SizedBox(height: 8),
        Text(
          '${completionRate.toStringAsFixed(0)}% Complete',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    ),
  );
}

Widget buildStatItem(String label, String value) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Color(0xFFF7DF27),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ],
  );
}

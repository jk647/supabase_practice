import 'package:flutter/material.dart';
import 'package:supabase_practice/screens/home/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onPin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isPinned ? const Color(0xFFF7DF27) : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isCompleted
                  ? const Color(0xFFF7DF27)
                  : Colors.transparent,
              border: Border.all(
                color: task.isCompleted ? const Color(0xFFF7DF27) : Colors.grey,
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, size: 18, color: Colors.black)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF7DF27).withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.category,
                style: const TextStyle(
                  color: Color(0xFFF7DF27),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                task.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: task.isPinned ? const Color(0xFFF7DF27) : Colors.grey,
              ),
              onPressed: onPin,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:easy_task_flow/models/task_model.dart';
import 'package:easy_task_flow/providers/dashboard_provider.dart';
import 'package:easy_task_flow/screens/task_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MyTasksScreen extends ConsumerWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(myTasksProvider);

    // Sort: Not completed first, then by Due Date
    final sortedTasks = List<TaskModel>.from(tasks)
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1; // Completed last
        }
        return a.dueDate.compareTo(b.dueDate);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
      ),
      body: sortedTasks.isEmpty
          ? const Center(child: Text('No tasks assigned to you.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedTasks.length,
              itemBuilder: (context, index) {
                final task = sortedTasks[index];
                final isOverdue = task.dueDate.toDate().isBefore(DateTime.now()) && !task.isCompleted;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (val) {
                        if (val != null) {
                          _toggleTaskCompletion(context, ref, task, val);
                        }
                      },
                    ),
                    title: Text(
                      task.taskName,
                      style: task.isCompleted
                          ? const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            )
                          : const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Due: ${DateFormat.yMMMd().format(task.dueDate.toDate())}',
                          style: TextStyle(
                            color: isOverdue ? Colors.red : null,
                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(
                            projectId: task.projectId,
                            task: task,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  void _toggleTaskCompletion(BuildContext context, WidgetRef ref, TaskModel task, bool isCompleted) {
    final updatedTask = task.copyWith(isCompleted: isCompleted);
    final db = ref.read(databaseServiceProvider);

    db.updateTask(task.projectId, updatedTask).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    });
  }
}

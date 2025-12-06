import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskId;
  final String taskName;
  final Timestamp dueDate;
  final List<String> assignees;
  final String taskDetails;
  final List<SubtaskModel> subtasks;

  TaskModel({
    required this.taskId,
    required this.taskName,
    required this.dueDate,
    required this.assignees,
    required this.taskDetails,
    required this.subtasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'taskName': taskName,
      'dueDate': dueDate,
      'assignees': assignees,
      'taskDetails': taskDetails,
      'subtasks': subtasks.map((subtask) => subtask.toMap()).toList(),
    };
  }
}

class SubtaskModel {
  final String subtaskName;
  final String subtaskDetails;

  SubtaskModel({
    required this.subtaskName,
    required this.subtaskDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'subtaskName': subtaskName,
      'subtaskDetails': subtaskDetails,
    };
  }
}

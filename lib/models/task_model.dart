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

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'taskName': taskName,
      'dueDate': dueDate,
      'assignees': assignees,
      'taskDetails': taskDetails,
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['taskId'],
      taskName: json['taskName'],
      dueDate: json['dueDate'],
      assignees: List<String>.from(json['assignees']),
      taskDetails: json['taskDetails'],
      subtasks: (json['subtasks'] as List)
          .map((item) => SubtaskModel.fromJson(item))
          .toList(),
    );
  }
}

class SubtaskModel {
  final String subtaskName;
  final String subtaskDetails;

  SubtaskModel({
    required this.subtaskName,
    required this.subtaskDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'subtaskName': subtaskName,
      'subtaskDetails': subtaskDetails,
    };
  }

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      subtaskName: json['subtaskName'],
      subtaskDetails: json['subtaskDetails'],
    );
  }
}

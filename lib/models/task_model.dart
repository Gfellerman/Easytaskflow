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

  Map<String, dynamic> toJson() => toMap();

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['taskId'] ?? '',
      taskName: json['taskName'] ?? '',
      dueDate: json['dueDate'] ?? Timestamp.now(),
      assignees: List<String>.from(json['assignees'] ?? []),
      taskDetails: json['taskDetails'] ?? '',
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((e) => SubtaskModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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

  Map<String, dynamic> toMap() {
    return {
      'subtaskName': subtaskName,
      'subtaskDetails': subtaskDetails,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      subtaskName: json['subtaskName'] ?? '',
      subtaskDetails: json['subtaskDetails'] ?? '',
    );
  }
}

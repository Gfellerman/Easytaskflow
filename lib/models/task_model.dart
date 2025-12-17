import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskId;
  final String taskName;
  final Timestamp dueDate;
  final List<String> assignees;
  final String taskDetails;
  final List<SubtaskModel> subtasks;
  final bool isCompleted;
  final Timestamp createdAt;
  final String projectId;

  TaskModel({
    required this.taskId,
    required this.taskName,
    required this.dueDate,
    required this.assignees,
    required this.taskDetails,
    required this.subtasks,
    this.isCompleted = false,
    Timestamp? createdAt,
    this.projectId = '',
  }) : createdAt = createdAt ?? Timestamp.now();

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'taskName': taskName,
      'dueDate': dueDate,
      'assignees': assignees,
      'taskDetails': taskDetails,
      'subtasks': subtasks.map((subtask) => subtask.toMap()).toList(),
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'projectId': projectId,
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
      isCompleted: json['isCompleted'] ?? false,
      // Default to epoch for existing tasks so they don't appear as "Recent"
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.fromMicrosecondsSinceEpoch(0),
      projectId: json['projectId'] ?? '',
    );
  }

  // Helper to create a copy with updated fields
  TaskModel copyWith({
    String? taskId,
    String? taskName,
    Timestamp? dueDate,
    List<String>? assignees,
    String? taskDetails,
    List<SubtaskModel>? subtasks,
    bool? isCompleted,
    Timestamp? createdAt,
    String? projectId,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      dueDate: dueDate ?? this.dueDate,
      assignees: assignees ?? this.assignees,
      taskDetails: taskDetails ?? this.taskDetails,
      subtasks: subtasks ?? this.subtasks,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      projectId: projectId ?? this.projectId,
    );
  }
}

class SubtaskModel {
  final String subtaskName;
  final String subtaskDetails;
  final bool isCompleted;

  SubtaskModel({
    required this.subtaskName,
    required this.subtaskDetails,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'subtaskName': subtaskName,
      'subtaskDetails': subtaskDetails,
      'isCompleted': isCompleted,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      subtaskName: json['subtaskName'] ?? '',
      subtaskDetails: json['subtaskDetails'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

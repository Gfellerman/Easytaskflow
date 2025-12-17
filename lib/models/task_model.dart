import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskId;
  final String taskName;
  final Timestamp dueDate;
  final List<String> assignees;
  final String taskDetails;
  final List<SubtaskModel> subtasks;
  final String status; // 'todo', 'in_progress', 'done'
  final Timestamp createdAt;
  final String projectId;

  TaskModel({
    required this.taskId,
    required this.taskName,
    required this.dueDate,
    required this.assignees,
    required this.taskDetails,
    required this.subtasks,
    this.status = 'todo',
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
      'status': status,
      'createdAt': createdAt,
      'projectId': projectId,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Migration logic: Map old 'isCompleted' to status if 'status' is missing
    String parsedStatus = json['status'] ?? 'todo';
    if (json['status'] == null && json.containsKey('isCompleted')) {
      parsedStatus = json['isCompleted'] == true ? 'done' : 'todo';
    }

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
      status: parsedStatus,
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
    String? status,
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
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      projectId: projectId ?? this.projectId,
    );
  }

  // Helpers for status checks
  bool get isDone => status == 'done';
  bool get isInProgress => status == 'in_progress';
  bool get isTodo => status == 'todo';
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

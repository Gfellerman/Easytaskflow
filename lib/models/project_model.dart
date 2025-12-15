import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String projectId;
  final String projectName;
  final String ownerId;
  final List<String> memberIds;
  final String? lastMessage;
  final Timestamp? lastMessageTimestamp;

  ProjectModel({
    required this.projectId,
    required this.projectName,
    required this.ownerId,
    required this.memberIds,
    this.lastMessage,
    this.lastMessageTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['projectId'] ?? '',
      projectName: json['projectName'] ?? '',
      ownerId: json['ownerId'] ?? '',
      memberIds: List<String>.from(json['memberIds'] ?? []),
      lastMessage: json['lastMessage'],
      lastMessageTimestamp: json['lastMessageTimestamp'],
    );
  }
}

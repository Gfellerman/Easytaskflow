class ProjectModel {
  final String projectId;
  final String projectName;
  final String ownerId;
  final List<String> memberIds;

  ProjectModel({
    required this.projectId,
    required this.projectName,
    required this.ownerId,
    required this.memberIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'ownerId': ownerId,
      'memberIds': memberIds,
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['projectId'],
      projectName: json['projectName'],
      ownerId: json['ownerId'],
      memberIds: List<String>.from(json['memberIds']),
    );
  }
}

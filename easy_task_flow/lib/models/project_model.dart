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

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'ownerId': ownerId,
      'memberIds': memberIds,
    };
  }
}

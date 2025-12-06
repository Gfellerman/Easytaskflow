class FileModel {
  final String fileId;
  final String fileName;
  final String fileUrl;
  final String fileType;

  FileModel({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
    };
  }

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      fileId: json['fileId'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      fileType: json['fileType'],
    );
  }
}
